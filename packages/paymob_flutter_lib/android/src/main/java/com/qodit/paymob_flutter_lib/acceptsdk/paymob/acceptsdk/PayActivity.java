package com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatCheckBox;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.HttpStack;
import com.android.volley.toolbox.HurlStack;
import com.android.volley.toolbox.Volley;
import com.qodit.paymob_flutter_lib.R;
import com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk.helper.StringPOSTRequest;
import com.qodit.paymob_flutter_lib.acceptsdk.paymob.acceptsdk.helper.TLSSocketFactory;


import org.json.JSONException;
import org.json.JSONObject;

import java.util.Locale;

import morxander.editcard.EditCard;

public class PayActivity extends AppCompatActivity implements View.OnClickListener, AsyncResponse {
	private boolean hasBilling;

	JSONObject billingData;

	String paymentKey;

	String token;

	String maskedPanNumber;

	Boolean saveCardDefault;

	Boolean showSaveCard;

	int themeColor;

	enum Status {
		IDLE, PROCESSING
	}

	String language = "en";

	EditText nameText;

	EditCard cardNumberText;

	EditText monthText;

	EditText yearText;

	EditText cvvText;

	AppCompatCheckBox saveCardCheckBox;

	TextView saveCardText;

	Button payBtn;

	LinearLayout cardName_linearLayout;

	LinearLayout expiration_linearLayout;

	LinearLayout saveCard_linearLayout;

	ProgressDialog mProgressDialog;

	String verificationActivity_title;

	Status status;

	JSONObject payDict;

	public static LocaleManager localeManager;

	@RequiresApi(api = 23)
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		resetVariables();
		initUiTheme();
		setContentView(R.layout.activity_card_information);
		init();
	}

	void initUiTheme() {
		Intent intent = getIntent();
		if (intent.hasExtra("language")) {
			this.language = intent.getStringExtra("language");
			setLocale(this.language);
		}
		this.themeColor = intent.getIntExtra("theme_color", getApplicationContext().getResources().getColor(R.color.colorPrimaryDark));
	}

	@RequiresApi(api = 23)
	private void init() {
		getAcceptParameters();
		Intent intent = getIntent();
		this.language = intent.getStringExtra("language");
		linkViews(this.language);
		updateLayout();
		Log.d("test", "onCreate: " + this.themeColor);
	}

	public void setLocale(String lang) {
		Locale myLocale = new Locale(lang);
		Resources res = getResources();
		DisplayMetrics dm = res.getDisplayMetrics();
		Configuration conf = res.getConfiguration();
		conf.locale = myLocale;
		res.updateConfiguration(conf, dm);
		onConfigurationChanged(conf);
	}

	@RequiresApi(api = 17)
	public void onBackPressed() {
		onCancelPress();
	}

	@RequiresApi(api = 22)
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == 4)
			onCancelPress();
		return true;
	}

	public void onClick(View v) {
		if (v.getId() == R.id.pay)
			handlePayment();
	}

	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == 16908332)
			onCancelPress();
		return super.onOptionsItemSelected(item);
	}

	private void onCancelPress() {
		if (this.status == Status.IDLE) {
			Intent canceledIntent = new Intent();
			setResult(1, canceledIntent);
			finish();
		}
	}

	private void handlePayment() {
		String nameString = this.nameText.getText().toString();
		String numberString = this.cardNumberText.getCardNumber();
		String monthString = this.monthText.getText().toString();
		String yearString = this.yearText.getText().toString();
		String cvvString = this.cvvText.getText().toString();
		JSONObject cardData = new JSONObject();
		if (this.token != null) {
			try {
				cardData.put("identifier", this.token);
				cardData.put("subtype", "TOKEN");
				cardData.put("cvn", cvvString);
			} catch (JSONException J) {
				return;
			}
		} else {
			if (!FormChecker.checkCardName(nameString)) {
				Toast.makeText(this, getString(R.string.Empty_name_check), Toast.LENGTH_LONG).show();
				return;
			}
			if (!FormChecker.checkCardNumber(numberString)) {
				Toast.makeText(this, getString(R.string.Card_Number_check), Toast.LENGTH_LONG).show();
				return;
			}
			if (!FormChecker.checkDate(monthString, yearString)) {
				Toast.makeText(this, getString(R.string.Date_check), Toast.LENGTH_LONG).show();
				return;
			}
			if (!FormChecker.checkCVV(cvvString)) {
				Toast.makeText(this, getString(R.string.Cvv_check), Toast.LENGTH_LONG).show();
				return;
			}
			try {
				cardData.put("identifier", numberString);
				cardData.put("sourceholder_name", nameString);
				cardData.put("subtype", "CARD");
				cardData.put("expiry_month", monthString);
				cardData.put("expiry_year", yearString);
				cardData.put("cvn", cvvString);
			} catch (JSONException J) {
				return;
			}
		}
		try {
			payAPIRequest(cardData);
		} catch (JSONException J) {
			notifyErrorTransaction("An error occured while handling payment response");
		}
	}

	void payAPIRequest(JSONObject cardData) throws JSONException {
		JSONObject params = new JSONObject();
		params.put("source", cardData);
		params.put("api_source", "SDK");
		if (this.hasBilling)
			params.put("billing", this.billingData);
		params.put("payment_token", this.paymentKey);
		String jsons = params.toString();
		RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
		HttpStack stack = null;
		if (Build.VERSION.SDK_INT >= 9)
			try {
				if (Build.VERSION.SDK_INT <= 19) {
					HurlStack hurlStack = new HurlStack(null, new TLSSocketFactory());
					queue = Volley.newRequestQueue(getApplicationContext(), (HttpStack)hurlStack);
				}
			} catch (Exception e) {
				Log.i("NetworkClient", "can no create custom socket factory");
			}
		StringPOSTRequest request = new StringPOSTRequest("https://accept.paymob.com/api/acceptance/payments/pay", jsons, new Response.Listener<String>() {
			public void onResponse(String response) {
				PayActivity.this.dismissProgressDialog();
				try {
					JSONObject jsonResult = new JSONObject(response);
					Log.d("notice", "json output: " + jsonResult);
					String direct3dSecure = jsonResult.getString("is_3d_secure");
					if (direct3dSecure != null) {
						PayActivity.this.payDict = jsonResult;
						if (direct3dSecure.equals("true")) {
							String redirectionURL = jsonResult.getString("redirection_url");
							if (redirectionURL != null) {
								PayActivity.this.open3DSecureView(redirectionURL);
							} else {
								PayActivity.this.dismissProgressDialog();
								PayActivity.this.notifyErrorTransaction("An error occured while reading the 3dsecure redirection URL");
							}
						} else {
							PayActivity.this.paymentInquiry();
						}
					} else {
						PayActivity.this.dismissProgressDialog();
						PayActivity.this.notifyErrorTransaction("An error occured while checking if the card is 3d secure");
					}
				} catch (Exception ex) {
					PayActivity.this.dismissProgressDialog();
					Log.d("notice", "exception caught " + ex.getMessage());
					PayActivity.this.notifyErrorTransaction(ex.getMessage());
				}
			}
		},new Response.ErrorListener() {
			public void onErrorResponse(VolleyError error) {
				Log.d("notice", "json error output: " + error);
				NetworkResponse networkResponse = error.networkResponse;
				PayActivity.this.dismissProgressDialog();
				if (networkResponse != null &&
						networkResponse.statusCode == 401)
					PayActivity.this.notifyErrorTransaction("Invalid or Expired Payment Key");
			}
		});
		request.setRetryPolicy(new DefaultRetryPolicy(30000, 1, 1.0F));
		request.setTag(0);
		queue.add((Request)request);
		showProgressDialog();
	}

	private void open3DSecureView(String url) {
		Intent intent = getIntent();
		this.themeColor = intent.getIntExtra("theme_color", getApplicationContext().getResources().getColor(R.color.colorPrimaryDark));
		Boolean actionBar = intent.getBooleanExtra("ActionBar", false);
		Intent threeDSecureViewIntent = new Intent(this, ThreeDSecureWebViewActivty.class);
		threeDSecureViewIntent.putExtra("three_d_secure_url", url);
		threeDSecureViewIntent.putExtra("ActionBar", actionBar);
		threeDSecureViewIntent.putExtra("theme_color", this.themeColor);
		threeDSecureViewIntent.putExtra("three_d_secure_activity_title", this.verificationActivity_title);
		startActivityForResult(threeDSecureViewIntent, IntentConstants.THREE_D_SECURE_VERIFICATION_REQUEST);
	}

	public void processFinish(String apiName, String output, String status_code) {
		dismissProgressDialog();
		Log.d("notice", "output: " + output);
		Log.d("notice", "status code: " + status_code);
		if (Integer.valueOf(status_code) == 401)
			notifyErrorTransaction("Invalid or Expired Payment Key");
		if (apiName.equalsIgnoreCase("USER_PAYMENT")) {
			try {
				JSONObject jsonResult = new JSONObject(output);
				Log.d("notice", "json output: " + jsonResult);
				String direct3dSecure = jsonResult.getString("is_3d_secure");
				if (direct3dSecure != null) {
					this.payDict = jsonResult;
					if (direct3dSecure.equals("true")) {
						String redirectionURL = jsonResult.getString("redirection_url");
						if (redirectionURL != null) {
							open3DSecureView(redirectionURL);
						} else {
							dismissProgressDialog();
							notifyErrorTransaction("An error occured while reading the 3dsecure redirection URL");
						}
					} else {
						paymentInquiry();
					}
				} else {
					dismissProgressDialog();
					notifyErrorTransaction("An error occured while checking if the card is 3d secure");
				}
			} catch (Exception ex) {
				dismissProgressDialog();
				Log.d("notice", "exception caught " + ex.getMessage());
				notifyErrorTransaction(ex.getMessage());
			}
		} else if (apiName.equalsIgnoreCase("CARD_TOKENIZER")) {
			dismissProgressDialog();
			notifySuccessfulTransactionSaveCard(output);
		}
	}

	private void paymentInquiry() {
		try {
			Log.d("notice paymentInquiry", this.payDict.toString());
			String success = this.payDict.optString("success", "");
			String txn_response_code = this.payDict.optString("txn_response_code", "");
			String dataMessage = this.payDict.optString("data.message", "");
			Log.d("NOTICEEEEE paymentInquiry", "txn_response_code is " + txn_response_code);
			if(!android.text.TextUtils.isDigitsOnly(txn_response_code)){
				Log.d("NOTICEEEEE paymentInquiry", "txn_response_code is String");
				if (txn_response_code.equals("ERROR")){
					String errorMsg = this.payDict.getString("data.message");
					notifyErrorTransaction("ERROR: "+errorMsg);
				}else{
					notifyErrorTransaction("An error occured while processing the transaction");
				}
			}else{
				Log.d("NOTICEEEEE paymentInquiry", "txn_response_code is Int");
				if (this.payDict.getInt("txn_response_code") == 1)
					notifyErrorTransaction("There was an error processing the transaction");
				if (this.payDict.getInt("txn_response_code") == 2)
					notifyErrorTransaction("Contact card issuing bank");
				if (this.payDict.getInt("txn_response_code") == 4)
					notifyErrorTransaction("Expired Card");
				if (this.payDict.getInt("txn_response_code") == 5)
					notifyErrorTransaction("Insufficient Funds");
				boolean isSuccess = "true".equals(success) || ("0".equals(txn_response_code) && "Approved".equals(dataMessage));
				if (isSuccess) {
					if (this.saveCardCheckBox.isChecked()) {
						JSONObject cardData = new JSONObject();
						cardData.put("pan", this.cardNumberText.getCardNumber());
						cardData.put("cardholder_name", this.nameText.getText().toString());
						cardData.put("expiry_month", this.monthText.getText().toString());
						cardData.put("expiry_year", this.yearText.getText().toString());
						cardData.put("cvn", this.cvvText.getText().toString());
						String jsons = cardData.toString();
						RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
						HttpStack stack = null;
						if (Build.VERSION.SDK_INT >= 9)
							try {
								if (Build.VERSION.SDK_INT <= 19) {
									HurlStack hurlStack = new HurlStack(null, new TLSSocketFactory());
									queue = Volley.newRequestQueue(getApplicationContext(), (HttpStack)hurlStack);
								}
							} catch (Exception e) {
								Log.i("NetworkClient", "can no create custom socket factory");
							}
						StringPOSTRequest request = new StringPOSTRequest("https://accept.paymob.com/api/acceptance/tokenization?payment_token=" + this.paymentKey, jsons, new Response.Listener<String>() {
							public void onResponse(String response) {
								Log.d("notice", "tokenize response " + response);
								PayActivity.this.dismissProgressDialog();
								PayActivity.this.notifySuccessfulTransactionSaveCard(response);
							}
						},new Response.ErrorListener() {
							public void onErrorResponse(VolleyError error) {
								NetworkResponse networkResponse = error.networkResponse;
								PayActivity.this.dismissProgressDialog();
								Log.d("notice", "tokenize error response " + error);
								if (networkResponse != null &&
										networkResponse.statusCode == 401)
									PayActivity.this.notifyErrorTransaction("Invalid or Expired Payment Key");
							}
						});
						request.setRetryPolicy(new DefaultRetryPolicy(30000, 1, 1.0F));
						request.setTag(0);
						queue.add((Request)request);
					} else {
						dismissProgressDialog();
						notifySuccesfulTransaction();
					}
				} else {
					dismissProgressDialog();
					notifyRejectedTransaction();
				}
			}
		} catch (JSONException J) {
			Log.d("notice paymentInquiry JSONException", "JSONException");
			J.printStackTrace();
			// notifyErrorTransaction("An error occured while reading returned message");
			notifyErrorTransaction("An error occured while processing the transaction");
		}
	}

	private void notifySuccessfulTransactionSaveCard(String saveCardData) {
		Intent successIntent = new Intent();
		try {
			JSONObject savedCardDict = new JSONObject(saveCardData);
			putSaveCardData(successIntent, savedCardDict);
			putPayDataInIntent(successIntent);
		} catch (JSONException J) {
			this.payDict.remove("merchant_order_id");
			try {
				this.payDict.put("merchant_order_id", "null");
				putPayDataInIntent(successIntent);
			} catch (JSONException jsonException) {
				jsonException.printStackTrace();
			}
		}
		setResult(8, successIntent);
		finish();
	}

	private void putSaveCardData(Intent intent, JSONObject saveCardData) {
		for (int i = 0; i < SaveCardResponseKeys.SAVE_CARD_DICT_KEYS.length; i++) {
			try {
				intent.putExtra(SaveCardResponseKeys.SAVE_CARD_DICT_KEYS[i], saveCardData
						.getString(SaveCardResponseKeys.SAVE_CARD_DICT_KEYS[i]));
			} catch (JSONException jSONException) {}
		}
	}

	private void notifyErrorTransaction(String reason) {
		Intent errorIntent = new Intent();
		errorIntent.putExtra("transaction_error_reason", reason); 
		setResult(3, errorIntent);
		finish();
	}

	private void notifyCancel3dSecure() {
		Intent cancel3dSecureIntent = new Intent();
		try {
			putPayDataInIntent(cancel3dSecureIntent);
			setResult(9, cancel3dSecureIntent);
		} catch (JSONException J) {
			cancel3dSecureIntent.putExtra("raw_pay_response", this.payDict.toString());
			setResult(10, cancel3dSecureIntent);
		}
		finish();
	}

	private void notifyRejectedTransaction() {
		Intent rejectIntent = new Intent();
		try {
			putPayDataInIntent(rejectIntent);
			setResult(4, rejectIntent);
		} catch (JSONException J) {
			rejectIntent.putExtra("raw_pay_response", this.payDict.toString());
			setResult(5, rejectIntent);
		}
		finish();
	}

	private void notifySuccesfulTransaction() {
		Intent successIntent = new Intent();
		try {
			putPayDataInIntent(successIntent);
			setResult(6, successIntent);
			finish();
		} catch (JSONException J) {
			notifySuccesfulTransactionParsingIssue(this.payDict.toString());
		}
	}

	private void notifySuccesfulTransactionParsingIssue(String raw_pay_response) {
		Intent successIntent = new Intent();
		successIntent.putExtra("raw_pay_response", raw_pay_response);
		setResult(7, successIntent);
		finish();
	}

	private void putPayDataInIntent(Intent intent) throws JSONException {
		for (int i = 0; i < PayResponseKeys.PAY_DICT_KEYS.length; i++)
			intent.putExtra(PayResponseKeys.PAY_DICT_KEYS[i], this.payDict.getString(PayResponseKeys.PAY_DICT_KEYS[i]));
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == IntentConstants.THREE_D_SECURE_VERIFICATION_REQUEST)
			if (resultCode == 2) {
				notifyCancel3dSecure();
			} else if (resultCode == 1) {
				notifyCancel3dSecure();
			} else if (resultCode == 17) {
				String raw_pay_response = data.getStringExtra("raw_pay_response");
				Log.d("noticeeee onActivityResult",raw_pay_response);
				try {
					this.payDict = new JSONObject(raw_pay_response);
					paymentInquiry();
				} catch (Exception var6) {
					Log.d("noticeeee onActivityResult Exception",raw_pay_response);
					notifySuccesfulTransactionParsingIssue(raw_pay_response);
				}
			}
	}

	private void showProgressDialog() {
		this.mProgressDialog = new ProgressDialog(this);
		this.mProgressDialog.setTitle(getString(R.string.processing));
		this.mProgressDialog.setMessage(getString(R.string.wait));
		this.mProgressDialog.setCancelable(false);
		this.status = Status.PROCESSING;
		this.mProgressDialog.show();
		getWindow().setFlags(16, 16);
	}

	private void dismissProgressDialog() {
		if (this.mProgressDialog != null)
			this.mProgressDialog.dismiss();
		this.status = Status.IDLE;
		getWindow().clearFlags(16);
	}

	@RequiresApi(api = 21)
	private void linkViews(String language) {
		Intent intent = getIntent();
		boolean showActionBar = intent.getBooleanExtra("ActionBar", false);
		if (showActionBar) {
			ActionBar actionBar = getSupportActionBar();
			actionBar.setDisplayHomeAsUpEnabled(true);
			ColorDrawable colorDrawable = new ColorDrawable(this.themeColor);
			assert actionBar != null;
			actionBar.setBackgroundDrawable(colorDrawable);
		} else {
			Log.d("actionBar", "no actionBar");
		}
		Window window = getWindow();
		window.addFlags(-2147483648);
		window.clearFlags(67108864);
		window.setStatusBarColor(this.themeColor);
		this.nameText = findViewById(R.id.cardName);
		this.cardNumberText = findViewById(R.id.cardNumber);
		this.monthText = findViewById(R.id.expiryMonth);
		this.yearText = findViewById(R.id.expiryYear);
		this.cvvText = findViewById(R.id.cvv);
		if (language.equals("ar")) {
			this.nameText.setGravity(5);
			this.cardNumberText.setGravity(5);
			this.monthText.setGravity(5);
			this.yearText.setGravity(5);
			this.cvvText.setGravity(5);
		}
		this.saveCardCheckBox = findViewById(R.id.saveCardCheckBox);
		this.saveCardText = findViewById(R.id.saveCardText);
		this.payBtn = findViewById(R.id.pay);
		if (getIntent().getStringExtra("PAY_BUTTON_TEXT") != null &&
				!getIntent().getStringExtra("PAY_BUTTON_TEXT").isEmpty())
			this.payBtn.setText(getIntent().getStringExtra("PAY_BUTTON_TEXT"));
		this.payBtn.setBackgroundColor(this.themeColor);
		this.payBtn.setOnClickListener(this);
		this.cardName_linearLayout = findViewById(R.id.cardName_linearLayout);
		this.expiration_linearLayout = findViewById(R.id.expiration_linearLayout);
		this.saveCard_linearLayout = findViewById(R.id.saveCard_linearLayout);
	}

	private void getAcceptParameters() {
		Intent intent = getIntent();
		if (intent.hasExtra("email")) {
			this.billingData = new JSONObject();
			readBillingData(intent);
			this.hasBilling = true;
		}
		this.paymentKey = intent.getStringExtra("payment_key");
		checkIfPassed("payment_key", this.paymentKey);
		this.token = intent.getStringExtra("token");
		this.maskedPanNumber = intent.getStringExtra("masked_pan_number");
		if (this.token != null)
			checkIfPassed("masked_pan_number", this.maskedPanNumber);
		this.saveCardDefault = intent.getBooleanExtra("save_card_default", false);
		this.showSaveCard = intent.getBooleanExtra("show_save_card", true);
		this.verificationActivity_title = intent.getStringExtra("three_d_secure_activity_title");
		if (this.verificationActivity_title == null)
			this.verificationActivity_title = "";
	}

	private void readBillingData(Intent intent) {
		try {
			readBillingValue(intent, "first_name");
			readBillingValue(intent, "last_name");
			readBillingValue(intent, "building");
			readBillingValue(intent, "floor");
			readBillingValue(intent, "apartment");
			readBillingValue(intent, "city");
			readBillingValue(intent, "state");
			readBillingValue(intent, "country");
			readBillingValue(intent, "email");
			readBillingValue(intent, "phone_number");
			readBillingValue(intent, "postal_code");
			Log.d("notice", "finished reading billing data");
		} catch (JSONException jSONException) {}
	}

	private void readBillingValue(Intent intent, String key) throws JSONException {
		String value = intent.getStringExtra(key);
		checkIfPassed(key, value);
		this.billingData.put(key, value);
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

	private void resetVariables() {
		this.billingData = null;
		this.paymentKey = null;
		this.token = null;
		this.maskedPanNumber = null;
		this.showSaveCard = Boolean.TRUE;
		this.saveCardDefault = Boolean.FALSE;
		this.mProgressDialog = null;
		this.payDict = null;
		this.verificationActivity_title = null;
		this.status = Status.IDLE;
		this.hasBilling = false;
	}

	private void updateLayout() {
		this.saveCardCheckBox.setChecked(this.saveCardDefault);
		this.saveCardCheckBox.setClickable(this.showSaveCard);
		ColorEditor.setAppCompatCheckBoxColors(this.saveCardCheckBox, -2139062144, Integer.parseInt(String.valueOf(this.themeColor)));
		if (!this.showSaveCard) {
			this.saveCardCheckBox.setVisibility(View.GONE);
			if (this.saveCardDefault) {
				this.saveCardText.setText("Your card will be saved for future use");
			} else {
				this.saveCard_linearLayout.setVisibility(View.GONE);
			}
		}
		if (this.token != null) {
			invalidateOptionsMenu();
			this.cardName_linearLayout.setVisibility(View.GONE);
			this.expiration_linearLayout.setVisibility(View.GONE);
			this.saveCardCheckBox.setChecked(false);
			this.saveCard_linearLayout.setVisibility(View.GONE);
			this.cardNumberText.setHint(this.maskedPanNumber);
			this.cardNumberText.setHintTextColor(getResources().getColor(R.color.colorText));
			this.cardNumberText.setEnabled(false);
			this.cardNumberText.setFocusable(false);
			Intent intent = getIntent();
			this.themeColor = intent.getIntExtra("theme_color", getApplicationContext().getResources().getColor(R.color.colorPrimaryDark));
		}
	}

	@RequiresApi(api = 17)
	private void setApplicationLanguage(String newLanguage) {
		Resources activityRes = getResources();
		Configuration activityConf = activityRes.getConfiguration();
		Locale newLocale = new Locale(newLanguage);
		if (Build.VERSION.SDK_INT >= 17)
			activityConf.setLocale(newLocale);
		activityRes.updateConfiguration(activityConf, activityRes.getDisplayMetrics());
		Resources applicationRes = getApplicationContext().getResources();
		Configuration applicationConf = applicationRes.getConfiguration();
		applicationConf.setLocale(newLocale);
		applicationRes.updateConfiguration(applicationConf, applicationRes
				.getDisplayMetrics());
	}

	protected void attachBaseContext(Context newBase) {
		localeManager = new LocaleManager(newBase);
		super.attachBaseContext(localeManager.setLocale(newBase));
	}

	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		localeManager.setLocale(this);
		super.onConfigurationChanged(newConfig);
		if (newConfig.locale == Locale.ENGLISH) {
			Toast.makeText(this, "English", Toast.LENGTH_SHORT).show();
		} else if (newConfig.locale == Locale.FRENCH) {
			Toast.makeText(this, "French", Toast.LENGTH_SHORT).show();
		}
	}
}
