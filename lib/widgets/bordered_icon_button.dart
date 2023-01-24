import 'package:flutter/material.dart';
import 'package:groceries/custom_theme.dart';

class BorderedIconButton extends StatelessWidget {
  Function onPressed;
  Icon icon;
  BorderedIconButton({Key? key, required this.onPressed, required this.icon}) : super(key: key);

  CustomTheme theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(3.0)),
      child: ColoredBox(
        color: theme.accentColor,
        child: IconButton(
          onPressed: () => onPressed(),
          icon: icon,
        ),
      ),
    );
  }
}
