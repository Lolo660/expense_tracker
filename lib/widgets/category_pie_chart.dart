import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryPieChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No category data available',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    final total = data.values.fold(0.0, (sum, amount) => sum + amount);
    if (total <= 0) {
      return Center(
        child: Text(
          'No spending data available',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    final sections = _createSections();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
          enabled: true,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        gridData: FlGridData(show: false),
        title: PieChartTitle(
          title: Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          positionPercentageOffset: 0.5,
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections() {
    final total = data.values.fold(0.0, (sum, amount) => sum + amount);
    final sections = <PieChartSectionData>[];
    
    int index = 0;
    data.forEach((category, amount) {
      if (amount > 0) {
        final percentage = (amount / total) * 100;
        final color = ExpenseCategory.categoryColors[category] ?? Colors.grey;
        
        sections.add(
          PieChartSectionData(
            color: color,
            value: amount,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: _buildBadge(category, amount, color),
            badgePositionPercentageOffset: 1.2,
          ),
        );
        index++;
      }
    });
    
    return sections;
  }

  Widget _buildBadge(String category, double amount, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
