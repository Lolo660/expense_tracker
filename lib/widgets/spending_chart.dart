import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class SpendingChart extends StatelessWidget {
  final String period;
  final List<Expense> expenses;

  const SpendingChart({
    super.key,
    required this.period,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();
    
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'No data available for $period',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _getHorizontalInterval(chartData),
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getBottomInterval(chartData),
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _formatBottomTitle(chartData[value.toInt()].date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getLeftInterval(chartData),
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY(chartData),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.amount);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final data = chartData[barSpot.x.toInt()];
                return LineTooltipItem(
                  '${_formatBottomTitle(data.date)}\n\$${data.amount.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  List<ChartDataPoint> _prepareChartData() {
    final now = DateTime.now();
    List<DateTime> dateRange;
    
    switch (period) {
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        dateRange = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
        break;
      case 'This Month':
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        dateRange = List.generate(daysInMonth, (index) => DateTime(now.year, now.month, index + 1));
        break;
      case 'Last Month':
        final daysInLastMonth = DateTime(now.year, now.month, 0).day;
        dateRange = List.generate(daysInLastMonth, (index) => DateTime(now.year, now.month - 1, index + 1));
        break;
      case 'This Year':
        dateRange = List.generate(12, (index) => DateTime(now.year, index + 1, 1));
        break;
      default:
        dateRange = [];
    }

    return dateRange.map((date) {
      double totalAmount = 0.0;
      
      if (period == 'This Year') {
        // For yearly view, sum all expenses in the month
        totalAmount = expenses
            .where((expense) => 
                expense.date.year == date.year && 
                expense.date.month == date.month)
            .fold(0.0, (sum, expense) => sum + expense.amount);
      } else {
        // For daily views, sum expenses on the specific date
        totalAmount = expenses
            .where((expense) => 
                expense.date.year == date.year && 
                expense.date.month == date.month && 
                expense.date.day == date.day)
            .fold(0.0, (sum, expense) => sum + expense.amount);
      }
      
      return ChartDataPoint(date: date, amount: totalAmount);
    }).toList();
  }

  double _getHorizontalInterval(List<ChartDataPoint> data) {
    final maxAmount = _getMaxY(data);
    return maxAmount / 5;
  }

  double _getLeftInterval(List<ChartDataPoint> data) {
    final maxAmount = _getMaxY(data);
    return maxAmount / 4;
  }

  int _getBottomInterval(List<ChartDataPoint> data) {
    if (data.length <= 7) return 1;
    if (data.length <= 14) return 2;
    if (data.length <= 31) return 3;
    return 2; // For monthly view
  }

  double _getMaxY(List<ChartDataPoint> data) {
    if (data.isEmpty) return 100;
    final maxAmount = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    return (maxAmount * 1.2).ceilToDouble(); // Add 20% padding
  }

  String _formatBottomTitle(DateTime date) {
    switch (period) {
      case 'This Week':
        return DateFormat('E').format(date);
      case 'This Month':
      case 'Last Month':
        return DateFormat('dd').format(date);
      case 'This Year':
        return DateFormat('MMM').format(date);
      default:
        return DateFormat('MM/dd').format(date);
    }
  }
}

class ChartDataPoint {
  final DateTime date;
  final double amount;

  ChartDataPoint({
    required this.date,
    required this.amount,
  });
}
