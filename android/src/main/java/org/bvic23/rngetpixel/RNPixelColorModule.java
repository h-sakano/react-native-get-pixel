package org.bvic23.rngetpixel;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;

import java.io.IOException;
import java.io.InputStream;

import static java.lang.Math.PI;
import static java.lang.Math.cos;
import static java.lang.Math.pow;
import static java.lang.Math.sin;

class RNPixelColorModule extends ReactContextBaseJavaModule {
    private final Context context;
    private static final double rotation =  PI / 2;

    public RNPixelColorModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;
    }

    @Override
    public String getName() {
        return "RNPixelColor";
    }

    @ReactMethod
    public void getPixelRGBAofImage(final String filePath, final int x, final int y, final Callback callback) {
        try {
            final Bitmap bitmap = loadImage(filePath);
            final int pixel = bitmap.getPixel(x, y);
            respondWithPixel(callback, pixel);
        } catch (Exception e) {
            callback.invoke(e.getMessage());
        }
    }

    @ReactMethod
    public void getPixelRGBAverageOfImage(final String filePath, final Callback callback) {
        try {
            final Bitmap bitmap = loadImage(filePath);
            
	        int height = bitmap.getHeight();
	        int width = bitmap.getWidth();
            int pixel_num = width * height;

	        int[] pixels = new int[width * height];
	        bitmap.getPixels(pixels, 0, width, 0, 0, width, height);

            int total_r = 0;
            int total_g = 0;
            int total_b = 0;
            
	        for (int i = 0; i < pixels.length; i += pixelSpacing) {
	        	int color = pixels[i];
	        	total_r += Color.red(color);
	        	total_g += Color.green(color);
	        	total_b += Color.blue(color);
	        }
	        final int average_color = Color.rgb(total_r / pixel_num, total_g / pixel_num, total_b / pixel_num);

            respondWithPixel(callback, average_color);
        } catch (Exception e) {
            callback.invoke(e.getMessage());
        }
    }

    @ReactMethod
    public void getPixelRGBAPolarOfImage(final String filePath, final double angle, final double radius, final Callback callback) {
        try {
            final Bitmap image = loadImage(filePath);
            final double width = image.getWidth();
            final double height = image.getHeight();
            final double rotatedAngle = angle + rotation;

            final double centerX = width * 0.5;
            final double centerY = height * 0.5;

            final int x = (int)(centerX + radius * cos(rotatedAngle));
            final int y = (int)(centerY + radius * sin(rotatedAngle));

            final int pixel = image.getPixel(x, y);
            respondWithPixel(callback, pixel);
        } catch (Exception e) {
            callback.invoke(e.getMessage());
        }
    }

    @ReactMethod
    public void findAngleOfNearestColor(final String filePath, final double minAngle, final double maxAngle, final double radius, final ReadableArray targetColor, final Callback callback) {
        try {
            final Bitmap image = loadImage(filePath);
            final double width = image.getWidth();
            final double height = image.getHeight();

            final double centerX = width * 0.5;
            final double centerY = height * 0.5;

            double angle = minAngle;

            final int targetRed = targetColor.getInt(0);
            final int targetGreen = targetColor.getInt(1);
            final int targetBlue = targetColor.getInt(2);

            double minDistance = Double.MAX_VALUE;
            double resultAngle = Double.MAX_VALUE;

            while (angle <= maxAngle) {
                final double rotatedAngle = angle + rotation;
                final int x = (int)(centerX + radius * cos(rotatedAngle));
                final int y = (int)(centerY + radius * sin(rotatedAngle));

                final int pixel = image.getPixel(x, y);
                final int red = Color.red(pixel);
                final int green = Color.green(pixel);
                final int blue = Color.blue(pixel);

                final double distance = pow(targetRed - red, 2) + pow(targetGreen - green, 2) + pow(targetBlue - blue, 2);

                if (distance < minDistance) {
                    minDistance = distance;
                    resultAngle = angle;
                }

                angle += PI / 180;
            }

            callback.invoke(null, resultAngle);
        } catch (Exception e) {
            callback.invoke(e.getMessage());
        }
    }

    private void respondWithPixel(final Callback callback, final int pixel) {
        final int r = Color.red(pixel);
        final int g = Color.green(pixel);
        final int b = Color.blue(pixel);

        final WritableArray result = new WritableNativeArray();
        result.pushInt(r);
        result.pushInt(g);
        result.pushInt(b);
        callback.invoke(null, result);
    }

    private Bitmap loadImage(final String filePath) throws IOException {
        try {
            return BitmapFactory.decodeFile(getContentResolver().openInputStream(filePath));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
}
