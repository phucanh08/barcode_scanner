package com.anhlp.barcode_scanner.mappers

import com.anhlp.barcode_scanner.Protos

object BarcodeFormatMapper {
    fun toMlKitBarcodeFormats(formats: List<Protos.BarcodeFormat>): List<Int> {
        val results: MutableList<Int> = mutableListOf<Int>()
        if (formats.contains(Protos.BarcodeFormat.all)) {
            results.add(com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ALL_FORMATS)
        } else {
            formats.forEach { format ->
                results.add(toMlKitBarcodeFormat(format))
            }
        }
        return results
    }

    fun toBarcodeFormat(format: Int): Protos.BarcodeFormat {
        return when (format) {
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_39 -> Protos.BarcodeFormat.code39
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_93 -> Protos.BarcodeFormat.code93
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_128 -> Protos.BarcodeFormat.code128
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ITF -> Protos.BarcodeFormat.itf
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_E -> Protos.BarcodeFormat.upce
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_8 -> Protos.BarcodeFormat.ean8
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_13 -> Protos.BarcodeFormat.ean13
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_QR_CODE -> Protos.BarcodeFormat.qr
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_PDF417 -> Protos.BarcodeFormat.pdf417
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_DATA_MATRIX -> Protos.BarcodeFormat.dataMatrix
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_AZTEC -> Protos.BarcodeFormat.aztec
            com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODABAR -> Protos.BarcodeFormat.codaBar
            else -> Protos.BarcodeFormat.unknown
        }
    }

    fun toMlKitBarcodeFormat(format: Protos.BarcodeFormat): Int {
        return when (format) {
            Protos.BarcodeFormat.code39 -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_39
            Protos.BarcodeFormat.code93 -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_93
            Protos.BarcodeFormat.code128 -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_128
            Protos.BarcodeFormat.itf -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ITF
            Protos.BarcodeFormat.upce -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_E
            Protos.BarcodeFormat.ean8 -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_8
            Protos.BarcodeFormat.ean13 -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_13
            Protos.BarcodeFormat.qr -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_QR_CODE
            Protos.BarcodeFormat.pdf417 -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_PDF417
            Protos.BarcodeFormat.dataMatrix -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_DATA_MATRIX
            Protos.BarcodeFormat.aztec -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_AZTEC
            Protos.BarcodeFormat.codaBar -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODABAR
            else -> com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UNKNOWN
        }
    }


    fun toZXingBarcodeFormats(formats: List<Protos.BarcodeFormat>): List<com.google.zxing.BarcodeFormat> {
        val results: MutableList<com.google.zxing.BarcodeFormat> = mutableListOf()
        formats.forEach { format ->
            val barcodeFormat = toZXingBarcodeFormat(format)
            if (barcodeFormat != null) {
                results.add(barcodeFormat)
            }
        }
        return results
    }

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

    fun toZXingBarcodeFormat(format: Protos.BarcodeFormat): com.google.zxing.BarcodeFormat? {
        return when (format) {
            Protos.BarcodeFormat.code39 -> com.google.zxing.BarcodeFormat.CODE_39
            Protos.BarcodeFormat.code93 -> com.google.zxing.BarcodeFormat.CODE_93
            Protos.BarcodeFormat.code128 -> com.google.zxing.BarcodeFormat.CODE_128
            Protos.BarcodeFormat.itf -> com.google.zxing.BarcodeFormat.ITF
            Protos.BarcodeFormat.upce -> com.google.zxing.BarcodeFormat.UPC_E
            Protos.BarcodeFormat.ean8 -> com.google.zxing.BarcodeFormat.EAN_8
            Protos.BarcodeFormat.ean13 -> com.google.zxing.BarcodeFormat.EAN_13
            Protos.BarcodeFormat.qr -> com.google.zxing.BarcodeFormat.QR_CODE
            Protos.BarcodeFormat.pdf417 -> com.google.zxing.BarcodeFormat.PDF_417
            Protos.BarcodeFormat.dataMatrix -> com.google.zxing.BarcodeFormat.DATA_MATRIX
            Protos.BarcodeFormat.aztec -> com.google.zxing.BarcodeFormat.AZTEC
            Protos.BarcodeFormat.codaBar -> com.google.zxing.BarcodeFormat.CODABAR
            Protos.BarcodeFormat.gs1DataBar -> com.google.zxing.BarcodeFormat.RSS_14
            Protos.BarcodeFormat.gs1DataBarExtended -> com.google.zxing.BarcodeFormat.RSS_EXPANDED
            else -> null
        }
    }
}
