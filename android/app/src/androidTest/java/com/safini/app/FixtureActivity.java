package com.safini.app;

/** A separate package used to verify blocking without installing a real child's app. */
public class FixtureActivity extends android.app.Activity {
    @Override public void onCreate(android.os.Bundle state) {
        super.onCreate(state);
        android.widget.TextView label = new android.widget.TextView(this);
        label.setText("Safini test app\nForeground time is being measured");
        label.setTextSize(28);
        label.setGravity(android.view.Gravity.CENTER);
        setContentView(label);
    }
}
