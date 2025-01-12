package com.example.petaniku

import android.os.Bundle
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.leaf_segmentation"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Chaquopy
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up MethodChannel to communicate with Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "segment") {
                val imgPath = call.argument<String>("imgPath")
                if (imgPath != null) {
                    try {
                        val segmentedImagePath = segmentImage(imgPath)
                        result.success(segmentedImagePath)
                    } catch (e: Exception) {
                        result.error("SEGMENTATION_ERROR", "Error during segmentation: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "imgPath is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun segmentImage(imgPath: String): String {
        val py = Python.getInstance()
        val pyModule = py.getModule("leaf_segmentation")
        val pyResult = pyModule.callAttr("segment", imgPath)
        return pyResult.toString()
    }
}