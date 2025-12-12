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
import 'package:nutriia/presentacion/widgets/bento/bento_grid.dart';
import 'package:nutriia/presentacion/widgets/dashboard/top_dashboard.dart';
import 'package:nutriia/presentacion/widgets/navigation/bottom_nav_bar.dart';

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
