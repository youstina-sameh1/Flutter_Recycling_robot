import 'package:first_app_robot/features/splash/presentation/widgets/NextPage/next_page.dart';
import 'package:flutter/material.dart';


class SplashBody extends StatefulWidget {
  const SplashBody({super.key});

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation? fadingAnimation;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    fadingAnimation =
        Tween<double>(begin: .2, end: 1).animate(animationController!);

    animationController?.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
        opacity: 0.0,
        child: Image.asset('assets/images/R.png'),
        ),
        Text(
          'Sorting Robot',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 78, 119, 78),
          ),
        ),
        const SizedBox(height: 50),
        AnimatedBuilder(
          animation: animationController!,
          builder: (context, child) {
            return Opacity(
              opacity: fadingAnimation?.value ?? 1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NextPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 36, 107, 40),
                  foregroundColor: const Color.fromARGB(149, 26, 27, 27),
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), 
                      ),
                ),
                child: const Text(
                  ' S T A R T ',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            );
          },
        ),
      ],
    ); //container
  }

 // void goToNextView() {
  //  Future.delayed(Duration(seconds: 3), () {
  //    Get.to(() => OnBoardingView(), transition: Transition.fade);
  // });
 // }
}