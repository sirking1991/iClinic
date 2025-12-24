import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FamilyGroupWidget extends StatelessWidget {
  const FamilyGroupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
          child: Text("HOUSEHOLD / FAMILY", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.sage500, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildMemberCard(context, "David", "Husband", 36),
              const SizedBox(width: 8),
              _buildMemberCard(context, "Lily", "Daughter", 8),
              const SizedBox(width: 8),
              _buildAddButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, String name, String rel, int age) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sage50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sage100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.midnight900)),
          Text("$rel, $age yrs", style: const TextStyle(fontSize: 12, color: AppColors.sage500)),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sage200, style: BorderStyle.none), // Dashed border needs custom painter or 3rd party
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text("+ Add Member", style: TextStyle(color: AppColors.sage400, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
