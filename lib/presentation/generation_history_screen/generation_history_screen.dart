import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/history_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/skeleton_loading_widget.dart';

class GenerationHistoryScreen extends StatefulWidget {
  const GenerationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<GenerationHistoryScreen> createState() =>
      _GenerationHistoryScreenState();
}

class _GenerationHistoryScreenState extends State<GenerationHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // State variables
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String _searchQuery = '';
  Map<String, dynamic> _currentFilters = {
    'dateRange': 'All Time',
    'genre': 'All Genres',
    'status': 'All Status',
  };

  List<Map<String, dynamic>> _allTracks = [];
  List<Map<String, dynamic>> _filteredTracks = [];
  Set<int> _selectedTracks = {};
  bool _isSelectionMode = false;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockTracks = [
    {
      "id": 1,
      "title": "Midnight Dreams",
      "genre": "Electronic",
      "duration": "3:24",
      "status": "completed",
      "createdAt": "Aug 15, 2025 • 8:30 PM",
      "thumbnail":
          "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop",
      "description": "A dreamy electronic track with ambient soundscapes",
      "audioUrl": "https://example.com/audio/midnight-dreams.mp3",
    },
    {
      "id": 2,
      "title": "Urban Vibes",
      "genre": "Hip-Hop",
      "duration": "2:56",
      "status": "completed",
      "createdAt": "Aug 15, 2025 • 6:15 PM",
      "thumbnail":
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop",
      "description": "Modern hip-hop beats with urban energy",
      "audioUrl": "https://example.com/audio/urban-vibes.mp3",
    },
    {
      "id": 3,
      "title": "Acoustic Sunset",
      "genre": "Folk",
      "duration": "4:12",
      "status": "processing",
      "createdAt": "Aug 15, 2025 • 5:45 PM",
      "thumbnail":
          "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=400&fit=crop",
      "description": "Gentle acoustic melodies for peaceful moments",
      "audioUrl": "",
    },
    {
      "id": 4,
      "title": "Jazz Fusion",
      "genre": "Jazz",
      "duration": "5:18",
      "status": "completed",
      "createdAt": "Aug 15, 2025 • 3:20 PM",
      "thumbnail":
          "https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=400&h=400&fit=crop",
      "description": "Complex jazz harmonies with modern fusion elements",
      "audioUrl": "https://example.com/audio/jazz-fusion.mp3",
    },
    {
      "id": 5,
      "title": "Rock Anthem",
      "genre": "Rock",
      "duration": "3:45",
      "status": "failed",
      "createdAt": "Aug 15, 2025 • 2:10 PM",
      "thumbnail":
          "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop",
      "description": "High-energy rock with powerful guitar riffs",
      "audioUrl": "",
    },
    {
      "id": 6,
      "title": "Classical Symphony",
      "genre": "Classical",
      "duration": "6:32",
      "status": "completed",
      "createdAt": "Aug 15, 2025 • 12:30 PM",
      "thumbnail":
          "https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=400&h=400&fit=crop",
      "description": "Orchestral composition with rich harmonies",
      "audioUrl": "https://example.com/audio/classical-symphony.mp3",
    },
    {
      "id": 7,
      "title": "Ambient Space",
      "genre": "Ambient",
      "duration": "7:15",
      "status": "completed",
      "createdAt": "Aug 14, 2025 • 11:45 PM",
      "thumbnail":
          "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&h=400&fit=crop",
      "description": "Ethereal ambient sounds for meditation",
      "audioUrl": "https://example.com/audio/ambient-space.mp3",
    },
    {
      "id": 8,
      "title": "Pop Sensation",
      "genre": "Pop",
      "duration": "3:08",
      "status": "completed",
      "createdAt": "Aug 14, 2025 • 9:20 PM",
      "thumbnail":
          "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop",
      "description": "Catchy pop melodies with modern production",
      "audioUrl": "https://example.com/audio/pop-sensation.mp3",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      _allTracks = List.from(_mockTracks);
      _filteredTracks = List.from(_allTracks);
      _isLoading = false;
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more data
    await Future.delayed(Duration(milliseconds: 1000));

    // For demo, we'll just mark as no more data after first load
    setState(() {
      _isLoadingMore = false;
      _hasMoreData = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _hasMoreData = true;
    });

    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      _allTracks = List.from(_mockTracks);
      _filteredTracks = List.from(_allTracks);
      _isLoading = false;
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allTracks);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((track) {
        final title = (track['title'] as String? ?? '').toLowerCase();
        final genre = (track['genre'] as String? ?? '').toLowerCase();
        final description =
            (track['description'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return title.contains(query) ||
            genre.contains(query) ||
            description.contains(query);
      }).toList();
    }

    // Apply genre filter
    if (_currentFilters['genre'] != 'All Genres') {
      filtered = filtered
          .where((track) => track['genre'] == _currentFilters['genre'])
          .toList();
    }

    // Apply status filter
    if (_currentFilters['status'] != 'All Status') {
      final statusFilter = (_currentFilters['status'] as String).toLowerCase();
      filtered =
          filtered.where((track) => track['status'] == statusFilter).toList();
    }

    // Apply date range filter (simplified for demo)
    if (_currentFilters['dateRange'] != 'All Time') {
      // In a real app, you would filter by actual dates
      // For demo, we'll just show all tracks
    }

    setState(() {
      _filteredTracks = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => FilterBottomSheetWidget(
          currentFilters: _currentFilters,
          onFiltersChanged: _onFiltersChanged,
        ),
      ),
    );
  }

  void _navigateToTrack(Map<String, dynamic> track) {
    Navigator.pushNamed(context, '/audio-playback-screen', arguments: track);
  }

  void _navigateToMusicGeneration() {
    Navigator.pushNamed(context, '/music-generation-screen');
  }

  void _playTrack(Map<String, dynamic> track) {
    if (track['status'] == 'completed') {
      _navigateToTrack(track);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Track is not ready for playback'),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
  }

  void _downloadTrack(Map<String, dynamic> track) {
    if (track['status'] == 'completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${track['title']}...'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Track is not ready for download'),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
  }

  void _shareTrack(Map<String, dynamic> track) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${track['title']}...'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _deleteTrack(Map<String, dynamic> track) {
    setState(() {
      _allTracks.removeWhere((t) => t['id'] == track['id']);
      _filteredTracks.removeWhere((t) => t['id'] == track['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${track['title']} deleted'),
        backgroundColor: AppTheme.error,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _allTracks.add(track);
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  void _renameTrack(Map<String, dynamic> track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Rename Track',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: TextField(
          controller: TextEditingController(text: track['title']),
          style: AppTheme.darkTheme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          onSubmitted: (newName) {
            if (newName.isNotEmpty) {
              setState(() {
                track['title'] = newName;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Track renamed to "$newName"'),
                  backgroundColor: AppTheme.success,
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Track renamed'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: Text('Rename', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _duplicateSettings(Map<String, dynamic> track) {
    Navigator.pushNamed(context, '/music-generation-screen', arguments: {
      'duplicateFrom': track,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildSearchBar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.secondary,
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generation History',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_filteredTracks.length} tracks',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (_isSelectionMode) ...[
            Text(
              '${_selectedTracks.length} selected',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedTracks.clear();
                });
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.white,
                  size: 5.w,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.darkTheme.scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'History'),
          Tab(text: 'Favorites'),
        ],
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 3,
        labelStyle: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.darkTheme.textTheme.titleSmall,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWidget(
      initialValue: _searchQuery,
      onSearchChanged: _onSearchChanged,
      onFilterTap: _showFilterBottomSheet,
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTracksList(), // All tab
        _buildTracksList(), // History tab (active)
        _buildTracksList(), // Favorites tab
      ],
    );
  }

  Widget _buildTracksList() {
    if (_isLoading) {
      return SkeletonLoadingWidget(itemCount: 6);
    }

    if (_filteredTracks.isEmpty) {
      return EmptyStateWidget(
        onCreateTrack: _navigateToMusicGeneration,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.primary,
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        itemCount: _filteredTracks.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _filteredTracks.length) {
            return Container(
              padding: EdgeInsets.all(4.w),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            );
          }

          final track = _filteredTracks[index];
          return HistoryCardWidget(
            track: track,
            onTap: () => _navigateToTrack(track),
            onPlay: () => _playTrack(track),
            onDownload: () => _downloadTrack(track),
            onShare: () => _shareTrack(track),
            onDelete: () => _deleteTrack(track),
            onRename: () => _renameTrack(track),
            onDuplicate: () => _duplicateSettings(track),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToMusicGeneration,
      backgroundColor: AppTheme.primary,
      child: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.onPrimary,
        size: 7.w,
      ),
    );
  }
}
