检查网络，如果无网则显示，登录失败则显示账号密码错误，登录成功则跳转至Activity Diao。用AsyncTask发动网络请求更新UI操作。

activity_main.xml
  <TextView
        android:id="@+id/show_tv"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Welcome"
        android:textSize="24sp"/>
    <EditText
        android:id="@+id/username_et"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="username"/>
    <EditText
        android:id="@+id/password_et"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="password"/>
    <Button
        android:id="@+id/log_bt"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="LogIn"/>
        
MainActivity.java
        public class MainActivity extends AppCompatActivity implements View.OnClickListener{
        private String BASE_URL = "http://xmuer.club/demo.php";
        TextView showTV;
        EditText usernameET;
        EditText passwordET;
        Button logBT;
        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_main);

            initView();
            logBT.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            boolean isNetwor = isNetworkConnected(this);
            if (isNetwor){
                String username = usernameET.getText().toString();
                String password = passwordET.getText().toString();
                String jiba = BASE_URL+"?username="+username+"&password="+password;
                new LogAsyncTask().execute(jiba);
            } else {
                showTV.setText("Sorry no network~");
            }



        }

        protected class LogAsyncTask extends AsyncTask<String,Void,String>{
            @Override
            protected String doInBackground(String... strings) {
                String diao = QueryUtils.fetchEarthquakeData(strings[0]);
                return diao;
            }

            @Override
            protected void onPostExecute(String s) {
                if (s.equals("shibai")){
                    Intent i = new Intent(MainActivity.this,Diao.class);
                    i.putExtra("response",s);
                    startActivity(i);
                    finish();//登录成功后销毁该activity，按back键不会返回该活动
                }else if (s.equals("jiba")){
                    showTV.setText("Sorry, wrong username or password~");
                } else {
                    Toast.makeText(MainActivity.this,"2333333",Toast.LENGTH_LONG).show();
                }
            }
        }

        protected void initView(){
            showTV = (TextView) findViewById(R.id.show_tv);
            usernameET = (EditText) findViewById(R.id.username_et);
            passwordET = (EditText) findViewById(R.id.password_et);
            logBT = (Button) findViewById(R.id.log_bt);
        }
        public boolean isNetworkConnected(Context context) {
            if (context != null) {
                ConnectivityManager mConnectivityManager = (ConnectivityManager) context
                        .getSystemService(Context.CONNECTIVITY_SERVICE);
                NetworkInfo mNetworkInfo = mConnectivityManager.getActiveNetworkInfo();
                if (mNetworkInfo != null) {
                    return mNetworkInfo.isAvailable();
                }
            }
            return false;
        }
    }
    
    
activity_diao.xml
    <TextView
        android:id="@+id/response_tv"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:textSize="24sp"/>
        
Diao.java
        public class Diao extends AppCompatActivity {
        TextView textView;
        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_diao);
            textView = (TextView) findViewById(R.id.response_tv);
            Intent intent = getIntent();
            String jiba = intent.getStringExtra("response");
            textView.setText(jiba);
        }
      }
      
      
QueryUtils.java
            public final class QueryUtils {

              private static final String LOG_TAG = QueryUtils.class.getSimpleName();

              private QueryUtils() {
              }


              public static String fetchEarthquakeData(String requestUrl) {
                  URL url = createUrl(requestUrl);
                  String jsonResponse = null;
                  try {
                      jsonResponse = makeHttpRequest(url);
                  } catch (IOException e) {
                      Log.e(LOG_TAG, "Problem making the HTTP request.", e);
                  }
                  return jsonResponse;
              }

              private static URL createUrl(String stringUrl) {
                  URL url = null;
                  try {
                      url = new URL(stringUrl);
                  } catch (MalformedURLException e) {
                      Log.e(LOG_TAG, "Problem building the URL ", e);
                  }
                  return url;
              }

              private static String makeHttpRequest(URL url) throws IOException {
                  String jsonResponse = "";

                  if (url == null) {
                      return jsonResponse;
                  }

                  HttpURLConnection urlConnection = null;
                  InputStream inputStream = null;
                  try {
                      urlConnection = (HttpURLConnection) url.openConnection();
                      urlConnection.setReadTimeout(10000 /* milliseconds */);
                      urlConnection.setConnectTimeout(15000 /* milliseconds */);
                      urlConnection.setRequestMethod("GET");
                      urlConnection.connect();

                      if (urlConnection.getResponseCode() == 200) {
                          inputStream = urlConnection.getInputStream();
                          jsonResponse = readFromStream(inputStream);
                      } else {
                          Log.e(LOG_TAG, "Error response code: " + urlConnection.getResponseCode());
                      }
                  } catch (IOException e) {
                      Log.e(LOG_TAG, "Problem retrieving the earthquake JSON results.", e);
                  } finally {
                      if (urlConnection != null) {
                          urlConnection.disconnect();
                      }
                      if (inputStream != null) {
                          inputStream.close();
                      }
                  }
                  return jsonResponse;
              }

              private static String readFromStream(InputStream inputStream) throws IOException {
                  StringBuilder output = new StringBuilder();
                  if (inputStream != null) {
                      InputStreamReader inputStreamReader = new InputStreamReader(inputStream, Charset.forName("UTF-8"));
                      BufferedReader reader = new BufferedReader(inputStreamReader);
                      String line = reader.readLine();
                      while (line != null) {
                          output.append(line);
                          line = reader.readLine();
                      }
                  }
                  return output.toString();
              }

          }
