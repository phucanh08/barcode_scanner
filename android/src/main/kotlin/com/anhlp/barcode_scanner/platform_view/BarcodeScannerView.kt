package com.anhlp.barcode_scanner.platform_view

import android.content.Context
import android.graphics.*
import android.os.*
import android.view.View
import android.widget.ImageView
import androidx.camera.core.ImageProxy
import com.anhlp.barcode_scanner.Protos
import com.anhlp.barcode_scanner.scanner.BarcodeScanner
import com.anhlp.barcode_scanner.utils.ImageUtils
import io.flutter.plugin.common.*
import io.flutter.plugin.platform.*
import kotlinx.coroutines.*


internal class BarcodeScannerView(
    binaryMessenger: BinaryMessenger,
    context: Context,
    id: Int,
    creationParams: Any?
) : PlatformView, MethodChannel.MethodCallHandler, CameraStreamDelegate {
    private val _view = android.widget.FrameLayout(context)
    private val imageView = ImageView(context).apply {
        scaleType = ImageView.ScaleType.CENTER_CROP // Đảm bảo ảnh lấp đầy và cắt nếu cần
        layoutParams = android.widget.FrameLayout.LayoutParams(
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT
        )
    }
    private val boundingBoxOverlay = BoundingBoxOverlay(context)

    private val barcodeScanner = BarcodeScanner()
    private val cameraManager: CameraManager = CameraManager(context)

    private val eventChannelHandler = EventChannelHandler()

    private var isDetectingByPath: Boolean = false

    init {
        _view.addView(cameraManager.previewView)
        _view.addView(imageView)
        _view.addView(boundingBoxOverlay)

        val methodChannel = MethodChannel(binaryMessenger, "com.anhlp.barcode_scanner/methods_$id")
        methodChannel.setMethodCallHandler(this)
        val eventChannel = EventChannel(binaryMessenger, "com.anhlp.barcode_scanner/events_$id")
        eventChannel.setStreamHandler(eventChannelHandler)


        cameraManager.delegate = this
        val config = Protos.Configuration.parseFrom(creationParams as ByteArray)
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

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "detectBarcodesByImagePath" -> handleBarcodeDetectionResult(
                call.arguments as String,
                result
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
        CoroutineScope(Dispatchers.Main) .launch {
            isDetectingByPath = true
            cameraManager.previewView.visibility = View.INVISIBLE
            imageView.scaleType = ImageView.ScaleType.FIT_CENTER
            boundingBoxOverlay.clear()
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                var bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
                    result.error("INVALID_IMAGE", "Không thể đọc ảnh từ đường dẫn", null)
                    return@launch
                }
                bitmap = ImageUtils.rotateImageIfRequired(bitmap, imagePath)
                withContext(Dispatchers.Main) {
                    imageView.setImageBitmap(bitmap)
                    pauseCameraPreview()
                }
                val barcodes = barcodeScanner.process(bitmap)
                if (barcodes.isNotEmpty()) {
                    val rectF = RectF(
                        barcodes[0].boundingBox.left,
                        barcodes[0].boundingBox.top,
                        barcodes[0].boundingBox.right,
                        barcodes[0].boundingBox.bottom
                    )
                    updateBoundingBoxOverlay(rectF, bitmap)
                }
                result.success(barcodes.map { it.toByteArray() })
            } catch (e: Exception) {
                result.error("BARCODE_DETECTION_ERROR", e.message, null)
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

    private fun updateBoundingBoxOverlay(rectF: RectF?, bitmap: Bitmap?) {
        val isDetectingByPath = isDetectingByPath

        CoroutineScope(Dispatchers.Main).launch {
            if (cameraManager.isPauseCamera && !isDetectingByPath) return@launch

            if (rectF == null || bitmap == null) {
                boundingBoxOverlay.clear()
                return@launch
            }

            if (!cameraManager.isPauseCamera) {
                imageView.setImageBitmap(bitmap)  
                pauseCameraPreview()
            }

            boundingBoxOverlay.setBoundingBox(rectF, bitmap.width, bitmap.height, !isDetectingByPath)
        }
    }

    override fun didReceiveFrame(imageProxy: ImageProxy) {
        if (cameraManager.isPauseCamera) {
            imageProxy.close()
            return
        }
        imageProxy.use {
            val bitmap = imageProxy.toBitmap()
            val rotationDegrees = imageProxy.imageInfo.rotationDegrees

            val barcodes = barcodeScanner.process(bitmap, rotationDegrees)
            if (barcodes.isNotEmpty()) {
                val rectF = RectF(
                    barcodes[0].boundingBox.left,
                    barcodes[0].boundingBox.top,
                    barcodes[0].boundingBox.right,
                    barcodes[0].boundingBox.bottom
                )
                updateBoundingBoxOverlay(rectF, bitmap)
                eventChannelHandler.success(barcodes.map { it.toByteArray() })
            }
        }
    }
}


open class EventChannelHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    open fun success(event: Any?) {
        handler.post { eventSink?.success(event) }
    }

    open fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
        handler.post { eventSink?.error(errorCode, errorMessage, errorDetails) }
    }


    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
