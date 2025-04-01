package com.anhlp.barcode_scanner

import android.content.Context
import android.graphics.*
import android.os.*
import android.view.View
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

            "pauseCamera" -> barcodeScannerViewController.pauseCameraPreview()
            "resumeCamera" -> barcodeScannerViewController.resumeCameraPreview()
            else -> result.notImplemented()
        }
    }

    private fun detectLiveStreamFrame(imageProxy: ImageProxy) {
        barcodeDetection.process(imageProxy)
    }

    private fun handleBarcodeDetectionResult(imagePath: String, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
                    result.error("INVALID_IMAGE", "Không thể đọc ảnh từ đường dẫn", null)
                    return@launch
                }
                val res = barcodeDetection.zxingProcess(bitmap)
                result.success(res?.text)
            } catch (e: Exception) {
                result.error("BARCODE_DETECTION_ERROR", e.message, null)
            }
        }
    }

    override fun didUpdateBoundingBoxOverlay(rect: RectF?, imageWidth: Int, imageHeight: Int) {
        val scaleX = container.width.toFloat() / imageWidth
        val scaleY = container.height.toFloat() / imageHeight
        val scale =
            if (container.width / imageWidth * imageHeight > container.height) scaleX else scaleY

        val wLost = (imageWidth * scale - container.width) / 2f
        val hLost = (imageHeight * scale - container.height) / 2f

        boundingBoxOverlay.setBoundingBox(
            if (rect != null) Rect(
                (scale * rect.left - wLost).toInt(),
                (scale * rect.top - hLost).toInt(),
                (scale * rect.right - wLost).toInt(),
                (scale * rect.bottom - hLost).toInt()
            )
            else null
        )
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
