import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

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
// 2. LOGICA DE ESTADO (Cubit)
// ---------------------------------------------------------------------------

// El Estado que define cómo se ve la pantalla
class NutritionState {
  final double caloriesConsumed;
  final int mealsConsumed;
  final int totalMeals;
  final List<FoodGroup> groups;

  // Datos para el gráfico (simulados)
  final double proteinPerc;
  final double carbPerc;
  final double vegPerc;

  NutritionState({
    this.caloriesConsumed = 1601,
    this.mealsConsumed = 3,
    this.totalMeals = 5,
    required this.groups,
    this.proteinPerc = 30,
    this.carbPerc = 45,
    this.vegPerc = 25,
  });

  // Helper para copiar el estado con cambios
  NutritionState copyWith({List<FoodGroup>? groups}) {
    return NutritionState(
      caloriesConsumed: caloriesConsumed,
      mealsConsumed: mealsConsumed,
      totalMeals: totalMeals,
      groups: groups ?? this.groups,
      proteinPerc: proteinPerc,
      carbPerc: carbPerc,
      vegPerc: vegPerc,
    );
  }
}

class NutritionCubit extends Cubit<NutritionState> {
  NutritionCubit()
    : super(
        NutritionState(
          groups: [
            FoodGroup(
              id: '1',
              name: 'Grupo 1',
              color: const Color(0xFFBBEFFF),
            ), // Cyan claro
            FoodGroup(
              id: '2',
              name: 'Grupo 2',
              color: const Color(0xFF8FE3F9),
            ), // Cyan medio
            FoodGroup(
              id: '3',
              name: 'Grupo 3',
              color: const Color(0xFF54C2DE),
            ), // Azulado
            FoodGroup(
              id: '4',
              name: 'Grupo 4',
              color: const Color(0xFF94C1FF),
            ), // Lila azulado
            FoodGroup(
              id: '5',
              name: 'Grupo 5',
              color: const Color(0xFF6AE2D8),
            ), // Turquesa
          ],
        ),
      );

  // Acción: Cuando el usuario presiona un cuadro
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
        scaffoldBackgroundColor: const Color(0xFF1A1F21), // Fondo oscuro
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
    return Scaffold(
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
      // Barra de navegación inferior (Visual)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1F21),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Color(0xFF6AE2D8),
              child: Icon(Icons.camera_alt_outlined, color: Colors.black),
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list, size: 30), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            label: '',
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS SECCION SUPERIOR ---

class TopDashboardSection extends StatelessWidget {
  const TopDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionCubit, NutritionState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gráfico Circular (fl_chart)
            SizedBox(
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
                          color: const Color(0xFF3B82F6), // Proteina
                          value: state.proteinPerc,
                          title: '',
                          radius: 25,
                        ),
                        PieChartSectionData(
                          color: const Color(0xFF2DD4BF), // Verduras
                          value: state.vegPerc,
                          title: '',
                          radius: 25,
                        ),
                        PieChartSectionData(
                          color: const Color(0xFF4097AA), // Carbos
                          value: state.carbPerc,
                          title: '',
                          radius: 25,
                        ),
                      ],
                    ),
                  ),
                  // Texto o imagen al centro si deseas
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- LEYENDA DE PORCENTAJES ---
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
                  label: "Verduras",
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

// Widget auxiliar para los items de la leyenda
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
          "$label ${percent.toInt()}%",
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

class BentoGridSection extends StatelessWidget {
  const BentoGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionCubit, NutritionState>(
      builder: (context, state) {
        // Mapeamos los grupos por ID para facilitar el acceso en el layout
        final g1 = state.groups.firstWhere((g) => g.id == '1');
        final g2 = state.groups.firstWhere((g) => g.id == '2');
        final g3 = state.groups.firstWhere((g) => g.id == '3');
        final g4 = state.groups.firstWhere((g) => g.id == '4');
        final g5 = state.groups.firstWhere((g) => g.id == '5');

        return Row(
          children: [
            // Columna Izquierda (Grupo 1 - Grande Vertical)
            Expanded(flex: 45, child: BentoCard(group: g1)),
            const SizedBox(width: 10),
            // Columna Derecha
            Expanded(
              flex: 55,
              child: Column(
                children: [
                  // Parte superior derecha (Grupo 4)
                  Expanded(flex: 4, child: BentoCard(group: g4)),
                  const SizedBox(height: 10),
                  // Parte media derecha (Grupo 2)
                  Expanded(flex: 2, child: BentoCard(group: g2)),
                  const SizedBox(height: 10),
                  // Parte inferior derecha dividida (Grupo 5 y 3)
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
            // Contenido centrado (Texto + Imagen placeholder)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Aquí irían tus imágenes reales, uso Iconos por ahora
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

            // Checkmark Overlay (Aparece si está checkeado)
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
