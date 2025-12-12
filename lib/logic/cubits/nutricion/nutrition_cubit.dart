import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'nutrition_state.dart';
import 'package:nutriia/data/models/food_group_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class NutritionCubit extends Cubit<NutritionState> {
  final ImagePicker _picker = ImagePicker();

  NutritionCubit()
    : super(
        NutritionState(
          groups: [
            FoodGroup(
              id: '1',
              name: 'Comida 1',
              color: const Color(0xFFBBEFFF),
            ),
            FoodGroup(
              id: '2',
              name: 'Comida 2',
              color: const Color(0xFF8FE3F9),
            ),
            FoodGroup(
              id: '3',
              name: 'Comida 3',
              color: const Color(0xFF54C2DE),
            ),
            FoodGroup(
              id: '4',
              name: 'Comida 4',
              color: const Color(0xFF94C1FF),
            ),
            FoodGroup(
              id: '5',
              name: 'Comida 5',
              color: const Color(0xFF6AE2D8),
            ),
          ],
        ),
      );

  // Acción: Checkbox del Bento Grid
  void toggleGroupCheck(String id) {
    final newGroups =
        state.groups.map((group) {
          if (group.id == id) {
            return group.copyWith(isChecked: !group.isChecked);
          }
          return group;
        }).toList();
    emit(state.copyWith(groups: newGroups));
  }

  void resetAll() {
    emit(
      NutritionState(
        // Reiniciamos los grupos para quitar los "check"
        groups: [
          FoodGroup(id: '1', name: 'Comida 1', color: const Color(0xFFBBEFFF)),
          FoodGroup(id: '2', name: 'Comida 2', color: const Color(0xFF8FE3F9)),
          FoodGroup(id: '3', name: 'Comida 3', color: const Color(0xFF54C2DE)),
          FoodGroup(id: '4', name: 'Comida 4', color: const Color(0xFF94C1FF)),
          FoodGroup(id: '5', name: 'Comida 5', color: const Color(0xFF6AE2D8)),
        ],
        // Todos los valores numéricos volverán a 0 gracias a los valores por defecto del constructor
        caloriesConsumed: 0,
        mealsConsumed: 0,
        totalProteinGrams: 0,
        totalCarbGrams: 0,
        totalFatGrams: 0,
        totalFiber: 0,
        totalSugar: 0,
        totalSodium: 0,
        totalCholesterol: 0,
      ),
    );
  }

  // Acción: Seleccionar Foto, Enviar a API y Actualizar Estado
  Future<void> pickAndAnalyzeFood() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      emit(state.copyWith(isLoading: true));

      // AJUSTA TU URL AQUÍ SEGÚN TU ENTORNO:
      // Emulador Android: 'http://10.0.2.2:8000/analyze-food'
      // iOS / Web: 'http://127.0.0.1:8000/analyze-food'
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.18.146:8000/analyze-food'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        final nutrition = data['total_nutrition'];

        // Extraer todos los datos
        double addedCals = (nutrition['calories'] as num).toDouble();
        double addedProtein = (nutrition['protein'] as num).toDouble();
        double addedCarbs = (nutrition['carbs'] as num).toDouble();
        double addedFat = (nutrition['fat'] as num).toDouble();
        double addedFiber = (nutrition['fiber'] as num).toDouble();
        double addedSugar = (nutrition['sugar'] as num).toDouble();
        double addedSodium = (nutrition['sodium'] as num).toDouble();
        double addedCholesterol = (nutrition['cholesterol'] as num).toDouble();

        emit(
          state.copyWith(
            isLoading: false,
            mealsConsumed: state.mealsConsumed + 1,
            // Acumulamos los valores a lo que ya teniamos
            caloriesConsumed: state.caloriesConsumed + addedCals,
            totalProteinGrams: state.totalProteinGrams + addedProtein,
            totalCarbGrams: state.totalCarbGrams + addedCarbs,
            totalFatGrams: state.totalFatGrams + addedFat,
            totalFiber: state.totalFiber + addedFiber,
            totalSugar: state.totalSugar + addedSugar,
            totalSodium: state.totalSodium + addedSodium,
            totalCholesterol: state.totalCholesterol + addedCholesterol,
          ),
        );

        print('Nutrición actualizada: $nutrition');
      } else {
        print('Error API: ${response.statusCode}');
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      print('Error general: $e');
      emit(state.copyWith(isLoading: false));
    }
  }
}
