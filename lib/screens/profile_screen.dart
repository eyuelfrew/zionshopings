import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zionshopings/services/theme_controller.dart';
import 'package:zionshopings/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import 'wishlist_screen.dart';
import 'help_center_screen.dart';
import 'address_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    
    return Consumer<AuthController>(
      builder: (context, controller, child) {
        final user = controller.state.user;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // --- Premium Header ---
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  'ZION SHOPINGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            user?.displayName ?? 'Jane Doe',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                              ],
                            ),
                          ),
                          Text(
                            user?.email ?? 'jane.doe@example.com',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              // --- Content ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Quick Actions Grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickAction(context, Icons.inventory_2_outlined, 'Orders'),
                            _buildQuickAction(context, Icons.favorite_border_rounded, 'Wishlist', onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                            }),
                            _buildQuickAction(context, Icons.location_on_outlined, 'Addresses', onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen()));
                            }),
                            _buildQuickAction(context, Icons.help_outline_rounded, 'Help', onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                            }),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // Account Settings Section
                      _buildSectionTitle(context, 'Account Settings'),
                      _buildSettingsGroup([

                        _buildSettingsTile(
                          context,
                          Icons.notifications_none_rounded,
                          'Notifications',
                          onTap: () {},
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.payment_rounded,
                          'Payment Methods',
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 25),

                      // Preference Section
                      _buildSectionTitle(context, 'Preferences'),
                      _buildSettingsGroup([
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.brightness_6_outlined, color: AppTheme.primaryColor, size: 20),
                          ),
                          title: const Text('Premium Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Switch.adaptive(
                            value: themeController.isDarkMode,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              themeController.toggleTheme(value);
                            },
                          ),
                        ),
                      ]),

                      const SizedBox(height: 25),

                      // Support Section
                      _buildSectionTitle(context, 'Support & Info'),
                      _buildSettingsGroup([
                        _buildSettingsTile(
                          context,
                          Icons.help_center_outlined,
                          'Help Center',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                          },
                        ),
                        _buildSettingsTile(context, Icons.info_outline, 'App Version', subtitle: '1.0.5'),
                        _buildSettingsTile(context, Icons.privacy_tip_outlined, 'Privacy Policy'),
                      ]),

                      const SizedBox(height: 40),

                      // Sign Out Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => context.read<AuthController>().signOut(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(color: Colors.redAccent, width: 1),
                            ),
                          ),
                          child: const Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 100), // Space for bottom navbar
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white10 
              : Colors.grey.shade100,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
    );
  }
}
