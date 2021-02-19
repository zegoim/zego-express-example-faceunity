package im.zego.expressample.faceu.demo.process;

import android.graphics.SurfaceTexture;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.Surface;


import java.nio.ByteBuffer;
import java.util.concurrent.CountDownLatch;

import im.zego.expressample.faceu.demo.faceunity.FURenderer;
import im.zego.expressample.faceu.demo.util.ZegoUtil;
import im.zego.expressample.faceu.demo.ve_gl.EglBase;
import im.zego.expressample.faceu.demo.ve_gl.EglBase14;
import im.zego.expressample.faceu.demo.ve_gl.GlRectDrawer;
import im.zego.expressample.faceu.demo.ve_gl.GlUtil;
import im.zego.zegoexpress.ZegoExpressEngine;
import im.zego.zegoexpress.callback.IZegoCustomVideoProcessHandler;
import im.zego.zegoexpress.constants.ZegoPublishChannel;

/**
 * VideoFilterByProcess
 * 通过Zego视频前处理，用户可以获取到Zego SDK采集到的摄像头数据。用户后续将数据塞给FaceUnity处理，最终将处理后的数据塞回Zego SDK进行推流。
 * 采用SURFACE_TEXTURE方式传递数据
 */
/**
 * VideoFilterByProcess
 * Through the Zego video pre-processing, users can obtain the camera data collected by the Zego SDK. The user then stuffs the data to FaceUnity for processing, and finally stuffs the processed data back to Zego SDK for publishing stream.
 *Use SURFACE_TEXTURE to transfer data
 */

public class VideoFilterByProcess extends IZegoCustomVideoProcessHandler implements SurfaceTexture.OnFrameAvailableListener {
    // faceunity 美颜处理类
    private final FURenderer mFuRender;

    private HandlerThread mThread = null;
    private volatile Handler mHandler = null;

    private EglBase mEglContext = null;
    private boolean mIsEgl14 = false;

    private int mOutputWidth = 0;
    private int mOutputHeight = 0;
    private SurfaceTexture mInputSurfaceTexture = null;
    private int mInputTextureId = 0;

    private GlRectDrawer mDrawer = null;
    private Surface mOutputSurface = null;
    private static boolean stopFlag =true;

    private final float[] transformationMatrix = new float[]{
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f
    };

    public VideoFilterByProcess(FURenderer fuRenderer) {
        this.mFuRender = fuRenderer;
        stopFlag=false;
    }




    /**
     * 释放资源
     *
     */
    public void stopAndDeAllocate() {
        stopFlag =true;
        final CountDownLatch barrier = new CountDownLatch(1);
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                release();
                barrier.countDown();
            }
        });

        try {
            barrier.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        mHandler = null;

        mThread.quit();
        mThread = null;
    }




    @Override
    public void onFrameAvailable(SurfaceTexture surfaceTexture) {
        if(stopFlag){
            return;
        }
        if (mInputTextureId == 0) {
            mInputTextureId = GlUtil.generateTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
            surfaceTexture.attachToGLContext(mInputTextureId);
        }

        surfaceTexture.updateTexImage();
        long timestampNs = surfaceTexture.getTimestamp();

        if (mDrawer == null) {
            mDrawer = new GlRectDrawer();
        }

        // 调用 faceunity 进行美颜，美颜后返回纹理 ID
        int textureID = mFuRender.onDrawOesFrame(mInputTextureId, mOutputWidth, mOutputHeight);

        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);

        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
        // 绘制美颜数据
        mDrawer.drawRgb(textureID, transformationMatrix,
                mOutputWidth, mOutputHeight, 0, 0, mOutputWidth, mOutputHeight);

        if (mIsEgl14) {
            ((EglBase14) mEglContext).swapBuffers(timestampNs);
        } else {
            mEglContext.swapBuffers();
        }
    }

    // 设置 Surface
    private void setOutputSurface(SurfaceTexture surfaceTexture, int width, int height) {
        if (mEglContext.hasSurface()) {
            mEglContext.makeCurrent();

            if (mDrawer != null) {
                mDrawer.release();
                mDrawer = null;
            }

            if (mInputTextureId != 0) {
                mInputSurfaceTexture.detachFromGLContext();

                int[] textures = new int[]{mInputTextureId};
                GLES20.glDeleteTextures(1, textures, 0);
                mInputTextureId = 0;
            }

            // 销毁 faceunity 相关的资源
            mFuRender.onSurfaceDestroyed();

            mEglContext.releaseSurface();
            mEglContext.detachCurrent();
        }

        if (mOutputSurface != null) {
            mOutputSurface.release();
            mOutputSurface = null;
        }

        surfaceTexture.setDefaultBufferSize(width, height);

        mOutputSurface = new Surface(surfaceTexture);
        mOutputWidth = width;
        mOutputHeight = height;

        mEglContext.createSurface(mOutputSurface);
        mEglContext.makeCurrent();

        // 创建及初始化 faceunity 相应的资源
        mFuRender.onSurfaceCreated();
    }

    // 释放 openGL 相关资源
    private void release() {
        if (mEglContext.hasSurface()) {
            mEglContext.makeCurrent();

            if (mDrawer != null) {
                mDrawer.release();
                mDrawer = null;
            }

            if (mInputTextureId != 0) {
                mInputSurfaceTexture.detachFromGLContext();

                int[] textures = new int[]{mInputTextureId};
                GLES20.glDeleteTextures(1, textures, 0);
                mInputTextureId = 0;
            }

            // 销毁 faceunity 相关的资源
            mFuRender.onSurfaceDestroyed();
        }
        mEglContext.release();
        mEglContext = null;

        mOutputWidth = 0;
        mOutputHeight = 0;

        if (mOutputSurface != null) {
            mOutputSurface.release();
            mOutputSurface = null;
        }

        if (mInputSurfaceTexture != null) {
            mInputSurfaceTexture.setOnFrameAvailableListener(null);
            mInputSurfaceTexture.release();
            mInputSurfaceTexture = null;
        }
    }

    @Override
    public SurfaceTexture getCustomVideoProcessInputSurfaceTexture(int width, int height, ZegoPublishChannel channel) {
        Log.e(ZegoUtil.VIDEO_FILTER_TAG,"Zego Custom Video Process + SurfaceTexture");
        mThread = new HandlerThread("video-filter");
        mThread.start();
        mHandler = new Handler(mThread.getLooper());

        final CountDownLatch barrier = new CountDownLatch(2);
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mEglContext = EglBase.create(null, EglBase.CONFIG_RECORDABLE);

                // 滤镜 SurfaceTexture
                mInputSurfaceTexture = new SurfaceTexture(0);
                mInputSurfaceTexture.setOnFrameAvailableListener(VideoFilterByProcess.this);
                mInputSurfaceTexture.detachFromGLContext();

                mIsEgl14 = EglBase14.isEGL14Supported();

                barrier.countDown();
            }
        });
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                // 设置 Surface
                setOutputSurface(ZegoExpressEngine.getEngine().getCustomVideoProcessOutputSurfaceTexture(width,height),width,height);
                barrier.countDown();
            }
        });
        try {
            barrier.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return mInputSurfaceTexture;
    }
}



