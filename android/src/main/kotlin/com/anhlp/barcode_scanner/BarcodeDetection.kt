package com.anhlp.barcode_scanner

import android.util.Log
import android.graphics.Bitmap
import android.graphics.PointF
import android.graphics.RectF
import androidx.core.graphics.toRectF
import com.google.mlkit.vision.barcode.*
import com.google.zxing.BarcodeFormat
import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.MultiFormatReader
import com.google.zxing.NotFoundException
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.Result
import com.google.zxing.common.HybridBinarizer
import kotlinx.coroutines.*

class BarcodeDetection(private val controllerDelegate: BarcodeScannerViewControllerDelegate) {
    private lateinit var mlKitBarcodeScanner: BarcodeScanner
    private var mMultiFormatReader: MultiFormatReader? = null
    private var mFormats: MutableList<BarcodeFormat> =
        mutableListOf(BarcodeFormat.PDF_417, BarcodeFormat.QR_CODE)
    private var coroutineScope = CoroutineScope(Dispatchers.Default)

    init {
        initMLKitBarcodeScanner()
        initMultiFormatReader()
    }

    private fun initMLKitBarcodeScanner() {
        val options = BarcodeScannerOptions.Builder().setBarcodeFormats(
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_QR_CODE,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_PDF417
        ).build()
        mlKitBarcodeScanner = BarcodeScanning.getClient(options)
    }

    private fun initMultiFormatReader() {
        val hints: MutableMap<DecodeHintType?, Any?> = mutableMapOf()
        hints.put(DecodeHintType.POSSIBLE_FORMATS, this.mFormats)
        this.mMultiFormatReader = MultiFormatReader()
        this.mMultiFormatReader!!.setHints(hints)
    }

    var timeMlkit: Long = 0

    fun process(bitmap: Bitmap, rotationDegrees: Int? = null): Result? {
        val width = bitmap.width
        val height = bitmap.height
        if (rotationDegrees != null) {
            coroutineScope.launch {
                val inputImage =
                    com.google.mlkit.vision.common.InputImage.fromBitmap(bitmap, rotationDegrees)
                mlKitBarcodeScanner.process(inputImage).addOnSuccessListener {
                    if (it.isNotEmpty()) {
                        timeMlkit = System.currentTimeMillis()
                    }
                    handleMlKitResult(it?.firstOrNull(), width, height)
                }.addOnFailureListener { handleMlKitResult(null, width, height) }
            }

        }

        if ((System.currentTimeMillis() - timeMlkit) < 1000 || rotationDegrees == null) {
            return null
        }

        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        val source = RGBLuminanceSource(width, height, pixels)
        val binaryBitmap = BinaryBitmap(HybridBinarizer(source))

        try {
            val rawResult = mMultiFormatReader?.decodeWithState(binaryBitmap)
                ?: mMultiFormatReader?.decodeWithState(BinaryBitmap(HybridBinarizer(source.invert())))
            handleResult(rawResult, width, height)
            if (rawResult != null) {
                return rawResult
            }
        } catch (_: NotFoundException) {
            Log.d(TAG, "Không tìm thấy mã vạch trong ảnh")
        } catch (e: Exception) {
            Log.d(TAG, "Lỗi khi quét mã vạch: ${e.message}")
        } finally {
            mMultiFormatReader?.reset()
        }

        return null
    }

    fun handleMlKitResult(
        result: com.google.mlkit.vision.barcode.common.Barcode?, imageWidth: Int, imageHeight: Int
    ) {
        result?.boundingBox?.toRectF()
        controllerDelegate.didUpdateBoundingBoxOverlay(
            result?.boundingBox?.toRectF(), imageWidth, imageHeight
        )

        val builder = Protos.ScanResult.newBuilder()
        if (result == null) {
            builder.let {
                it.format = Protos.BarcodeFormat.unknown
                it.rawContent = "No data was scanned"
                it.type = Protos.ResultType.Error
            }
        } else {
            val rawValue = result.rawValue
            val format = formatMapMLKit[result.format]
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

    fun handleResult(result: Result?, imageWidth: Int, imageHeight: Int) {
        val points = result?.resultPoints?.filterNotNull()?.take(4)?.map { point ->
            PointF(
                point.x, point.y
            )
        } ?: emptyList()

        controllerDelegate.didUpdateBoundingBoxOverlay(
            if (points.size == 4) RectF(
                points.map { it.x }.min(),
                points.map { it.y }.min(),
                points.map { it.x }.max(),
                points.map { it.y }.max()
            )
            else null, imageWidth, imageHeight
        )


        val builder = Protos.ScanResult.newBuilder()
        if (result == null) {
            builder.let {
                it.format = Protos.BarcodeFormat.unknown
                it.rawContent = "No data was scanned"
                it.type = Protos.ResultType.Error
            }
        } else {
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
        controllerDelegate.didScanBarcodeWithResult(res)
    }

    companion object {
        private const val TAG = "BarcodeDetection"

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

        internal val formatMapMLKit: Map<Int, Protos.BarcodeFormat> = mapOf(
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_AZTEC to Protos.BarcodeFormat.aztec,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_39 to Protos.BarcodeFormat.code39,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_93 to Protos.BarcodeFormat.code93,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_128 to Protos.BarcodeFormat.code128,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_DATA_MATRIX to Protos.BarcodeFormat.dataMatrix,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_8 to Protos.BarcodeFormat.ean8,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_13 to Protos.BarcodeFormat.ean13,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ITF to Protos.BarcodeFormat.interleaved2of5,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_PDF417 to Protos.BarcodeFormat.pdf417,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_QR_CODE to Protos.BarcodeFormat.qr,
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_E to Protos.BarcodeFormat.upce
        )
    }
}

interface BarcodeScannerViewControllerDelegate {
    fun didUpdateBoundingBoxOverlay(rect: RectF?, imageWidth: Int, imageHeight: Int)

    fun didScanBarcodeWithResult(scanResult: Protos.ScanResult)

    fun didFailWithErrorCode(errorCode: String)
}