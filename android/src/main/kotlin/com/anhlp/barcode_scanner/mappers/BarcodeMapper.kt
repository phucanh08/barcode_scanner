package com.anhlp.barcode_scanner.mappers

import com.anhlp.barcode_scanner.Protos

object BarcodeMapper {
    fun toBarcodes(barcodes: List<com.google.mlkit.vision.barcode.common.Barcode>): List<Protos.BarcodeResult> {
        return barcodes.map { toBarcode(it) }
    }

    private fun toBarcode(barcode: com.google.mlkit.vision.barcode.common.Barcode): Protos.BarcodeResult {
        val format = BarcodeFormatMapper.toBarcodeFormat(barcode.format)
        val boundingBox = Protos.Rect.newBuilder()
            .setLeft(barcode.boundingBox?.left?.toFloat() ?: 0f)
            .setTop(barcode.boundingBox?.top?.toFloat() ?: 0f)
            .setRight(barcode.boundingBox?.right?.toFloat() ?: 0f)
            .setBottom(barcode.boundingBox?.bottom?.toFloat() ?: 0f)
            .build()

        val builder = Protos.BarcodeResult.newBuilder()
        builder.setFormat(format)
        builder.setRawValue(barcode.rawValue)
        builder.setBoundingBox(boundingBox)
        for (e in barcode.cornerPoints!!) {
            val cornerPointsBuilder = Protos.Point.newBuilder()
            cornerPointsBuilder.setX(e.x.toFloat())
            cornerPointsBuilder.setY(e.y.toFloat())
            builder.addCornerPoints(cornerPointsBuilder.build())
        }
        builder.setTimestamp(System.currentTimeMillis() / 1000)
        return builder.build()
    }

    fun toBarcode(barcode: com.google.zxing.Result): Protos.BarcodeResult {
        val format = BarcodeFormatMapper.toBarcodeFormat(barcode.barcodeFormat)
        val boundingBox =
            barcode.resultPoints?.filterNotNull()?.takeIf { it.size >= 4 }?.let { points ->
                val xs = points.map { it.x }
                val ys = points.map { it.y }
                Protos.Rect.newBuilder()
                    .setLeft(xs.minOrNull() ?: 0f)
                    .setTop(ys.minOrNull() ?: 0f)
                    .setRight(xs.maxOrNull() ?: 0f)
                    .setBottom(ys.maxOrNull() ?: 0f)
                    .build()
            }

        val builder = Protos.BarcodeResult.newBuilder()
        builder.setFormat(format)
        builder.setRawValue(barcode.text)
        builder.setBoundingBox(boundingBox)
        for (e in barcode.resultPoints) {
            val cornerPointsBuilder = Protos.Point.newBuilder()
            cornerPointsBuilder.setX(e.x)
            cornerPointsBuilder.setY(e.y)
            builder.addCornerPoints(cornerPointsBuilder.build())
        }
        builder.setTimestamp(System.currentTimeMillis() / 1000)
        return builder.build()
    }
}