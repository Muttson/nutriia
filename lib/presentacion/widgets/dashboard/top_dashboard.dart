import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:nutriia/logic/cubits/nutricion/nutrition_cubit.dart';
import 'package:nutriia/logic/cubits/nutricion/nutrition_state.dart';
import 'package:nutriia/main.dart';
import 'package:nutriia/presentacion/widgets/dashboard/legend_item.dart';
import 'package:nutriia/presentacion/widgets/dashboard/stat_item.dart';

class TopDashboardSection extends StatelessWidget {
  const TopDashboardSection({super.key});

  // Función para mostrar el Pop-up
  void _showDetailsDialog(BuildContext context, NutritionState state) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F21),
          title: const Text(
            "Información Nutricional",
            style: TextStyle(color: Colors.tealAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(
                "Calorías",
                "${state.caloriesConsumed.toStringAsFixed(1)} kcal",
              ),
              const Divider(color: Colors.grey),
              _detailRow(
                "Proteína",
                "${state.totalProteinGrams.toStringAsFixed(1)} g",
              ),
              _detailRow(
                "Carbohidratos",
                "${state.totalCarbGrams.toStringAsFixed(1)} g",
              ),
              _detailRow(
                "Grasas",
                "${state.totalFatGrams.toStringAsFixed(1)} g",
              ),
              const Divider(color: Colors.grey),
              _detailRow("Fibra", "${state.totalFiber.toStringAsFixed(1)} g"),
              _detailRow("Azúcar", "${state.totalSugar.toStringAsFixed(1)} g"),
              _detailRow("Sodio", "${state.totalSodium.toStringAsFixed(1)} mg"),
              _detailRow(
                "Colesterol",
                "${state.totalCholesterol.toStringAsFixed(1)} mg",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                "Cerrar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionCubit, NutritionState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gráfico Circular con Detector de Gestos
            GestureDetector(
              onTap: () {
                // Al presionar la gráfica, mostramos el popup
                _showDetailsDialog(context, state);
              },
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 60,
                        startDegreeOffset: 270,
                        sections: [
                          PieChartSectionData(
                            color: const Color(0xFF3B82F6),
                            value: state.proteinPerc,
                            title: '',
                            radius: 25,
                          ),
                          PieChartSectionData(
                            color: const Color(0xFF2DD4BF),
                            value: state.vegPerc, // Grasa
                            title: '',
                            radius: 25,
                          ),
                          PieChartSectionData(
                            color: const Color(0xFF4097AA),
                            value: state.carbPerc,
                            title: '',
                            radius: 25,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child:
                          state.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.touch_app, color: Colors.white54),
                                  Text(
                                    "Ver detalles",
                                    style: TextStyle(
                                      color: Colors.white24,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Leyenda (Igual que antes)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                LegendItem(
                  color: const Color(0xFF3B82F6),
                  label: "Proteína",
                  percent: state.proteinPerc,
                ),
                LegendItem(
                  color: const Color(0xFF4097AA),
                  label: "Carbos",
                  percent: state.carbPerc,
                ),
                LegendItem(
                  color: const Color(0xFF2DD4BF),
                  label: "Grasa",
                  percent: state.vegPerc,
                ),
              ],
            ),

            // -------------------------------
            const SizedBox(height: 20),
            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(
                  value: "${state.caloriesConsumed.toInt()}",
                  label: "Calorias\nConsumidas",
                  color: const Color(0xFF6AE2D8),
                ),
                StatItem(
                  value: "${state.mealsConsumed}/${state.totalMeals}",
                  label: "Comidas\nconsumidas",
                  color: const Color(0xFF6AE2D8),
                ),
                const StatItem(
                  value: "Ideal",
                  label: "Progreso\ndel dia",
                  color: Color(0xFF6AE2D8),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
