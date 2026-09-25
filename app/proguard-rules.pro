# Keep WebView JavaScript bridge classes if added in the future.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
