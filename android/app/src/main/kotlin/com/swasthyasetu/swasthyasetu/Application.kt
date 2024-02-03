//package com.swasthyasetu.swasthyasetu;
//
//import io.flutter.app.FlutterApplication
//import io.flutter.plugin.common.PluginRegistry
//
////import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin
//import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
//
///*import io.flutter.app.FlutterApplication
//import io.flutter.plugin.common.PluginRegistry
//import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
//import io.flutter.plugins.GeneratedPluginRegistrant
//import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService*/
//
///*
//class Application : FlutterApplication(), PluginRegistrantCallback {
//
//    override fun onCreate() {
//        super.onCreate()
//        FlutterFirebaseMessagingService.setPluginRegistrant(this);
//    }
//
//    override fun registerWith(registry: PluginRegistry?) {
//        io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
//    }
//}*/
//
//class Application() : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
//    override fun registerWith(registry: PluginRegistry?) {
//        val key: String? = FlutterFirebaseMessagingPlugin::class.java.canonicalName
//        if (!registry?.hasPlugin(key)!!) {
//            FlutterFirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin"));
//        }
//        ConnectycubeFlutterCallKitPlugin().registerWith(registry.registrarFor("ConnectycubeFlutterCallKitPlugin"));
//    }
//}