import 'package:flutter/material.dart';
import '../../../../models/filter_option.dart';

class FilterControlsWidget extends StatelessWidget {
  final FilterOption selectedFilter;
  final List<FilterOption> availableFilters;
  final ValueChanged<FilterOption> onFilterSelected;

  const FilterControlsWidget({
    Key? key,
    required this.selectedFilter,
    required this.availableFilters,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableFilters.length,
        itemBuilder: (context, index) {
          final filter = availableFilters[index];
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16.0 : 8.0,
              right: index == availableFilters.length - 1 ? 16.0 : 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onFilterSelected(filter),
                      child: Center(
                        child: Icon(
                          Icons.filter,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  filter.name,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
