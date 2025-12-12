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
