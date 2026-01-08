The "Nykaa-Style" Product Card Prompt
Task: Rewrite the ProductCard widget in Flutter to match a premium e-commerce design (Nykaa/Sephora aesthetic).

Structural Layout:

Container: Use a clean white background with a very subtle border (Colors.grey[200]) and a BorderRadius of 8. Remove heavy shadows.

Top Image Area:

An AspectRatio of 1:1 for the product image.

Header: Overlay a text "COMPLETE MAKEUP KIT" in an elegant Serif font (or italicized TextStyle) at the top of the image area.

Favorite Icon: A small circular white container in the bottom-left of the image area containing a heart_plus or favorite_border icon.

Brand & Title Section:

Status Label: Small purple text "ONLY AT NYKAA" in all caps.

Brand Name: Bold black text for the brand (e.g., "SUGAR").

Product Name: Medium-weight text with maxLines: 2 and ellipsis.

Attribute Label: A small grey text for product count (e.g., "8 Pcs").

Pricing Section:

Horizontal Row: Show the Discounted Price (bold), the Strikethrough Original Price (grey), and a vertical divider leading to a green "Percentage Off" text (e.g., "35% Off").

Status Badges:

A "Price Dropped" badge: A light green pill-shaped container with a down-arrow icon and green text.

Rating:

A row of 5 stars (filled based on product.rating) followed by the review count in parentheses.

Footer Action:

A full-width, bright pink (Color(0xFFFC2779)) "Add to Bag" button with a shopping bag icon.

Constraints: Ensure the widget is "overflow-safe" using Flexible and FittedBox for text elements so that long names do not break the card layout in a 2-column GridView.

Tips for your AI Agent:
Color Palette: Specifically tell it to use Fuchsia Pink (#FC2779) for the primary action button to get that signature beauty-store look.

Spacing: Ask it to use MainAxisAlignment.spaceBetween in the main Column to ensure the "Add to Bag" button always sticks to the very bottom of the card, regardless of text length.