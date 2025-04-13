package com.anhlp.barcode_scanner.platform_view

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.anhlp.barcode_scanner.BarcodeScannerPlugin

class PermissionManager() {
    fun checkAndRequestCameraPermission(onResult: (Boolean) -> Unit) {
        val activity = BarcodeScannerPlugin.Companion.getActivity()
        if (activity == null) {
            onResult(false)
            return
        }
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            onResult(true)
            return
        }
        permissionCallbacks[CAMERA_PERMISSION_REQUEST_CODE] = onResult
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.CAMERA),
            CAMERA_PERMISSION_REQUEST_CODE
        )
    }

    companion object {
        private const val CAMERA_PERMISSION_REQUEST_CODE = 1001

        private val permissionCallbacks = mutableMapOf<Int, (Boolean) -> Unit>()

        fun onRequestPermissionsResult(
            requestCode: Int,
            grantResults: IntArray
        ): Boolean {
            if (permissionCallbacks[requestCode] != null) {
                permissionCallbacks[requestCode]?.invoke(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
                permissionCallbacks.remove(requestCode)
                return true
            }

            return false
        }
    }
}