// lib/models/food.dart
import 'dart:convert';

class Recipe {
  final int recipeId;
  final String recipeCategory;
  final String recipeName;
  final String recipeImage;
  final double prepTime;
  final double cookTime;
  final double recipeReview;
  final int recipeServing;
  final List<String> recipeIngredients;
  final String recipeMethod;
  final bool isPopular;

  Recipe({
    required this.recipeId,
    required this.recipeCategory,
    required this.recipeName,
    required this.recipeImage,
    required this.prepTime,
    required this.cookTime,
    required this.recipeServing,
    required this.recipeIngredients,
    required this.recipeMethod,
    required this.recipeReview,
    required this.isPopular,
  });

  // ✅ PERBAIKAN TOTAL: Disesuaikan 100% dengan response JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parse ingredients dari list of objects
    List<String> parseIngredients(dynamic ingredients) {
      if (ingredients == null) return [];

      // JSON response adalah list of objects: [{"name": "...", "quantity": "...", ...}, ...]
      if (ingredients is List) {
        return ingredients
            .map((e) => e['name']?.toString() ?? '') // Ambil hanya field 'name'
            .where((name) => name.isNotEmpty) // Hapus yang kosong
            .toList();
      }

      // Fallback jika formatnya bukan list (tapi tidak akan terjadi dengan JSON ini)
      return [];
    }

    return Recipe(
      // ✅ PERBAIKAN: Mapping field langsung dari JSON
      recipeId: json['id'] ?? 0,
      recipeCategory: json['category'] ?? '',
      recipeName: json['title'] ?? '',
      recipeImage: json['image'] ?? '',
      prepTime: (json['prepTime'] ?? 0).toDouble(),
      cookTime: (json['cookTime'] ?? 0).toDouble(),
      recipeServing: json['servings'] ?? 0,
      recipeIngredients: parseIngredients(json['ingredients']),
      recipeMethod: json['description'] ??
          '', // 'description' di JSON adalah 'recipeMethod'
      recipeReview: (json['_count']['reviews'] ?? 0)
          .toDouble(), // Data review ada di dalam _count
      isPopular: json['isPopular'] ??
          false, // Field ini tidak ada di JSON, jadi default false
    );
  }

  // ✅ PERBAIKAN: Sesuaikan toJson agar konsisten dengan fromJson yang baru
  Map<String, dynamic> toJson() {
    return {
      'id': recipeId,
      'category': recipeCategory,
      'title': recipeName,
      'image': recipeImage,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': recipeServing,
      'description': recipeMethod,
      '_count': {
        'reviews': recipeReview,
      },
      'isPopular': isPopular,
    };
  }

  Recipe copyWith({
    int? recipeId,
    String? recipeCategory,
    String? recipeName,
    String? recipeImage,
    double? prepTime,
    double? cookTime,
    int? recipeServing,
    List<String>? recipeIngredients,
    String? recipeMethod,
    double? recipeReview,
    bool? isPopular,
  }) {
    return Recipe(
      recipeId: recipeId ?? this.recipeId,
      recipeCategory: recipeCategory ?? this.recipeCategory,
      recipeName: recipeName ?? this.recipeName,
      recipeImage: recipeImage ?? this.recipeImage,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      recipeServing: recipeServing ?? this.recipeServing,
      recipeIngredients: recipeIngredients ?? this.recipeIngredients,
      recipeMethod: recipeMethod ?? this.recipeMethod,
      recipeReview: recipeReview ?? this.recipeReview,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}
