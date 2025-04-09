package com.anhlp.barcode_scanner.scanner.interfaces

import android.graphics.Bitmap
import android.media.Image
import com.anhlp.barcode_scanner.Protos

interface IBarcodeScanner {
    fun setFormats(formats: List<Protos.BarcodeFormat>)

    fun process(bitmap: Bitmap, rotationDegrees: Int): List<Protos.BarcodeResult> {
        throw Exception("Barcode processing with bitmap not implemented")
    }

    fun process(image: Image, rotationDegrees: Int): List<Protos.BarcodeResult> {
        throw Exception("Barcode processing with image proxy not implemented")
    }

}