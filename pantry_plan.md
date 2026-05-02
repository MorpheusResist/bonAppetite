# WasteLess Kitchen Rebuild Plan

## Product Vision

WasteLess Kitchen is an AI-powered smart kitchen assistant for iPhone that helps people see what they already own, cook expiring food first, shop only for what is missing, and understand the money and nutrition impact of their food habits.

The app should feel like an Apple-quality kitchen utility: fast, calm, trustworthy, accessible, and useful during real cooking.

## MVP Scope

- Onboarding for household size, diet, allergies, skill, budget, notification style, and accessibility preferences.
- Home dashboard with Cook Tonight, Expiring Soon, Kitchen Inventory, savings, and quick scan.
- Camera/photo picker scan flow with local mock AI detections for fridge, pantry, freezer, receipt, barcode, and label modes.
- Confirmation screen for detected items with editable quantity, location, category, expiry, and confidence.
- Inventory organized by Fridge, Freezer, Pantry, Spices, and Shopping, with search, filters, badges, swipe actions, and manual entry.
- Recipe planner that ranks 20+ sample recipes by inventory match, expiring ingredients, diet/allergen fit, time, budget, cuisine, and equipment.
- Cooking mode with large readable steps, read-aloud, timers, previous/next controls, and inventory consumption after cooking.
- Categorized shopping list with one-tap missing ingredient import and purchased-to-inventory conversion.
- Analytics dashboard for food saved, money saved, expired/discarded items, most-wasted categories, and nutrition overview.
- Notification scheduling service for expiry and cook-tonight reminders.
- App Intents for "What can I cook tonight?", "What is expiring soon?", "Add milk to my shopping list", and "Start cooking mode".
- WidgetKit extension showing expiring items and a cook-tonight suggestion.
- Unit and UI tests for core logic and flows.

## Stretch Features

- Real Vision/Core ML ingredient classifier.
- Real OCR receipt parser using Vision text recognition.
- Barcode product lookup through an external database.
- iCloud sync and shared household pantry.
- HealthKit nutrition export or meal summary.
- Live Activities for cooking timers.
- Smart leftovers and batch-cooking planning.
- Camera overlay bounding boxes for detected items.
- Import recipes from URLs, social links, and handwritten cards.

## Architecture

- SwiftUI for all UI.
- MVVM-style state through `KitchenStore`, feature views, and small value models.
- SwiftData `@Model` classes for `PantryItem`, `Recipe`, `ShoppingItem`, `AnalyticsEntry`, and `CookingSession`.
- Local deterministic service protocols for AI-like work:
  - `IngredientDetectionService`
  - `RecipeGenerationService`
  - `ExpiryRiskEngine`
  - `NutritionEstimator`
  - `ShoppingListEngine`
- Framework wrappers for platform services:
  - `NotificationScheduling`
  - `SpeechCookingReader`
  - `CameraPicker`
  - App Intents
  - WidgetKit

## Apple Frameworks

- SwiftUI: full app UI, navigation, sheets, animations, materials, Dynamic Type.
- SwiftData: persisted domain models.
- Vision/Core ML: represented by replaceable detection protocols with local mock implementation.
- PhotosUI: image selection.
- AVFoundation: camera picker and read-aloud speech.
- Speech: hands-free command protocol surface; demo falls back to large controls.
- UserNotifications: expiry and cook-tonight reminders.
- WidgetKit: expiring items widget.
- App Intents: Siri and Shortcuts actions.
- Charts: waste and savings analytics.
- HealthKit: future stretch for nutrition export; not required for MVP.

## Data Models

- `PantryItem`: name, category, location, quantity, unit, expiry date, purchase date, price estimate, calories, protein, detection confidence, status.
- `Recipe`: title, cuisine, diet tags, allergy flags, ingredients, steps, equipment, cook time, calories, protein, cost, favorite flag.
- `RecipeMatch`: recipe, match score, matched ingredients, missing ingredients, expiring ingredients, explanation.
- `ShoppingItem`: name, category, quantity, source recipe, checked state.
- `AnalyticsEntry`: date, foodSavedCount, wastedCount, moneySaved, category.
- `UserPreferences`: household size, diet, allergies, skill, budget, notification style, cuisines, accessibility toggles.
- `DetectedIngredient`: name, category, suggested location, quantity, expiry, confidence.

## Screen Map

- Onboarding
  - Welcome and household
  - Diet and allergens
  - Cooking style and budget
  - Notifications and accessibility
- Main tabs
  - Home
  - Inventory
  - Recipes
  - Shopping
  - Analytics
  - Settings
- Modal flows
  - Scan flow
  - Detection confirmation
  - Manual item entry
  - Edit inventory item
  - Recipe detail
  - Cooking mode

## Testing Plan

- Unit tests:
  - Expiry risk classification and expiring-soon sorting.
  - Recipe match scoring and expiring-first ranking.
  - Missing ingredient shopping list generation.
  - Marking a recipe cooked consumes inventory.
  - Notification scheduling payload generation.
  - Nutrition estimator totals.
- UI tests:
  - Complete onboarding.
  - Add item manually.
  - Run scan and confirm detected item.
  - Open expiring-soon list.
  - Add missing recipe ingredients to shopping.
  - Navigate cooking mode next/previous.
  - Convert purchased shopping item to inventory.
  - Verify key accessibility labels.
- Manual QA:
  - Light/dark mode.
  - Dynamic Type.
  - Reduce Motion.
  - VoiceOver labels.
  - Small iPhone layout.

## Accessibility Plan

- VoiceOver labels and hints for all primary cards, buttons, lists, badges, and cooking controls.
- Dynamic Type-friendly layouts using stacks and wrapping labels, no fixed text heights for content.
- Large cooking mode with high-contrast option.
- Dyslexia-friendly font toggle using rounded system design.
- Color-independent freshness labels with text and symbols.
- Reduce Motion support for transitions and shimmer/loading effects.
- Read-aloud cooking steps using AVSpeechSynthesizer.
- Large hit targets for scan, cook, previous, next, timer, and consume actions.

## Resume Bullet Points The Finished App Should Support

- Built a production-style SwiftUI iOS app using SwiftData, Charts, WidgetKit, App Intents, UserNotifications, AVFoundation, PhotosUI, and accessibility APIs.
- Designed and implemented a local AI service layer for ingredient detection, expiry risk, recipe generation, nutrition estimates, and shopping list automation.
- Created an end-to-end food waste loop: scan pantry, confirm inventory, rank recipes by expiry risk, cook hands-free, consume ingredients, and track savings.
- Added portfolio-grade UX polish including dark mode, Liquid Glass-inspired materials, haptics, empty states, swipe actions, animated transitions, and Dynamic Type.
- Wrote unit and UI tests covering onboarding, inventory, scanning, recipe matching, cooking mode, shopping conversion, and notification logic.
