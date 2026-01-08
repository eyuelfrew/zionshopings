Objective:
  You are an expert mobile app developer specializing in [Specify Framework, e.g., React Native, Flutter, Swift, Kotlin]. Your task is to build a "Product Listing" screen
  for an e-commerce application. This screen will display products fetched from a backend API and allow users to search, filter, and sort them.

  Core Features:
   1. Display Products: Fetch and display products in a user-friendly grid or list format.
   2. Filter by Category: Allow users to filter the product list by selecting a category.
   3. Search: Implement a real-time search functionality.
   4. Sort: Allow users to sort products by price or date.
   5. Pagination: Implement infinite scrolling to load more products as the user scrolls.

  ---

  API Details:

   * Base URL: [Your API Base URL, e.g., https://api.yourshop.com]
   * Endpoint: /api/products
   * Method: GET
   * Product Data Model: Each product object in the items array will have the following structure:

    1     {
    2         "id": 1,
    3         "name": "Smartphone X",
    4         "slug": "smartphone-x",
    5         "description": "A high-end smartphone with a great camera.",
    6         "price": 799.99,
    7         "discount": 50,
    8         "stock": 120,
    9         "sku": "SP-XYZ-001",
   10         "status": "active",
   11         "category": "Electronics",
   12         "brand": "TechCorp",
   13         "images": [
   14             { "path": "/uploads/products/1/image1.jpg", "altText": "Smartphone X" }
   15         ],
   16         "createdAt": "2025-12-26T10:00:00.000Z"
   17     }

   * Query Parameters:
       * category (string): Filters products by a specific category name (e.g., ?category=Electronics).
       * search (string): Filters products by a search term in the name or description.
       * sortBy (string): Sorts the list. Accepts price or date.
       * sortDir (string): Sets the sort direction. Accepts asc or desc.
       * page (integer): The page number for pagination (e.g., ?page=2).
       * limit (integer): The number of items to return per page (e.g., ?limit=20).

  ---

  Functional & UI/UX Requirements:

   1. Screen Layout:
       * A search bar at the top.
       * A dropdown or a set of filter chips to select a category.
       * A button or dropdown to select sorting preferences (e.g., "Price: Low to High").
       * A grid of "Product Cards" to display the results.

   2. Product Card Component:
       * Each card must display the primary product image, name, and price.
       * Tapping on a card should navigate to a (currently placeholder) Product Detail screen.

  ---

  Functional & UI/UX Requirements:

   1. Screen Layout:
       * A search bar at the top.
       * A dropdown or a set of filter chips to select a category.
       * A button or dropdown to select sorting preferences (e.g., "Price: Low to High").
       * A grid of "Product Cards" to display the results.

   2. Product Card Component:
       * Each card must display the primary product image, name, and price.
       * Tapping on a card should navigate to a (currently placeholder) Product Detail screen.


  Functional & UI/UX Requirements:

   1. Screen Layout:
       * A search bar at the top.
       * A dropdown or a set of filter chips to select a category.
       * A button or dropdown to select sorting preferences (e.g., "Price: Low to High").
       * A grid of "Product Cards" to display the results.

   2. Product Card Component:
       * Each card must display the primary product image, name, and price.
       * Tapping on a card should navigate to a (currently placeholder) Product Detail screen.


   1. Screen Layout:
       * A search bar at the top.
       * A dropdown or a set of filter chips to select a category.
       * A button or dropdown to select sorting preferences (e.g., "Price: Low to High").
       * A grid of "Product Cards" to display the results.

   2. Product Card Component:
       * Each card must display the primary product image, name, and price.
       * Tapping on a card should navigate to a (currently placeholder) Product Detail screen.

       * A dropdown or a set of filter chips to select a category.
       * A button or dropdown to select sorting preferences (e.g., "Price: Low to High").
       * A grid of "Product Cards" to display the results.

   2. Product Card Component:
       * Each card must display the primary product image, name, and price.
       * Tapping on a card should navigate to a (currently placeholder) Product Detail screen.


   2. Product Card Component:
       * Each card must display the primary product image, name, and price.
       * Tapping on a card should navigate to a (currently placeholder) Product Detail screen.

   2. Product Card Component:
       * Each card must display the primary product image, name, and price.
       * Tapping on a card should navigate to a (currently placeholder) Product Detail screen.

       * Each card must display the primary product image, name, and price.
       * Tapping on a card should navigate to a (currently placeholder) Product Detail screen.

   3. API Interaction & State Management:

   3. API Interaction & State Management:
   3. API Interaction & State Management:
       * On initial screen load, fetch the first page of products (/api/products?page=1&limit=20).
       * Search: As the user types in the search bar, debounce the input by 300ms before making a new API call with the search parameter.
       * Filtering: When a user selects a category, clear existing products and fetch the first page for that category.
       * Sorting: When a user changes the sort order, clear existing products and fetch the first page with the new sortBy and sortDir parameters.
       * Infinite Scroll: When the user scrolls to the bottom of the list, automatically fetch the next page and append the new products to the existing list.

   4. User Feedback:
       * Display a full-screen loading spinner during the initial data fetch.
       * Show a smaller loading indicator at the bottom of the list when fetching the next page for infinite scroll.
       * If the API returns an error, display a clear error message with a "Retry" button.
       * If a search or filter returns no results, display a "No products found" message.



       