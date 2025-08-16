import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/api_usage_widget.dart';
import './widgets/settings_action_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_selection_widget.dart';
import './widgets/settings_slider_widget.dart';
import './widgets/settings_toggle_widget.dart';
import './widgets/storage_usage_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Section expansion states
  bool _audioPreferencesExpanded = true;
  bool _generationSettingsExpanded = true;
  bool _appPreferencesExpanded = true;
  bool _storageManagementExpanded = true;
  bool _accountExpanded = true;

  // Audio Preferences
  String _defaultGenre = 'Electronic';
  String _audioQuality = 'High';
  bool _autoDownload = false;

  // Generation Settings
  double _defaultStyleWeight = 0.7;
  bool _instrumentalPreference = false;
  String _negativeTagsTemplate = 'low quality, distorted, noise';

  // App Preferences
  String _themeSelection = 'Dark';
  bool _notificationsEnabled = true;
  bool _offlineModeEnabled = false;

  // Storage data
  double _usedSpace = 245.6 * 1024 * 1024; // 245.6 MB in bytes
  double _totalSpace = 2.0 * 1024 * 1024 * 1024; // 2 GB in bytes

  // API Usage data
  int _currentApiUsage = 847;
  int _monthlyApiLimit = 1000;
  DateTime _apiResetDate = DateTime(2025, 9, 15);

  // User data
  final Map<String, dynamic> _userData = {
    "name": "Alex Rodriguez",
    "email": "alex.rodriguez@email.com",
    "subscription": "Pro Plan",
    "memberSince": "January 2024",
    "totalGenerations": 1247,
  };

  final List<String> _genreOptions = [
    'Classical',
    'Pop',
    'Rock',
    'Hip-Hop',
    'Electronic',
    'Jazz',
    'Folk',
    'Country',
    'R&B',
    'Indie',
    'Alternative',
    'Ambient',
    'Blues',
    'Reggae',
    'Metal',
    'Funk',
    'House',
    'Techno',
    'Dubstep',
    'Trap'
  ];

  final List<String> _qualityOptions = ['High', 'Medium', 'Low'];
  final List<String> _themeOptions = ['Dark', 'Light', 'Auto'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultGenre = prefs.getString('default_genre') ?? 'Electronic';
      _audioQuality = prefs.getString('audio_quality') ?? 'High';
      _autoDownload = prefs.getBool('auto_download') ?? false;
      _defaultStyleWeight = prefs.getDouble('default_style_weight') ?? 0.7;
      _instrumentalPreference =
          prefs.getBool('instrumental_preference') ?? false;
      _negativeTagsTemplate = prefs.getString('negative_tags_template') ??
          'low quality, distorted, noise';
      _themeSelection = prefs.getString('theme_selection') ?? 'Dark';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _offlineModeEnabled = prefs.getBool('offline_mode_enabled') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_genre', _defaultGenre);
    await prefs.setString('audio_quality', _audioQuality);
    await prefs.setBool('auto_download', _autoDownload);
    await prefs.setDouble('default_style_weight', _defaultStyleWeight);
    await prefs.setBool('instrumental_preference', _instrumentalPreference);
    await prefs.setString('negative_tags_template', _negativeTagsTemplate);
    await prefs.setString('theme_selection', _themeSelection);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('offline_mode_enabled', _offlineModeEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 1.h),
              _buildAudioPreferencesSection(),
              _buildGenerationSettingsSection(),
              _buildAppPreferencesSection(),
              _buildStorageManagementSection(),
              _buildAccountSection(),
              _buildResetSection(),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.textPrimary,
          size: 24,
        ),
      ),
      title: Text(
        'Settings',
        style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
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
      ),
    );
  }

  Widget _buildAudioPreferencesSection() {
    return SettingsSectionWidget(
      title: 'Audio Preferences',
      isExpanded: _audioPreferencesExpanded,
      onToggle: () => setState(
          () => _audioPreferencesExpanded = !_audioPreferencesExpanded),
      children: [
        SettingsSelectionWidget(
          title: 'Default Genre',
          subtitle: 'Your preferred music style for new generations',
          currentValue: _defaultGenre,
          options: _genreOptions,
          iconName: 'music_note',
          onChanged: (value) {
            setState(() => _defaultGenre = value);
            _saveSettings();
          },
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsSelectionWidget(
          title: 'Audio Quality',
          subtitle: 'Higher quality uses more storage space',
          currentValue: _audioQuality,
          options: _qualityOptions,
          iconName: 'high_quality',
          onChanged: (value) {
            setState(() => _audioQuality = value);
            _saveSettings();
          },
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsToggleWidget(
          title: 'Auto-Download',
          subtitle: 'Automatically save generated tracks to device',
          value: _autoDownload,
          iconName: 'download',
          onChanged: (value) {
            setState(() => _autoDownload = value);
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _buildGenerationSettingsSection() {
    return SettingsSectionWidget(
      title: 'Generation Settings',
      isExpanded: _generationSettingsExpanded,
      onToggle: () => setState(
          () => _generationSettingsExpanded = !_generationSettingsExpanded),
      children: [
        SettingsSliderWidget(
          title: 'Default Style Weight',
          subtitle: 'How strongly the AI follows style guidelines',
          value: _defaultStyleWeight,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          iconName: 'tune',
          onChanged: (value) {
            setState(() => _defaultStyleWeight = value);
            _saveSettings();
          },
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsToggleWidget(
          title: 'Instrumental Preference',
          subtitle: 'Generate instrumental tracks by default',
          value: _instrumentalPreference,
          iconName: 'piano',
          onChanged: (value) {
            setState(() => _instrumentalPreference = value);
            _saveSettings();
          },
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsActionWidget(
          title: 'Negative Tags Template',
          subtitle: _negativeTagsTemplate,
          iconName: 'block',
          onTap: () => _showNegativeTagsDialog(),
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection() {
    return SettingsSectionWidget(
      title: 'App Preferences',
      isExpanded: _appPreferencesExpanded,
      onToggle: () =>
          setState(() => _appPreferencesExpanded = !_appPreferencesExpanded),
      children: [
        SettingsSelectionWidget(
          title: 'Theme',
          subtitle: 'Choose your preferred app appearance',
          currentValue: _themeSelection,
          options: _themeOptions,
          iconName: 'palette',
          onChanged: (value) {
            setState(() => _themeSelection = value);
            _saveSettings();
          },
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsToggleWidget(
          title: 'Notifications',
          subtitle: 'Receive updates about generation progress',
          value: _notificationsEnabled,
          iconName: 'notifications',
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _saveSettings();
          },
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsToggleWidget(
          title: 'Offline Mode',
          subtitle: 'Access downloaded content without internet',
          value: _offlineModeEnabled,
          iconName: 'offline_bolt',
          onChanged: (value) {
            setState(() => _offlineModeEnabled = value);
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _buildStorageManagementSection() {
    return SettingsSectionWidget(
      title: 'Storage Management',
      isExpanded: _storageManagementExpanded,
      onToggle: () => setState(
          () => _storageManagementExpanded = !_storageManagementExpanded),
      children: [
        StorageUsageWidget(
          usedSpace: _usedSpace,
          totalSpace: _totalSpace,
          onManageDownloads: () => _navigateToDownloads(),
          onClearCache: () => _showClearCacheDialog(),
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsActionWidget(
          title: 'Download Location',
          subtitle: 'Internal Storage > MelodyAI',
          iconName: 'folder',
          onTap: () => _showDownloadLocationDialog(),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return SettingsSectionWidget(
      title: 'Account',
      isExpanded: _accountExpanded,
      onToggle: () => setState(() => _accountExpanded = !_accountExpanded),
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      (_userData["name"] as String)
                          .split(' ')
                          .map((e) => e[0])
                          .join(''),
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData["name"] as String,
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _userData["email"] as String,
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_userData["subscription"]} • Member since ${_userData["memberSince"]}',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'analytics',
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Total Generations: ${_userData["totalGenerations"]}',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: AppTheme.divider, height: 1),
        ApiUsageWidget(
          currentUsage: _currentApiUsage,
          monthlyLimit: _monthlyApiLimit,
          resetDate: _apiResetDate,
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsActionWidget(
          title: 'Privacy Settings',
          subtitle: 'Manage data collection and analytics',
          iconName: 'privacy_tip',
          onTap: () => _showPrivacyDialog(),
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsActionWidget(
          title: 'Terms of Service',
          iconName: 'description',
          onTap: () => _showTermsDialog(),
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsActionWidget(
          title: 'Contact Support',
          iconName: 'support_agent',
          onTap: () => _contactSupport(),
        ),
        Divider(color: AppTheme.divider, height: 1),
        SettingsActionWidget(
          title: 'About MelodyAI',
          subtitle: 'Version 1.2.3 (Build 456)',
          iconName: 'info',
          onTap: () => _showAboutDialog(),
        ),
      ],
    );
  }

  Widget _buildResetSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: ElevatedButton(
        onPressed: () => _showResetDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error.withValues(alpha: 0.1),
          foregroundColor: AppTheme.error,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'restore',
              color: AppTheme.error,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Reset to Defaults',
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNegativeTagsDialog() {
    final controller = TextEditingController(text: _negativeTagsTemplate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Negative Tags Template',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLength: 200,
          maxLines: 3,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Enter negative tags to avoid in generations...',
            hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _negativeTagsTemplate = controller.text);
              _saveSettings();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _navigateToDownloads() {
    Navigator.pushNamed(context, '/generation-history-screen');
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Clear Cache',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'This will clear temporary files and cached data. Downloaded music files will not be affected.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() =>
                  _usedSpace = _usedSpace * 0.7); // Simulate cache clearing
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            child: Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showDownloadLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Download Location',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'phone_android', color: AppTheme.primary, size: 20),
              title: Text('Internal Storage',
                  style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: Text('/storage/emulated/0/MelodyAI',
                  style: TextStyle(color: AppTheme.textSecondary)),
              trailing: CustomIconWidget(
                  iconName: 'check_circle', color: AppTheme.success, size: 20),
            ),
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'sd_card', color: AppTheme.textSecondary, size: 20),
              title: Text('SD Card',
                  style: TextStyle(color: AppTheme.textSecondary)),
              subtitle: Text('Not available',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Privacy Settings',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'MelodyAI respects your privacy. We only collect necessary data to improve your music generation experience. No personal audio content is stored on our servers.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Terms of Service',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'By using MelodyAI, you agree to our terms of service. Generated music is for personal and commercial use. Please respect copyright laws and use responsibly.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening support chat...'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'About MelodyAI',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.2.3 (Build 456)',
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'MelodyAI is a professional AI-powered music generation platform that transforms your creative ideas into high-quality music tracks.',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '© 2025 MelodyAI Technologies',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Reset to Defaults',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'This will reset all settings to their default values. This action cannot be undone.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              setState(() {
                _defaultGenre = 'Electronic';
                _audioQuality = 'High';
                _autoDownload = false;
                _defaultStyleWeight = 0.7;
                _instrumentalPreference = false;
                _negativeTagsTemplate = 'low quality, distorted, noise';
                _themeSelection = 'Dark';
                _notificationsEnabled = true;
                _offlineModeEnabled = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
}
