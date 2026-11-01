import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/widgets/stat_card.dart';
import 'package:fittrack/widgets/custom_button.dart';
import 'package:fittrack/widgets/reusable_widgets.dart';
import 'package:fittrack/widgets/custom_charts.dart';
import 'package:fittrack/models/weight_record.dart';

void main() {
  group('Widget Tests', () {
    testWidgets(
      'StatCard renders title, value, subtitle, and responds to tap',
      (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatCard(
                title: 'Current Weight',
                value: '72.5 kg',
                subtitle: 'Tap to log weight',
                icon: Icons.monitor_weight_outlined,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Current Weight'), findsOneWidget);
        expect(find.text('72.5 kg'), findsOneWidget);
        expect(find.text('Tap to log weight'), findsOneWidget);
        expect(find.byIcon(Icons.monitor_weight_outlined), findsOneWidget);

        await tester.tap(find.byType(StatCard));
        expect(tapped, isTrue);
      },
    );

    testWidgets('CustomButton renders text, icon and handles tap', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Finish Workout',
              icon: Icons.check,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Finish Workout'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.byType(CustomButton));
      expect(pressed, isTrue);
    });

    testWidgets('MetricBadge renders label with styled container', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricBadge(label: 'Normal weight', color: Colors.green),
          ),
        ),
      );

      expect(find.text('Normal weight'), findsOneWidget);
    });

    testWidgets(
      'EmptyStateWidget renders icon, title, message and action button',
      (WidgetTester tester) async {
        bool clicked = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.fitness_center,
                title: 'No Workouts',
                message: 'Get started by creating a workout.',
                buttonText: 'Add Workout',
                onButtonPressed: () {
                  clicked = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('No Workouts'), findsOneWidget);
        expect(find.text('Get started by creating a workout.'), findsOneWidget);
        expect(find.text('Add Workout'), findsOneWidget);

        await tester.tap(find.text('Add Workout'));
        expect(clicked, isTrue);
      },
    );

    testWidgets(
      'WeightTrendChart renders empty message when records list is empty',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: WeightTrendChart(records: [])),
          ),
        );

        expect(find.text('No weight records logged yet'), findsOneWidget);
      },
    );

    testWidgets('WeightTrendChart paints when records are provided', (
      WidgetTester tester,
    ) async {
      final records = [
        WeightRecord(
          weightKg: 72.0,
          date: '2026-10-25',
          createdAt: '2026-10-25T10:00:00',
        ),
        WeightRecord(
          weightKg: 71.5,
          date: '2026-10-28',
          createdAt: '2026-10-28T10:00:00',
        ),
        WeightRecord(
          weightKg: 71.0,
          date: '2026-10-31',
          createdAt: '2026-10-31T10:00:00',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WeightTrendChart(records: records)),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('WeeklyBarChart renders daily values and bars', (
      WidgetTester tester,
    ) async {
      final dailyData = {
        '2026-10-25': 2000,
        '2026-10-26': 2500,
        '2026-10-27': 1800,
        '2026-10-28': 3000,
        '2026-10-29': 2200,
        '2026-10-30': 2700,
        '2026-10-31': 2500,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyBarChart(dailyData: dailyData, unit: 'ml'),
          ),
        ),
      );

      expect(find.byType(WeeklyBarChart), findsOneWidget);
      expect(find.text('10/25'), findsOneWidget);
      expect(find.text('10/31'), findsOneWidget);
    });
  });
}
