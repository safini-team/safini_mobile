package com.safini.app;
public class FixtureRunner extends android.test.InstrumentationTestRunner {
    public static android.os.Bundle arguments;
    @Override public void onCreate(android.os.Bundle args) {
        arguments = args;
        super.onCreate(args);
    }
}
