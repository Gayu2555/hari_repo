// lib/services/recipe_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_app/models/food.dart'; // Sesuaikan path jika model Anda bernama lain
import 'package:recipe_app/services/auth_storage.dart';

class RecipeApiService {
  static const String baseUrl = 'https://api.gayuyunma.my.id';

  // Helper: dapatkan header dengan token jika tersedia
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Recipe>> getAllRecipes() async {
    return _fetchRecipes();
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    return _fetchRecipes(category: category);
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    return _fetchRecipes(search: query);
  }

  Future<List<Recipe>> getPopularRecipes() async {
    return _fetchRecipes(popular: true);
  }

  Future<List<Recipe>> _fetchRecipes({
    String? category,
    String? search,
    bool? popular,
    int page = 1,
    int limit = 100,
  }) async {
    final uri = Uri(
      scheme: 'https',
      host: 'api.gayuyunma.my.id',
      path: 'recipes',
      queryParameters: {
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (popular == true) 'popular': 'true',
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    try {
      final headers = await _getHeaders();
      print('📡 Mengirim request ke: $uri');
      print('🔑 Header: $headers');

      final response = await http.get(uri, headers: headers);

      print('📬 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        List<dynamic> recipeList;

        if (body is List) {
          recipeList = body;
        } else if (body is Map && body.containsKey('data')) {
          recipeList = List<dynamic>.from(body['data']);
        } else {
          throw Exception('Format respons API tidak dikenali');
        }

        return recipeList.map((json) => Recipe.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Tidak terautentikasi. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat resep: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di _fetchRecipes: $e');
      rethrow;
    }
  }

  Future<Recipe> getRecipeById(int id) async {
    final uri = Uri.parse('$baseUrl/recipes/$id');
    final headers = await _getHeaders();

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Jika endpoint /recipes/:id mengembalikan objek langsung (bukan array/wrapper)
        return Recipe.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Tidak terautentikasi.');
      } else {
        throw Exception('Gagal memuat resep: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di getRecipeById: $e');
      rethrow;
    }
  }
}
