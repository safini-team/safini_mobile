package com.safini.app

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** The paired credential is scoped to one child's enforcement endpoints. */
class EnforcementHttpException(val status: Int, message: String) : IllegalStateException(message)

class EnforcementClient(private val context: Context) {
    private val prefs get() = context.getSharedPreferences("safini_device_credentials", Context.MODE_PRIVATE)
    private fun key(): SecretKey {
        val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (store.getKey("safini_enforcement", null) as? SecretKey)?.let { return it }
        return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore").apply {
            init(KeyGenParameterSpec.Builder("safini_enforcement", KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build())
        }.generateKey()
    }
    fun configure(baseUrl: String, childId: String, token: String, expiresAt: String) {
        require(URL(baseUrl).protocol == "https" || (context.applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply { init(Cipher.ENCRYPT_MODE, key()) }
        val encrypted = cipher.doFinal(token.toByteArray())
        prefs.edit().putString("url", baseUrl.trimEnd('/')+"/v1/children/"+childId+"/enforcement")
            .putString("childId", childId).putString("expiresAt", expiresAt)
            .putString("iv", Base64.encodeToString(cipher.iv, Base64.NO_WRAP))
            .putString("token", Base64.encodeToString(encrypted, Base64.NO_WRAP)).commit()
    }
    fun childId(): String? = prefs.getString("childId", null)
    fun configured(childId: String): Boolean = this.childId() == childId && runCatching {
        java.time.Instant.parse(prefs.getString("expiresAt", "")).toEpochMilli() > System.currentTimeMillis()+86_400_000
    }.getOrDefault(false)
    private fun token(): String {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply {
            init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128, Base64.decode(prefs.getString("iv", ""), Base64.NO_WRAP)))
        }
        return String(cipher.doFinal(Base64.decode(prefs.getString("token", ""), Base64.NO_WRAP)))
    }
    fun request(path: String, body: JSONObject?, method: String = "POST"): JSONObject {
        val base = prefs.getString("url", null) ?: error("Open Safini to connect app limits.")
        val connection = URL(base+path).openConnection() as HttpURLConnection
        try {
            connection.requestMethod = method
            connection.connectTimeout = 10000
            connection.readTimeout = 10000
            connection.instanceFollowRedirects = false
            connection.setRequestProperty("X-Safini-Device-Token", token())
            connection.setRequestProperty("Content-Type", "application/json")
            if (body != null) {
                connection.doOutput = true
                connection.outputStream.use { it.write(body.toString().toByteArray()) }
            }
            val status = connection.responseCode
            if (status !in 200..299) {
                // Do not log headers, credentials or child data.
                if (status == 401) prefs.edit().remove("expiresAt").commit()
                throw EnforcementHttpException(status, if (status == 409) "Purchase unavailable. Check your balance and parent limits in Safini." else "Unable to connect ($status). Open Safini or try again.")
            }
            return JSONObject(connection.inputStream.bufferedReader().use { it.readText() })
        } finally { connection.disconnect() }
    }
    fun purchaseId(slug: String): String {
        val pendingSlug = prefs.getString("purchaseSlug", null)
        check(pendingSlug == null || pendingSlug == slug) { "Finish the previous purchase first." }
        val id = prefs.getString("purchaseId", null) ?: java.util.UUID.randomUUID().toString().also {
            prefs.edit().putString("purchaseId", it).putString("purchaseSlug", slug).commit()
        }
        return id
    }
    fun purchased() { prefs.edit().remove("purchaseId").remove("purchaseSlug").commit() }
    fun clear() { prefs.edit().clear().commit() }
}
