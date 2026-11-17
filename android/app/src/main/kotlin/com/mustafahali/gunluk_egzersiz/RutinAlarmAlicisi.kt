package com.mustafahali.gunluk_egzersiz

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager

// Zamanı gelen alarmı veya cihaz yeniden başlatıldığında alarmları tetikleyen BroadcastReceiver.
class RutinAlarmAlicisi : BroadcastReceiver() {
    companion object {
        const val ACTION_ALARM_TETIKLENDI = "com.mustafahali.gunlukegzersiz.ALARM_TETIKLENDI"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        val aksiyon = intent?.action ?: return

        if (aksiyon == Intent.ACTION_BOOT_COMPLETED ||
            aksiyon == Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            RutinAlarmYoneticisi.yenidenBaslatmaSonrasiKur(context)
            return
        }

        if (aksiyon == ACTION_ALARM_TETIKLENDI) {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            val wakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "GunlukEgzersiz:AlarmWakeLock",
            )
            wakeLock.acquire(15_000L)

            val rutinId = intent.getIntExtra("rutinId", 0)
            val alarmId = intent.getIntExtra("alarmId", rutinId)
            val rutinAdi = intent.getStringExtra("rutinAdi") ?: "Rutin"
            val muzikYolu = intent.getStringExtra("muzikYolu")
            val ertelemeMi = intent.getBooleanExtra("ertelemeMi", false)

            val servisIntent = Intent(context, RutinAlarmServisi::class.java).apply {
                action = RutinAlarmServisi.ACTION_BASLAT
                putExtra("rutinId", rutinId)
                putExtra("rutinAdi", rutinAdi)
                putExtra("muzikYolu", muzikYolu)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(servisIntent)
            } else {
                context.startService(servisIntent)
            }

            if (!ertelemeMi && alarmId > 0) {
                RutinAlarmYoneticisi.sonrakiHaftalikAlarmiPlanla(context, alarmId)
            }
        }
    }
}
