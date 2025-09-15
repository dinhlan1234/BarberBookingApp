import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/widgets/CustomScrollBehavior.dart';
import 'package:testrunflutter/features/Auth/authPage.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await VietnamProvinces.initialize();
  await initializeDateFormatting('vi_VN', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 740),
        minTextAdapt: true, // tự điều chỉnh chữ nhỏ
        splitScreenMode: true, // hỗ trợ chia đôi màn hình (tablet, fold)
        builder: (context, child) {
          return MaterialApp(
            locale: const Locale('vi', 'VN'),
            supportedLocales: const [
              Locale('vi', 'VN'), // Tiếng Việt
              Locale('en', 'US'), // Tiếng Anh
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            scrollBehavior: MyCustomScrollBehavior(),
            debugShowCheckedModeBanner: false,
            title: 'BarberBooking App',
            theme: ThemeData(primarySwatch: Colors.deepPurple),
            home: const Authpage(),
          );
        });
  }
}