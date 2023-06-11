import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:store_redirect/store_redirect.dart';

import '../res/colors.dart';
import '../res/strings.dart';
import '../res/textStyles.dart';

class NeededUpdate extends StatelessWidget {
  const NeededUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Center(
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 40,
              children: [
                Lottie.asset(
                  'assets/lottie/126421-setting.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Wrap(
                  spacing: 20,
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      MyStrings.needAnUpdate,
                      style: MyTextStyles.big,
                    ),
                    Text(
                      MyStrings.youCanUseTheServiceAfterUpdate,
                      textAlign: TextAlign.center,
                      style: MyTextStyles.medium.copyWith(color: Colors.grey),
                    )
                  ],
                ),
                FilledButton(
                  onPressed: () {
                    StoreRedirect.redirect();
                  },
                  style:
                      FilledButton.styleFrom(backgroundColor: MyColors.primary),
                  child: const Text(MyStrings.update),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
