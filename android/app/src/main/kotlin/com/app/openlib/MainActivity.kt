package com.app.openlib

import android.content.ClipData
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.widget.Toast
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "openlib/readers")
            .setMethodCallHandler { call, result ->
                try {
                    val mime = call.argument<String>("mimeType")
                    require(mime == "application/epub+zip" || mime == "application/pdf")
                    when (call.method) {
                        "readers" -> result.success(readers(mime!!))
                        "open" -> {
                            val file = File(call.argument<String>("path") ?: "")
                            require(file.isFile) { "The book file could not be found." }
                            val reader = call.argument<String>("reader") ?: "ask"
                            if (reader == "com.tct.book") {
                                require(mime == "application/epub+zip" && Build.VERSION.SDK_INT >= 29)
                                val launch = packageManager.getLaunchIntentForPackage(reader)
                                    ?: error("TCL Bookshelf is not installed.")
                                val displayName = call.argument<String>("displayName") ?: file.name
                                Thread {
                                    try {
                                        exportForBookshelf(file, displayName)
                                        runOnUiThread {
                                            try {
                                                startActivity(launch)
                                                Toast.makeText(this,
                                                    "Saved to Download/Openlib. Use Bookshelf's Import books.",
                                                    Toast.LENGTH_LONG).show()
                                                result.success(null)
                                            } catch (e: Exception) {
                                                result.error("reader_unavailable", e.message, null)
                                            }
                                        }
                                    } catch (e: Exception) {
                                        runOnUiThread { result.error("export_failed", e.message, null) }
                                    }
                                }.start()
                            } else {
                                val uri = FileProvider.getUriForFile(this,
                                    "$packageName.fileProvider.com.crazecoder.openfile", file)
                                val intent = Intent(Intent.ACTION_VIEW).apply {
                                    setDataAndType(uri, mime)
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                    clipData = ClipData.newRawUri("Book", uri)
                                    if (reader != "ask") setPackage(reader)
                                }
                                startActivity(if (reader == "ask")
                                    Intent.createChooser(intent, "Open book with") else intent)
                                result.success(null)
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("reader_unavailable", e.message, null)
                }
            }
    }

    @Suppress("DEPRECATION")
    private fun readers(mime: String): List<Map<String, Any>> {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(Uri.parse("content://openlib/book"), mime)
        }
        val apps = packageManager.queryIntentActivities(intent, 0)
            .filter { it.activityInfo.packageName != packageName }
            .distinctBy { it.activityInfo.packageName }
            .map { mapOf<String, Any>("id" to it.activityInfo.packageName,
                "label" to it.loadLabel(packageManager).toString()) }
            .toMutableList()
        if (mime == "application/epub+zip" && Build.VERSION.SDK_INT >= 29 &&
            packageManager.getLaunchIntentForPackage("com.tct.book") != null) {
            apps.removeAll { it["id"] == "com.tct.book" }
            apps.add(mapOf("id" to "com.tct.book", "label" to "TCL Bookshelf",
                "requiresImport" to true))
        }
        return apps.sortedBy { (it["label"] as String).lowercase() }
    }

    private fun exportForBookshelf(file: File, displayName: String) {
        check(Build.VERSION.SDK_INT >= 29)
        val name = displayName.replace(Regex("[/\\\\\\p{Cntrl}]"), "_").take(200)
        val identity = "${file.absolutePath}:${file.length()}:${file.lastModified()}:$name"
        val key = MessageDigest.getInstance("SHA-256").digest(identity.toByteArray())
            .joinToString("") { "%02x".format(it) }
        val preferences = getSharedPreferences("bookshelf_exports", MODE_PRIVATE)
        val previous = preferences.getString(key, null)
        if (previous != null) {
            try {
                contentResolver.openFileDescriptor(Uri.parse(previous), "r")?.use {
                    if (it.statSize == file.length()) return
                }
            } catch (_: Exception) { /* A removed export can be created again. */ }
        }
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, name)
            put(MediaStore.MediaColumns.MIME_TYPE, "application/epub+zip")
            put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/Openlib")
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: error("Could not create the book in Downloads.")
        try {
            val output = contentResolver.openOutputStream(uri)
                ?: error("Could not write the book in Downloads.")
            output.use { file.inputStream().use { input -> input.copyTo(it) } }
            contentResolver.update(uri, ContentValues().apply {
                put(MediaStore.MediaColumns.IS_PENDING, 0)
            }, null, null)
            preferences.edit().putString(key, uri.toString()).apply()
        } catch (e: Exception) {
            contentResolver.delete(uri, null, null)
            throw e
        }
    }
}
