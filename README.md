# 🍳 Recipe Explorer

Because apparently, we all need just another recipe app in our lives. But hey, at least this one's built with Flutter!

So, welcome to Recipe Explorer—the app that promises to make you a master chef. Or, at the very least, to help you understand what you *could* be making instead of instant noodles.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.3 (latest stable version)
- Dart SDK 3.5.3 (latest stable version)
- Visual Studio 2022 (17.11.3)
- A burning desire to look at food pictures

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
- Image caching

## 🏗️ Project Structure

```
lib/
├── constants/      # Text and UI values
├── models/         # Data models (Category, Meal)
├── screens/        # UI screens
├── services/       # Business logic and API calls
├── utils/          # Utility functions
└── widgets/        # Reusable UI components
```

## 📝 Additional Notes

- The app uses a responsive design pattern, so it looks good on everything from your phone to your smart fridge
- Images are cached locally to save your data (and API provider's bandwidth)
- SQLite with FFI support means the app works smoothly on desktop platforms

## 🐛 Known Issues
- When you make a search by name, maximum of 25 results gets listed(API limitation). 
- May cause unexpected hunger
- This project doesn't benefit from any state managament solution other than good old setState method becase the company I've made this for wanted me to do so

## ⭕ Random notes
- I've made MANY versions of this, from a quickly built trash to over-engineered masterpieces... But then decided to submit this. Why? Idk.
- If user doesn't select a filter OR explicitly unchecks both filters in the filter dialog, app will search for recipes by their names, which is probably the most intuitive default behavior for users.

---
Made with 💖 and probably too much coffee
