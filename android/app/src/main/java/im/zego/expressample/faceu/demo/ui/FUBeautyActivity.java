package im.zego.expressample.faceu.demo.ui;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewStub;
import android.widget.Toast;

import androidx.databinding.DataBindingUtil;


import org.json.JSONObject;

import java.util.Date;


import im.zego.expressample.faceu.demo.GetAppIDConfig;
import im.zego.expressample.faceu.demo.capture.VideoCaptureFromCamera;
import im.zego.expressample.faceu.demo.capture.VideoCaptureFromCamera2;
import im.zego.expressample.faceu.demo.faceunity.FURenderer;
import im.zego.expressample.faceu.demo.util.ZegoUtil;
import im.zego.expressample.faceu.demo.view.BeautyControlView;
import im.zego.expressample.faceu.demo.view.CustomDialog;
import im.zego.expresssample.faceu.demo.R;
import im.zego.expresssample.faceu.demo.databinding.ActivityFuBaseBinding;
import im.zego.zegoexpress.ZegoExpressEngine;
import im.zego.zegoexpress.callback.IZegoCustomVideoCaptureHandler;
import im.zego.zegoexpress.callback.IZegoDestroyCompletionCallback;
import im.zego.zegoexpress.callback.IZegoEventHandler;
import im.zego.zegoexpress.constants.ZegoPublishChannel;
import im.zego.zegoexpress.constants.ZegoPublisherState;
import im.zego.zegoexpress.constants.ZegoRoomState;
import im.zego.zegoexpress.constants.ZegoScenario;
import im.zego.zegoexpress.constants.ZegoVideoBufferType;
import im.zego.zegoexpress.entity.ZegoCanvas;
import im.zego.zegoexpress.entity.ZegoCustomVideoCaptureConfig;
import im.zego.zegoexpress.entity.ZegoUser;


/**
 * 带美颜的推流界面
 */

public class FUBeautyActivity extends Activity implements FURenderer.OnTrackingStatusChangedListener {
    public final static String TAG = FUBeautyActivity.class.getSimpleName();

    private ActivityFuBaseBinding binding;

    private ViewStub mBottomViewStub;
    private BeautyControlView mBeautyControlView;

    // faceunity 美颜相关的封装类
    protected FURenderer mFURenderer;

    // 房间 ID
    private String mRoomID = "";

    // 主播流名
    private String anchorStreamID = ZegoUtil.getPublishStreamID();

    private FilterType chooseFilterType;
    private ZegoExpressEngine engine;
    private ZegoVideoBufferType videoBufferType;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = DataBindingUtil.setContentView(this, R.layout.activity_fu_base);

        mBottomViewStub = (ViewStub) findViewById(R.id.fu_base_bottom);
        mBottomViewStub.setInflatedId(R.id.fu_base_bottom);

        binding.goBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        // 创建 faceUnity 美颜实例
        mFURenderer = new FURenderer
                .Builder(this)
                .maxFaces(4)
                .inputTextureType(0)
                .setOnTrackingStatusChangedListener(this)
                .build();

        mBottomViewStub.setLayoutResource(R.layout.layout_fu_beauty);
        mBottomViewStub.inflate();

        mBeautyControlView = (BeautyControlView) findViewById(R.id.fu_beauty_control);

        mRoomID = getIntent().getStringExtra("roomID");
        chooseFilterType = (FilterType) getIntent().getSerializableExtra("FilterType");

        mBeautyControlView.setOnFUControlListener(mFURenderer);
        videoBufferType=ZegoVideoBufferType.getZegoVideoBufferType(getIntent().getIntExtra("videoBufferType", 0));
        // 初始化SDK
        initSDK();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (mBeautyControlView.isShown()) {
            mBeautyControlView.hideBottomLayoutAnimator();
        }
        return super.onTouchEvent(event);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mBeautyControlView != null) {
            mBeautyControlView.onResume();
        }
    }

    @Override
    public void finish() {
        super.finish();
        if (videoCaptureFromCamera != null) {
            videoCaptureFromCamera.onStop(ZegoPublishChannel.MAIN);
        }
        ZegoExpressEngine.getEngine().setCustomVideoCaptureHandler(null);
        // 停止预览
        ZegoExpressEngine.getEngine().stopPreview();

        // 在退出页面时停止推流
        ZegoExpressEngine.getEngine().stopPublishingStream();

        // 登出房间
        ZegoExpressEngine.getEngine().logoutRoom(mRoomID);

        ZegoExpressEngine.getEngine().setEventHandler(null);

    }

    // 前处理传递数据的类型枚举
    public enum FilterType {
        FilterType_SurfaceTexture
    }

    /**
     * 供其他Activity调用，进入本专题的方法
     *
     * @param activity
     */
    public static void actionStart(Activity activity, String roomID) {
        Intent intent = new Intent(activity, FUBeautyActivity.class);
        intent.putExtra("roomID", roomID);
        // intent.putExtra("FilterType", filterType);
        activity.startActivity(intent);
    }

    IZegoCustomVideoCaptureHandler videoCaptureFromCamera;

    /**
     * 初始化SDK逻辑
     * 初始化成功后登录房间并推流
     */
    private void initSDK() {

        Log.i("ZegoExpressEngine Version", ZegoExpressEngine.getVersion());

        // 设置外部滤镜---必须在初始化 ZEGO SDK 之前设置，否则不会回调   SyncTexture
        engine=ZegoExpressEngine.createEngine(GetAppIDConfig.appID, GetAppIDConfig.appSign, true, ZegoScenario.LIVE, this.getApplication(), null);
        //  if (FilterType.FilterType_SurfaceTexture == chooseFilterType) {
        if(videoBufferType==ZegoVideoBufferType.SURFACE_TEXTURE){
            videoCaptureFromCamera=new VideoCaptureFromCamera2((mFURenderer));
        }else if(videoBufferType==ZegoVideoBufferType.RAW_DATA){
            videoCaptureFromCamera = new VideoCaptureFromCamera(mFURenderer);
        }
        ZegoCustomVideoCaptureConfig zegoCustomVideoCaptureConfig=new ZegoCustomVideoCaptureConfig();
        zegoCustomVideoCaptureConfig.bufferType=videoBufferType;
        engine.enableCustomVideoCapture(true,zegoCustomVideoCaptureConfig);

        //videoCaptureFromCamera.setView();
        ZegoExpressEngine.getEngine().setCustomVideoCaptureHandler(videoCaptureFromCamera);
        // }
        // 初始化成功，登录房间并推流
        startPublish();

    }

    public void startPublish() {

        // 防止用户点击，弹出加载对话框
        CustomDialog.createDialog("登录房间中...", this).show();

        String randomSuffix = String.valueOf(new Date().getTime() % (new Date().getTime() / 1000));
        String userID = "user" + randomSuffix;
        String userName = "user" + randomSuffix;
        ZegoExpressEngine.getEngine().loginRoom(mRoomID, new ZegoUser(userID, userName));

        ZegoExpressEngine.getEngine().setEventHandler(new IZegoEventHandler() {

            @Override
            public void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode, JSONObject extendedData) {
                CustomDialog.createDialog(FUBeautyActivity.this).cancel();
                if (errorCode == 0) {

                    ZegoExpressEngine.getEngine().startPreview(new ZegoCanvas(binding.preview));
                    // 开始推流
                    ZegoExpressEngine.getEngine().startPublishingStream(anchorStreamID);
                } else {

                    Toast.makeText(FUBeautyActivity.this, "login room failure", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onPublisherStateUpdate(String streamID, ZegoPublisherState state, int errorCode, JSONObject extendedData) {
                // 推流状态更新，errorCode 非0 则说明推流失败
                // 推流常见错误码请看文档: <a>https://doc.zego.im/CN/308.html</a>

                if (errorCode == 0) {

                    Toast.makeText(FUBeautyActivity.this, getString(R.string.tx_publish_success), Toast.LENGTH_SHORT).show();
                } else {

                    Toast.makeText(FUBeautyActivity.this, getString(R.string.tx_publish_fail), Toast.LENGTH_SHORT).show();
                }
            }
        });
    }


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~FURenderer信息回调~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    @Override
    public void onTrackingStatusChanged(final int status) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // faceunity 是否检测到人脸的通知
//                binding.fuBaseIsTrackingText.setVisibility(status > 0 ? View.INVISIBLE : View.VISIBLE);
            }
        });
    }
}
