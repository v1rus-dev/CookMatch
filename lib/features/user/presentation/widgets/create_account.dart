import 'package:flutter/material.dart';
import 'package:groceryhelper/app/router/app_router.dart';
import 'package:groceryhelper/app/router/router_paths.dart';
import 'package:design/design.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        appRouter.push(RouterPaths.register, extra: {'fromScreen': 'user'});
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Нет аккаунта? ',
              style: TextStyle(color: context.theme.secondaryText, fontSize: 16, fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'Зарегистрируйтесь!',
              style: TextStyle(color: context.theme.primary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
