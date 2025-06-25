# 🍳 Recipe Explorer

Because apparently, we all need just another recipe app in our lives. But hey, at least this one's built with Flutter!

So, welcome to Recipe Explorer—the app that promises to make you a master chef.

[Download](https://github.com/KatayR/recipe_explorer/releases/download/v2/app-release.apk)

# Video
[![IMAGE ALT TEXT](https://i.ytimg.com/vi/NuWcoQqPGF4/hqdefault.jpg)](https://youtu.be/NuWcoQqPGF4 "Recipe Explorer Demo")

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.32.4 (latest stable version)
- Dart SDK 3.8.1 (latest stable version)
- Android Studio 2024.3.2 (latest stable version)
- Visual Studio 2022 (to build Windows app)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/KatayR/recipe_explorer.git
```

2. Switch to "experimental" branch:
```bash
git checkout experimental
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## 🛠️ Technologies Used

- **Flutter**: Because I need a Flutter job
- **GetX**: Modern reactive state management and dependency injection
- **SQLite with FFI**: For local storage of favorited recipes because ✨Offline First✨
- **TheMealDB API**: Backend for all the data
- **connectivity_plus**: To remind you that you need internet to browse online content
- **http**: For fetching data
- **path_provider**: For managing local storage paths
- **sqflite_common_ffi**: Making SQLite play nice with Windows and Linux

## 📋 What's Cooking?

- Search recipes by name or ingredients
- Browse recipe categories
- View detailed recipe instructions
- Save favorite recipes locally
- Responsive design (works on mobile, tablet, and desktop)
- Offline support for favorite recipes
- Image caching and preloading
- Reactive UI with GetX state management
- Named route navigation

## 🏗️ Project Structure

```
lib/
├── constants/      # Text and UI values
├── models/         # Data models (Category, Meal)
├── routes/         # GetX navigation routes and pages
├── screens/        # UI screens with GetView architecture
├── services/       # GetX controllers and services
├── utils/          # Utility functions
└── widgets/        # Reusable UI components
```

## 📝 Additional Notes

- The app uses a responsive design pattern, so it looks good on everything from your phone to your smart fridge
- Images are cached locally to save your data (and API provider's bandwidth)
- SQLite with FFI support means the app works smoothly on desktop platforms
- Built with GetX architecture for reactive state management and clean code structure
- Uses dependency injection for better testability and maintainability

## 🐛 Known Issues
- When you make a search by name, maximum of 25 results gets listed(API limitation). 
- May cause unexpected hunger

## 🎯 Planned Features & Enhancements

### 🔥 High Priority Features
- [ ] **Random Recipe Discovery** - Add random recipe button using `/random.php` endpoint for daily cooking inspiration
- [ ] **Search by Cuisine/Area** - Filter recipes by country/cuisine (Italian, Mexican, Chinese, etc.) using `/filter.php?a=` endpoint
- [ ] **Countries Category Section** - Add dedicated section for browsing recipes by country using `/list.php?a=list`
- [ ] **Sharable Shopping List Generator** - Create and share shopping lists from selected recipes with quantities

### 🚀 Core Enhancements
- [ ] **Search History** - Store and suggest previous searches for better user experience
- [ ] **Personal Recipe Notes** - Add cooking notes and modifications to saved recipes
- [ ] **Cooking Timers** - Integrate timers for recipes with time-based cooking processes
- [ ] **Recipe Sharing** - Export and share recipes via PDF, image, or text format
- [ ] **Favorites Search** - Search functionality within saved favorite recipes
- [ ] **Custom Recipe Tags** - Add custom tags to favorites (breakfast, snack, dinner, etc.)
- [ ] **Dietary Labels** - Add dietary indicators (vegetarian, vegan, gluten-free, etc.)
- [ ] **Allergy Warnings** - Highlight common allergens in recipes
- [ ] **Cooking Time Estimates** - Display prep time and cooking time for better planning

### 🌟 Advanced Features
- [ ] **Basic Nutrition Estimates** - Display approximate calories, protein, carbs, and fat content
- [ ] **AI Integration** - Launch installed AI apps (ChatGPT, Gemini) with current recipe for live cooking assistance
- [ ] **Cross-Device Sync** - Sync favorited meals across multiple devices using cloud storage

### 📊 Implementation Priority
1. **Phase 1**: Random recipes, cuisine search, countries category
2. **Phase 2**: Shopping list, search history, recipe notes
3. **Phase 3**: Sharing features, dietary labels, cooking timers
4. **Phase 4**: Advanced features and AI integration

## 🔄 Architecture Evolution
- **Previously**: Used traditional Flutter setState() for state management per client requirements
- **Current**: Migrated to GetX architecture for improved reactivity and maintainability
- **Migration**: Completed systematic 12-step conversion while maintaining all existing functionality

## ⭕ Random notes
- If user doesn't select a filter OR explicitly unchecks both filters in the filter dialog, app will search for recipes by their names, which is probably the most intuitive default behavior for users.

---
Made with 💖 and probably too much coffee
