#壓縮比，預設5不修改
-optimizationpasses 5 

#不使用大小寫混合，混淆後類名稱為小寫
-dontusemixedcaseclassnames 

#指定不去忽略公開的 publicli classes
-dontskipnonpubliclibraryclasses

#混淆後產生印射文件
-verbose 

#註解此行，可以自動上傳 mapping 檔到 Firebase
#-printmapping mapping.txt

#保留泛型
-keepattributes Signature

# 不做預校驗，加速建置速度
-dontpreverify

# 保留Annotation不混淆
-keepattributes *Annotation*,InnerClasses
 
# 避免混淆泛型
-keepattributes Signature
 
# 抛出異常時保留檔名與行數
-keepattributes SourceFile,LineNumberTable

# 保留 android-support
-dontwarn android.support.design.**
-keep class android.support.design.** { *; }
-keep interface android.support.design.** { *; }
-keep public class android.support.design.R$* { *; }

-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
    public static *** d(...);
    public static *** v(...);
}

-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }