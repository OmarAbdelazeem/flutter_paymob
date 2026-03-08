package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.Window;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import com.qodit.paymob_flutter_lib.R;

public class ThreeDSecureWebViewActivty extends AppCompatActivity {
    String authenticationUrl;

    int themeColor;

    String title;

    @RequiresApi(api = 21)
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_three_d_secure);
        resetVariables();
        getThreeDSecureParameters();
        linkViews();
        WebView webView = (WebView)findViewById(R.id.webView1);
        webView.setWebViewClient(new WebViewClient() {
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                Log.d("Accept - NEW URL: ", url);
                boolean isSuccess = url.startsWith("https://accept.paymob.com/api/acceptance/post_pay")
                    || (url.contains("data.message=Approved") && url.contains("?"));
                if (isSuccess) {
                    Log.d("Accept - SUCCESS_URL", url);
                    Intent intent = new Intent();
                    try {
                        String rawPayResponse = QueryParamsExtractor.getQueryParams(url);
                        if (rawPayResponse != null) {
                            intent.putExtra("raw_pay_response", rawPayResponse);
                            ThreeDSecureWebViewActivty.this.setResult(17, intent);
                        }
                    } catch (Exception exception) {
                        Log.e("Accept", "getQueryParams failed", exception);
                    }
                    ThreeDSecureWebViewActivty.this.finish();
                    return true;
                }
                return false;
            }
        });
        webView.getSettings().setJavaScriptEnabled(true);
        webView.loadUrl(this.authenticationUrl);
    }

    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == 16908332)
            onCancelPress();
        return super.onOptionsItemSelected(item);
    }

    private void onCancelPress() {
        Intent canceledIntent = new Intent();
        setResult(1, canceledIntent);
        finish();
    }

    private void resetVariables() {
        this.authenticationUrl = null;
    }

    private void getThreeDSecureParameters() {
        Intent intent = getIntent();
        this.authenticationUrl = intent.getStringExtra("three_d_secure_url");
        checkIfPassed("three_d_secure_url", this.authenticationUrl);
        this.themeColor = intent.getIntExtra("theme_color", getApplicationContext().getResources().getColor(R.color.colorPrimaryDark));
    }

    @RequiresApi(api = 21)
    private void linkViews() {
        Intent intent = getIntent();
        boolean showActionBar = intent.getBooleanExtra("ActionBar", false);
        if (showActionBar) {
            ActionBar actionBar = getSupportActionBar();
            ColorDrawable colorDrawable1 = new ColorDrawable(this.themeColor);
            assert actionBar != null;
            actionBar.setBackgroundDrawable((Drawable)colorDrawable1);
        }
        ColorDrawable colorDrawable = new ColorDrawable(this.themeColor);
        Window window = getWindow();
        window.addFlags(-2147483648);
        window.clearFlags(67108864);
        window.setStatusBarColor(this.themeColor);
    }

    private void checkIfPassed(String key, String value) {
        if (value == null)
            abortForNotPassed(key);
    }

    private void abortForNotPassed(String key) {
        Intent errorIntent = new Intent();
        errorIntent.putExtra("missing_argument_value", key);
        setResult(2, errorIntent);
        finish();
    }
}
