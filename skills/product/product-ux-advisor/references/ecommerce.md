# E-commerce UX Patterns

## Criticality Rules for E-commerce

A pattern is **Critical** when it directly impacts conversion rate or purchase confidence.
A pattern is **Recommended** when it reduces friction or increases average order value.
A pattern is **Polish** when it improves perceived quality or brand trust.

---

## Product Detail Page (PDP)

### Image Gallery / Carousel
**Critical for**: any product with visual appeal (fashion, furniture, electronics, food)
**Skip when**: commodity products where image doesn't drive decision (e.g. screws, raw materials)
**What it needs**:
- Thumbnail strip + main image (zoom on hover/tap)
- Multiple angles: front, back, detail, lifestyle/context shot
- Mobile: swipeable, dots indicator
- Zoom: pinch-to-zoom on mobile, hover zoom on desktop
**Anti-patterns**: single static image, autoplay carousel without user control, tiny thumbnails
**Real examples**: Zara (editorial + product), Apple (product angles + lifestyle), ASOS (360 + video)

### Product Video
**Recommended for**: fashion, gadgets, home decor, anything where motion shows value
**What it is**: short loop video (5-15s) showing product in use, plays on hover/tap
**Real example**: Allbirds product videos, Nike sneaker 360

### Size / Variant Selector
**Critical for**: any product with variants (size, color, material)
**What it needs**:
- Color swatches (not just a dropdown) — visual selection
- Out-of-stock variants clearly marked (greyed out, not hidden)
- Size guide link next to size selector
- Selected variant reflected in the image gallery immediately
**Anti-pattern**: hiding out-of-stock options (user can't see availability at a glance)

### Trust Signals on PDP
**Critical for**: any store without brand recognition
**Components**:
- Star rating + review count near the title (not below the fold)
- "X people are viewing this" or "X sold this week" (social proof + urgency)
- Shipping estimate ("Arrives by Thursday")
- Return policy in one line near the CTA
- Payment methods icons near checkout CTA

### Sticky Add to Cart
**Critical for**: products with long descriptions or many variants
**What it is**: CTA button stays fixed as user scrolls down the PDP
**Real example**: Amazon's sticky right panel, most Shopify themes

### Reviews & Ratings Section
**Critical for**: any store without strong brand recognition — reviews replace trust
**What it needs**:
- Average rating + total count near the product title (above the fold, always)
- Rating breakdown: bar chart showing distribution (5★ 60%, 4★ 20%, etc.)
- Filter reviews by: star rating, with photos, verified purchase
- Customer photos/videos in reviews — highest trust signal after gallery
- Seller/brand response to negative reviews
- "Helpful / Not helpful" voting on reviews
- Pagination or "Load more" — don't show all 200 reviews at once
**Anti-patterns**: reviews hidden below the fold with no anchor link, fake-looking 5-star-only reviews, no way to filter
**Real examples**: Amazon (best-in-class review UX), Sephora (photos + skin type filter), MercadoLibre

### Notify Me When Back in Stock
**Critical for**: any store with inventory limits or products that go out of stock
**What it is**: when a variant is OOS, replace "Add to Cart" with an email/SMS capture: "Notify me when available"
**What it needs**:
- Replaces or sits below the disabled CTA — not hidden
- Single input (email or phone), minimal friction
- Confirmation: "We'll notify you the moment it's back"
- Optional: show how many people are waiting ("47 people waiting") — creates urgency when restocked
**Anti-pattern**: just greying out the button with no action — user has no reason to come back
**Real examples**: Nike (size OOS → notify me), ASOS, most Shopify themes via back-in-stock apps

### Related Products / You May Also Like
**Recommended for**: stores with >20 products
**What it is**: horizontal scroll of related or complementary products, placed below the main CTA or at the bottom of the PDP
**Types**:
- Same category / similar products (for undecided users)
- "Complete the look" / "Frequently bought together" (increases AOV)
- Recently viewed (personalized, high relevance)
**Anti-pattern**: generic "featured products" that aren't related to what the user is viewing
**Placement**: after the description but before reviews, or sticky at the bottom on mobile

---

## Category / Listing Page (PLP)

### Product Card
**Critical**: the card IS the product on a listing page
**Needs**:
- Image that fills the card (not letterboxed with whitespace)
- Hover: second image (alternate angle or lifestyle) — increases CTR significantly
- Price visible without hover
- Quick add to cart on hover (optional but high impact)
- Badge system: "New", "Sale", "Best Seller", "Low Stock"

### Filter & Sort
**Critical for**: catalogs with >20 products
**What it needs**:
- Filters persist without page reload (URL params for shareability)
- Active filters visible as removable chips
- Sort by: featured, price low/high, newest, best rated
- Mobile: filter as bottom sheet, not sidebar
**Anti-pattern**: filters that require a full page reload, hidden active filters

### Infinite Scroll vs Pagination
- **Infinite scroll**: better for browsing/discovery (fashion, inspiration)
- **Pagination**: better for goal-oriented shopping (electronics, search results)
- **Load more button**: good middle ground — user controls loading, preserves scroll position

---

## Cart

### Mini Cart / Drawer Cart
**Recommended for**: stores where users add multiple items
**What it is**: sliding drawer that appears when adding to cart, without leaving the page
**Why**: keeps user in shopping flow, shows order summary, upsell opportunity
**Real example**: most modern Shopify themes, Net-a-Porter

### Cart Empty State
**Critical**: often forgotten
**What it needs**: not just "Your cart is empty" — show featured products or "continue shopping" CTA

### Cross-sell / Upsell in Cart
**Recommended**: "Frequently bought together" or "Complete the look"
**When**: show in cart drawer or cart page, max 3-4 suggestions
**Anti-pattern**: aggressive upsell that blocks checkout CTA

---

## Checkout

### Progress Indicator
**Critical**: users abandon when they don't know how many steps remain
**Typical steps**: Cart → Information → Shipping → Payment → Confirmation
**What it needs**: current step highlighted, completed steps checkmarked, future steps visible

### Guest Checkout
**Critical**: forcing account creation before purchase kills conversion
**Pattern**: offer guest checkout prominently, offer account creation AFTER purchase confirmation

### Address Autocomplete
**Recommended**: Google Places or similar — reduces form friction significantly
**Real example**: every major checkout (Shopify, Stripe)

### Order Summary Persistence
**Critical**: order summary visible on every checkout step (not just the first)
**Mobile**: collapsible summary at the top, expanded by default on desktop

### Trust at Checkout
**Critical for**: unknown brands
**Components**:
- SSL badge / "Secure checkout" label
- Payment method logos (Visa, MC, PayPal, Apple Pay)
- Money-back guarantee reminder
- No hidden fees message near total

---

## Post-Purchase

### Order Confirmation Page
**Critical**: this page has the highest engagement of any page — use it
**What to include**:
- Order number prominently
- Summary of what was ordered (with images)
- Estimated delivery date
- "Track your order" CTA
- Account creation prompt (if guest) — "Save your details for next time"
- Referral or social share prompt

### Transactional Emails
**Critical**: order confirmation, shipping notification, delivery confirmation
**Anti-pattern**: plain text emails with no product image — missed brand opportunity

---

## Discovery & Navigation

### Search with Autocomplete
**Critical for**: catalogs with >50 products
**What it needs**: product suggestions with image + price as you type, recent searches, popular searches

### Breadcrumbs
**Recommended for**: deep category structures
**What it is**: Home > Category > Subcategory > Product — helps navigation and SEO

### Recently Viewed
**Recommended**: persistent across sessions
**Where**: footer of PDP, sidebar, dedicated section on homepage

---

## E-commerce Product Type Matrix

| Store Type | Critical Patterns |
|---|---|
| Fashion / Apparel | Image gallery (multiple angles), size selector + guide, color swatches, hover second image, fit description |
| Electronics | Spec comparison, variant selector, "compatible with", trust signals, detailed reviews |
| Home & Furniture | Lifestyle images + room context, AR view (nice-to-have), dimensions prominently, fabric/material swatches |
| Food & Beverage | Ingredients/allergens visible, quantity selector, subscription option, freshness/delivery timing |
| Marketplace (multi-vendor) | Seller rating + info, shipping per seller, unified cart across sellers |
| Luxury / High-ticket | Editorial imagery, no "sale" badges, minimal UI, contact/concierge CTA, no aggressive urgency |
