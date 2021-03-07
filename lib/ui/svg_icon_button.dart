import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgIconButton extends StatelessWidget {
  SvgIconButton(
      {Key key,
      this.iconName,
      this.width,
      this.height,
      this.iconWidth,
      this.onPressed})
      : super(key: key);

  final void Function() onPressed;
  final String iconName;
  final double width;
  final double height;
  final double iconWidth;

  void toggle(bool toggled) {}

  @override
  Widget build(BuildContext context) {
    return new ButtonTheme(
        height: height,
        minWidth: width,
        child: RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            child: SvgPicture.asset(
              iconName,
              width: iconWidth,
            ),
            shape: CircleBorder(),
            elevation: 3,
            onPressed: onPressed));
  }
}
