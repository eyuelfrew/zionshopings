import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zionshopings/services/theme_controller.dart';
import 'package:zionshopings/theme/app_theme.dart';
import 'package:zionshopings/utils/auth_helper.dart';
import 'package:zionshopings/widgets/sign_in_bottom_sheet.dart';
import '../auth/auth_controller.dart';
import 'wishlist_screen.dart';
import 'help_center_screen.dart';
import 'address_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    
    return Consumer<AuthController>(
      builder: (context, controller, child) {
        final user = controller.state.user;
        final isGuest = user == null;
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            controller: _scrollController,
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
                          if (isGuest) ...[
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Guest User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                                ],
                              ),
                            ),
                            const Text(
                              'Sign in for a personalized experience',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ] else ...[
                            Text(
                              user.displayName ?? 'User',
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
                              user.email ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
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
                      // Sign In Card for Guest Users
                      if (isGuest) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.card_giftcard_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Unlock Premium Features',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sign in to save your wishlist, track orders, and get personalized recommendations',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await SignInBottomSheet.show(context);
                                  },
                                  icon: const Icon(Icons.login),
                                  label: const Text(
                                    'Sign In with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],

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
                            _buildQuickAction(
                              context,
                              Icons.inventory_2_outlined,
                              'Orders',
                              requiresAuth: true,
                              onTap: () async {
                                if (isGuest) {
                                  await AuthHelper.requireAuth(
                                    context,
                                    message: 'Sign in to view your order history.',
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                                  );
                                }
                              },
                            ),
                            _buildQuickAction(
                              context,
                              Icons.favorite_border_rounded,
                              'Wishlist',
                              requiresAuth: true,
                              onTap: () async {
                                if (isGuest) {
                                  await AuthHelper.requireAuth(
                                    context,
                                    message: 'Sign in to view your wishlist and save your favorite items.',
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const WishlistScreen()),
                                  );
                                }
                              },
                            ),
                            _buildQuickAction(
                              context,
                              Icons.location_on_outlined,
                              'Addresses',
                              requiresAuth: true,
                              onTap: () async {
                                if (isGuest) {
                                  await AuthHelper.requireAuth(
                                    context,
                                    message: 'Sign in to manage your delivery addresses.',
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddressScreen()),
                                  );
                                }
                              },
                            ),
                            _buildQuickAction(
                              context,
                              Icons.help_outline_rounded,
                              'Help',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // Account Settings Section
                      _buildSectionTitle(context, 'Account Settings'),
                      _buildSettingsGroup([
                        _buildSettingsTile(
                          context,
                          Icons.shopping_bag_outlined,
                          'Order History',
                          onTap: () async {
                            if (isGuest) {
                              await AuthHelper.requireAuth(
                                context,
                                message: 'Sign in to view your order history.',
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                              );
                            }
                          },
                        ),
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

                      // Sign Out Button (only show if authenticated)
                      if (!isGuest)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              // 1. Sign out first
                              await context.read<AuthController>().signOut();
                              
                              // 2. Set guest mode flag to true so the user stays in the app
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('guest_mode', true);
                              
                              // 3. Scroll to the absolute top of the profile screen
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutQuint,
                                );
                              }
                            },
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

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool requiresAuth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 24),
              ),
              if (requiresAuth && !AuthHelper.isAuthenticated(context))
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
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
