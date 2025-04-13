package com.anhlp.barcode_scanner.platform_view

import android.Manifest
import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.RectF
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.View
import android.widget.ImageView
import androidx.annotation.RequiresPermission
import androidx.camera.core.ImageProxy
import com.anhlp.barcode_scanner.BarcodeScannerPlugin
import com.anhlp.barcode_scanner.Protos
import com.anhlp.barcode_scanner.mappers.RectFMapper
import com.anhlp.barcode_scanner.scanner.BarcodeScanner
import com.anhlp.barcode_scanner.utils.ImageUtils
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext


internal class BarcodeScannerView(
    context: Context, id: Int, creationParams: Any?
) : PlatformView, CameraStreamDelegate {
    private val _view = android.widget.FrameLayout(context)
    private val imageView = ImageView(context).apply {
        scaleType = ImageView.ScaleType.CENTER_CROP
        layoutParams = android.widget.FrameLayout.LayoutParams(
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT
        )
    }
    private val boundingBoxOverlay = BoundingBoxOverlay(context)

    private val barcodeScanner = BarcodeScanner()
    private val cameraManager: CameraManager = CameraManager(context)

    private val eventChannelHandler = EventChannelHandler(context)

    private var isDetectingByPath: Boolean = false

    init {
        _view.addView(cameraManager.previewView)
        _view.addView(imageView)
        _view.addView(boundingBoxOverlay)

        val binaryMessenger = BarcodeScannerPlugin.getBinaryMessenger()
        val methodChannel = MethodChannel(binaryMessenger, "com.anhlp.barcode_scanner/methods_$id")
        methodChannel.setMethodCallHandler(::onMethodCall)
        val eventChannel = EventChannel(binaryMessenger, "com.anhlp.barcode_scanner/events_$id")
        eventChannel.setStreamHandler(eventChannelHandler)

        cameraManager.delegate = this
        val config = Protos.Configuration.parseFrom(creationParams as ByteArray)
        eventChannelHandler.beepOnScan = config.resultSettings.beepOnScan
        eventChannelHandler.vibrateOnScan = config.resultSettings.vibrateOnScan
        cameraManager.setCameraSetting(config.cameraSettings)
        barcodeScanner.setFormats(config.barcodeFormatsList)
        cameraManager.startCamera()
    }

    override fun getView(): View {
        return _view
    }

    override fun dispose() {
        cameraManager.stopCamera()
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "detectBarcodesByImagePath" -> handleBarcodeDetectionResult(
                call.arguments as String, result
            )

            "pauseCamera" -> {
                val isPauseCamera = pauseCameraPreview()
                result.success(isPauseCamera)
            }

            "resumeCamera" -> {
                val isResumeCamera = resumeCameraPreview()
                result.success(isResumeCamera)
            }

            "isFlashOn" -> {
                val isFlashOn = cameraManager.isFlashOn()
                result.success(isFlashOn)
            }

            "toggleFlash" -> {
                val isFlashOn = cameraManager.toggleFlash()
                result.success(isFlashOn)
            }

            else -> result.notImplemented()
        }
    }


    private fun handleBarcodeDetectionResult(imagePath: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.Main).launch {
            isDetectingByPath = true
            cameraManager.previewView.visibility = View.INVISIBLE
            imageView.scaleType = ImageView.ScaleType.FIT_CENTER
            boundingBoxOverlay.clear()
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                var bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
                    result.error("INVALID_IMAGE_PATH", "Không thể đọc ảnh từ đường dẫn", null)
                    return@launch
                }
                bitmap = ImageUtils.rotateImageIfRequired(bitmap, imagePath)
                withContext(Dispatchers.Main) {
                    imageView.setImageBitmap(bitmap)
                    pauseCameraPreview()
                }
                val barcodes = barcodeScanner.process(bitmap)
                if (barcodes.isNotEmpty()) {
                    val rectF = RectFMapper.toRectF(barcodes[0].boundingBox)
                    boundingBoxOverlay.setBoundingBox(rectF, bitmap.width, bitmap.height, false)
                }
                result.success(barcodes.map { it.toByteArray() })
            } catch (e: Exception) {
                result.success(emptyList<Any>())
            } finally {
                delay(500)
                isDetectingByPath = false
            }
        }
    }

    private fun pauseCameraPreview(): Boolean {
        try {
            cameraManager.pauseCameraPreview()
            return true
        } catch (_: Exception) {
            return false
        }
    }

    private fun resumeCameraPreview(): Boolean {
        try {
            CoroutineScope(Dispatchers.Main).launch {
                boundingBoxOverlay.clear()
                imageView.setImageResource(0)
                cameraManager.previewView.visibility = View.VISIBLE
                imageView.scaleType = ImageView.ScaleType.CENTER_CROP
            }
            cameraManager.resumeCameraPreview()
            return true
        } catch (_: Exception) {
            return false
        }
    }

    override fun didReceiveFrame(imageProxy: ImageProxy) {
        if (cameraManager.isPauseCamera) {
            imageProxy.close()
            return
        }
        imageProxy.use {
            val bitmap = imageProxy.toBitmap()
            val barcodes = barcodeScanner.process(bitmap, imageProxy.imageInfo.rotationDegrees)
            CoroutineScope(Dispatchers.Main).launch {
                if (barcodes.isNotEmpty()) {
                    val rectF = RectFMapper.toRectF(barcodes[0].boundingBox)
                    if (isDetectingByPath) return@launch
                    imageView.setImageBitmap(bitmap)
                    pauseCameraPreview()
                    boundingBoxOverlay.setBoundingBox(
                        rectF, bitmap.width, bitmap.height, true
                    )
                    eventChannelHandler.success(barcodes.map { it.toByteArray() })
                } else {
                    boundingBoxOverlay.clear()
                }
            }
        }
    }
}

open class EventChannelHandler(context: Context) : EventChannel.StreamHandler {
    private val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val vibratorManager =
            context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
        vibratorManager.defaultVibrator
    } else {
        @Suppress("DEPRECATION") context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    }
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    var vibrateOnScan: Boolean = false
    var beepOnScan: Boolean = false

    open fun success(event: Any?) {
        handler.post { eventSink?.success(event) }
        beep()
        vibrate()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun beep() {
        if (beepOnScan) {
            val toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, 100)
            toneGenerator.startTone(ToneGenerator.TONE_CDMA_PIP, 150)
        }
    }

    @RequiresPermission(Manifest.permission.VIBRATE)
    private fun vibrate() {
        if (vibrateOnScan) {
            val milliseconds = 250L
            CoroutineScope(Dispatchers.IO).launch {
                if (vibrator.hasVibrator()) {
                    when (Build.VERSION.SDK_INT) {
                        in Build.VERSION_CODES.BASE..Build.VERSION_CODES.N_MR1 -> {
                            @Suppress("DEPRECATION") vibrator.vibrate(milliseconds)
                        }

                        in Build.VERSION_CODES.O..Build.VERSION_CODES.P -> {
                            val effect = VibrationEffect.createOneShot(
                                milliseconds, VibrationEffect.DEFAULT_AMPLITUDE
                            )
                            vibrator.vibrate(effect)
                        }

                        else -> {
                            val effect = VibrationEffect.createOneShot(
                                milliseconds, VibrationEffect.EFFECT_HEAVY_CLICK
                            )
                            vibrator.vibrate(effect)
                        }
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val effect = VibrationEffect.createOneShot(
                            milliseconds, VibrationEffect.DEFAULT_AMPLITUDE
                        )
                        vibrator.vibrate(effect)
                    } else {
                        @Suppress("DEPRECATION") vibrator.vibrate(milliseconds)
                    }
                }
            }
        }
    }
}
