package im.zego.expressample.faceu.demo.view.seekbar.internal.compat;



public abstract class AnimatorCompat {
    public interface AnimationFrameUpdateListener {
        public void onAnimationFrame(float currentValue);
    }

    AnimatorCompat() {

    }

    public abstract void cancel();

    public abstract boolean isRunning();

    public abstract void setDuration(int progressAnimationDuration);

    public abstract void start();

    public static final AnimatorCompat create(float start, float end, AnimationFrameUpdateListener listener) {
        return new AnimatorCompatBase(start, end, listener);
    }

    private static class AnimatorCompatBase extends AnimatorCompat {

        private final AnimationFrameUpdateListener mListener;
        private final float mEndValue;

        public AnimatorCompatBase(float start, float end, AnimationFrameUpdateListener listener) {
            mListener = listener;
            mEndValue = end;
        }

        @Override
        public void cancel() {

        }

        @Override
        public boolean isRunning() {
            return false;
        }

        @Override
        public void setDuration(int progressAnimationDuration) {

        }

        @Override
        public void start() {
            mListener.onAnimationFrame(mEndValue);
        }
    }
}
