import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgIconButton extends StatelessWidget {
  SvgIconButton(
      {Key? key,
      required this.iconName,
      required this.width,
      required this.height,
      this.iconWidth = null,
      this.onPressed = null})
      : super(key: key);

  final void Function()? onPressed;
  final String iconName;
  final double width;
  final double height;
  final double? iconWidth;

  void toggle(bool toggled) {}

  @override
  Widget build(BuildContext context) {
    return new ElevatedButton(
        style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: CircleBorder(),
            fixedSize: Size.fromHeight(height),
            minimumSize: Size(width, height),
            tapTargetSize: MaterialTapTargetSize.padded),
        child: SvgPicture.asset(
          //TODO: replace to standard icons
          iconName,
          width: iconWidth,
        ),
        onPressed: onPressed);
  }
}
