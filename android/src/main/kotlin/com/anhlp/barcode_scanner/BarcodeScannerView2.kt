package com.anhlp.barcode_scanner

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.graphics.RectF
import android.util.Log
import android.view.View
import androidx.camera.core.ImageProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class BarcodeScannerView2(
    binaryMessenger: BinaryMessenger,
    context: Context,
    id: Int,
    creationParams: Any?
) : PlatformView, MethodCallHandler, BarcodeScannerViewControllerDelegate {
    private var config: Protos.Configuration
    private val barcodeDetection: BarcodeDetection
    private val barcodeScannerViewController: BarcodeScannerViewController

    private val boundingBoxOverlay: BoundingBoxOverlay2
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
        boundingBoxOverlay = BoundingBoxOverlay2(context)
        container.addView(boundingBoxOverlay)
        barcodeDetection = BarcodeDetection(this)
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        barcodeScannerViewController.stopCamera()
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
        try {
            var bitmap = imageProxy.toBitmap()
            imageProxy.close()
            barcodeDetection.process(bitmap, imageProxy.imageInfo.rotationDegrees)
        } catch (e: Exception) {
            boundingBoxOverlay.setBoundingBox(null)
            Log.d("BarcodeScannerView", "Lỗi khi xử lý ảnh: ${e.message}")
            eventChannelHandler.error(
                "SCAN_ERROR",
                "Lỗi khi xử lý ảnh: ${e.message}",
                null
            )
        }
    }

    private fun handleBarcodeDetectionResult(imagePath: String, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
                    result.error("INVALID_IMAGE", "Không thể đọc ảnh từ đường dẫn", null)
                    return@launch
                }
                val res = barcodeDetection.process(bitmap)
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

        val wLost = (imageWidth * scale - container.width ) / 2f
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

    override fun didFailWithErrorCode(errorCode: String) {
        TODO("Not yet implemented")
    }

    companion object {
        private const val TAG = "BarcodeScannerView"
    }
}