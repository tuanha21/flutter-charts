import 'dart:math';

import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

import '../widgets/bar_chart.dart';

class MultiBarChartScreen extends StatefulWidget {
  MultiBarChartScreen({Key key}) : super(key: key);

  @override
  _MultiBarChartScreenState createState() => _MultiBarChartScreenState();
}

class _MultiBarChartScreenState extends State<MultiBarChartScreen> {
  Map<int, List<BarValue<void>>> _values = <int, List<BarValue<void>>>{};
  double targetMax;
  double targetMin;
  bool _showValues = false;
  int minItems = 6;
  bool _legendOnEnd = true;
  bool _legendOnBottom = true;
  bool _stackItems = false;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = _rand.nextDouble() * 10;
    targetMax = 5 + ((_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25)).roundToDouble();
    _values.addAll(Map<int, List<BarValue<void>>>.fromEntries(List.generate(3, (key) {
      return MapEntry(
          key,
          List.generate(minItems, (index) {
            return BarValue<void>(targetMax * 0.4 + _rand.nextDouble() * targetMax * 0.9);
          }));
    })));
    targetMin = targetMax - ((_rand.nextDouble() * 3) + (targetMax * 0.2));
  }

  void _addValues() {
    _values = Map.fromEntries(List.generate(3, (key) {
      return MapEntry(
          key,
          List.generate(minItems, (index) {
            if (_values[key].length > index) {
              return _values[key][index];
            }

            return BarValue<void>(targetMax * 0.4 + Random().nextDouble() * targetMax * 0.9);
          }));
    }));
  }

  List<List<BarValue<void>>> _getMap() {
    return [
      _values[0]
          .asMap()
          .map<int, BarValue<void>>((index, e) {
            return MapEntry(index, BarValue<void>(e.max + _values[1][index].max + _values[2][index].max));
          })
          .values
          .toList(),
      _values[1]
          .asMap()
          .map<int, BarValue<void>>((index, e) {
            return MapEntry(index, BarValue<void>(e.max + _values[2][index].max));
          })
          .values
          .toList(),
      _values[2].toList()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bar chart',
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BarChart.map(
                _getMap(),
                height: MediaQuery.of(context).size.height * 0.4,
                itemOptions: ChartItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    minBarWidth: 4.0,
                    // isTargetInclusive: true,
                    color: Theme.of(context).colorScheme.primary,
                    radius: const BorderRadius.vertical(
                      top: Radius.circular(24.0),
                    ),
                    colorForKey: (_, index) {
                      return [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryVariant,
                        Theme.of(context).colorScheme.secondary
                      ][index];
                    }),
                chartOptions: ChartOptions(
                  padding: _showValues
                      ? EdgeInsets.only(right: _legendOnEnd ? 12.0 : 0.0, left: _legendOnEnd ? 0.0 : 12.0)
                      : null,
                ),
                chartBehaviour: ChartBehaviour(
                  multiItemStack: _stackItems,
                ),
                backgroundDecorations: [
                  GridDecoration(
                    showVerticalGrid: true,
                    showHorizontalValues: _showValues,
                    showVerticalValues: _showValues,
                    showTopHorizontalValue: _legendOnBottom ? _showValues : false,
                    horizontalLegendPosition:
                        _legendOnEnd ? HorizontalLegendPosition.end : HorizontalLegendPosition.start,
                    verticalLegendPosition:
                        _legendOnBottom ? VerticalLegendPosition.bottom : VerticalLegendPosition.top,
                    valueAxisStep: 1,
                    itemAxisStep: 1,
                    textStyle: Theme.of(context).textTheme.caption,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  ),
                ],
                foregroundDecorations: [
                  BorderDecoration(),
                  ValueDecoration(
                    alignment: Alignment.bottomCenter,
                    textStyle:
                        Theme.of(context).textTheme.button.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: ChartOptionsWidget(
              onRefresh: () {
                setState(() {
                  _values.clear();
                  _updateValues();
                });
              },
              onAddItems: () {
                setState(() {
                  minItems += 4;
                  _addValues();
                });
              },
              onRemoveItems: () {
                setState(() {
                  if (minItems > 6) {
                    minItems -= 4;
                    _values = _values.map((key, value) {
                      return MapEntry(key, value..removeRange(value.length - 4, value.length));
                    });
                  }
                });
              },
              toggleItems: [
                ToggleItem(
                  title: 'Axis values',
                  value: _showValues,
                  onChanged: (value) {
                    setState(() {
                      _showValues = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _legendOnEnd,
                  title: 'Legend on end',
                  onChanged: (value) {
                    setState(() {
                      _legendOnEnd = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _legendOnBottom,
                  title: 'Legend on bottom',
                  onChanged: (value) {
                    setState(() {
                      _legendOnBottom = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _stackItems,
                  title: 'Stack items',
                  onChanged: (value) {
                    setState(() {
                      _stackItems = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
