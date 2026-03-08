# paymob_flutter_lib

This plugin is for [paymob.pk](https://docs.paymob.pk/). It's implementation of the native Paymob SDK of Android and IOS to work on Flutter environment.

## Usage

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  paymob_flutter_lib: ^1.0.9
```

## Android

You have to edit `AndroidManifest.xml` file with following.

```manifest
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
     xmlns:tools="http://schemas.android.com/tools">
    <application
        android:supportsRtl="true"
        tools:replace="android:label,android:supportsRtl">
    </appliaction>
</manifest>
```

## ios

Add this to your `Podfile` file

```podfile
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"  //----> add this statement
    end
  end
end

```

