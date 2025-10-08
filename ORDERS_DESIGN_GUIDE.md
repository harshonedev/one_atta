# Orders Page - Visual Design Guide

## Color Palette

### Status Colors
```
Delivered:   Green (#4CAF50 / Colors.green.shade700)
Shipped:     Blue (#1976D2 / Colors.blue.shade700)
Processing:  Orange (#F57C00 / Colors.orange.shade700)
Confirmed:   Purple (#7B1FA2 / Colors.purple.shade700)
Pending:     Amber (#F57F17 / Colors.amber.shade700)
Cancelled:   Red (#D32F2F / Colors.red.shade700)
```

### Payment Status Colors
```
Paid:              Green
Pending:           Orange
Failed:            Red
Refunded:          Blue
```

## Component Breakdown

### 1. Orders Page Header
```
┌─────────────────────────────────────┐
│ My Orders                           │ ← titleLarge, bold
│ Track and manage your orders        │ ← bodyMedium, variant
│                                     │
│ ╔═══╦═══╦═══╦═══╗                  │
│ ║All║Act║Com║Can║ ← Tab Bar         │
│ ╚═══╩═══╩═══╩═══╝                  │
└─────────────────────────────────────┘
```

### 2. Order Card Layout
```
┌─────────────────────────────────────┐
│ Order #A1B2C3D4    [🔵 Shipped]    │
│ 📅 12 Oct 2025, 10:30 AM           │
│─────────────────────────────────────│
│ • Product Name 1 (2kg)      ₹300   │
│ • Blend Name (1kg)           ₹150   │
│ +2 more items                       │
│                                     │
│ [✓ Paid]        Total: ₹560 [💰]   │
└─────────────────────────────────────┘
```

### 3. Order Detail Page Structure

#### Header Card (Gradient)
```
┌─────────────────────────────────────┐
│ Order ID               [Status]     │
│ #A1B2C3D4 📋                       │
│ 📅 12 October 2025, 10:30 AM       │
└─────────────────────────────────────┘
```

#### Timeline Section
```
┌─────────────────────────────────────┐
│ Order Status                        │
│                                     │
│ ● ─ Order Placed                   │
│ │   12 Oct, 10:30 AM               │
│ │                                   │
│ ● ─ Order Confirmed                │
│ │   12 Oct, 11:00 AM               │
│ │                                   │
│ ◯ ─ Processing                     │
│ │   Waiting...                     │
│ │                                   │
│ ◯ ─ Shipped                        │
│ │   Waiting...                     │
│ │                                   │
│ ◯   Delivered                      │
│     Waiting...                     │
└─────────────────────────────────────┘
```

#### Order Items Card
```
┌─────────────────────────────────────┐
│ Order Items (3)                     │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [🌾] Product Name    ₹300       │ │
│ │      [Blend] 2kg × ₹150         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [📦] Another Product  ₹200      │ │
│ │      [Product] 1kg × ₹200       │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### Price Breakdown Card
```
┌─────────────────────────────────────┐
│ Price Breakdown                     │
│                                     │
│ Subtotal                      ₹500  │
│ Discount (SAVE10)            -₹50   │ ← Green
│ Atta Points (100)            -₹10   │ ← Green
│ Delivery Charges              ₹40   │
│ COD Charges                   ₹20   │
│─────────────────────────────────────│
│ Total Amount                  ₹500  │ ← Primary color, bold
└─────────────────────────────────────┘
```

## Typography Hierarchy

```
┌──────────────────────────────────────────┐
│ headlineMedium (28sp, Bold)              │ ← Page title
│   titleLarge (22sp, Bold)                │ ← Section headers
│     titleMedium (16sp, Bold)             │ ← Card titles
│       titleSmall (14sp, w600)            │ ← Item names
│         bodyMedium (14sp, Regular)       │ ← Normal text
│           bodySmall (12sp, Regular)      │ ← Subtitles
│             labelSmall (11sp, w700)      │ ← Chips
└──────────────────────────────────────────┘
```

## Spacing System

### Padding
- Large containers: 20px
- Medium containers: 16px
- Small items: 12px
- Chips: 8-10px horizontal, 4-6px vertical

### Margins
- Between sections: 16px
- Between cards: 12px
- Between elements: 8-16px

### Border Radius
- Cards: 16px
- Buttons: 12px
- Chips: 20px (pill)
- Small elements: 8-12px

## Interactive Elements

### Status Chips
```
Format: [Icon] Text
Size: labelSmall (11sp)
Padding: 10-12px horizontal, 6-8px vertical
Border Radius: 20px (pill-shaped)
Background: Status color @ 15% opacity
Text/Icon: Status color @ 700 shade
```

### Action Buttons
```
Primary Action:
- Background: Primary color
- Text: onPrimary color
- Padding: 16px vertical, 32px horizontal
- Border Radius: 12px

Secondary Action:
- Background: Red.shade50
- Text: Red.shade700
- Same padding/radius as primary
```

### Timeline Indicators
```
Active/Completed:
- Circle: 32px diameter
- Background: Primary color
- Icon: onPrimary color
- Border: 2px primary color

Pending:
- Circle: 32px diameter
- Background: surfaceContainerHighest
- Icon: onSurfaceVariant
- Border: 2px outlineVariant
```

## Elevation & Shadows

### Cards
```
Background: surfaceContainerHighest @ 30% opacity
Border: outlineVariant @ 50% opacity, 1px
Shadow: None (flat design with borders)
```

### Header Cards
```
Background: Gradient
  - primaryContainer @ 60% opacity
  - secondaryContainer @ 40% opacity
Border: None
Shadow: None
```

## Icon Usage

### Icons by Category
```
Status:
- Delivered: check_circle_outline
- Shipped: local_shipping_outlined
- Processing: autorenew
- Confirmed: assignment_turned_in_outlined
- Pending: schedule
- Cancelled: cancel_outlined

Actions:
- Calendar: calendar_today_outlined
- Location: location_on_outlined
- Payment: payment_outlined
- Copy: copy
- Phone: phone_outlined
- Note: note_outlined
- Refresh: refresh

Items:
- Blend: blender
- Product: inventory_2_outlined
```

## Animation Guidelines

### Page Transitions
- Use default GoRouter transitions
- Smooth fade/slide animations

### Loading States
- CircularProgressIndicator with primary color
- Center-aligned in available space

### Interactive Feedback
- Ripple effect on tappable cards
- Slight scale on button press
- Smooth color transitions on status changes

## Responsive Behavior

### Breakpoints
```
Small (< 600px):  Single column, full width
Medium (≥ 600px): Same as small
Large (≥ 1024px): Same as small (mobile-first)
```

### Scroll Behavior
- Pull to refresh on lists
- Smooth scrolling with momentum
- ScrollPhysics: BouncingScrollPhysics

## Empty States

### Message Hierarchy
```
┌─────────────────────────────────────┐
│                                     │
│        [Large Icon]                 │ ← 80px, faded
│                                     │
│     No Orders Yet                   │ ← titleLarge
│  Your order history will appear     │ ← bodyMedium
│            here                     │
│                                     │
└─────────────────────────────────────┘
```

## Error States

### Layout
```
┌─────────────────────────────────────┐
│                                     │
│     [❌ Error Icon]                 │ ← 64px, error color
│                                     │
│   Failed to load orders             │ ← titleLarge
│  Something went wrong. Please try   │ ← bodyMedium
│         again later.                │
│                                     │
│    [🔄 Retry Button]               │
│                                     │
└─────────────────────────────────────┘
```

## Accessibility

### Color Contrast
- All text meets WCAG AA standards
- Status colors have sufficient contrast
- Icons + text for status indicators

### Touch Targets
- Minimum 48x48px for all interactive elements
- Adequate spacing between tappable items

### Screen Reader Support
- Semantic labels for all interactive elements
- Proper heading hierarchy
- Alternative text for status indicators

## Best Practices

1. **Consistency**: Use the same spacing, colors, and typography throughout
2. **Hierarchy**: Clear visual distinction between primary and secondary information
3. **Feedback**: Provide immediate feedback for user actions
4. **Loading**: Show loading states during data fetches
5. **Errors**: Graceful error handling with clear messages
6. **Navigation**: Smooth transitions between pages
7. **Performance**: Optimize list rendering with ListView.builder
8. **Accessibility**: Ensure all users can access the functionality
