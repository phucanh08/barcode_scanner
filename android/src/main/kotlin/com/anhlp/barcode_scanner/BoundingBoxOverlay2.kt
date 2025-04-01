package com.anhlp.barcode_scanner

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PointF
import android.graphics.Rect
import android.view.View
import kotlin.math.atan2

class BoundingBoxOverlay2(context: Context) : View(context) {
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
//        boundingBox?.let { points ->
//            if (points.size == 4) {
//
//                // Tính toán tâm của các điểm
//                val centerX = points.sumOf { it.x.toDouble() } / points.size
//                val centerY = points.sumOf { it.y.toDouble() } / points.size
//
//                // Sắp xếp các điểm theo góc so với tâm
//                val sortedPoints = points.sortedBy { point ->
//                    atan2(point.y - centerY, point.x - centerX)
//                }
//
//                // Vẽ polygon theo thứ tự đã sắp xếp
//                path.moveTo(sortedPoints[0].x, sortedPoints[0].y)
//                sortedPoints.forEach { point -> path.lineTo(point.x, point.y) }
//                path.close()
//
//                canvas.drawPath(path, paint)
//            }
//        }
    }
}

class BoundingBoxOverlay(context: Context) : View(context) {
    private val path = Path()

    private val paint = Paint().apply {
        color = android.graphics.Color.GREEN
        style = Paint.Style.STROKE
        strokeWidth = 5f
    }

    private var boundingBox: List<PointF>? = null

    fun setBoundingBox(points: List<PointF>?) {
        boundingBox = points
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        path.reset()
        boundingBox?.let { points ->
            if (points.size == 4) {

                // Tính toán tâm của các điểm
                val centerX = points.sumOf { it.x.toDouble() } / points.size
                val centerY = points.sumOf { it.y.toDouble() } / points.size

                // Sắp xếp các điểm theo góc so với tâm
                val sortedPoints = points.sortedBy { point ->
                    atan2(point.y - centerY, point.x - centerX)
                }

                // Vẽ polygon theo thứ tự đã sắp xếp
                path.moveTo(sortedPoints[0].x, sortedPoints[0].y)
                sortedPoints.forEach { point -> path.lineTo(point.x, point.y) }
                path.close()

                canvas.drawPath(path, paint)
            }
        }
    }
}

