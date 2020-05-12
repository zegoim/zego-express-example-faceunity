package im.zego.expressample.faceu.demo.application;

import android.app.Application;



/**
 * Created by zego on 2018/10/16.
 */

public class ZegoApplication extends Application {

    public static ZegoApplication zegoApplication;

    @Override
    public void onCreate() {
        super.onCreate();
        zegoApplication = this;


        // 添加悬浮日志视图
        // Add floating log view

    }


}
