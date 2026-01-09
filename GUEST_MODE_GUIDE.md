# Guest Mode - Quick Visual Guide

## 🎯 What Changed?

### 1. Last Onboarding Screen
```
Before:
[Continue Button] → Goes to Login Screen

After:
[Sign In with Google Button] → Goes to Login Screen
[Skip for now] → Goes directly to app as guest
```

### 2. Login Screen
```
Before:
[Continue with Google]

After:
[Continue with Google]
[Continue as Guest] ← NEW
```

### 3. Profile Screen - Guest View
```
┌─────────────────────────────────┐
│  👤 Guest User                  │
│  Sign in for personalized exp   │
├─────────────────────────────────┤
│                                 │
│  🎁 Unlock Premium Features     │
│  Sign in to save wishlist...    │
│  [Sign In with Google]          │
│                                 │
├─────────────────────────────────┤
│  📦🔒  ❤️🔒  📍🔒  ❓          │
│  Orders Wishlist Address Help   │
│  (locked icons for guests)      │
└─────────────────────────────────┘
```

### 4. Profile Screen - Authenticated View
```
┌─────────────────────────────────┐
│  Jane Doe                       │
│  jane@example.com               │
├─────────────────────────────────┤
│  📦   ❤️   📍   ❓             │
│  Orders Wishlist Address Help   │
│  (all unlocked)                 │
├─────────────────────────────────┤
│  [Sign Out]                     │
└─────────────────────────────────┘
```

### 5. Sign-In Bottom Sheet (NEW!)
```
┌─────────────────────────────────┐
│         ────                    │
│                                 │
│         🔒                      │
│                                 │
│    Sign In Required             │
│                                 │
│  Please sign in to access       │
│  this feature...                │
│                                 │
│  [🔵 Sign In with Google]       │
│  [Maybe Later]                  │
│                                 │
└─────────────────────────────────┘
```

## 🔐 Protected Actions

When a guest user tries these actions, they see the sign-in sheet:

### Product Card
- ❤️ **Add to Wishlist** → "Sign in to save items to your wishlist..."
- 🛍️ **Add to Bag** → "Sign in to add items to your bag..."

### Header Icons
- ❤️ **Wishlist Icon** → "Sign in to view your wishlist..."
- 🛒 **Cart Icon** → "Sign in to view your shopping bag..."

### Profile Quick Actions
- 📦 **Orders** → Requires sign-in
- ❤️ **Wishlist** → Requires sign-in
- 📍 **Addresses** → Requires sign-in
- ❓ **Help** → Available to all

## 🎨 UI Indicators

### Guest Mode Indicators:
1. **Profile Header**: Shows "Guest User" with person icon
2. **Lock Icons**: Small orange lock badges on protected features
3. **Premium Card**: Pink gradient card promoting sign-in benefits

### Authenticated Indicators:
1. **Profile Header**: Shows user name and email
2. **No Lock Icons**: All features accessible
3. **Sign Out Button**: Visible at bottom of profile

## 📱 User Journeys

### Journey 1: Guest → Browse → Sign In
```
Onboarding → Skip → Browse Products → Try to Add to Wishlist 
→ Sign-In Sheet Appears → Sign In → Action Completes
```

### Journey 2: Guest → Profile → Sign In
```
Onboarding → Skip → Browse → Go to Profile 
→ See Guest UI → Click "Sign In with Google" → Authenticated
```

### Journey 3: Direct Sign In
```
Onboarding → Sign In with Google → Authenticated → Full Access
```

### Journey 4: Login Screen Guest
```
Onboarding → Continue → Login Screen → Continue as Guest 
→ Browse as Guest
```

## 🔄 State Management

### SharedPreferences Flags:
```dart
'has_completed_onboarding': true/false
'guest_mode': true/false
```

### State Transitions:
```
Initial → Onboarding → (Skip) → guest_mode=true → Guest Access
Initial → Onboarding → (Sign In) → guest_mode=false → Full Access
Guest → (Sign In) → guest_mode=false → Full Access
Authenticated → (Sign Out) → guest_mode=false → Login Screen
```

## 💡 Key Features

### ✅ What Guests CAN Do:
- Browse all products
- View product details
- Search products
- Browse categories
- View promotional content
- Access help center
- Toggle dark/light theme

### ❌ What Guests CANNOT Do:
- Add to wishlist
- Add to cart
- View orders
- Manage addresses
- Access personalized features

## 🎯 Benefits

### For Users:
- ✨ Instant access to browse
- 🚀 No signup friction
- 🔒 Sign in only when needed
- 💝 Contextual sign-in prompts

### For Business:
- 📈 Lower bounce rate
- 🎯 Better conversion funnel
- 💡 Users see value before committing
- 🔄 Easy upgrade path to authenticated

## 🛠️ Technical Implementation

### Files Modified:
1. `lib/screens/onboarding/onboarding_screen_4.dart`
2. `lib/screens/auth_wrapper.dart`
3. `lib/screens/login_screen.dart`
4. `lib/screens/profile_screen.dart`
5. `lib/screens/home_screen.dart`
6. `lib/widgets/product_card.dart`

### Files Created:
1. `lib/widgets/sign_in_bottom_sheet.dart` ✨
2. `lib/utils/auth_helper.dart` ✨

### Key Utilities:
```dart
// Check auth and show sheet if needed
await AuthHelper.requireAuth(context, message: "...");

// Simple auth check
bool isAuth = AuthHelper.isAuthenticated(context);

// Show sign-in sheet manually
await SignInBottomSheet.show(context, message: "...");
```

## 🧪 Testing Tips

1. **Clear App Data** between tests to reset onboarding
2. **Test Both Flows**: Skip and Sign In
3. **Try All Protected Actions** as guest
4. **Verify State Persistence** after app restart
5. **Test Sign Out** and re-authentication

## 📝 Notes

- Facebook sign-in code is commented throughout for future implementation
- All sign-in prompts use contextual messages
- Guest mode persists across app restarts
- Signing in automatically clears guest mode
- Beautiful, consistent UI across all sign-in touchpoints
