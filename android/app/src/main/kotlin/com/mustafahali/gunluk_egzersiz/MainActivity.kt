package com.mustafahali.gunluk_egzersiz

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val KANAL_ADI = "com.mustafahali.gunlukegzersiz/alarm"
    }

    private var alarmKanali: MethodChannel? = null
    private var bekleyenRutinId: Int? = null
    private var bekleyenTetiklenmeMilis: Long? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val rutinIdExtra = intent?.getIntExtra("acilis_rutin_id", -1) ?: -1
        if (rutinIdExtra > 0) {
            bekleyenRutinId = rutinIdExtra
            val tetikExtra = intent?.getLongExtra("acilis_tetiklenme_milis", 0L) ?: 0L
            bekleyenTetiklenmeMilis = if (tetikExtra > 0L) tetikExtra else System.currentTimeMillis()
        }

        alarmKanali = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            KANAL_ADI,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "tumAlarmlariKur" -> {
                        @Suppress("UNCHECKED_CAST")
                        val alarmlar = call.arguments as? List<Map<String, Any?>> ?: emptyList()
                        RutinAlarmYoneticisi.tumAlarmlariKur(applicationContext, alarmlar)
                        result.success(true)
                    }
                    "tumAlarmlariIptalEt" -> {
                        RutinAlarmYoneticisi.tumAlarmlariIptalEt(applicationContext)
                        result.success(true)
                    }
                    "simdiTestAlarmiCal" -> {
                        val args = call.arguments as? Map<*, *>
                        val rutinId = (args?.get("rutinId") as? Number)?.toInt() ?: 0
                        val rutinAdi = args?.get("rutinAdi") as? String ?: "Rutin"
                        val muzikYolu = args?.get("muzikYolu") as? String

                        val servisIntent = Intent(applicationContext, RutinAlarmServisi::class.java).apply {
                            action = RutinAlarmServisi.ACTION_BASLAT
                            putExtra("rutinId", rutinId)
                            putExtra("rutinAdi", rutinAdi)
                            putExtra("muzikYolu", muzikYolu)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            applicationContext.startForegroundService(servisIntent)
                        } else {
                            applicationContext.startService(servisIntent)
                        }
                        val aktiviteIntent = Intent(this@MainActivity, RutinAlarmAktivitesi::class.java).apply {
                            putExtra("rutinId", rutinId)
                            putExtra("rutinAdi", rutinAdi)
                            putExtra("muzikYolu", muzikYolu)
                            putExtra("tetiklenmeMilis", System.currentTimeMillis())
                        }
                        startActivity(aktiviteIntent)
                        result.success(true)
                    }
                    "alarmiDurdur" -> {
                        val durdurIntent = Intent(applicationContext, RutinAlarmServisi::class.java).apply {
                            action = RutinAlarmServisi.ACTION_DURDUR
                        }
                        applicationContext.startService(durdurIntent)
                        result.success(true)
                    }
                    "varsayilanErtelemeKaydet" -> {
                        val dakika = (call.arguments as? Number)?.toInt() ?: 15
                        RutinAlarmYoneticisi.varsayilanErtelemeDakikasiKaydet(
                            applicationContext,
                            dakika,
                        )
                        result.success(true)
                    }
                    "acilisRutinIdGetir" -> {
                        val id = bekleyenRutinId
                        bekleyenRutinId = null
                        bekleyenTetiklenmeMilis = null
                        result.success(id)
                    }
                    "acilisRutinBilgisiGetir" -> {
                        val id = bekleyenRutinId
                        val tetik = bekleyenTetiklenmeMilis
                        bekleyenRutinId = null
                        bekleyenTetiklenmeMilis = null
                        if (id != null && id > 0) {
                            result.success(
                                mapOf(
                                    "rutinId" to id,
                                    "tetiklenmeMilis" to (tetik ?: System.currentTimeMillis()),
                                ),
                            )
                        } else {
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val rutinId = intent.getIntExtra("acilis_rutin_id", -1)
        if (rutinId > 0) {
            val tetikExtra = intent.getLongExtra("acilis_tetiklenme_milis", 0L)
            val tetik = if (tetikExtra > 0L) tetikExtra else System.currentTimeMillis()
            bekleyenRutinId = rutinId
            bekleyenTetiklenmeMilis = tetik
            alarmKanali?.invokeMethod(
                "rutinAc",
                mapOf("rutinId" to rutinId, "tetiklenmeMilis" to tetik),
            )
        }
    }
}
