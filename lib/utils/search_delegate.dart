// import 'package:flutter/material.dart';
// import '/services/meals_service.dart';
// import '/utils/error_handler.dart';

// import '../widgets/home/custom_search_bar.dart';

// class MealSearchDelegate extends SearchDelegate<String> {
//   final MealService _mealService = MealService();
//   final SearchOptions searchOptions;

//   MealSearchDelegate({required this.searchOptions});

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () => close(context, ''),
//     );
//   }

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       if (query.isNotEmpty)
//         IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () => query = '',
//         ),
//     ];
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     if (query.trim().isEmpty) return const SizedBox();

//     close(context, query);
//     return const SizedBox();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     if (query.trim().length < 2) {
//       return const Center(child: Text('Type at least 2 characters to search'));
//     }

//     return FutureBuilder<List<dynamic>>(
//       future: _mealService.searchMealsByName(query),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return ErrorHandler.buildErrorWidget('Error loading suggestions');
//         }

//         final suggestions = snapshot.data ?? [];

//         return ListView.builder(
//           itemCount: suggestions.length,
//           itemBuilder: (context, index) {
//             final meal = suggestions[index];
//             return ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: NetworkImage(meal['strMealThumb']),
//               ),
//               title: Text(meal['strMeal']),
//               onTap: () => close(context, meal['strMeal']),
//             );
//           },
//         );
//       },
//     );
//   }
// }
