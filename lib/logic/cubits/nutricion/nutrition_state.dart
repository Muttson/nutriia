import 'package:nutriia/data/models/food_group_model.dart';

class NutritionState {
  final double caloriesConsumed;
  final int mealsConsumed;
  final int totalMeals;
  final List<FoodGroup> groups;
  final bool isLoading;

  // Macros principales (para la gráfica)
  final double totalProteinGrams;
  final double totalCarbGrams;
  final double totalFatGrams;

  // Nuevos datos detallados (para el popup)
  final double totalFiber;
  final double totalSugar;
  final double totalSodium;
  final double totalCholesterol;

  // Getters para porcentajes (sin cambios)
  double get proteinPerc {
    double total = totalProteinGrams + totalCarbGrams + totalFatGrams;
    if (total == 0) return 33;
    return (totalProteinGrams / total) * 100;
  }

  double get carbPerc {
    double total = totalProteinGrams + totalCarbGrams + totalFatGrams;
    if (total == 0) return 33;
    return (totalCarbGrams / total) * 100;
  }

  double get vegPerc {
    double total = totalProteinGrams + totalCarbGrams + totalFatGrams;
    if (total == 0) return 34;
    return (totalFatGrams / total) * 100;
  }

  NutritionState({
    this.caloriesConsumed = 0, // Iniciamos en 0 para ver el efecto real
    this.mealsConsumed = 0,
    this.totalMeals = 5,
    required this.groups,
    this.isLoading = false,
    this.totalProteinGrams = 0,
    this.totalCarbGrams = 0,
    this.totalFatGrams = 0,
    // Inicializar nuevos campos
    this.totalFiber = 0,
    this.totalSugar = 0,
    this.totalSodium = 0,
    this.totalCholesterol = 0,
  });

  NutritionState copyWith({
    List<FoodGroup>? groups,
    double? caloriesConsumed,
    int? mealsConsumed,
    bool? isLoading,
    double? totalProteinGrams,
    double? totalCarbGrams,
    double? totalFatGrams,
    double? totalFiber,
    double? totalSugar,
    double? totalSodium,
    double? totalCholesterol,
  }) {
    return NutritionState(
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      mealsConsumed: mealsConsumed ?? this.mealsConsumed,
      totalMeals: totalMeals,
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      totalProteinGrams: totalProteinGrams ?? this.totalProteinGrams,
      totalCarbGrams: totalCarbGrams ?? this.totalCarbGrams,
      totalFatGrams: totalFatGrams ?? this.totalFatGrams,
      // Copiar nuevos campos
      totalFiber: totalFiber ?? this.totalFiber,
      totalSugar: totalSugar ?? this.totalSugar,
      totalSodium: totalSodium ?? this.totalSodium,
      totalCholesterol: totalCholesterol ?? this.totalCholesterol,
    );
  }
}
