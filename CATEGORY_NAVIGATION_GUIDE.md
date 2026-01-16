# Category Navigation - Quick Reference Guide

## 🚀 Quick Start

### Using the Category Service

```dart
import 'package:zionshopings/services/category_service.dart';

final categoryService = CategoryService();

// Get root categories
final roots = await categoryService.getRootCategories();

// Get children of a category
final children = await categoryService.getSubCategories(categoryId);

// Check if category has children
final hasChildren = await categoryService.hasChildren(categoryId);
```

### Navigation Pattern

```dart
Future<void> _onCategoryTap(Category category) async {
  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    // Check for children
    final children = await categoryService.getSubCategories(category.id);
    
    // Dismiss loading
    if (mounted) Navigator.pop(context);

    if (children.isNotEmpty) {
      // Has children - navigate to sub-categories
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryNavigationScreen(
              parentCategory: category,
              title: category.name,
            ),
          ),
        );
      }
    } else {
      // No children - navigate to products
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(
              category: category,
            ),
          ),
        );
      }
    }
  } catch (e) {
    // Handle error
    if (mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

## 📱 Screen Usage

### CategoryListingScreen
**Purpose**: Entry point showing root categories
**Location**: Bottom navigation "Categories" tab

```dart
// Already integrated in MainAppShell
const CategoryListingScreen()
```

**Features:**
- Shows root categories only
- Search functionality
- Smart navigation to sub-categories or products

### CategoryNavigationScreen
**Purpose**: Recursive screen for any category level
**Usage**: Navigate to sub-categories

```dart
// Show root categories
CategoryNavigationScreen()

// Show sub-categories
CategoryNavigationScreen(
  parentCategory: category,
  title: category.name,
)
```

**Features:**
- Loads children of parent category
- Supports infinite depth
- Loading and error states
- Beautiful grid layout

### CategoryProductsScreen
**Purpose**: Show products for a leaf category
**Usage**: Navigate when category has no children

```dart
CategoryProductsScreen(category: category)
```

## 🎨 UI Components

### Category Card

```dart
Widget _buildCategoryCard(Category category) {
  final imageUrl = category.image.startsWith('http')
      ? category.image
      : 'http://localhost:5000${category.image}';

  return GestureDetector(
    onTap: () => _onCategoryTap(category),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [...],
      ),
      child: Column(
        children: [
          // Image with gradient overlay
          Expanded(
            child: Stack(
              children: [
                Image.network(imageUrl),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(...),
                  ),
                ),
                // Category name overlay
                Positioned(
                  bottom: 0,
                  child: Text(category.name),
                ),
                // Arrow indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Loading State

```dart
Widget _buildLoadingSkeleton() {
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
    ),
    itemBuilder: (context, index) => const SkeletonLoader(height: 200),
  );
}
```

### Error State

```dart
Widget _buildErrorView() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text('Oops! Something went wrong'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _loadCategories,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

### Empty State

```dart
Widget _buildEmptyView() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('No categories found'),
        Text('There are no categories available'),
      ],
    ),
  );
}
```

## 🔄 Navigation Flows

### Flow 1: Root → Sub-Category → Products
```
CategoryListingScreen (Roots)
    ↓ Tap "Electronics"
CategoryNavigationScreen (Electronics children)
    ↓ Tap "Phones"
CategoryNavigationScreen (Phones children)
    ↓ Tap "Smartphones" (leaf)
CategoryProductsScreen (Smartphones products)
```

### Flow 2: Root → Products (Direct)
```
CategoryListingScreen (Roots)
    ↓ Tap "Accessories" (leaf)
CategoryProductsScreen (Accessories products)
```

### Flow 3: Search → Navigate
```
CategoryListingScreen (Roots)
    ↓ Search "Phone"
CategoryListingScreen (Filtered)
    ↓ Tap "Phones"
CategoryNavigationScreen (Phones children)
```

## 🛠️ Common Patterns

### Pattern 1: Load Categories
```dart
Future<void> _loadCategories() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final categories = widget.parentCategory == null
        ? await _categoryService.getRootCategories()
        : await _categoryService.getSubCategories(widget.parentCategory!.id);

    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}
```

### Pattern 2: Search with Debounce
```dart
Timer? _debounceTimer;

void _setupSearchController() {
  _searchController.addListener(() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterCategories();
      });
    });
  });
}

void _filterCategories() {
  if (_searchQuery.isEmpty) {
    setState(() {
      _filteredCategories = _rootCategories;
    });
  } else {
    setState(() {
      _filteredCategories = _rootCategories.where((category) =>
        category.name.toLowerCase().contains(_searchQuery) ||
        (category.description?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    });
  }
}
```

### Pattern 3: Error Handling
```dart
try {
  final children = await _categoryService.getSubCategories(category.id);
  // Success handling
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading category: $e'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => _onCategoryTap(category),
        ),
      ),
    );
  }
}
```

## 📊 State Management

### Screen State
```dart
class _CategoryNavigationScreenState extends State<CategoryNavigationScreen> {
  bool _isLoading = true;
  List<Category> _categories = [];
  String? _error;
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
```

### Loading States
```dart
// Initial load
if (_isLoading) return _buildLoadingSkeleton();

// Error state
if (_error != null) return _buildErrorView();

// Empty state
if (_categories.isEmpty) return _buildEmptyView();

// Success state
return _buildCategoryGrid();
```

## 🎯 Best Practices

### 1. Always Check `mounted`
```dart
if (mounted) {
  Navigator.push(...);
}
```

### 2. Show Loading Feedback
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => const Center(
    child: CircularProgressIndicator(),
  ),
);
```

### 3. Handle Errors Gracefully
```dart
try {
  // API call
} catch (e) {
  // Show user-friendly error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### 4. Provide Retry Options
```dart
ElevatedButton.icon(
  onPressed: _loadCategories,
  icon: const Icon(Icons.refresh),
  label: const Text('Retry'),
)
```

### 5. Use Debounce for Search
```dart
Timer(const Duration(milliseconds: 300), () {
  // Perform search
});
```

## 🐛 Debugging

### Check API Responses
```dart
print('Root categories: ${roots.length}');
roots.forEach((cat) => print('  - ${cat.name} (ID: ${cat.id})'));

print('Children of ${category.name}: ${children.length}');
children.forEach((cat) => print('  - ${cat.name} (ID: ${cat.id})'));
```

### Verify Navigation Logic
```dart
print('Category tapped: ${category.name}');
print('Has children: ${children.isNotEmpty}');
print('Navigating to: ${children.isNotEmpty ? "Sub-categories" : "Products"}');
```

### Monitor State Changes
```dart
setState(() {
  print('State updated:');
  print('  Loading: $_isLoading');
  print('  Error: $_error');
  print('  Categories: ${_categories.length}');
  _isLoading = false;
});
```

## 📝 Checklist

### Before Navigation
- [ ] Check if category has children
- [ ] Show loading indicator
- [ ] Handle mounted state

### During Navigation
- [ ] Pass correct parameters
- [ ] Use appropriate screen
- [ ] Maintain navigation stack

### After Navigation
- [ ] Dismiss loading indicator
- [ ] Handle errors
- [ ] Update UI state

## 🔗 Related Files

### Core Files
- `lib/services/category_service.dart` - API service
- `lib/screens/category_navigation_screen.dart` - Navigation screen
- `lib/screens/category_listing_screen.dart` - Root categories
- `lib/screens/category_products_screen.dart` - Products screen

### Supporting Files
- `lib/models/category_model.dart` - Category model
- `lib/widgets/category_card.dart` - Category card widget
- `lib/widgets/skeleton_loader.dart` - Loading skeleton

## 💡 Tips

1. **Performance**: Only load categories when needed
2. **UX**: Always show loading feedback
3. **Errors**: Provide clear error messages and retry options
4. **Search**: Use debounce to avoid excessive API calls
5. **Images**: Handle loading errors with fallback icons
6. **Theme**: Support both light and dark modes
7. **Navigation**: Use Navigator.push for proper back button support

## 🎓 Examples

### Example 1: Simple Category Navigation
```dart
// In your widget
onTap: () async {
  final children = await CategoryService().getSubCategories(category.id);
  
  if (children.isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryNavigationScreen(
          parentCategory: category,
          title: category.name,
        ),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(category: category),
      ),
    );
  }
}
```

### Example 2: With Error Handling
```dart
onTap: () async {
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    final children = await CategoryService().getSubCategories(category.id);
    Navigator.pop(context); // Dismiss loading

    if (children.isNotEmpty) {
      Navigator.push(context, ...);
    } else {
      Navigator.push(context, ...);
    }
  } catch (e) {
    Navigator.pop(context); // Dismiss loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### Example 3: With Search
```dart
final filteredCategories = _rootCategories.where((category) =>
  category.name.toLowerCase().contains(_searchQuery) ||
  (category.description?.toLowerCase().contains(_searchQuery) ?? false)
).toList();
```
