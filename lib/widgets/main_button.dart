import 'package:flutter/material.dart';
import 'package:bmrt_shop/utils/utils.dart';

class MainButton extends StatelessWidget {
  final Function? onTap;
  final String? label;
  final bool? enabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? labelColor;

  const MainButton({
    super.key,
    this.label,
    this.onTap,
    this.icon,
    this.backgroundColor = Utils.mainThemeColor,
    this.iconColor = Colors.white,
    this.labelColor = Colors.white,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Material(
        color: enabled! ? backgroundColor : backgroundColor!.withAlpha(128),
        child: InkWell(
          onTap: enabled! ? () => onTap!() : null,
          highlightColor: Colors.white.withAlpha(51),
          splashColor: Colors.white.withAlpha(26),
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor, size: 20),
                  SizedBox(width: 20),
                ],
                Text(
                  label!,
                  style: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}