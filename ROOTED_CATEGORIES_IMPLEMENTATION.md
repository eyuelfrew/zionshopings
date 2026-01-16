# Rooted Categories Implementation

## 🎯 Overview

Implemented a dynamic, hierarchical category navigation system using "Rooted Categories" that supports infinite depth navigation. The system intelligently determines whether to show sub-categories or products based on the category structure.

## 🏗️ Architecture

### API Endpoints Used

1. **GET /api/categories/roots**
   - Returns top-level categories (where `parentId` is null)
   - Used as the entry point for category navigation

2. **GET /api/categories/children/{id}**
   - Returns direct children of a specific category
   - Returns empty array if category has no children (leaf node)

3. **GET /api/categories** (Legacy)
   - Returns all categories
   - Kept for backward compatibility

## 📁 Files Created

### 1. `lib/screens/category_navigation_screen.dart` ✨ NEW
A reusable screen for navigating through category hierarchies at any depth.

**Features:**
- Loads root categories or sub-categories based on parent
- Beautiful grid layout with category cards
- Loading states with skeleton loaders
- Error handling with retry functionality
- Empty state handling
- Automatic navigation to products for leaf categories

**Usage:**
```dart
// Show root categories
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CategoryNavigationScreen(),
  ),
);

// Show sub-categories
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CategoryNavigationScreen(
      parentCategory: category,
      title: category.name,
    ),
  ),
);
```

## 📝 Files Modified

### 1. `lib/services/category_service.dart`
Added new methods for rooted category navigation:

```dart
// Fetch root categories
Future<List<Category>> getRootCategories()

// Fetch sub-categories of a specific category
Future<List<Category>> getSubCategories(int categoryId)

// Check if a category has children
Future<bool> hasChildren(int categoryId)
```

**Response Handling:**
- Handles multiple response structures from backend
- Returns empty list for 404 (no children)
- Robust error handling

### 2. `lib/screens/category_listing_screen.dart`
Updated to use the rooted category approach:

**Changes:**
- Now loads only root categories initially
- Implements dynamic navigation based on category structure
- Shows loading indicator while checking for children
- Navigates to `CategoryNavigationScreen` for parent categories
- Navigates to `CategoryProductsScreen` for leaf categories
- Improved UI with better card design
- Search functionality maintained

### 3. `lib/widgets/category_card.dart`
Minor fixes:
- Removed unused import
- Fixed `Stack.fitExpanding` to `StackFit.expand`

### 4. `lib/screens/category_products_screen.dart`
Added missing import for `CategoryCard` widget

### 5. `lib/screens/main_app_shell.dart`
Removed unused import

## 🔄 Navigation Flow

```
┌─────────────────────────────────────┐
│   CategoryListingScreen             │
│   (Shows Root Categories)           │
└──────────────┬──────────────────────┘
               │
               │ User taps category
               ▼
┌─────────────────────────────────────┐
│   Check if category has children    │
│   (API call to /children/{id})      │
└──────────────┬──────────────────────┘
               │
        ┌──────┴──────┐
        │             │
   Has Children    No Children
        │             │
        ▼             ▼
┌──────────────┐  ┌──────────────┐
│ Category     │  │  Category    │
│ Navigation   │  │  Products    │
│ Screen       │  │  Screen      │
│ (Sub-cats)   │  │  (Products)  │
└──────┬───────┘  └──────────────┘
       │
       │ User taps sub-category
       ▼
┌──────────────────────────────────┐
│  Repeat: Check for children      │
│  (Supports infinite depth)       │
└──────────────────────────────────┘
```

## 🎨 UI Components

### Category Card Design

**Features:**
- Full-width image with gradient overlay
- Category name and description overlaid on image
- Arrow indicator in top-right corner
- Smooth shadows and rounded corners
- Error handling with fallback icon
- Responsive to theme (light/dark mode)

**Visual Structure:**
```
┌─────────────────────────┐
│                         │
│    Category Image       │
│    with Gradient        │
│                         │
│    ┌─────────┐         │
│    │Category │    →    │
│    │Name     │         │
│    │Desc     │         │
│    └─────────┘         │
└─────────────────────────┘
```

### Loading States

1. **Skeleton Loaders**: Grid of shimmer placeholders
2. **Dialog Loader**: Circular progress indicator when checking children
3. **Pull-to-refresh**: Supported in listing screens

### Error States

1. **Error View**: Icon + message + retry button
2. **Empty View**: Icon + message (no categories found)
3. **Snackbar**: For navigation errors

## 💡 Key Features

### 1. Infinite Depth Support
- Categories can be nested to any level
- Each level uses the same `CategoryNavigationScreen`
- Navigation stack allows easy back navigation

### 2. Smart Navigation
```dart
Future<void> _onCategoryTap(Category category) async {
  // Show loading
  showDialog(...);
  
  // Check for children
  final children = await _categoryService.getSubCategories(category.id);
  
  // Dismiss loading
  Navigator.pop(context);
  
  if (children.isNotEmpty) {
    // Navigate to sub-categories
    Navigator.push(...CategoryNavigationScreen...);
  } else {
    // Navigate to products
    Navigator.push(...CategoryProductsScreen...);
  }
}
```

### 3. Robust Error Handling
- Network errors caught and displayed
- 404 responses treated as "no children"
- Retry functionality on errors
- User-friendly error messages

### 4. Search Functionality
- Search within current level categories
- Real-time filtering with debounce
- Clear button when search is active
- Maintains root categories for reset

### 5. Theme Support
- Adapts to light/dark mode
- Dynamic colors from category data
- Consistent with app theme

## 🔧 Technical Implementation

### Category Service Methods

```dart
// Get root categories
final roots = await CategoryService().getRootCategories();

// Get children of a category
final children = await CategoryService().getSubCategories(categoryId);

// Check if has children
final hasKids = await CategoryService().hasChildren(categoryId);
```

### Response Structure Handling

The service handles multiple response formats:
```json
// Format 1: Direct array
[{...}, {...}]

// Format 2: Wrapped in data
{
  "data": [{...}, {...}]
}

// Format 3: Nested in data.categories
{
  "data": {
    "categories": [{...}, {...}]
  }
}

// Format 4: Nested in data.children
{
  "data": {
    "children": [{...}, {...}]
  }
}
```

## 📊 State Management

### CategoryListingScreen State
```dart
bool _isLoading = true;
List<Category> _rootCategories = [];
List<Category> _filteredCategories = [];
String? _error;
String _searchQuery = '';
```

### CategoryNavigationScreen State
```dart
bool _isLoading = true;
List<Category> _categories = [];
String? _error;
```

## 🎯 User Experience

### Navigation Breadcrumbs
- AppBar title shows current category name
- Back button navigates to parent level
- Root level shows "Categories"

### Visual Feedback
1. **Loading**: Skeleton loaders + dialog spinner
2. **Success**: Smooth navigation transitions
3. **Error**: Clear error messages with retry
4. **Empty**: Helpful empty state messages

### Performance
- Lazy loading of categories (only load when needed)
- Efficient API calls (only fetch children when tapped)
- Debounced search (300ms delay)
- Cached images with error fallbacks

## 🧪 Testing Scenarios

### Test Case 1: Root Categories
```
1. Open Categories tab
2. Should show root categories
3. Tap a category with children
4. Should navigate to sub-categories
```

### Test Case 2: Leaf Category
```
1. Navigate to a category
2. Tap a category without children
3. Should navigate to products screen
```

### Test Case 3: Deep Nesting
```
1. Navigate: Electronics → Phones → Smartphones → Android
2. Each level should load correctly
3. Back button should work at each level
```

### Test Case 4: Search
```
1. Type in search box
2. Categories should filter in real-time
3. Clear search should restore all categories
```

### Test Case 5: Error Handling
```
1. Disconnect network
2. Try to navigate
3. Should show error with retry button
4. Reconnect and retry
5. Should work correctly
```

## 🚀 Future Enhancements

### Potential Improvements
1. **Breadcrumb Navigation**: Show full path in UI
2. **Category Icons**: Add icon support alongside images
3. **Favorites**: Allow users to favorite categories
4. **Recent Categories**: Show recently viewed categories
5. **Category Filters**: Filter by attributes within categories
6. **Offline Support**: Cache category structure
7. **Analytics**: Track category navigation patterns
8. **Deep Linking**: Support direct links to categories

### Performance Optimizations
1. **Prefetching**: Preload likely next categories
2. **Image Caching**: Better image cache strategy
3. **Pagination**: For categories with many children
4. **Virtual Scrolling**: For very long category lists

## 📚 Code Examples

### Example 1: Navigate to Root Categories
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CategoryNavigationScreen(),
  ),
);
```

### Example 2: Navigate to Sub-Categories
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CategoryNavigationScreen(
      parentCategory: selectedCategory,
      title: selectedCategory.name,
    ),
  ),
);
```

### Example 3: Check for Children
```dart
final categoryService = CategoryService();
final children = await categoryService.getSubCategories(category.id);

if (children.isNotEmpty) {
  // Has children - show sub-categories
} else {
  // Leaf category - show products
}
```

### Example 4: Custom Category Card
```dart
Widget _buildCategoryCard(Category category) {
  return GestureDetector(
    onTap: () => _onCategoryTap(category),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // ... styling
      ),
      child: Stack(
        children: [
          // Image
          Image.network(imageUrl),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(...),
            ),
          ),
          // Category info
          Positioned(
            bottom: 0,
            child: Text(category.name),
          ),
        ],
      ),
    ),
  );
}
```

## 🔍 Debugging Tips

### Check API Responses
```dart
print('Root categories: ${roots.length}');
print('Children of ${category.id}: ${children.length}');
```

### Verify Navigation
```dart
print('Navigating to: ${category.name}');
print('Has children: ${children.isNotEmpty}');
```

### Monitor State
```dart
print('Loading: $_isLoading');
print('Error: $_error');
print('Categories: ${_categories.length}');
```

## ✅ Implementation Checklist

- [x] Create CategoryService methods for rooted categories
- [x] Create CategoryNavigationScreen for recursive navigation
- [x] Update CategoryListingScreen to use root categories
- [x] Implement smart navigation (children vs products)
- [x] Add loading states and error handling
- [x] Design beautiful category cards
- [x] Support search functionality
- [x] Handle empty states
- [x] Support theme (light/dark mode)
- [x] Fix all linting errors
- [x] Test navigation flow
- [x] Document implementation

## 🎉 Summary

The rooted category system provides a flexible, scalable solution for hierarchical category navigation. It supports infinite depth, handles errors gracefully, and provides an excellent user experience with smooth animations and clear visual feedback.

**Key Benefits:**
- ✅ Infinite depth support
- ✅ Smart navigation logic
- ✅ Beautiful UI with modern design
- ✅ Robust error handling
- ✅ Search functionality
- ✅ Theme support
- ✅ Performance optimized
- ✅ Maintainable code structure
