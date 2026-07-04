package com.example.myapp

import android.content.Intent
import android.media.MediaScannerConnection
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class MainActivity : AudioServiceActivity() {
    companion object {
        private const val BACKGROUND_CHANNEL = "com.example.myapp/background"
        private const val YTMP3_CHANNEL = "com.example.myapp/ytmp3"
        private const val YTMP3_EVENTS = "com.example.myapp/ytmp3/events"
        private val YOUTUBE_URL_REGEX = Regex(
            """https?://(?:[\w-]+\.)?(?:youtube\.com|youtu\.be)[^\s]+""",
            RegexOption.IGNORE_CASE
        )
    }

    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pendingYoutubeUrl: String? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureYoutubeUrl(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureYoutubeUrl(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "moveToBackground" -> {
                    moveTaskToBack(true)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, YTMP3_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, YTMP3_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "consumeSharedYoutubeUrl" -> {
                    val url = pendingYoutubeUrl
                    pendingYoutubeUrl = null
                    result.success(url)
                }

                "convertToMp3" -> {
                    val url = call.argument<String>("url")?.trim()
                    if (url.isNullOrEmpty()) {
                        result.error("invalid_url", "A YouTube URL is required.", null)
                        return@setMethodCallHandler
                    }

                    executor.execute {
                        val conversionResult = convertYoutubeToMp3(url)
                        mainHandler.post {
                            result.success(conversionResult)
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        executor.shutdownNow()
        super.onDestroy()
    }

    private fun captureYoutubeUrl(intent: Intent?) {
        val url = extractYoutubeUrl(intent) ?: return
        pendingYoutubeUrl = url
        mainHandler.post {
            eventSink?.success(url)
        }
    }

    private fun extractYoutubeUrl(intent: Intent?): String? {
        if (intent == null) {
            return null
        }

        val candidates = mutableListOf<String>()
        intent.dataString?.let(candidates::add)

        if (intent.action == Intent.ACTION_SEND) {
            intent.getStringExtra(Intent.EXTRA_TEXT)?.let(candidates::add)
            intent.getStringExtra(Intent.EXTRA_SUBJECT)?.let(candidates::add)
        }

        val clipData = intent.clipData
        if (clipData != null) {
            for (index in 0 until clipData.itemCount) {
                clipData.getItemAt(index)?.text?.toString()?.let(candidates::add)
                clipData.getItemAt(index)?.uri?.toString()?.let(candidates::add)
            }
        }

        return candidates.firstNotNullOfOrNull(::extractYoutubeUrlFromText)
    }

    private fun extractYoutubeUrlFromText(text: String): String? {
        return YOUTUBE_URL_REGEX.find(text)?.value?.trim()
    }

    private fun convertYoutubeToMp3(url: String): Map<String, Any?> {
        if (!isArm64Device()) {
            return mapOf(
                "success" to false,
                "message" to "The bundled ytmp3 binary currently supports arm64 Android devices only."
            )
        }

        return try {
            val binaryFile = ensureBinaryCopied("ytmp3-bin")
            val outputDirectory = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                "MusicPlayer"
            )

            if (!outputDirectory.exists()) {
                outputDirectory.mkdirs()
            }

            val beforeConversion = outputDirectory
                .listFiles { file -> file.isFile && file.extension.equals("mp3", ignoreCase = true) }
                ?.map { it.absolutePath }
                ?.toSet()
                ?: emptySet()

            val processBuilder = ProcessBuilder(
                binaryFile.absolutePath,
                "--output-dir",
                outputDirectory.absolutePath,
                url
            ).redirectErrorStream(true)

            processBuilder.environment()["HOME"] = filesDir.absolutePath
            processBuilder.environment()["TMPDIR"] = cacheDir.absolutePath
            val logFile = File(cacheDir, "ytmp3-output.log")
            if (logFile.exists()) {
                logFile.delete()
            }
            processBuilder.redirectOutput(logFile)

            val process = processBuilder.start()
            val finished = process.waitFor(10, TimeUnit.MINUTES)
            val output = if (logFile.exists()) logFile.readText() else ""

            if (!finished) {
                process.destroyForcibly()
                return mapOf(
                    "success" to false,
                    "message" to "The YouTube conversion timed out.",
                    "rawOutput" to output
                )
            }

            val newestMp3 = outputDirectory
                .listFiles { file -> file.isFile && file.extension.equals("mp3", ignoreCase = true) }
                ?.sortedByDescending { it.lastModified() }
                ?.firstOrNull()

            val createdMp3 = outputDirectory
                .listFiles { file -> file.isFile && file.extension.equals("mp3", ignoreCase = true) }
                ?.firstOrNull { it.absolutePath !in beforeConversion }
                ?: newestMp3

            if (process.exitValue() == 0 && createdMp3 != null) {
                MediaScannerConnection.scanFile(
                    this,
                    arrayOf(createdMp3.absolutePath),
                    arrayOf("audio/mpeg"),
                    null
                )

                return mapOf(
                    "success" to true,
                    "message" to "Saved ${createdMp3.name} to Downloads/MusicPlayer.",
                    "filePath" to createdMp3.absolutePath,
                    "rawOutput" to output
                )
            }

            mapOf(
                "success" to false,
                "message" to lastMeaningfulOutputLine(output)
                    ?: "The ytmp3 binary finished without producing an MP3 file.",
                "rawOutput" to output
            )
        } catch (exception: Exception) {
            mapOf(
                "success" to false,
                "message" to (exception.message ?: "Unknown conversion error.")
            )
        }
    }

    private fun ensureBinaryCopied(assetName: String): File {
        val targetFile = File(filesDir, assetName)
        if (!targetFile.exists() || targetFile.length() == 0L) {
            assets.open(assetName).use { input ->
                targetFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }

        targetFile.setExecutable(true)
        return targetFile
    }

    private fun isArm64Device(): Boolean {
        return android.os.Build.SUPPORTED_ABIS.any { abi ->
            abi.equals("arm64-v8a", ignoreCase = true)
        }
    }

    private fun lastMeaningfulOutputLine(output: String): String? {
        return output
            .lineSequence()
            .map(String::trim)
            .lastOrNull { it.isNotEmpty() }
    }
}
