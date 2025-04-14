package com.anhlp.barcode_scanner.mappers

import android.graphics.RectF
import com.anhlp.barcode_scanner.Protos

object RectFMapper {
    fun toRectF(rect: Protos.Rect): RectF {
        return RectF(rect.left, rect.top, rect.right, rect.bottom)
    }
}