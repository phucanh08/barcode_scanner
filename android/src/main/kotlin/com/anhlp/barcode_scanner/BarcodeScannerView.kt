package com.anhlp.barcode_scanner

import android.content.Context
import android.graphics.Color
import android.graphics.PointF
import android.os.Handler
import android.os.Looper
import android.view.View
import com.google.zxing.BarcodeFormat
import com.google.zxing.Result
import com.google.zxing.ResultPoint
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import me.dm7.barcodescanner.zxing.ZXingScannerView


class BarcodeScannerViewFactory(private val binaryMessenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return BarcodeScannerView2(binaryMessenger, context, viewId, args)
    }
}

internal class BarcodeScannerView(
    binaryMessenger: BinaryMessenger,
    context: Context,
    id: Int,
    creationParams: Any?
) : PlatformView, ZXingScannerView.ResultHandler, MethodCallHandler {
    private val eventChannelHandler: EventChannelHandler = EventChannelHandler()
    private var config: Protos.Configuration
    private val scannerView: ZXingAutofocusScannerView
    private val container = android.widget.FrameLayout(context).apply {
        layoutParams = android.widget.FrameLayout.LayoutParams(
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
        )
        setBackgroundColor(Color.WHITE)
    }
    private val boundingBoxOverlay: BoundingBoxOverlay

    init {
        val methodChannel = MethodChannel(binaryMessenger, "com.anhlp.barcode_scanner/methods_$id")
        methodChannel.setMethodCallHandler(this)
        val eventChannel = EventChannel(binaryMessenger, "com.anhlp.barcode_scanner/events_$id")
        eventChannel.setStreamHandler(eventChannelHandler)
        config = Protos.Configuration.parseFrom(creationParams as ByteArray)
        scannerView = ZXingAutofocusScannerView(context).apply {
            setAutoFocus(config.android.useAutoFocus)
            val restrictedFormats = mapRestrictedBarcodeTypes()
            if (restrictedFormats.isNotEmpty()) {
                setFormats(restrictedFormats)
            }
            setAspectTolerance(config.android.aspectTolerance.toFloat())
            if (config.autoEnableFlash) {
                flash = config.autoEnableFlash
                invalidate()
            }
        }
        container.addView(scannerView)
        boundingBoxOverlay = BoundingBoxOverlay(context)
        container.addView(boundingBoxOverlay)
        scannerView.setResultHandler(this)
        if (config.useCamera > -1) {
            scannerView.startCamera(config.useCamera)
        } else {
            scannerView.startCamera()
        }

    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        scannerView.stopCamera()
    }

    private fun makeAbsolute(
        points: Array<ResultPoint>?,
        leftOffset: Int,
        topOffset: Int
    ): List<PointF> {
        return points?.filterNotNull()?.map { PointF(it.x + leftOffset, it.y + topOffset) }
            ?: emptyList();
    }

    override fun handleResult(result: Result?) {
        Log.d("BarcodeScannerView", "Scanned result: $result")


        val builder = Protos.ScanResult.newBuilder()
        if (result == null) {
            boundingBoxOverlay.setBoundingBox(emptyList())

            builder.let {
                it.format = Protos.BarcodeFormat.unknown
                it.rawContent = "No data was scanned"
                it.type = Protos.ResultType.Error
            }
        } else {
            val data = makeAbsolute(
                result.resultPoints,
                scannerView.rect?.left ?: 0,
                scannerView.rect?.top ?: 0
            )
            boundingBoxOverlay.setBoundingBox(data)


            val format = (formatMap.filterValues { it == result.barcodeFormat }.keys.firstOrNull()
                ?: Protos.BarcodeFormat.unknown)

            var formatNote = ""
            if (format == Protos.BarcodeFormat.unknown) {
                formatNote = result.barcodeFormat.toString()
            }

            builder.let {
                it.format = format
                it.formatNote = formatNote
                it.rawContent = result.text
                it.type = Protos.ResultType.Barcode
            }
        }
        val res = builder.build()
        eventChannelHandler.success(res.toByteArray())
    }

    private fun mapRestrictedBarcodeTypes(): List<BarcodeFormat> {
        val types: MutableList<BarcodeFormat> = mutableListOf()

        this.config.restrictFormatList.filterNotNull().forEach {
            if (!formatMap.containsKey(it)) {
                print("Unrecognized")
                return@forEach
            }

            types.add(formatMap.getValue(it))
        }

        return types
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "detectBarcodesByImagePath" -> {
                return scannerView.detectBarcodesByImagePath(call.arguments as String, result)
            }

            "pauseCamera" -> {
                scannerView.stopCameraPreview()
                return result.success(null)
            }

            "resumeCamera" -> {
                scannerView.resumeCameraPreview()
                return result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    companion object {
        internal val formatMap: Map<Protos.BarcodeFormat, BarcodeFormat> = mapOf(
            Protos.BarcodeFormat.aztec to BarcodeFormat.AZTEC,
            Protos.BarcodeFormat.code39 to BarcodeFormat.CODE_39,
            Protos.BarcodeFormat.code93 to BarcodeFormat.CODE_93,
            Protos.BarcodeFormat.code128 to BarcodeFormat.CODE_128,
            Protos.BarcodeFormat.dataMatrix to BarcodeFormat.DATA_MATRIX,
            Protos.BarcodeFormat.ean8 to BarcodeFormat.EAN_8,
            Protos.BarcodeFormat.ean13 to BarcodeFormat.EAN_13,
            Protos.BarcodeFormat.interleaved2of5 to BarcodeFormat.ITF,
            Protos.BarcodeFormat.pdf417 to BarcodeFormat.PDF_417,
            Protos.BarcodeFormat.qr to BarcodeFormat.QR_CODE,
            Protos.BarcodeFormat.upce to BarcodeFormat.UPC_E
        )
    }
}

open class EventChannelHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    open fun success(event: Any?) {
        handler.post { eventSink?.success(event) }
    }

    open fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
        handler.post { eventSink?.success(eventSink?.error(errorCode, errorMessage, errorDetails)) }
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