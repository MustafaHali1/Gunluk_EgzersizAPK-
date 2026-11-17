package com.mustafahali.gunluk_egzersiz

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.SeekBar
import android.widget.TextView
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

// Alarm çaldığında kilit ekranında veya tam ekranda açılan, durdurma ve gün bitene kadar erteleme sunan pencere.
class RutinAlarmAktivitesi : Activity() {
    private var rutinId: Int = 0
    private var rutinAdi: String = "Rutin"
    private var muzikYolu: String? = null
    private var tetiklenmeMilis: Long = 0L

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        @Suppress("DEPRECATION")
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
        )

        rutinId = intent?.getIntExtra("rutinId", 0) ?: 0
        rutinAdi = intent?.getStringExtra("rutinAdi") ?: "Rutin"
        muzikYolu = intent?.getStringExtra("muzikYolu")
        tetiklenmeMilis = intent?.getLongExtra("tetiklenmeMilis", System.currentTimeMillis())
            ?: System.currentTimeMillis()

        arayuzuKur()
    }

    private fun arayuzuKur() {
        val anaKaydirici = ScrollView(this).apply {
            setBackgroundColor(Color.parseColor("#0F172A"))
            isFillViewport = true
        }

        val icerik = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(48, 80, 48, 64)
        }

        val simdiSaat = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
        val saatYazisi = TextView(this).apply {
            text = simdiSaat
            textSize = 52f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
        }
        icerik.addView(saatYazisi)

        val baslikYazisi = TextView(this).apply {
            text = "⏰ $rutinAdi"
            textSize = 26f
            setTextColor(Color.parseColor("#5EEAD4"))
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, 16, 0, 12)
        }
        icerik.addView(baslikYazisi)

        val altYazi = TextView(this).apply {
            text = "Rutin vakti geldi! Müsait değilsen gün bitene kadar erteleyebilirsin."
            textSize = 15f
            setTextColor(Color.parseColor("#CBD5E1"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 40)
        }
        icerik.addView(altYazi)

        // Durdur ve Rutini Aç butonu
        val rutiniAcButon = yuvarlakButon(
            metin = "Durdur ve Rutini Aç",
            arkaPlan = Color.parseColor("#0D9488"),
            yaziRengi = Color.WHITE,
        ) {
            servisiDurdur()
            val acilis = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("acilis_rutin_id", rutinId)
                putExtra("acilis_tetiklenme_milis", tetiklenmeMilis)
            }
            startActivity(acilis)
            finish()
        }
        icerik.addView(rutiniAcButon, tamGenislikParams(altBosluk = 20))

        // Sadece Sustur butonu
        val susturButon = yuvarlakButon(
            metin = "Sadece Sustur",
            arkaPlan = Color.parseColor("#334155"),
            yaziRengi = Color.WHITE,
        ) {
            servisiDurdur()
            finish()
        }
        icerik.addView(susturButon, tamGenislikParams(altBosluk = 44))

        // Erteleme kartı
        val ertelemeKarti = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(36, 36, 36, 36)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1E293B"))
                cornerRadius = 32f
            }
        }

        val ertelemeBaslik = TextView(this).apply {
            text = "Müsait Değilim — Ertele"
            textSize = 18f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, 0, 0, 20)
        }
        ertelemeKarti.addView(ertelemeBaslik)

        // Hızlı erteleme satırı 1: 5 dk, 15 dk, 30 dk
        val hizliSatir1 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
        }
        for ((etiket, dk) in listOf("5 dk" to 5, "15 dk" to 15, "30 dk" to 30)) {
            val btn = yuvarlakButon(
                metin = etiket,
                arkaPlan = Color.parseColor("#0F766E"),
                yaziRengi = Color.WHITE,
            ) {
                alarmiErteleVeKapat(dk)
            }
            val lp = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                setMargins(6, 0, 6, 16)
            }
            hizliSatir1.addView(btn, lp)
        }
        ertelemeKarti.addView(hizliSatir1)

        // Hızlı erteleme satırı 2: 1 saat, 2 saat, Gün Sonu (23:59)
        val simdiMilis = System.currentTimeMillis()
        val gunSonuMilis = RutinAlarmYoneticisi.bugununSonuMilis()
        val kalanGunSonuDk = (((gunSonuMilis - simdiMilis) / 60_000L).toInt()).coerceAtLeast(5)

        val hizliSatir2 = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
        }
        for ((etiket, dk) in listOf(
            "1 saat" to 60,
            "2 saat" to 120,
            "Gün Sonu" to kalanGunSonuDk,
        )) {
            val btn = yuvarlakButon(
                metin = etiket,
                arkaPlan = Color.parseColor("#1D4ED8"),
                yaziRengi = Color.WHITE,
            ) {
                alarmiErteleVeKapat(dk)
            }
            val lp = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                setMargins(6, 0, 6, 24)
            }
            hizliSatir2.addView(btn, lp)
        }
        ertelemeKarti.addView(hizliSatir2)

        // Gün bitene kadar özel erteleme kaydırıcısı
        val maksimumDk = kalanGunSonuDk.coerceAtLeast(5)
        var seciliOzelDk = RutinAlarmYoneticisi.varsayilanErtelemeDakikasıGetir(this)
            .coerceIn(5, maksimumDk)

        val ozelEtiket = TextView(this).apply {
            textSize = 14f
            setTextColor(Color.parseColor("#94A3B8"))
            setPadding(0, 4, 0, 12)
        }

        fun ozelEtiketiGuncelle(dk: Int) {
            val hedef = System.currentTimeMillis() + (dk * 60_000L)
            val saat = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(hedef))
            val sureYazisi = if (dk >= 60) {
                val sa = dk / 60
                val artanDk = dk % 60
                if (artanDk == 0) "$sa saat" else "$sa sa $artanDk dk"
            } else {
                "$dk dk"
            }
            ozelEtiket.text = "Özel Erteleme: $sureYazisi sonra (Saat $saat)"
        }
        ozelEtiketiGuncelle(seciliOzelDk)
        ertelemeKarti.addView(ozelEtiket)

        val seekBar = SeekBar(this).apply {
            max = (maksimumDk - 5).coerceAtLeast(0)
            progress = (seciliOzelDk - 5).coerceAtLeast(0)
            setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(sb: SeekBar?, progress: Int, fromUser: Boolean) {
                    seciliOzelDk = 5 + progress
                    ozelEtiketiGuncelle(seciliOzelDk)
                }

                override fun onStartTrackingTouch(sb: SeekBar?) {}
                override fun onStopTrackingTouch(sb: SeekBar?) {}
            })
        }
        ertelemeKarti.addView(seekBar, tamGenislikParams(altBosluk = 20))

        val ozelErteleButon = yuvarlakButon(
            metin = "Seçilen Süre Kadar Ertele",
            arkaPlan = Color.parseColor("#F59E0B"),
            yaziRengi = Color.BLACK,
        ) {
            alarmiErteleVeKapat(seciliOzelDk)
        }
        ertelemeKarti.addView(ozelErteleButon, tamGenislikParams(altBosluk = 0))

        icerik.addView(ertelemeKarti, tamGenislikParams(altBosluk = 0))
        anaKaydirici.addView(icerik)
        setContentView(anaKaydirici)
    }

    private fun alarmiErteleVeKapat(ertelemeDakika: Int) {
        val hedefMilis = RutinAlarmYoneticisi.ertelemePlanla(
            context = this,
            rutinId = rutinId,
            rutinAdi = rutinAdi,
            muzikYolu = muzikYolu,
            ertelemeDakika = ertelemeDakika,
        )
        val saatMetni = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(hedefMilis))
        Toast.makeText(
            this,
            "$rutinAdi alarmı $saatMetni saatine ertelendi",
            Toast.LENGTH_LONG,
        ).show()
        servisiDurdur()
        finish()
    }

    private fun servisiDurdur() {
        val durdurIntent = Intent(this, RutinAlarmServisi::class.java).apply {
            action = RutinAlarmServisi.ACTION_DURDUR
        }
        startService(durdurIntent)
    }

    private fun yuvarlakButon(
        metin: String,
        arkaPlan: Int,
        yaziRengi: Int,
        tiklandiginda: () -> Unit,
    ): Button {
        return Button(this).apply {
            text = metin
            isAllCaps = false
            textSize = 15f
            setTextColor(yaziRengi)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(24, 28, 24, 28)
            background = GradientDrawable().apply {
                setColor(arkaPlan)
                cornerRadius = 24f
            }
            setOnClickListener { tiklandiginda() }
        }
    }

    private fun tamGenislikParams(altBosluk: Int): LinearLayout.LayoutParams {
        return LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
        ).apply {
            setMargins(0, 0, 0, altBosluk)
        }
    }
}
