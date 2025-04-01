package com.anhlp.barcode_scanner

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.hardware.Camera
import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.MultiFormatReader
import com.google.zxing.NotFoundException
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import me.dm7.barcodescanner.core.CameraWrapper
import me.dm7.barcodescanner.zxing.ZXingScannerView

class ZXingAutofocusScannerView(context: Context) : ZXingScannerView(context) {
    private var mMultiFormatReader: MultiFormatReader? = null
    private var callbackFocus = false
    private var autofocusPresence = false
    var rect: Rect? = null

    init {
        initMultiFormatReader()
    }

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

    public override fun resumeCameraPreview() {
        super.resumeCameraPreview()
    }

    @Synchronized
    override fun getFramingRectInPreview(previewWidth: Int, previewHeight: Int): Rect? {
        rect = super.getFramingRectInPreview(previewWidth, previewHeight)
        return rect
    }

    private fun initMultiFormatReader() {
        val hints: MutableMap<DecodeHintType?, Any?> = mutableMapOf()
        hints.put(DecodeHintType.POSSIBLE_FORMATS, this.formats)
        this.mMultiFormatReader = MultiFormatReader()
        this.mMultiFormatReader!!.setHints(hints)
    }

    @OptIn(DelicateCoroutinesApi::class)
    override fun onPreviewFrame(data: ByteArray?, camera: Camera?) {
        GlobalScope.launch(Dispatchers.IO) {
            super.onPreviewFrame(data, camera)
        }
    }

    @OptIn(DelicateCoroutinesApi::class)
    fun detectBarcodesByImagePath(imagePath: String, result: MethodChannel.Result) {
        GlobalScope.launch(Dispatchers.IO) {
            try {
                val bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
                    result.error("INVALID_IMAGE", "Không thể đọc ảnh từ đường dẫn", null)
                    return@launch
                }

                val width = bitmap.width
                val height = bitmap.height
                val pixels = IntArray(width * height)
                bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

                val source = RGBLuminanceSource(width, height, pixels)
                val binaryBitmap = BinaryBitmap(HybridBinarizer(source))

                val multiFormatReader = mMultiFormatReader ?: run {
                    result.error("READER_ERROR", "Trình quét mã vạch chưa được khởi tạo", null)
                    return@launch
                }

                try {
                    val rawResult = multiFormatReader.decodeWithState(binaryBitmap)
                        ?: multiFormatReader.decodeWithState(BinaryBitmap(HybridBinarizer(source.invert())))

                    if (rawResult != null) {
                        result.success(listOf(rawResult.text))
                    } else {
                        result.error("NO_BARCODE", "Không tìm thấy mã vạch trong ảnh", null)
                    }
                } catch (_: NotFoundException) {
                    result.error("NO_BARCODE", "Không tìm thấy mã vạch trong ảnh", null)
                } catch (e: Exception) {
                    result.error("SCAN_ERROR", "Lỗi khi quét mã vạch: ${e.message}", null)
                } finally {
                    multiFormatReader.reset()
                }
            } catch (e: Exception) {
                result.error("SCAN_ERROR", "Lỗi khi xử lý ảnh: ${e.message}", null)
            }
        }
    }
}