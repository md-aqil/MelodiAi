import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialValue;
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    Key? key,
    this.initialValue,
    required this.onSearchChanged,
    this.onFilterTap,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _searchController;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue ?? '');
    _isSearchActive = (widget.initialValue?.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSearchActive ? AppTheme.primary : AppTheme.divider,
          width: _isSearchActive ? 2 : 1,
        ),
        boxShadow: _isSearchActive
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search tracks, genres, or descriptions...',
                hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: _isSearchActive
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    size: 5.w,
                  ),
                ),
                suffixIcon: _isSearchActive
                    ? GestureDetector(
                        onTap: _clearSearch,
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'clear',
                            color: AppTheme.textSecondary,
                            size: 5.w,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
              onChanged: _onSearchChanged,
              onTap: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
              onSubmitted: (value) {
                if (value.isEmpty) {
                  setState(() {
                    _isSearchActive = false;
                  });
                }
              },
            ),
          ),
          Container(
            width: 1,
            height: 6.h,
            color: AppTheme.divider,
          ),
          GestureDetector(
            onTap: widget.onFilterTap,
            child: Container(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'tune',
                color: AppTheme.primary,
                size: 5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isSearchActive = value.isNotEmpty;
    });
    widget.onSearchChanged(value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearchActive = false;
    });
    widget.onSearchChanged('');
  }
}
