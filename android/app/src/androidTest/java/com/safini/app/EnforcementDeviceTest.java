package com.safini.app;

import android.content.Context;
import android.content.Intent;
import android.test.InstrumentationTestCase;
import org.json.JSONObject;
import org.json.JSONArray;

/** Device tests use only synthetic state, never a family's production data. */
public class EnforcementDeviceTest extends InstrumentationTestCase {
    private Context context() { return getInstrumentation().getTargetContext(); }
    public void testPersistentBudgetAndReset() throws Exception {
        EnforcementStore store = new EnforcementStore(context());
        long now = System.currentTimeMillis();
        String pkg = "com.safini.app.test";
        JSONObject app = new JSONObject().put("app_slug", "roblox").put("package_name", pkg)
            .put("is_limited", true).put("daily_limit_minutes", 1).put("used_minutes", 0)
            .put("bonus_minutes_remaining", 1);
        JSONObject data = new JSONObject().put("usage_date", store.day(now)).put("family_timezone", "UTC")
            .put("apps", new JSONArray().put(app));
        store.applySnapshot(data);
        store.record(pkg, now, now+90000);
        store.persist();
        EnforcementStore reopened = new EnforcementStore(context());
        assertEquals(Long.valueOf(30000), reopened.remaining(pkg, now));
        reopened.applySnapshot(data);
        assertEquals(Long.valueOf(30000), reopened.remaining(pkg, now));
        assertEquals(Long.valueOf(60000), reopened.remaining(pkg, now+86400000));
        app.put("is_limited", false);
        reopened.applySnapshot(data);
        assertNull(reopened.remaining(pkg, now));
        app.put("is_blocked", true);
        reopened.applySnapshot(data);
        assertEquals(Long.valueOf(0), reopened.remaining(pkg, now));
        reopened.clear();
    }
    public void testConfigureLocalFixture() throws Exception {
        // Explicitly opt in to the disposable API configured by the test operator.
        android.os.Bundle args = FixtureRunner.arguments;
        String token = args.getString("deviceToken");
        if (token == null) return;
        EnforcementClient client = new EnforcementClient(context());
        client.configure("http://10.0.2.2:8765", args.getString("childId"), token, java.time.Instant.now().plusSeconds(30L*86400).toString());
        EnforcementStore store = new EnforcementStore(context());
        store.clear();
        JSONObject body = new JSONObject().put("usage", new JSONArray()).put("usage_access", true)
            .put("overlay_permission", true).put("service_running", true);
        store.applySnapshot(client.request("/sync", body, "POST"));
        context().startForegroundService(new Intent(context(), AppBlockForegroundService.class));
    }
}
