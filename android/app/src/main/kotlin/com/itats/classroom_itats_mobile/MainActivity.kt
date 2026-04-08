package com.itats.classroom_itats_mobile

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Environment
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val WHATSAPP_CHANNEL = "com.itats.classroom/whatsapp"
    private val DOWNLOAD_CHANNEL = "com.itats.classroom/download"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Channel: WhatsApp launcher (existing) ──────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WHATSAPP_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "launchWhatsApp") {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        try {
                            val intent = Intent(Intent.ACTION_VIEW)
                            intent.data = Uri.parse(url)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Could not open WhatsApp.", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "URL is null", null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        // ── Channel: Download Manager ──────────────────────────────────────
        // Menggunakan Android DownloadManager sehingga file tersimpan di
        // folder Download bawaan device tanpa perlu permission apapun.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOAD_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "downloadFile") {
                    val url      = call.argument<String>("url")
                    val fileName = call.argument<String>("fileName")
                    val title    = call.argument<String>("title") ?: fileName ?: "Download"

                    if (url == null || fileName == null) {
                        result.error("INVALID_ARGUMENT", "url dan fileName wajib diisi", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val dm = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager

                        val request = DownloadManager.Request(Uri.parse(url)).apply {
                            setTitle(title)
                            setDescription("Mengunduh file...")
                            setNotificationVisibility(
                                DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED
                            )
                            // Simpan ke folder Download publik (/storage/emulated/0/Download/)
                            setDestinationInExternalPublicDir(
                                Environment.DIRECTORY_DOWNLOADS,
                                fileName
                            )
                            // Izinkan download via WiFi dan data seluler
                            setAllowedOverMetered(true)
                            setAllowedOverRoaming(true)
                        }

                        val downloadId = dm.enqueue(request)
                        // Kembalikan download ID (Long) sebagai String agar mudah dikirim
                        result.success(downloadId.toString())
                    } catch (e: Exception) {
                        result.error("DOWNLOAD_ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
