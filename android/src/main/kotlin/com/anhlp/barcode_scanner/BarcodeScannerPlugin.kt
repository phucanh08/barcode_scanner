package com.anhlp.barcode_scanner

import android.app.Activity
import com.anhlp.barcode_scanner.platform_view.BarcodeScannerViewFactory
import com.anhlp.barcode_scanner.platform_view.PermissionManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry

class BarcodeScannerPlugin : FlutterPlugin, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = binding
        binding.platformViewRegistry
            .registerViewFactory(
                "barcode_scanner_view",
                BarcodeScannerViewFactory()
            )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = binding
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.removeRequestPermissionsResultListener(this)
        activityPluginBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityPluginBinding?.removeRequestPermissionsResultListener(this)
        activityPluginBinding = null
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String?>,
        grantResults: IntArray
    ): Boolean {
        return PermissionManager.onRequestPermissionsResult(
            requestCode,
            grantResults
        )
    }

    companion object {
        private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
        private var activityPluginBinding: ActivityPluginBinding? = null

        fun getBinaryMessenger(): BinaryMessenger = flutterPluginBinding.binaryMessenger
        fun getActivity(): Activity? = activityPluginBinding?.activity
    }
}