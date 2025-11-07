import 'package:flutter/foundation.dart';
import 'package:recipe_app/models/food.dart'; // Sesuaikan path jika model Anda bernama lain
import 'package:recipe_app/services/recipe_api_services.dart'; // Pastikan nama file benar

class ListOfRecipes with ChangeNotifier {
  final RecipeApiService _apiService = RecipeApiService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  // Getter
  List<Recipe> get getRecipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 🔥 MUAT SEMUA RESEP DARI API
  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notifikasi UI: sedang loading

    try {
      final recipes = await _apiService.getAllRecipes();
      _recipes = recipes;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _recipes = []; // Opsional: kosongkan jika error
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifikasi UI: selesai loading
    }
  }

  // 🔍 CARI RESEP BERDASARKAN KATEGORI (dari data yang sudah dimuat)
  List<Recipe> findByCategory(String categoryName) {
    if (categoryName == 'All' || categoryName.isEmpty) {
      return _recipes;
    }
    return _recipes
        .where((recipe) =>
            recipe.recipeCategory.toLowerCase() == categoryName.toLowerCase())
        .toList();
  }

  // ⭐ AMBIL RESEP POPULER (dari data yang sudah dimuat)
  List<Recipe> get popularRecipes =>
      _recipes.where((recipe) => recipe.isPopular == true).toList();

  // 🔍 CARI RESEP BERDASARKAN ID
  Recipe findById(int id) {
    return _recipes.firstWhere(
      (recipe) => recipe.recipeId == id,
      orElse: () => throw Exception('Recipe not found'),
    );
  }

  // 🔍 PENCARIAN RESEP (dari API, dengan fallback ke lokal)
  Future<List<Recipe>> searchRecipe(String searchText) async {
    if (searchText.trim().isEmpty) {
      return _recipes;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recipes = await _apiService.searchRecipes(searchText);
      _error = null;
      return recipes;
    } catch (e) {
      _error = 'Gagal mencari resep: $e';
      // Fallback: cari di data lokal
      return _recipes
          .where((recipe) => recipe.recipeName
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔄 REFRESH DATA
  Future<void> refresh() async {
    await loadRecipes();
  }
}
