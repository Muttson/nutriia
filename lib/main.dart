import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriia/logic/cubits/nutricion/nutrition_cubit.dart';
import 'package:nutriia/presentacion/screens/nutrition_home_screen.dart';

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
