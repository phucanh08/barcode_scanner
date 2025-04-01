package com.anhlp.barcode_scanner

import android.R.attr.scaleX
import android.content.Context
import android.graphics.*
import android.os.*
import android.view.View
import android.widget.ImageView
import androidx.camera.core.ImageProxy
import io.flutter.plugin.common.*
import io.flutter.plugin.platform.*
import kotlinx.coroutines.*

class BarcodeScannerViewFactory(private val binaryMessenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return BarcodeScannerView(binaryMessenger, context, viewId, args)
    }
}

internal class BarcodeScannerView(
    binaryMessenger: BinaryMessenger,
    context: Context,
    id: Int,
    creationParams: Any?
) : PlatformView, MethodChannel.MethodCallHandler, BarcodeScannerViewControllerDelegate {
    private var config: Protos.Configuration
    private val barcodeDetection: BarcodeDetection
    private val barcodeScannerViewController: BarcodeScannerViewController
    private var imageView: ImageView

    private val boundingBoxOverlay: BoundingBoxOverlay
    private val eventChannelHandler: EventChannelHandler = EventChannelHandler()
    private val container = android.widget.FrameLayout(context)
    private val coroutineScope = CoroutineScope(Dispatchers.IO)

    init {
        val methodChannel = MethodChannel(binaryMessenger, "com.anhlp.barcode_scanner/methods_$id")
        methodChannel.setMethodCallHandler(this)
        val eventChannel = EventChannel(binaryMessenger, "com.anhlp.barcode_scanner/events_$id")
        eventChannel.setStreamHandler(eventChannelHandler)
        config = Protos.Configuration.parseFrom(creationParams as ByteArray)
        barcodeScannerViewController =
            BarcodeScannerViewController(context, this::detectLiveStreamFrame)
        container.addView(barcodeScannerViewController.previewView)
        imageView = ImageView(context).apply {
            visibility = View.GONE
            scaleType = ImageView.ScaleType.CENTER_CROP // Đảm bảo ảnh lấp đầy và cắt nếu cần
            layoutParams = android.widget.FrameLayout.LayoutParams(
                android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
                android.widget.FrameLayout.LayoutParams.MATCH_PARENT
            )
        }
        container.addView(imageView)
        boundingBoxOverlay = BoundingBoxOverlay(context)
        container.addView(boundingBoxOverlay)
        barcodeDetection = BarcodeDetection(this, config.restrictFormatList.filterNotNull())
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        barcodeScannerViewController.stopCamera()
        barcodeDetection.dispose()
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

            "pauseCamera" -> pauseCameraPreview()
            "resumeCamera" -> resumeCameraPreview()
            else -> result.notImplemented()
        }
    }

    private fun detectLiveStreamFrame(imageProxy: ImageProxy) {
        if (barcodeScannerViewController.isPauseCamera) {
            imageProxy.close()
            return
        }
        barcodeDetection.process(imageProxy)
    }

    private var isDetectingByPath: Boolean = false

    private fun handleBarcodeDetectionResult(imagePath: String, result: MethodChannel.Result) {
        isDetectingByPath = true
        coroutineScope.launch {
            try {
                var bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
                    result.error("INVALID_IMAGE", "Không thể đọc ảnh từ đường dẫn", null)
                    return@launch
                }
                bitmap = ImageUtils.rotateImageIfRequired(bitmap, imagePath)
                withContext(Dispatchers.Main) {
                    boundingBoxOverlay.setBoundingBox(null)
                    imageView.setImageBitmap(bitmap)
                    pauseCameraPreview()
                }

                val res = barcodeDetection.zxingProcess(bitmap)
                val list = listOfNotNull(res)
                if (list.isEmpty()) {
                    result.error(
                        "NOT_FOUND",
                        "No barcode found in the image",
                        null
                    )
                } else {
                    result.success(list)
                }
            } catch (e: Exception) {
                result.error("BARCODE_DETECTION_ERROR", e.message, null)
            } finally {
                isDetectingByPath = false
            }
        }
    }

    private fun pauseCameraPreview() {
        barcodeScannerViewController.pauseCameraPreview()
        imageView.visibility = View.VISIBLE
    }

    private fun resumeCameraPreview() {
        barcodeScannerViewController.resumeCameraPreview()
        imageView.visibility = View.GONE
    }

    override fun didUpdateBoundingBoxOverlay(rectF: RectF?, bitmap: Bitmap?) {
        if (isDetectingByPath) {
            barcodeScannerViewController.previewView.visibility = View.GONE
            imageView.scaleType = ImageView.ScaleType.FIT_CENTER
        } else {
            barcodeScannerViewController.previewView.visibility = View.VISIBLE
            imageView.scaleType = ImageView.ScaleType.CENTER_CROP
        }


        var rect: Rect? = null

        if (bitmap != null && rectF != null) {
            val imageWidth = bitmap.width
            val imageHeight = bitmap.height
            val scaleX = container.width.toFloat() / imageWidth
            val scaleY = container.height.toFloat() / imageHeight
            if (isDetectingByPath) {
                val scale =
                    if (container.width / imageWidth * imageHeight > container.height) scaleY else scaleX

                val wLost = if (scale == scaleY) (imageWidth * scale - container.width) / 2f else 0f
                val hLost =
                    if (scale == scaleY) 0f else (imageHeight * scale - container.height) / 2f

                rect = Rect(
                    (scale * rectF.left - wLost).toInt(),
                    (scale * rectF.top - hLost).toInt(),
                    (scale * rectF.right - wLost).toInt(),
                    (scale * rectF.bottom - hLost).toInt()
                )
                boundingBoxOverlay.setBoundingBox(rect)
                return
            } else {
                val scale =
                    if (container.width / imageWidth * imageHeight > container.height) scaleX else scaleY

                val wLost = (imageWidth * scale - container.width) / 2f
                val hLost = (imageHeight * scale - container.height) / 2f


                rect = Rect(
                    (scale * rectF.left - wLost).toInt(),
                    (scale * rectF.top - hLost).toInt(),
                    (scale * rectF.right - wLost).toInt(),
                    (scale * rectF.bottom - hLost).toInt()
                )
            }
        }

        if (barcodeScannerViewController.isPauseCamera) return
        if (bitmap != null) {
            imageView.setImageBitmap(bitmap)
            pauseCameraPreview()
        }
        boundingBoxOverlay.setBoundingBox(rect)
    }

    override fun didScanBarcodeWithResult(scanResult: Protos.ScanResult) {
        eventChannelHandler.success(scanResult.toByteArray())
    }

    override fun didFailWithErrorCode(
        errorCode: String?,
        errorMessage: String?,
        errorDetails: Any?
    ) {
        eventChannelHandler.error(errorCode, errorMessage, errorDetails)
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
