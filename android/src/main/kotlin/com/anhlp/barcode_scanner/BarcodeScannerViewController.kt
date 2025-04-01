package com.anhlp.barcode_scanner

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Size
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageAnalysis.Analyzer
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class BarcodeScannerViewController(private val context: Context, private val analyzer: Analyzer) {
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalyzer: ImageAnalysis? = null
    private val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
    private var backgroundExecutor: ExecutorService? = null
    private val rotation: Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) context.display.rotation else (context.getSystemService(
            Context.WINDOW_SERVICE
        ) as WindowManager).defaultDisplay.rotation
    private val previewUseCase: Preview
    val previewView: PreviewView = PreviewView(context)
    var isPauseCamera = false

    init {
        previewUseCase = Preview.Builder()
            .setTargetRotation(rotation)
            .build().also {
                it.surfaceProvider = previewView.surfaceProvider
            }
        startCamera()
    }

    fun stopCamera() {
        cameraProvider?.unbindAll()
        backgroundExecutor?.shutdown()
        backgroundExecutor = null
    }


    fun startCamera() {
        val lifecycleOwner = getLifecycleOwner()
        if (lifecycleOwner == null) return
        backgroundExecutor?.shutdown()
        backgroundExecutor = Executors.newSingleThreadExecutor()
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()
                bindCameraUseCases(lifecycleOwner)
            } catch (e: Exception) {
                Log.e("NativeView", "Failed to get camera provider", e)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    fun pauseCameraPreview() {
        if(isPauseCamera) return
        isPauseCamera = true
//        Handler(Looper.getMainLooper()).postDelayed({
//            cameraProvider?.unbindAll()
//        }, 100)
    }

    fun resumeCameraPreview() {
//        val lifecycleOwner = getLifecycleOwner()
//        if (lifecycleOwner == null) return
//        cameraProvider?.bindToLifecycle(
//            lifecycleOwner,
//            cameraSelector,
//            previewUseCase,
//            imageAnalyzer
//        )
        isPauseCamera = false
    }

    private fun bindCameraUseCases(lifecycleOwner: LifecycleOwner) {
        try {
            val resolutionSelector = ResolutionSelector.Builder()
                .setResolutionStrategy(
                    ResolutionStrategy(
                        Size(1920, 1080),
                        ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER
                    )
                )
                .setAspectRatioStrategy(AspectRatioStrategy.RATIO_16_9_FALLBACK_AUTO_STRATEGY)
                .build()

            imageAnalyzer = ImageAnalysis.Builder()
                .setResolutionSelector(resolutionSelector)
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setTargetRotation(rotation)
                .setOutputImageRotationEnabled(true)
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
                .build()
                .also {
                    backgroundExecutor?.let { backgroundExecutor ->
                        it.setAnalyzer(backgroundExecutor, analyzer)
                    }
                }

            cameraProvider?.unbindAll()

            cameraProvider?.bindToLifecycle(
                lifecycleOwner,
                cameraSelector,
                previewUseCase,
                imageAnalyzer
            )
            Log.d(TAG, "Camera bound successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Use case binding failed", e)
        }
    }

    private fun getLifecycleOwner(): LifecycleOwner? {
        val context = this.context

        if (context is LifecycleOwner) {
            return context
        }

        while (context is android.content.ContextWrapper) {
            return context.baseContext as LifecycleOwner?
        }

        return null
    }

    companion object {
        private const val TAG = "BarcodeScannerViewController"
    }
}