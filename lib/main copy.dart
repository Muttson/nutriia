import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// ---------------------------------------------------------------------------
// 1. MODELOS (Data Layer)
// ---------------------------------------------------------------------------
class FoodGroup {
  final String id;
  final String name;
  final Color color;
  final bool isChecked;

  FoodGroup({
    required this.id,
    required this.name,
    required this.color,
    this.isChecked = false,
  });

  FoodGroup copyWith({bool? isChecked}) {
    return FoodGroup(
      id: id,
      name: name,
      color: color,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

// ---------------------------------------------------------------------------
// 2. LÓGICA DE ESTADO (Cubit)
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// 3. UI (Presentation Layer)
// ---------------------------------------------------------------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1F21),
        primaryColor: Colors.tealAccent,
      ),
      home: BlocProvider(
        create: (_) => NutritionCubit(),
        child: const NutritionHomeScreen(),
      ),
    );
  }
}

class NutritionHomeScreen extends StatelessWidget {
  const NutritionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos isLoading para mostrar un overlay si es necesario
    return BlocListener<NutritionCubit, NutritionState>(
      listenWhen:
          (previous, current) => previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Analizando alimentos...')),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Sección Superior: Gráfico y Stats
                const Expanded(flex: 4, child: TopDashboardSection()),

                const SizedBox(height: 20),

                // Sección Media: Bento Grid (Botones)
                const Expanded(flex: 5, child: BentoGridSection()),
              ],
            ),
          ),
        ),
        // Barra de navegación inferior con lógica de Tap
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionCubit>();

    return BlocBuilder<NutritionCubit, NutritionState>(
      builder: (context, state) {
        return BottomNavigationBar(
          backgroundColor: const Color(0xFF1A1F21),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            // Lógica de botones
            if (index == 2) {
              // --- CÁMARA (Centro) ---
              if (!state.isLoading) {
                cubit.pickAndAnalyzeFood();
              }
            } else if (index == 4) {
              // --- RESET (Último a la derecha) ---
              // Llamamos al reset del Cubit
              cubit.resetAll();

              // Feedback visual (SnackBar)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todo reiniciado a 0'),
                  backgroundColor: Colors.teal,
                  duration: Duration(milliseconds: 800),
                ),
              );
            }
          },
          items: [
            // 0. HOME (Izquierda)
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 30),
              label: '',
            ),
            // 1. SEARCH (Izquierda)
            const BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 30),
              label: '',
            ),

            // 2. CÁMARA (Centro - Loading o Icono)
            BottomNavigationBarItem(
              icon:
                  state.isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                      : const CircleAvatar(
                        backgroundColor: Color(0xFF6AE2D8),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                        ),
                      ),
              label: '',
            ),

            // 3. LISTA / TRES BARRAS (Derecha - INTACTO)
            const BottomNavigationBarItem(
              icon: Icon(Icons.list, size: 30),
              label: '',
            ),

            // 4. RESET (Derecha extrema - ANTES USUARIO)
            const BottomNavigationBarItem(
              icon: Icon(Icons.refresh, size: 30), // Cambiado a Refresh
              label: 'Reset',
            ),
          ],
        );
      },
    );
  }
}

// --- WIDGETS SECCION SUPERIOR ---

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
                _LegendItem(
                  color: const Color(0xFF3B82F6),
                  label: "Proteína",
                  percent: state.proteinPerc,
                ),
                _LegendItem(
                  color: const Color(0xFF4097AA),
                  label: "Carbos",
                  percent: state.carbPerc,
                ),
                _LegendItem(
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
                _StatItem(
                  value: "${state.caloriesConsumed.toInt()}",
                  label: "Calorias\nConsumidas",
                  color: const Color(0xFF6AE2D8),
                ),
                _StatItem(
                  value: "${state.mealsConsumed}/${state.totalMeals}",
                  label: "Comidas\nconsumidas",
                  color: const Color(0xFF6AE2D8),
                ),
                const _StatItem(
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double percent;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          "$label ${percent.toStringAsFixed(0)}%",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// --- WIDGETS SECCION MEDIA (BENTO GRID) ---
// (Sin cambios mayores en lógica, solo UI)

class BentoGridSection extends StatelessWidget {
  const BentoGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionCubit, NutritionState>(
      builder: (context, state) {
        final g1 = state.groups.firstWhere((g) => g.id == '1');
        final g2 = state.groups.firstWhere((g) => g.id == '2');
        final g3 = state.groups.firstWhere((g) => g.id == '3');
        final g4 = state.groups.firstWhere((g) => g.id == '4');
        final g5 = state.groups.firstWhere((g) => g.id == '5');

        return Row(
          children: [
            Expanded(flex: 45, child: BentoCard(group: g1)),
            const SizedBox(width: 10),
            Expanded(
              flex: 55,
              child: Column(
                children: [
                  Expanded(flex: 4, child: BentoCard(group: g4)),
                  const SizedBox(height: 10),
                  Expanded(flex: 2, child: BentoCard(group: g2)),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(child: BentoCard(group: g5)),
                        const SizedBox(width: 10),
                        Expanded(child: BentoCard(group: g3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class BentoCard extends StatelessWidget {
  final FoodGroup group;

  const BentoCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<NutritionCubit>().toggleGroupCheck(group.id),
      child: Container(
        decoration: BoxDecoration(
          color: group.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fastfood_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 30,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (group.isChecked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(Icons.check, color: Colors.black, size: 30),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
