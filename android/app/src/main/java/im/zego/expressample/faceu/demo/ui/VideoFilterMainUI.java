package im.zego.expressample.faceu.demo.ui;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import androidx.core.content.ContextCompat;
import androidx.databinding.DataBindingUtil;

import im.zego.expressample.faceu.demo.faceunity.FURenderer;
import im.zego.expressample.faceu.demo.faceunity.authpack;
import im.zego.expressample.faceu.demo.view.CustomPopWindow;
import im.zego.expresssample.faceu.demo.R;
import im.zego.expresssample.faceu.demo.databinding.ActivityVideoFilterMainBinding;
import im.zego.zegoexpress.ZegoExpressEngine;
import im.zego.zegoexpress.constants.ZegoVideoBufferType;
import im.zego.zegoexpress.entity.ZegoCustomVideoCaptureConfig;
import im.zego.zegoexpress.entity.ZegoEngineConfig;

public class VideoFilterMainUI extends Activity implements View.OnClickListener {

    private ActivityVideoFilterMainBinding binding;

    private FUBeautyActivity.FilterType mFilterType = FUBeautyActivity.FilterType.FilterType_SurfaceTexture;

    private static final int REQUEST_PERMISSION_CODE = 101;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        binding = DataBindingUtil.setContentView(this, R.layout.activity_video_filter_main);

        // 获取选定的前处理传递数据的类型
        setCheckedFilterTypeListener();

        // 前处理传递数据类型说明的点击事件监听
        binding.MemTexture2DDescribe.setOnClickListener(this);

        binding.goBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        if (null == authpack.A()) {
            binding.authpack.setText(R.string.tx_has_no_fu_authpack);
            binding.loginBtn.setVisibility(View.INVISIBLE);
        } else {
            // 初始化 FaceUnity
            FURenderer.initFURenderer(this);
        }
    }

    // 获取选定的前处理传递数据的类型
    public void setCheckedFilterTypeListener(){
        binding.RadioMemTexture2D.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                zegoEngineConfig.customVideoCaptureMainConfig = new ZegoCustomVideoCaptureConfig();
                zegoEngineConfig.customVideoCaptureMainConfig.bufferType = ZegoVideoBufferType.SURFACE_TEXTURE;
                mFilterType = FUBeautyActivity.FilterType.FilterType_SurfaceTexture;
            }
        });
    }


    // 需要申请 麦克风权限-读写sd卡权限-摄像头权限
    private static String[] PERMISSIONS_STORAGE = {
            "android.permission.CAMERA",
            "android.permission.RECORD_AUDIO"};

    /**
     * 校验并请求权限
     */
    public boolean checkOrRequestPermission(int code) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, "android.permission.CAMERA") != PackageManager.PERMISSION_GRANTED
                    || ContextCompat.checkSelfPermission(this, "android.permission.RECORD_AUDIO") != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(PERMISSIONS_STORAGE, code);
                return false;
            }
        }
        return true;
    }

    ZegoEngineConfig zegoEngineConfig = new ZegoEngineConfig();
    public void onClickLoginRoomAndPublish(View view) {
        boolean orRequestPermission = this.checkOrRequestPermission(REQUEST_PERMISSION_CODE);
        if(orRequestPermission) {
            String roomID = binding.edRoomId.getText().toString();
            if (!"".equals(roomID)) {
                ZegoExpressEngine.setEngineConfig(zegoEngineConfig);
                // 跳转到创建并登录房间的页面
                FUBeautyActivity.actionStart(VideoFilterMainUI.this, roomID, mFilterType);
            } else {
                Toast.makeText(VideoFilterMainUI.this, "room id is no null", Toast.LENGTH_SHORT).show();

            }
        }else {
            Toast.makeText(this, "请打开麦克风与摄像头权限再推流", Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void finish() {
        super.finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    /**
     * 供其他Activity调用，进入本专题的方法
     * For other activities to call into the methods of this topic
     * @param activity
     */
    public static void actionStart(Activity activity) {
        Intent intent = new Intent(activity, VideoFilterMainUI.class);
        activity.startActivity(intent);
    }

    // 前处理传递数据类型的描述
    // Preprocessing passes a description of the data type
    @Override
    public void onClick(View v) {
        int id = v.getId();
         if (id == R.id.MemTexture2DDescribe) {
            showPopWindows(getString(R.string.memTexture2D_describe), v);
        }
    }

    /**
     * 显示描述窗口
     * Display description window
     * @param msg  显示内容 Display content
     * @param view
     */
    private void showPopWindows(String msg, View view) {

        new CustomPopWindow.PopupWindowBuilder(this)
                .enableBackgroundDark(true)
                .setBgDarkAlpha(0.7f)
                .create()
                .setMsg(msg)
                .showAsDropDown(view, 0, 20);
    }
}
