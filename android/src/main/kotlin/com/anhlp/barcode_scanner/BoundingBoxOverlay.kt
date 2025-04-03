package com.anhlp.barcode_scanner

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Rect
import android.graphics.RectF
import android.view.View

class BoundingBoxOverlay(context: Context) : View(context) {
    private val path = Path()

    private val paint = Paint().apply {
        color = android.graphics.Color.GREEN
        style = Paint.Style.STROKE
        strokeWidth = 5f
    }

    private var rect: Rect? = null

    fun clear() {
        rect = null
        invalidate()
    }

    fun setBoundingBox(rectF: RectF, imageWidth: Int, imageHeight: Int) {
        val scaleX = width.toFloat() / imageWidth
        val scaleY = height.toFloat() / imageHeight

        val scale = maxOf(scaleX, scaleY)

        val wLost = (imageWidth * scale - width) / 2f
        val hLost = (imageHeight * scale - height) / 2f

        rect = Rect(
            (scale * rectF.left - wLost).toInt(),
            (scale * rectF.top - hLost).toInt(),
            (scale * rectF.right - wLost).toInt(),
            (scale * rectF.bottom - hLost).toInt()
        )

        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        path.reset()
        rect?.let {canvas.drawRect(it, paint)}
    }
}
