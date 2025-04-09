package com.anhlp.barcode_scanner.scanner.implements

import android.graphics.Bitmap
import android.media.Image
import com.anhlp.barcode_scanner.Protos
import com.anhlp.barcode_scanner.mappers.BarcodeFormatMapper
import com.anhlp.barcode_scanner.mappers.BarcodeMapper
import com.anhlp.barcode_scanner.scanner.interfaces.IBarcodeScanner
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage


class MlKitBarcodeScanner : IBarcodeScanner {
    private var formats: List<Int> = emptyList()
    private var mlKitBarcodeScanner: BarcodeScanner? = null

    override fun setFormats(formats: List<Protos.BarcodeFormat>) {
        this.formats = BarcodeFormatMapper.toMlKitBarcodeFormats(formats)
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