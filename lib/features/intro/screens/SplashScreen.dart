import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/widgets/Main_bottom_nav.dart';
import 'package:testrunflutter/features/intro/screens/OnBoard.dart';

class Splashscreen extends StatefulWidget {
  final bool check;
  const Splashscreen({super.key, required this.check});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2),(){
      Navigator.pushReplacement(context, _createRoute());
    });
  }

  Route _createRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.check? const MainNavigationScreen() : const OnBoard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child){
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1000)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          width: 1.sw,
          height: 1.sh,
          decoration: const BoxDecoration(color: Color(0xFF363062)),
          child: Center(
            child: Image.asset(
              "assets/images/LOGO GOBAR VERTICAL 1.png",
              fit: BoxFit.cover,
            ),
          ),
        ));
  }
}
