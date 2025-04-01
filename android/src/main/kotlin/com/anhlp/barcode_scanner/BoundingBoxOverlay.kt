package com.anhlp.barcode_scanner

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Rect
import android.view.View

class BoundingBoxOverlay(context: Context) : View(context) {
    private val path = Path()

    private val paint = Paint().apply {
        color = android.graphics.Color.GREEN
        style = Paint.Style.STROKE
        strokeWidth = 5f
    }

    private var boundingBox: Rect? = null

    fun setBoundingBox(rect: Rect?) {
        boundingBox = rect
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        path.reset()
        boundingBox?.let {canvas.drawRect(it, paint)}
    }
}
