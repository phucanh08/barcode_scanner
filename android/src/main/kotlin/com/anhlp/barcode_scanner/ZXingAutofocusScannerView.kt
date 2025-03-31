package com.anhlp.barcode_scanner

import android.content.Context
import android.graphics.Rect
import android.hardware.Camera
import me.dm7.barcodescanner.core.CameraWrapper
import me.dm7.barcodescanner.core.IViewFinder
import me.dm7.barcodescanner.core.ViewFinderView
import me.dm7.barcodescanner.zxing.ZXingScannerView

class ZXingAutofocusScannerView(context: Context) : ZXingScannerView(context) {

    private var callbackFocus = false
    private var autofocusPresence = false

    override fun setupCameraPreview(cameraWrapper: CameraWrapper?) {
        cameraWrapper?.mCamera?.parameters?.let { parameters ->
            try {
                autofocusPresence =
                    parameters.supportedFocusModes.contains(Camera.Parameters.FOCUS_MODE_AUTO);
                parameters.focusMode = Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE
                cameraWrapper.mCamera.parameters = parameters
            } catch (ex: Exception) {
                callbackFocus = true
            }
        }

        super.setupCameraPreview(cameraWrapper)
    }

    override fun setAutoFocus(state: Boolean) {
        if (autofocusPresence) {
            super.setAutoFocus(callbackFocus)
        }
    }
}
