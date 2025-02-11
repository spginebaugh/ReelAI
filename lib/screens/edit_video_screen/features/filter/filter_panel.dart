import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../state/video_edit_provider.dart';
import '../../../../models/filter_option.dart';

class FilterPanel extends ConsumerWidget {
  const FilterPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: state.availableFilters.map((filter) {
                  final isSelected = filter == state.selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilterChip(
                          selected: isSelected,
                          label: Text(filter.name),
                          onSelected: (_) => ref
                              .read(videoEditControllerProvider.notifier)
                              .updateFilter(filter),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
