package com.anhlp.barcode_scanner.scanner

import android.graphics.Bitmap
import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageProxy
import com.anhlp.barcode_scanner.Protos
import com.anhlp.barcode_scanner.scanner.implements.MlKitBarcodeScanner
import com.anhlp.barcode_scanner.scanner.implements.ZXingBarcodeScanner

class BarcodeScanner {
    private var formats: List<Protos.BarcodeFormat> = emptyList()

    private var mlKitBarcodeScanner: MlKitBarcodeScanner = MlKitBarcodeScanner()
    private var zxingBarcodeScanner: ZXingBarcodeScanner = ZXingBarcodeScanner()

    fun setFormats(formats: List<Protos.BarcodeFormat>) {
        this.formats = formats
        mlKitBarcodeScanner.setFormats(formats)
        zxingBarcodeScanner.setFormats(formats)
    }

    @OptIn(ExperimentalGetImage::class)
    fun process(imageProxy: ImageProxy): List<Protos.BarcodeResult> {
        imageProxy.use {
            val bitmap = imageProxy.toBitmap()
            val rotationDegrees = it.imageInfo.rotationDegrees
            var barcodes =
                mlKitBarcodeScanner.process(bitmap, rotationDegrees)

            if (barcodes.isEmpty()) {
                barcodes = zxingBarcodeScanner.process(bitmap, rotationDegrees)
            }

            return barcodes
        }
    }

    fun process(bitmap: Bitmap,  rotationDegrees: Int = 0): List<Protos.BarcodeResult> {
        var barcodes =
            mlKitBarcodeScanner.process(bitmap, rotationDegrees)

        if (barcodes.isEmpty()) {
            barcodes = zxingBarcodeScanner.process(bitmap, rotationDegrees)
        }
        return barcodes
    }
}