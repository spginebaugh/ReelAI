import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FilterControlsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FilterControlsWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        children: VideoConstants.videoFilters.keys
            .map(
              (filter) => ChoiceChip(
                label: Text(filter),
                selected: selectedFilter == filter,
                onSelected: (selected) {
                  if (selected) {
                    onFilterSelected(filter);
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
