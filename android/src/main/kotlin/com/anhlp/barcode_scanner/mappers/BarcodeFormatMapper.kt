package com.anhlp.barcode_scanner.mappers

import com.anhlp.barcode_scanner.Protos
import com.google.mlkit.vision.barcode.common.Barcode.*

object BarcodeFormatMapper {
    fun toBarcodeFormat(format: com.google.zxing.BarcodeFormat): Protos.BarcodeFormat {
        return when (format) {
            com.google.zxing.BarcodeFormat.CODE_39 -> Protos.BarcodeFormat.code39
            com.google.zxing.BarcodeFormat.CODE_93 -> Protos.BarcodeFormat.code93
            com.google.zxing.BarcodeFormat.CODE_128 -> Protos.BarcodeFormat.code128
            com.google.zxing.BarcodeFormat.ITF -> Protos.BarcodeFormat.itf
            com.google.zxing.BarcodeFormat.UPC_E -> Protos.BarcodeFormat.upce
            com.google.zxing.BarcodeFormat.EAN_8 -> Protos.BarcodeFormat.ean8
            com.google.zxing.BarcodeFormat.EAN_13 -> Protos.BarcodeFormat.ean13
            com.google.zxing.BarcodeFormat.QR_CODE -> Protos.BarcodeFormat.qr
            com.google.zxing.BarcodeFormat.PDF_417 -> Protos.BarcodeFormat.pdf417
            com.google.zxing.BarcodeFormat.DATA_MATRIX -> Protos.BarcodeFormat.dataMatrix
            com.google.zxing.BarcodeFormat.AZTEC -> Protos.BarcodeFormat.aztec
            com.google.zxing.BarcodeFormat.CODABAR -> Protos.BarcodeFormat.codaBar
            com.google.zxing.BarcodeFormat.RSS_14 -> Protos.BarcodeFormat.gs1DataBar
            com.google.zxing.BarcodeFormat.RSS_EXPANDED -> Protos.BarcodeFormat.gs1DataBarExtended
            else -> Protos.BarcodeFormat.unknown
        }
    }

    fun toBarcodeFormat(format: Int): Protos.BarcodeFormat {
        return when (format) {
            FORMAT_CODE_39 -> Protos.BarcodeFormat.code39
            FORMAT_CODE_93 -> Protos.BarcodeFormat.code93
            FORMAT_CODE_128 -> Protos.BarcodeFormat.code128
            FORMAT_ITF -> Protos.BarcodeFormat.itf
            FORMAT_UPC_E -> Protos.BarcodeFormat.upce
            FORMAT_EAN_8 -> Protos.BarcodeFormat.ean8
            FORMAT_EAN_13 -> Protos.BarcodeFormat.ean13
            FORMAT_QR_CODE -> Protos.BarcodeFormat.qr
            FORMAT_PDF417 -> Protos.BarcodeFormat.pdf417
            FORMAT_DATA_MATRIX -> Protos.BarcodeFormat.dataMatrix
            FORMAT_AZTEC -> Protos.BarcodeFormat.aztec
            FORMAT_CODABAR -> Protos.BarcodeFormat.codaBar
           else -> Protos.BarcodeFormat.unknown
        }
    }
}
