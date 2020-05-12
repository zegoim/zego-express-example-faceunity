package im.zego.expressample.faceu.demo;


public class ZGFilterHelper {

    private static ZGFilterHelper zgFilterHelper = null;

    public static ZGFilterHelper sharedInstance() {
        synchronized (ZGFilterHelper.class) {
            if (zgFilterHelper == null) {
                zgFilterHelper = new ZGFilterHelper();
            }
        }
        return zgFilterHelper;
    }


}
