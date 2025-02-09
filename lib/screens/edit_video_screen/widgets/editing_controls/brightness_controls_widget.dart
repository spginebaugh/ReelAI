import 'package:flutter/material.dart';

class BrightnessControlsWidget extends StatelessWidget {
  final double brightness;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const BrightnessControlsWidget({
    Key? key,
    required this.brightness,
    required this.onChanged,
    required this.onChangeEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.brightness_low),
          Expanded(
            child: Slider(
              value: brightness,
              min: -1.0,
              max: 1.0,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          const Icon(Icons.brightness_high),
        ],
      ),
    );
  }
}
