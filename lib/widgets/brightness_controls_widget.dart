import 'package:flutter/material.dart';

class BrightnessControlsWidget extends StatelessWidget {
  final double brightness;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const BrightnessControlsWidget({
    super.key,
    required this.brightness,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Brightness'),
      subtitle: Slider(
        value: brightness,
        min: 0.0,
        max: 2.0,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}
