package com.anhlp.barcode_scanner.scanner.implements

import android.graphics.Bitmap
import com.anhlp.barcode_scanner.Protos
import com.anhlp.barcode_scanner.mappers.BarcodeMapper
import com.anhlp.barcode_scanner.scanner.interfaces.IBarcodeScanner
import com.google.zxing.BarcodeFormat
import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.MultiFormatReader
import com.google.zxing.NotFoundException
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer

class ZXingBarcodeScanner : IBarcodeScanner {
    private var formats: List<BarcodeFormat> = emptyList()
    private var reader: MultiFormatReader? = null

    override fun setFormats(formats: List<Protos.BarcodeFormat>) {
        this.formats = formats.map { zxingFormatMap[it] as BarcodeFormat }
        val hints = mapOf(DecodeHintType.POSSIBLE_FORMATS to this.formats)
        reader = MultiFormatReader()
        reader?.setHints(hints)
    }

    override fun process(bitmap: Bitmap, rotationDegrees: Int): List<Protos.BarcodeResult> {
//        val bitmap = ImageUtils.toGrayscale(bitmap)
        val width = bitmap.width
        val height = bitmap.height
        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        val source = RGBLuminanceSource(width, height, pixels)
        val binaryBitmap = BinaryBitmap(HybridBinarizer(source))

        try {
            val result = reader?.decodeWithState(binaryBitmap)
                ?: reader?.decodeWithState(BinaryBitmap(HybridBinarizer(source.invert())))

            return result?.let {
                val barcode = BarcodeMapper.toBarcode(it)
                return listOf(barcode)
            } ?: emptyList()
        } catch (_: NotFoundException) {
        } finally {
            reader?.reset()
        }

        return emptyList()
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
            Protos.BarcodeFormat.itf to BarcodeFormat.ITF,
            Protos.BarcodeFormat.pdf417 to BarcodeFormat.PDF_417,
            Protos.BarcodeFormat.qr to BarcodeFormat.QR_CODE,
            Protos.BarcodeFormat.upce to BarcodeFormat.UPC_E
        )
    }
}