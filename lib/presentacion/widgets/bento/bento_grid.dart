import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriia/logic/cubits/nutricion/nutrition_cubit.dart';
import 'package:nutriia/logic/cubits/nutricion/nutrition_state.dart';
import 'package:nutriia/main.dart';
import 'package:nutriia/presentacion/widgets/bento/bento_card.dart';

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
