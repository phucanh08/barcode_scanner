package com.anhlp.barcode_scanner

import android.graphics.*
import android.os.SystemClock
import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageProxy
import androidx.core.graphics.toRectF
import com.google.mlkit.vision.barcode.*
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import kotlinx.coroutines.*

class BarcodeDetection(
    private val controllerDelegate: BarcodeScannerViewControllerDelegate,
    barcodeFormats: List<Protos.BarcodeFormat>
) {
    private lateinit var mlKitBarcodeScanner: BarcodeScanner
    private var mMultiFormatReader: MultiFormatReader? = null
    private var mZxingFormats = barcodeFormats.map { zxingFormatMap[it] as BarcodeFormat }
    private var mMlKitFormats = barcodeFormats.mapNotNull { mlKitFormatMap[it] }
    private var coroutineScope = CoroutineScope(Dispatchers.IO)
    private var isZxingProcessing = false

    init {
        initMLKitBarcodeScanner()
        initMultiFormatReader()
    }

    fun dispose() {
        coroutineScope.cancel()
        mlKitBarcodeScanner.close()
        mMultiFormatReader = null
    }

    private fun initMLKitBarcodeScanner() {
        if (mMlKitFormats.isEmpty()) {
            // Fallback nếu không có format nào được chỉ định
            mlKitBarcodeScanner = BarcodeScanning.getClient()
        } else {
            val options = BarcodeScannerOptions.Builder().setBarcodeFormats(
                mMlKitFormats[0], // format đầu tiên
                *mMlKitFormats.drop(1).toIntArray() // các format còn lại
            ).build()
            mlKitBarcodeScanner = BarcodeScanning.getClient(options)
        }
    }

    private fun initMultiFormatReader() {
        val hints: MutableMap<DecodeHintType?, Any?> = mutableMapOf()
        hints.put(DecodeHintType.POSSIBLE_FORMATS, this.mZxingFormats)
        this.mMultiFormatReader = MultiFormatReader()
        this.mMultiFormatReader!!.setHints(hints)
    }

    private var timeMlKit: Long = 0

    fun process(imageProxy: ImageProxy) {
        coroutineScope.launch {
            val bitmap =
                if ((SystemClock.uptimeMillis() - timeMlKit) > 1000 && !isZxingProcessing) imageProxy.toBitmap() else null
            launch(Dispatchers.IO) { mlKitBarcodeScannerProcess(imageProxy) }
            if (bitmap != null) {
                launch(Dispatchers.IO) {
                    isZxingProcessing = true
                    zxingProcess(bitmap)
                    isZxingProcessing = false
                }
            }
        }
    }

    @OptIn(ExperimentalGetImage::class)
    private fun mlKitBarcodeScannerProcess(imageProxy: ImageProxy) {
        val image = imageProxy.image
        if (image == null) {
            imageProxy.close()
        }
        val inputImage =
            com.google.mlkit.vision.common.InputImage.fromMediaImage(
                image!!,
                imageProxy.imageInfo.rotationDegrees
            )
        mlKitBarcodeScanner.process(inputImage).addOnSuccessListener {
            if (it.isNotEmpty()) {
                timeMlKit = SystemClock.uptimeMillis()
                handleMlKitResult(it[0], imageProxy.toBitmap())
            }
        }.addOnCompleteListener {
            imageProxy.close()
        }
    }

    fun zxingProcess(bitmap: Bitmap): Result? {
        var bitmap = ImageUtils.toGrayscale(bitmap)
        bitmap = ImageUtils.resizeScale(bitmap, 1280)
        val width = bitmap.width
        val height = bitmap.height
        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        val source = RGBLuminanceSource(width, height, pixels)
        val binaryBitmap = BinaryBitmap(HybridBinarizer(source))

        try {
            val rawResult = mMultiFormatReader?.decodeWithState(binaryBitmap)
                ?: mMultiFormatReader?.decodeWithState(BinaryBitmap(HybridBinarizer(source.invert())))
            handleResult(rawResult, bitmap)

            if (rawResult == null) {
                CoroutineScope(Dispatchers.Main).launch {
                    controllerDelegate.didUpdateBoundingBoxOverlay(null)
                }
            }
            return rawResult
        } catch (_: NotFoundException) {
            CoroutineScope(Dispatchers.Main).launch {
                controllerDelegate.didUpdateBoundingBoxOverlay(null)
            }
            return null
        } catch (e: Exception) {
            CoroutineScope(Dispatchers.Main).launch {
                controllerDelegate.didUpdateBoundingBoxOverlay(null)
            }
            controllerDelegate.didFailWithErrorCode(
                "SCAN_ERROR",
                "An error occurred while scanning the barcode: ${e.message}",
                e
            )
        } finally {
            mMultiFormatReader?.reset()
        }
        return null

    }

    private fun handleMlKitResult(
        result: com.google.mlkit.vision.barcode.common.Barcode?, bitmap: Bitmap
    ) {
        result?.boundingBox?.toRectF()
        CoroutineScope(Dispatchers.Main).launch {
            controllerDelegate.didUpdateBoundingBoxOverlay(
                result?.boundingBox?.toRectF(), bitmap
            )
        }

        val builder = Protos.ScanResult.newBuilder()
        if (result == null) {
            builder.let {
                it.format = Protos.BarcodeFormat.unknown
                it.rawContent = "No data was scanned"
                it.type = Protos.ResultType.Error
            }
        } else {
            val rawValue = result.rawValue
            val format = (mlKitFormatMap.filterValues { it == result.format }.keys.firstOrNull()
                ?: Protos.BarcodeFormat.unknown)
            builder.let {
                it.format = format
                it.formatNote = ""
                it.rawContent = rawValue
                it.type = Protos.ResultType.Barcode
            }
        }
        val res = builder.build()
        controllerDelegate.didScanBarcodeWithResult(res)

    }

    private fun handleResult(result: Result?, bitmap: Bitmap) {
        val boundingBox =
            result?.resultPoints?.filterNotNull()?.takeIf { it.size >= 4 }?.let { points ->
                val xs = points.map { it.x }
                val ys = points.map { it.y }
                RectF(
                    xs.minOrNull() ?: 0f,
                    ys.minOrNull() ?: 0f,
                    xs.maxOrNull() ?: 0f,
                    ys.maxOrNull() ?: 0f
                )
            }

        CoroutineScope(Dispatchers.Main).launch {
            controllerDelegate.didUpdateBoundingBoxOverlay(boundingBox, bitmap)
        }

        val builder = Protos.ScanResult.newBuilder()
        if (result == null) {
            builder.let {
                it.format = Protos.BarcodeFormat.unknown
                it.rawContent = "No data was scanned"
                it.type = Protos.ResultType.Error
            }
        } else {
            val format =
                (zxingFormatMap.filterValues { it == result.barcodeFormat }.keys.firstOrNull()
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
        controllerDelegate.didScanBarcodeWithResult(res)
    }

    companion object {
        internal val zxingFormatMap: Map<Protos.BarcodeFormat, BarcodeFormat> = mapOf(
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

        internal val mlKitFormatMap: Map<Protos.BarcodeFormat, Int> = mapOf(
            Protos.BarcodeFormat.aztec to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_AZTEC,
            Protos.BarcodeFormat.code39 to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_39,
            Protos.BarcodeFormat.code93 to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_93,
            Protos.BarcodeFormat.code128 to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_128,
            Protos.BarcodeFormat.dataMatrix to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_DATA_MATRIX,
            Protos.BarcodeFormat.ean8 to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_8,
            Protos.BarcodeFormat.ean13 to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_13,
            Protos.BarcodeFormat.interleaved2of5 to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ITF,
            Protos.BarcodeFormat.pdf417 to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_PDF417,
            Protos.BarcodeFormat.qr to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_QR_CODE,
            Protos.BarcodeFormat.upce to com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_E
        )
    }
}

interface BarcodeScannerViewControllerDelegate {
    fun didUpdateBoundingBoxOverlay(rect: RectF?, bitmap: Bitmap? = null)

    fun didScanBarcodeWithResult(scanResult: Protos.ScanResult)

    fun didFailWithErrorCode(errorCode: String?, errorMessage: String?, errorDetails: Any?)
}
