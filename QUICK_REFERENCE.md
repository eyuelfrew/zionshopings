# Guest Mode - Quick Reference Card

## 🚀 Quick Start

### Enable Guest Mode
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('guest_mode', true);
```

### Check Authentication
```dart
// Method 1: With UI prompt
final isAuth = await AuthHelper.requireAuth(
  context,
  message: 'Custom message here',
);

// Method 2: Silent check
final isAuth = AuthHelper.isAuthenticated(context);
```

### Show Sign-In Sheet
```dart
final result = await SignInBottomSheet.show(
  context,
  message: 'Optional custom message',
);
// Returns true if signed in, false if dismissed
```

## 📋 Common Patterns

### Protect a Feature
```dart
Future<void> _protectedAction() async {
  final isAuth = await AuthHelper.requireAuth(
    context,
    message: 'Sign in to access this feature',
  );
  
  if (!isAuth) return;
  
  // Your protected code here
}
```

### Conditional UI
```dart
final isGuest = !AuthHelper.isAuthenticated(context);

if (isGuest) {
  // Show guest UI
} else {
  // Show authenticated UI
}
```

### Navigation with Auth Check
```dart
onTap: () async {
  final isAuth = await AuthHelper.requireAuth(context);
  
  if (isAuth && mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProtectedScreen()),
    );
  }
}
```

## 🎨 UI Components

### Guest Profile Header
```dart
if (isGuest) ...[
  Icon(Icons.person_outline_rounded, size: 48),
  Text('Guest User'),
  Text('Sign in for personalized experience'),
]
```

### Lock Badge
```dart
if (requiresAuth && !isAuthenticated) {
  Positioned(
    right: 0, top: 0,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.lock, size: 12),
    ),
  ),
}
```

### Sign-In Prompt Card
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
    ),
  ),
  child: Column(
    children: [
      Icon(Icons.card_giftcard_rounded),
      Text('Unlock Premium Features'),
      ElevatedButton(
        onPressed: () => SignInBottomSheet.show(context),
        child: Text('Sign In with Google'),
      ),
    ],
  ),
)
```

## 🔧 State Management

### Clear Guest Mode (After Sign In)
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('guest_mode', false);
```

### Sign Out Flow
```dart
await context.read<AuthController>().signOut();
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('guest_mode', false);
```

## 📱 Screen-Specific Code

### Product Card
```dart
// Wishlist
await AuthHelper.requireAuth(
  context,
  message: 'Sign in to save items to your wishlist...',
);

// Add to Cart
await AuthHelper.requireAuth(
  context,
  message: 'Sign in to add items to your bag...',
);
```

### Home Screen
```dart
// Wishlist Icon
onPressed: () async {
  final isAuth = await AuthHelper.requireAuth(
    context,
    message: 'Sign in to view your wishlist...',
  );
  if (isAuth && mounted) {
    Navigator.push(context, ...);
  }
}
```

### Profile Screen
```dart
// Quick Action
_buildQuickAction(
  context,
  Icons.favorite_border_rounded,
  'Wishlist',
  requiresAuth: true,
  onTap: () async {
    if (isGuest) {
      await AuthHelper.requireAuth(context, ...);
    } else {
      Navigator.push(context, ...);
    }
  },
)
```

## 🎯 Contextual Messages

### Wishlist
```
"Sign in to save items to your wishlist and access them across all your devices."
```

### Cart
```
"Sign in to add items to your bag and complete your purchase."
```

### Orders
```
"Sign in to view your order history and track deliveries."
```

### Addresses
```
"Sign in to manage your delivery addresses."
```

### Generic
```
"Please sign in to access this feature and enjoy a personalized shopping experience."
```

## 🐛 Debugging

### Check Guest Mode Status
```dart
final prefs = await SharedPreferences.getInstance();
final isGuest = prefs.getBool('guest_mode') ?? false;
print('Guest Mode: $isGuest');
```

### Check Auth Status
```dart
final authController = context.read<AuthController>();
final user = authController.state.user;
print('User: ${user?.email ?? "Not authenticated"}');
```

### Reset Everything
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.clear(); // Clears all preferences
// Restart app
```

## 📦 Dependencies

```yaml
dependencies:
  shared_preferences: ^2.2.2  # For guest mode flag
  provider: ^6.0.0            # For state management
  firebase_auth: ^6.1.3       # For authentication
```

## 🔗 Related Files

### Core Files
- `lib/utils/auth_helper.dart` - Auth utilities
- `lib/widgets/sign_in_bottom_sheet.dart` - Sign-in UI
- `lib/screens/auth_wrapper.dart` - Auth routing

### Modified Files
- `lib/screens/onboarding/onboarding_screen_4.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/widgets/product_card.dart`

## ⚡ Performance Tips

1. **Cache Auth Status**: Don't call `isAuthenticated()` repeatedly in build methods
2. **Use Consumer**: Wrap only necessary widgets with Consumer
3. **Async Handling**: Always check `mounted` before navigation after async calls
4. **State Updates**: Clear guest mode immediately after successful sign-in

## 🎓 Best Practices

1. ✅ Always provide contextual messages
2. ✅ Check `mounted` before navigation
3. ✅ Clear guest mode after sign-in
4. ✅ Use consistent UI patterns
5. ✅ Handle loading states
6. ✅ Provide "Maybe Later" option
7. ✅ Show value before requiring auth

## 🚨 Common Pitfalls

1. ❌ Forgetting to clear guest mode after sign-in
2. ❌ Not checking `mounted` after async operations
3. ❌ Blocking too many features for guests
4. ❌ Not providing clear value proposition
5. ❌ Inconsistent sign-in prompts
6. ❌ Missing error handling

## 📞 Support

For issues or questions:
1. Check `flutter analyze` output
2. Review implementation docs
3. Test with cleared app data
4. Verify SharedPreferences state
