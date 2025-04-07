package com.anhlp.barcode_scanner.scanner.implements

import android.graphics.Bitmap
import android.media.Image
import com.anhlp.barcode_scanner.Protos
import com.anhlp.barcode_scanner.mappers.BarcodeMapper
import com.anhlp.barcode_scanner.scanner.interfaces.IBarcodeScanner
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode.*
import com.google.mlkit.vision.common.InputImage


class MlKitBarcodeScanner : IBarcodeScanner {
    private var formats: List<Int> = emptyList()
    private var mlKitBarcodeScanner: BarcodeScanner? = null

    override fun setFormats(formats: List<Protos.BarcodeFormat>) {
        this.formats = formats.map {
            when (it) {
                Protos.BarcodeFormat.all -> FORMAT_ALL_FORMATS
                Protos.BarcodeFormat.aztec -> FORMAT_AZTEC
                Protos.BarcodeFormat.codaBar -> FORMAT_CODABAR
                Protos.BarcodeFormat.code128 -> FORMAT_CODE_128
                Protos.BarcodeFormat.code39 -> FORMAT_CODE_39
                Protos.BarcodeFormat.code93 -> FORMAT_CODE_93
                Protos.BarcodeFormat.itf -> FORMAT_ITF
                Protos.BarcodeFormat.upce -> FORMAT_UPC_E
                Protos.BarcodeFormat.ean8 -> FORMAT_EAN_8
                Protos.BarcodeFormat.ean13 -> FORMAT_EAN_13
                Protos.BarcodeFormat.qr -> FORMAT_QR_CODE
                Protos.BarcodeFormat.pdf417 -> FORMAT_PDF417
                Protos.BarcodeFormat.dataMatrix -> FORMAT_DATA_MATRIX
                else -> FORMAT_UNKNOWN
            }
        }
        mlKitBarcodeScanner = BarcodeScanning.getClient()
    }

    override fun process(image: Image, rotationDegrees: Int): List<Protos.BarcodeResult> {
        if (mlKitBarcodeScanner != null) {
            val inputImage = InputImage.fromMediaImage(image, rotationDegrees)
            val barcodes = Tasks.await(mlKitBarcodeScanner!!.process(inputImage))
            if (barcodes.isNotEmpty()) {
                barcodes[0].cornerPoints
                return BarcodeMapper.toBarcodes(barcodes)
            }
        }
        return emptyList()
    }

    override fun process(bitmap: Bitmap, rotationDegrees: Int): List<Protos.BarcodeResult> {
        if (mlKitBarcodeScanner != null) {
            val inputImage = InputImage.fromBitmap(bitmap, rotationDegrees)
            val barcodes = Tasks.await(mlKitBarcodeScanner!!.process(inputImage))
            if (barcodes.isNotEmpty()) {
                barcodes[0].cornerPoints
                return BarcodeMapper.toBarcodes(barcodes)
            }
        }
        return emptyList()
    }
}