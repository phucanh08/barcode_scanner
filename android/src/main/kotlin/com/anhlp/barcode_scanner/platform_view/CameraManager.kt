package com.anhlp.barcode_scanner.platform_view

import android.content.Context
import android.os.Build
import android.util.Log
import android.util.Size
import android.view.WindowManager
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.core.TorchState
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.anhlp.barcode_scanner.Protos
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class CameraManager(private val context: Context) {
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalyzer: ImageAnalysis? = null
    private var cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
    private var backgroundExecutor: ExecutorService? = null
    private val rotation: Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) context.display.rotation else (context.getSystemService(
            Context.WINDOW_SERVICE
        ) as WindowManager).defaultDisplay.rotation
    private val previewUseCase: Preview
    val previewView: PreviewView = PreviewView(context)
    var isPauseCamera = false

    private var resolutionSize: Size = Size(1280, 720)

    private var camera: androidx.camera.core.Camera? = null

    var delegate: CameraStreamDelegate? = null

    init {
        previewUseCase = Preview.Builder()
            .setTargetRotation(rotation)
            .build().also {
                it.surfaceProvider = previewView.surfaceProvider
            }
    }

    fun setCameraSetting(setting: Protos.CameraSettings) {
        setResolutionPreset(setting.resolutionPreset)
        setCameraPosition(setting.cameraPosition)
    }

    fun setResolutionPreset(resolutionPreset: Protos.ResolutionPreset) {
        resolutionSize = when (resolutionPreset) {
            Protos.ResolutionPreset.hd1280x720 -> Size(1280, 720)
            Protos.ResolutionPreset.hd1920x1080 -> Size(1920, 1080)
            else -> Size(1280, 720)
        }
    }

    fun setCameraPosition(cameraPosition: Protos.CameraPosition) {
        cameraSelector = when (cameraPosition) {
            Protos.CameraPosition.front -> CameraSelector.DEFAULT_FRONT_CAMERA
            Protos.CameraPosition.back -> CameraSelector.DEFAULT_BACK_CAMERA
            else -> CameraSelector.DEFAULT_BACK_CAMERA
        }
    }


    /**
     * Kiểm tra xem đèn flash có đang bật không
     * @return true nếu đèn flash đang bật, false nếu đang tắt
     */
    fun isFlashOn(): Boolean {
        return camera?.cameraInfo?.torchState?.value == TorchState.ON
    }

    /**
     * Bật/tắt đèn flash
     * @return trạng thái đèn flash sau khi thay đổi (true: bật, false: tắt)
     */
    fun toggleFlash(): Boolean {
        val camera = this.camera ?: return false

        val enableTorch = camera.cameraInfo.torchState.value != TorchState.ON
        camera.cameraControl.enableTorch(enableTorch)
        return enableTorch
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
        if (isPauseCamera) return
        isPauseCamera = true
    }

    fun resumeCameraPreview() {
        isPauseCamera = false
    }

    private fun bindCameraUseCases(lifecycleOwner: LifecycleOwner) {
        try {
            val resolutionSelector = ResolutionSelector.Builder()
                .setResolutionStrategy(
                    ResolutionStrategy(
                        resolutionSize,
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
                        it.setAnalyzer(backgroundExecutor, this::didReceiveFrame)
                    }
                }

            cameraProvider?.unbindAll()

            camera = cameraProvider?.bindToLifecycle(
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

    private fun didReceiveFrame(imageProxy: ImageProxy) {
        if (delegate == null) {
            imageProxy.close()
            return
        }

        delegate?.didReceiveFrame(imageProxy)
    }

    companion object {
        private const val TAG = "BarcodeScannerViewController"
    }
}

interface CameraStreamDelegate {
    fun didReceiveFrame(imageProxy: ImageProxy)
}
