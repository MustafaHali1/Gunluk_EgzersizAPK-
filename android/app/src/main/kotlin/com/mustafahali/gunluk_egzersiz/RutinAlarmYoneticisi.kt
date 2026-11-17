package com.mustafahali.gunluk_egzersiz

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

// Rutin alarmlarını Android AlarmManager.setAlarmClock ile planlayan ve yeniden başlatma sonrası koruyan yönetici.
object RutinAlarmYoneticisi {
    private const val PREFS_ADI = "rutin_alarmlari_prefs"
    private const val ANAHTAR_ALARMLAR = "kayitli_alarmlar"
    private const val ANAHTAR_ERTELEME_DAKIKA = "varsayilan_erteleme_dakika"
    private const val ERTELEME_ISTEK_KODU_TABANI = 90000

    fun varsayilanErtelemeDakikasıGetir(context: Context): Int {
        val prefs = context.getSharedPreferences(PREFS_ADI, Context.MODE_PRIVATE)
        return prefs.getInt(ANAHTAR_ERTELEME_DAKIKA, 15).coerceIn(1, 720)
    }

    fun varsayilanErtelemeDakikasiKaydet(context: Context, dakika: Int) {
        val prefs = context.getSharedPreferences(PREFS_ADI, Context.MODE_PRIVATE)
        prefs.edit().putInt(ANAHTAR_ERTELEME_DAKIKA, dakika.coerceIn(1, 720)).apply()
    }

    fun tumAlarmlariKur(context: Context, alarmlar: List<Map<String, Any?>>) {
        mevcutPlanliAlarmlariIptalEt(context)

        val jsonDizisi = JSONArray()
        for (alarm in alarmlar) {
            val rutinId = (alarm["rutinId"] as? Number)?.toInt() ?: 0
            val alarmId = (alarm["alarmId"] as? Number)?.toInt() ?: rutinId
            val obj = JSONObject()
            obj.put("alarmId", alarmId)
            obj.put("rutinId", rutinId)
            obj.put("rutinAdi", alarm["rutinAdi"] as? String ?: "Rutin")
            obj.put("saat", (alarm["saat"] as? Number)?.toInt() ?: 9)
            obj.put("dakika", (alarm["dakika"] as? Number)?.toInt() ?: 0)
            obj.put("alarmAcikMi", alarm["alarmAcikMi"] as? Boolean ?: false)
            obj.put("sadeceTarih", alarm["sadeceTarih"] as? String)
            obj.put("haftaninGunleri", alarm["haftaninGunleri"] as? String ?: "")
            obj.put("muzikYolu", alarm["muzikYolu"] as? String)
            jsonDizisi.put(obj)
        }

        context.getSharedPreferences(PREFS_ADI, Context.MODE_PRIVATE)
            .edit()
            .putString(ANAHTAR_ALARMLAR, jsonDizisi.toString())
            .apply()

        for (i in 0 until jsonDizisi.length()) {
            val obj = jsonDizisi.getJSONObject(i)
            if (obj.optBoolean("alarmAcikMi", false)) {
                tekRutinAlarmiPlanla(context, obj)
            }
        }
    }

    fun yenidenBaslatmaSonrasiKur(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_ADI, Context.MODE_PRIVATE)
        val ham = prefs.getString(ANAHTAR_ALARMLAR, null) ?: return
        try {
            val dizi = JSONArray(ham)
            for (i in 0 until dizi.length()) {
                val obj = dizi.getJSONObject(i)
                if (obj.optBoolean("alarmAcikMi", false)) {
                    tekRutinAlarmiPlanla(context, obj)
                }
            }
        } catch (_: Exception) {
        }
    }

    fun tumAlarmlariIptalEt(context: Context) {
        mevcutPlanliAlarmlariIptalEt(context)
        context.getSharedPreferences(PREFS_ADI, Context.MODE_PRIVATE)
            .edit()
            .remove(ANAHTAR_ALARMLAR)
            .apply()
        val durdurIntent = Intent(context, RutinAlarmServisi::class.java).apply {
            action = RutinAlarmServisi.ACTION_DURDUR
        }
        context.startService(durdurIntent)
    }

    fun sonrakiHaftalikAlarmiPlanla(context: Context, alarmId: Int) {
        val prefs = context.getSharedPreferences(PREFS_ADI, Context.MODE_PRIVATE)
        val ham = prefs.getString(ANAHTAR_ALARMLAR, null) ?: return
        try {
            val dizi = JSONArray(ham)
            for (i in 0 until dizi.length()) {
                val obj = dizi.getJSONObject(i)
                val kayitliAlarmId = obj.optInt("alarmId", obj.optInt("rutinId", 0))
                if (kayitliAlarmId == alarmId && obj.optBoolean("alarmAcikMi", false)) {
                    tekRutinAlarmiPlanla(context, obj)
                    break
                }
            }
        } catch (_: Exception) {
        }
    }

    fun ertelemePlanla(
        context: Context,
        rutinId: Int,
        rutinAdi: String,
        muzikYolu: String?,
        ertelemeDakika: Int,
        saatMetni: String? = null,
    ): Long {
        val simdi = System.currentTimeMillis()
        val gunSonu = bugununSonuMilis()
        val istenenHedef = simdi + (ertelemeDakika.coerceAtLeast(1) * 60_000L)
        val hedefMilis = if (istenenHedef > gunSonu && gunSonu > simdi + 30_000L) {
            gunSonu
        } else {
            istenenHedef
        }

        val intent = Intent(context, RutinAlarmAlicisi::class.java).apply {
            action = RutinAlarmAlicisi.ACTION_ALARM_TETIKLENDI
            putExtra("rutinId", rutinId)
            putExtra("rutinAdi", rutinAdi)
            putExtra("muzikYolu", muzikYolu)
            putExtra("saatMetni", saatMetni ?: "")
            putExtra("ertelemeMi", true)
        }

        val istekKodu = ERTELEME_ISTEK_KODU_TABANI + rutinId
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            istekKodu,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        alarmYoneticisiIleKur(context, hedefMilis, pendingIntent, rutinId, rutinAdi)
        return hedefMilis
    }

    fun bugununSonuMilis(): Long {
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 23)
            set(Calendar.MINUTE, 59)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return cal.timeInMillis
    }

    private fun tekRutinAlarmiPlanla(context: Context, obj: JSONObject) {
        val rutinId = obj.optInt("rutinId", 0)
        val alarmId = obj.optInt("alarmId", rutinId)
        val rutinAdi = obj.optString("rutinAdi", "Rutin")
        val saat = obj.optInt("saat", 9)
        val dakika = obj.optInt("dakika", 0)
        val sadeceTarih = obj.optString("sadeceTarih", "").takeIf { it.isNotBlank() && it != "null" }
        val haftaninGunleri = obj.optString("haftaninGunleri", "")
        val muzikYolu = obj.optString("muzikYolu", "").takeIf { it.isNotBlank() && it != "null" }

        val tetiklemeMilis = if (sadeceTarih != null) {
            tekSeferlikTetiklemeHesapla(sadeceTarih, saat, dakika)
        } else {
            sonrakiHaftalikTetiklemeHesapla(haftaninGunleri, saat, dakika)
        } ?: return

        val saatMetni = String.format(java.util.Locale.US, "%02d:%02d", saat, dakika)
        val intent = Intent(context, RutinAlarmAlicisi::class.java).apply {
            action = RutinAlarmAlicisi.ACTION_ALARM_TETIKLENDI
            putExtra("alarmId", alarmId)
            putExtra("rutinId", rutinId)
            putExtra("rutinAdi", rutinAdi)
            putExtra("muzikYolu", muzikYolu)
            putExtra("saatMetni", saatMetni)
            putExtra("ertelemeMi", false)
        }

        val istekKodu = 10000 + alarmId
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            istekKodu,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        alarmYoneticisiIleKur(context, tetiklemeMilis, pendingIntent, rutinId, rutinAdi)
    }

    private fun alarmYoneticisiIleKur(
        context: Context,
        tetiklemeMilis: Long,
        pendingIntent: PendingIntent,
        rutinId: Int,
        rutinAdi: String,
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val acilisIntent = Intent(context, MainActivity::class.java).apply {
            putExtra("acilis_rutin_id", rutinId)
            putExtra("acilis_rutin_adi", rutinAdi)
        }
        val showPendingIntent = PendingIntent.getActivity(
            context,
            20000 + rutinId,
            acilisIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        try {
            val bilgi = AlarmManager.AlarmClockInfo(tetiklemeMilis, showPendingIntent)
            alarmManager.setAlarmClock(bilgi, pendingIntent)
        } catch (_: SecurityException) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    tetiklemeMilis,
                    pendingIntent,
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    tetiklemeMilis,
                    pendingIntent,
                )
            }
        }
    }

    private fun mevcutPlanliAlarmlariIptalEt(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val prefs = context.getSharedPreferences(PREFS_ADI, Context.MODE_PRIVATE)
        val ham = prefs.getString(ANAHTAR_ALARMLAR, null) ?: return
        try {
            val dizi = JSONArray(ham)
            for (i in 0 until dizi.length()) {
                val obj = dizi.getJSONObject(i)
                val alarmId = obj.optInt("alarmId", obj.optInt("rutinId", 0))
                val normalIntent = PendingIntent.getBroadcast(
                    context,
                    10000 + alarmId,
                    Intent(context, RutinAlarmAlicisi::class.java).apply {
                        action = RutinAlarmAlicisi.ACTION_ALARM_TETIKLENDI
                    },
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
                )
                if (normalIntent != null) {
                    alarmManager.cancel(normalIntent)
                    normalIntent.cancel()
                }
            }
        } catch (_: Exception) {
        }
    }

    private fun tekSeferlikTetiklemeHesapla(
        tarihMetni: String,
        saat: Int,
        dakika: Int,
    ): Long? {
        val parcalar = tarihMetni.split("-")
        if (parcalar.size != 3) return null
        val yil = parcalar[0].toIntOrNull() ?: return null
        val ay = parcalar[1].toIntOrNull() ?: return null
        val gun = parcalar[2].toIntOrNull() ?: return null

        val cal = Calendar.getInstance().apply {
            set(Calendar.YEAR, yil)
            set(Calendar.MONTH, ay - 1)
            set(Calendar.DAY_OF_MONTH, gun)
            set(Calendar.HOUR_OF_DAY, saat)
            set(Calendar.MINUTE, dakika)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return if (cal.timeInMillis > System.currentTimeMillis()) cal.timeInMillis else null
    }

    private fun sonrakiHaftalikTetiklemeHesapla(
        haftaninGunleriMetni: String,
        saat: Int,
        dakika: Int,
    ): Long? {
        val isoGunler = haftaninGunleriMetni
            .split(",")
            .mapNotNull { it.trim().toIntOrNull() }
            .filter { it in 1..7 }
            .toSet()

        if (isoGunler.isEmpty()) return null

        val simdi = System.currentTimeMillis()
        for (ekGun in 0..7) {
            val aday = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, ekGun)
                set(Calendar.HOUR_OF_DAY, saat)
                set(Calendar.MINUTE, dakika)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val isoGun = when (aday.get(Calendar.DAY_OF_WEEK)) {
                Calendar.MONDAY -> 1
                Calendar.TUESDAY -> 2
                Calendar.WEDNESDAY -> 3
                Calendar.THURSDAY -> 4
                Calendar.FRIDAY -> 5
                Calendar.SATURDAY -> 6
                Calendar.SUNDAY -> 7
                else -> 1
            }
            if (isoGunler.contains(isoGun) && aday.timeInMillis > simdi + 1000L) {
                return aday.timeInMillis
            }
        }
        return null
    }
}
