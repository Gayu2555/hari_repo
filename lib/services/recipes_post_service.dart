// lib/services/recipe_api_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class RecipeApiService {
  static const String baseUrl = 'https://api.gayuyunma.my.id';

  // Simpan token JWT di sini atau ambil dari secure storage
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Create Recipe
  Future<Map<String, dynamic>> createRecipe({
    required String title,
    required String description,
    required String category,
    required String difficulty,
    required String servings,
    required String prepTime,
    required String cookTime,
    required File mainImage,
    required List<String> ingredients,
    required List<Map<String, dynamic>> steps,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/recipes');
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add text fields
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['difficulty'] = difficulty;
      request.fields['servings'] = servings;
      request.fields['prepTime'] = prepTime;
      request.fields['cookTime'] = cookTime;

      // Add ingredients as JSON array
      request.fields['ingredients'] = jsonEncode(ingredients);

      // Add main image
      final mainImageMimeType = lookupMimeType(mainImage.path);
      final mainImageFile = await http.MultipartFile.fromPath(
        'mainImage',
        mainImage.path,
        contentType: mainImageMimeType != null
            ? MediaType.parse(mainImageMimeType)
            : null,
      );
      request.files.add(mainImageFile);

      // Add steps and step images
      for (int i = 0; i < steps.length; i++) {
        request.fields['steps[$i][description]'] = steps[i]['description'];
        request.fields['steps[$i][order]'] = (i + 1).toString();

        if (steps[i]['image'] != null) {
          final stepImagePath = steps[i]['image'] as String;
          final stepImageFile = File(stepImagePath);

          if (await stepImageFile.exists()) {
            final stepImageMimeType = lookupMimeType(stepImagePath);
            final stepImage = await http.MultipartFile.fromPath(
              'steps[$i][image]',
              stepImagePath,
              contentType: stepImageMimeType != null
                  ? MediaType.parse(stepImageMimeType)
                  : null,
            );
            request.files.add(stepImage);
          }
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating recipe: $e');
    }
  }

  // Get all recipes
  Future<Map<String, dynamic>> getAllRecipes({
    String? category,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri =
          Uri.parse('$baseUrl/recipes').replace(queryParameters: queryParams);
      final response =
          await http.get(uri, headers: _getHeaders(includeAuth: false));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recipes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  // Get single recipe
  Future<Map<String, dynamic>> getRecipe(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/recipes/$id');
      final response =
          await http.get(uri, headers: _getHeaders(includeAuth: false));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching recipe: $e');
    }
  }

  // Update recipe
  Future<Map<String, dynamic>> updateRecipe({
    required int id,
    String? title,
    String? description,
    String? category,
    String? difficulty,
    String? servings,
    String? prepTime,
    String? cookTime,
    File? mainImage,
    List<String>? ingredients,
    List<Map<String, dynamic>>? steps,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/recipes/$id');
      final request = http.MultipartRequest('PATCH', uri);

      // Add auth header
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add text fields only if they're not null
      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;
      if (difficulty != null) request.fields['difficulty'] = difficulty;
      if (servings != null) request.fields['servings'] = servings;
      if (prepTime != null) request.fields['prepTime'] = prepTime;
      if (cookTime != null) request.fields['cookTime'] = cookTime;

      if (ingredients != null) {
        request.fields['ingredients'] = jsonEncode(ingredients);
      }

      // Add main image if provided
      if (mainImage != null) {
        final mainImageMimeType = lookupMimeType(mainImage.path);
        final mainImageFile = await http.MultipartFile.fromPath(
          'mainImage',
          mainImage.path,
          contentType: mainImageMimeType != null
              ? MediaType.parse(mainImageMimeType)
              : null,
        );
        request.files.add(mainImageFile);
      }

      // Add steps if provided
      if (steps != null) {
        for (int i = 0; i < steps.length; i++) {
          request.fields['steps[$i][description]'] = steps[i]['description'];
          request.fields['steps[$i][order]'] = (i + 1).toString();

          if (steps[i]['image'] != null) {
            final stepImagePath = steps[i]['image'] as String;
            final stepImageFile = File(stepImagePath);

            if (await stepImageFile.exists()) {
              final stepImageMimeType = lookupMimeType(stepImagePath);
              final stepImage = await http.MultipartFile.fromPath(
                'steps[$i][image]',
                stepImagePath,
                contentType: stepImageMimeType != null
                    ? MediaType.parse(stepImageMimeType)
                    : null,
              );
              request.files.add(stepImage);
            }
          }
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating recipe: $e');
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/recipes/$id');
      final response = await http.delete(uri, headers: _getHeaders());

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting recipe: $e');
    }
  }
}
