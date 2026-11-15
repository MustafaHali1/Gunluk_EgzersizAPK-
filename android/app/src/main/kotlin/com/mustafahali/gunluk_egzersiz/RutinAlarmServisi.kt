package com.mustafahali.gunluk_egzersiz

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.widget.Toast
import java.io.File
import java.io.FileInputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

// Alarm vakti geldiğinde seçili müziği MediaPlayer (USAGE_ALARM) ile çalan ve erteleme/durdurma sunan ön plan servisi.
class RutinAlarmServisi : Service() {
    companion object {
        const val ACTION_BASLAT = "com.mustafahali.gunlukegzersiz.ALARM_BASLAT"
        const val ACTION_DURDUR = "com.mustafahali.gunlukegzersiz.ALARM_DURDUR"
        const val ACTION_DURDUR_VE_AC = "com.mustafahali.gunlukegzersiz.ALARM_DURDUR_VE_AC"
        const val ACTION_HIZLI_ERTELE = "com.mustafahali.gunlukegzersiz.ALARM_HIZLI_ERTELE"
        private const val KANAL_ID = "rutin_uyanma_alarm_servisi_v1"
        private const val BILDIRIM_ID = 77001
        private const val OTOMATIK_DURDURMA_MS = 10 * 60 * 1000L
    }

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private val zamanlayici = Handler(Looper.getMainLooper())
    private var mevcutRutinId: Int = 0
    private var mevcutRutinAdi: String = "Rutin"
    private var mevcutMuzikYolu: String? = null

    private val otomatikDurdurGorevi = Runnable {
        alarmiKapatVeDurdur()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val aksiyon = intent?.action ?: ACTION_BASLAT

        when (aksiyon) {
            ACTION_DURDUR -> {
                alarmiKapatVeDurdur()
                return START_NOT_STICKY
            }
            ACTION_DURDUR_VE_AC -> {
                val rutinId = intent?.getIntExtra("rutinId", mevcutRutinId) ?: mevcutRutinId
                alarmiKapatVeDurdur()
                val acilis = Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    putExtra("acilis_rutin_id", rutinId)
                }
                startActivity(acilis)
                return START_NOT_STICKY
            }
            ACTION_HIZLI_ERTELE -> {
                val rutinId = intent?.getIntExtra("rutinId", mevcutRutinId) ?: mevcutRutinId
                val rutinAdi = intent?.getStringExtra("rutinAdi") ?: mevcutRutinAdi
                val muzikYolu = intent?.getStringExtra("muzikYolu") ?: mevcutMuzikYolu
                val ertelemeDk = intent?.getIntExtra(
                    "ertelemeDakika",
                    RutinAlarmYoneticisi.varsayilanErtelemeDakikasıGetir(this),
                ) ?: 15
                val hedefMilis = RutinAlarmYoneticisi.ertelemePlanla(
                    context = this,
                    rutinId = rutinId,
                    rutinAdi = rutinAdi,
                    muzikYolu = muzikYolu,
                    ertelemeDakika = ertelemeDk,
                )
                val saatMetni = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(hedefMilis))
                Toast.makeText(
                    this,
                    "$rutinAdi alarmı $saatMetni saatine ertelendi",
                    Toast.LENGTH_LONG,
                ).show()
                alarmiKapatVeDurdur()
                return START_NOT_STICKY
            }
            else -> {
                mevcutRutinId = intent?.getIntExtra("rutinId", 0) ?: 0
                mevcutRutinAdi = intent?.getStringExtra("rutinAdi") ?: "Rutin"
                mevcutMuzikYolu = intent?.getStringExtra("muzikYolu")

                kanaliOlustur()
                val bildirim = alarmBildirimiOlustur(
                    rutinId = mevcutRutinId,
                    rutinAdi = mevcutRutinAdi,
                    muzikYolu = mevcutMuzikYolu,
                )
                startForeground(BILDIRIM_ID, bildirim)

                muzigiBaslat(mevcutMuzikYolu)
                titresimiBaslat()

                // Ekran kilidi kapalıysa fullScreenIntent açar; izin varsa veya uygulama öndeyse erteleme penceresini doğrudan aç
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q || Settings.canDrawOverlays(this)) {
                    try {
                        val aktiviteIntent = Intent(this, RutinAlarmAktivitesi::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                            putExtra("rutinId", mevcutRutinId)
                            putExtra("rutinAdi", mevcutRutinAdi)
                            putExtra("muzikYolu", mevcutMuzikYolu)
                        }
                        startActivity(aktiviteIntent)
                    } catch (_: Exception) {
                    }
                }

                zamanlayici.removeCallbacks(otomatikDurdurGorevi)
                zamanlayici.postDelayed(otomatikDurdurGorevi, OTOMATIK_DURDURMA_MS)
                return START_NOT_STICKY
            }
        }
    }

    private fun kanaliOlustur() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (manager.getNotificationChannel(KANAL_ID) == null) {
                val kanal = NotificationChannel(
                    KANAL_ID,
                    "Rutin Alarm Sesi",
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply {
                    description = "Rutin alarmı çaldığında tam ekran uyarı ve kontrol sunar"
                    setSound(null, null)
                    enableVibration(false)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                manager.createNotificationChannel(kanal)
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun alarmBildirimiOlustur(
        rutinId: Int,
        rutinAdi: String,
        muzikYolu: String?,
    ): Notification {
        val varsayilanErteleme = RutinAlarmYoneticisi.varsayilanErtelemeDakikasıGetir(this)
        val ertelemeEtiketi = if (varsayilanErteleme >= 60 && varsayilanErteleme % 60 == 0) {
            "${varsayilanErteleme / 60} sa Ertele"
        } else {
            "$varsayilanErteleme dk Ertele"
        }

        val aktiviteIntent = Intent(this, RutinAlarmAktivitesi::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("rutinId", rutinId)
            putExtra("rutinAdi", rutinAdi)
            putExtra("muzikYolu", muzikYolu)
        }
        val tamEkranPendingIntent = PendingIntent.getActivity(
            this,
            30001,
            aktiviteIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val durdurIntent = Intent(this, RutinAlarmServisi::class.java).apply {
            action = ACTION_DURDUR
        }
        val durdurPendingIntent = PendingIntent.getService(
            this,
            30002,
            durdurIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val hizliErteleIntent = Intent(this, RutinAlarmServisi::class.java).apply {
            action = ACTION_HIZLI_ERTELE
            putExtra("rutinId", rutinId)
            putExtra("rutinAdi", rutinAdi)
            putExtra("muzikYolu", muzikYolu)
            putExtra("ertelemeDakika", varsayilanErteleme)
        }
        val hizliErtelePendingIntent = PendingIntent.getService(
            this,
            30003,
            hizliErteleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val durdurVeAcIntent = Intent(this, RutinAlarmServisi::class.java).apply {
            action = ACTION_DURDUR_VE_AC
            putExtra("rutinId", rutinId)
        }
        val durdurVeAcPendingIntent = PendingIntent.getService(
            this,
            30004,
            durdurVeAcIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, KANAL_ID)
        } else {
            Notification.Builder(this)
        }

        builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("⏰ $rutinAdi Alarmı Çalıyor!")
            .setContentText("Susturmak veya ertelemek (5 dk / 1 sa / gün sonu) için dokunun.")
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setContentIntent(tamEkranPendingIntent)
            .setFullScreenIntent(tamEkranPendingIntent, true)
            .addAction(
                Notification.Action.Builder(
                    null,
                    "Durdur",
                    durdurPendingIntent,
                ).build(),
            )
            .addAction(
                Notification.Action.Builder(
                    null,
                    "Ertele (Seç)",
                    tamEkranPendingIntent,
                ).build(),
            )
            .addAction(
                Notification.Action.Builder(
                    null,
                    "Rutini Aç",
                    durdurVeAcPendingIntent,
                ).build(),
            )

        return builder.build()
    }

    private fun muzigiBaslat(ozelMuzikYolu: String?) {
        muzigiDurdur()
        val sesOzellikleri = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()

        val player = MediaPlayer()
        try {
            player.setAudioAttributes(sesOzellikleri)
            player.isLooping = true

            val dosya = ozelMuzikYolu?.takeIf { it.isNotBlank() }?.let { File(it) }
            if (dosya != null && dosya.exists() && dosya.canRead()) {
                FileInputStream(dosya).use { fis ->
                    player.setDataSource(fis.fd)
                }
            } else {
                val varsayilanUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                player.setDataSource(this, varsayilanUri)
            }
            player.prepare()
            player.start()
            mediaPlayer = player
        } catch (_: Exception) {
            player.release()
            try {
                val yedekPlayer = MediaPlayer()
                yedekPlayer.setAudioAttributes(sesOzellikleri)
                yedekPlayer.isLooping = true
                val varsayilanUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                yedekPlayer.setDataSource(this, varsayilanUri)
                yedekPlayer.prepare()
                yedekPlayer.start()
                mediaPlayer = yedekPlayer
            } catch (_: Exception) {
            }
        }
    }

    private fun muzigiDurdur() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (_: Exception) {
        }
        mediaPlayer = null
    }

    @Suppress("DEPRECATION")
    private fun titresimiBaslat() {
        try {
            val vib = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vm.defaultVibrator
            } else {
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            vibrator = vib
            val desen = longArrayOf(0, 600, 400)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vib.vibrate(VibrationEffect.createWaveform(desen, 0))
            } else {
                vib.vibrate(desen, 0)
            }
        } catch (_: Exception) {
        }
    }

    private fun titresimiDurdur() {
        try {
            vibrator?.cancel()
        } catch (_: Exception) {
        }
        vibrator = null
    }

    private fun alarmiKapatVeDurdur() {
        zamanlayici.removeCallbacks(otomatikDurdurGorevi)
        muzigiDurdur()
        titresimiDurdur()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    override fun onDestroy() {
        zamanlayici.removeCallbacks(otomatikDurdurGorevi)
        muzigiDurdur()
        titresimiDurdur()
        super.onDestroy()
    }
}
