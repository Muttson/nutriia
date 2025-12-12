import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriia/data/models/food_group_model.dart';
import 'package:nutriia/logic/cubits/nutricion/nutrition_cubit.dart';

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
