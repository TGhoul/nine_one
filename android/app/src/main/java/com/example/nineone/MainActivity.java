package com.example.nineone;

import com.blankj.utilcode.util.ActivityUtils;
import com.blankj.utilcode.util.BrightnessUtils;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "samples.flutter.dev/brightness";

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
            (call, result) -> {
              if (call.method.equals("upActivityBrightness")) {
                BrightnessUtils.setWindowBrightness(
                    ActivityUtils.getTopActivity().getWindow(), 255);
              } else if (call.method.equals("downActivityBrightness")) {
                BrightnessUtils.setWindowBrightness(ActivityUtils.getTopActivity().getWindow(), 1);
              }
            });
  }
}
