import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImageLoader extends StatelessWidget {
  final bool isNetwork;
  final String? assetName;
  final String? url;
  final double width;
  final double height;
  final BoxFit fit;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  const SvgImageLoader({
    super.key,
    this.isNetwork = false,
    this.assetName,
    this.url,
    this.width = 24,
    this.height = 24,
    this.fit = BoxFit.contain,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isNetwork) {
      return Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: SvgPicture.network(
          url!,
          width: width,
          height: height,
          fit: fit,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          placeholderBuilder: (context) =>
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
        ),
      );
    } else {
      // For asset SVGs, you might want to use a package like flutter_svg
      // Here, we'll just return a placeholder for demonstration
      return Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          assetName!,
          width: width,
          height: height,
          fit: fit,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        ),
      );
    }
  }
}
