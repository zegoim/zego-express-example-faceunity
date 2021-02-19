package im.zego.expressample.faceu.demo.ui;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.RadioGroup;
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
import im.zego.zegoexpress.entity.ZegoEngineConfig;

public class VideoFilterMainUI extends Activity implements View.OnClickListener {

    private ActivityVideoFilterMainBinding binding;

    public static boolean useExpressCustomCapture=true;//使用自定义采集或前处理实现滤镜

    private static final int REQUEST_PERMISSION_CODE = 101;
    private static ZegoVideoBufferType videoBufferType=ZegoVideoBufferType.RAW_DATA;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        binding = DataBindingUtil.setContentView(this, R.layout.activity_video_filter_main);
        binding.captureOrProcess.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                switch (checkedId){
                    case R.id.videoCapture:
                        binding.zegoProcess.setVisibility(View.GONE);
                        binding.zegoCustomCapture.setVisibility(View.VISIBLE);
                        useExpressCustomCapture = true;
                        binding.captureMem.setChecked(true);
                        videoBufferType=ZegoVideoBufferType.RAW_DATA;
                        break;
                    case R.id.videoProcess:
                        binding.zegoCustomCapture.setVisibility(View.GONE);
                        binding.zegoProcess.setVisibility(View.VISIBLE);
                        useExpressCustomCapture =false;
                        binding.processTexture2D.setChecked(true);
                        videoBufferType=ZegoVideoBufferType.GL_TEXTURE_2D;
                        break;
                    default:
                        break;
                }
            }
        });
        // 获取选定的前处理传递数据的类型
        setCheckedFilterTypeListener();

        // 前处理传递数据类型说明的点击事件监听
        binding.videoBufferTypeDescribe.setOnClickListener(this);
        binding.videofilterTypeDescribe.setOnClickListener(this);
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
        binding.zegoSdkVersion.setText("zego sdk version:"+ZegoExpressEngine.getVersion());
        binding.faceunitySdkVersion.setText("faceunity sdk version:"+FURenderer.getVersion());
    }

    // 获取选定的前处理传递数据的类型
    public void setCheckedFilterTypeListener(){
        binding.captureBufferType.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                switch (checkedId) {
                    case R.id.captureMem:
                        videoBufferType=ZegoVideoBufferType.RAW_DATA;
                        break;
                    case R.id.captureSurfaceTexture:
                        videoBufferType=ZegoVideoBufferType.SURFACE_TEXTURE;
                        break;
                    default:
                        break;
                }
            }
        });
        binding.processBufferType.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                switch (checkedId) {
                    case R.id.processTexture2D:
                        videoBufferType=ZegoVideoBufferType.GL_TEXTURE_2D;
                        break;
                    case R.id.processSurfaceTexture:
                        videoBufferType=ZegoVideoBufferType.SURFACE_TEXTURE;
                        break;
                    default:
                        break;
                }
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
                Intent intent = new Intent(VideoFilterMainUI.this, FUBeautyActivity.class);
                intent.putExtra("roomID", roomID);
                intent.putExtra("videoBufferType", videoBufferType.value());
                startActivity(intent);
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
         if (id == R.id.videoBufferTypeDescribe) {
             if(useExpressCustomCapture) {
                 showPopWindows(getString(R.string.videoBufferType_describe), v);
             }else{
                 showPopWindows(getString(R.string.videoBufferType2_describe), v);
             }
        }
         if(id == R.id.videofilterTypeDescribe){
             showPopWindows(getString(R.string.videofilterType_describe), v);
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
