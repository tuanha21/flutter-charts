import 'dart:ui';

import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

/// Position of legend in [FixedHorizontalAxisDecoration]
enum HorizontalLegendPosition {
  /// Show axis legend at the start of the chart
  start,

  /// Show legend at the end of the decoration
  end,
}

typedef AxisValueFromValue = String Function(int value);

/// Default axis generator, it will just take current index, convert it to string and return it.
String defaultAxisValue(int index) => '$index';

/// Decoration for drawing horizontal lines on the chart, decoration can add horizontal axis legend
///
/// This can be used if you don't need anything from [VerticalAxisDecoration], otherwise you might
/// consider using [GridDecoration]
class FixedHorizontalAxisDecoration extends DecorationPainter {
  /// Constructor for horizontal axis decoration
  FixedHorizontalAxisDecoration({
    this.showValues = false,
    this.showTopValue = false,
    this.showLines = true,
    this.valuesAlign = TextAlign.end,
    this.valuesPadding = EdgeInsets.zero,
    this.lineColor = Colors.grey,
    this.lineWidth = 1.0,
    this.axisValue = defaultAxisValue,
    this.axisStep = 1.0,
    this.textScale = 1.5,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  });

  FixedHorizontalAxisDecoration._lerp({
    this.showValues = false,
    this.showTopValue = false,
    this.showLines = true,
    this.valuesAlign = TextAlign.end,
    this.valuesPadding = EdgeInsets.zero,
    this.lineColor = Colors.grey,
    this.lineWidth = 1.0,
    this.axisStep = 1.0,
    this.textScale = 1.5,
    this.axisValue = defaultAxisValue,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  });

  /// Show axis legend values
  final bool showValues;

  /// Align text on the axis legend
  final TextAlign valuesAlign;

  /// Padding for the values in the axis legend
  final EdgeInsets valuesPadding;

  /// Should top horizontal value be shown This will increase padding such that
  /// text fits above the chart and adds top most value on horizontal scale.
  final bool showTopValue;

  /// Generate horizontal axis legend from value steps
  final AxisValueFromValue axisValue;

  /// Show horizontal lines
  final bool showLines;

  /// Set color to paint horizontal lines with
  final Color lineColor;

  /// Set line width
  final double lineWidth;

  /// Step for lines
  final double axisStep;

  /// Text style for axis legend
  final TextStyle legendFontStyle;

  final double textScale;

  String _longestText;

  @override
  void initDecoration(ChartState state) {
    super.initDecoration(state);
    if (showValues) {
      _longestText = axisValue.call(state.maxValue.toInt()).toString() + '0';
    }
  }

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    return Offset(state.defaultMargin.left, state.defaultMargin.top);
  }

  @override
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    return constraints.deflate(state.defaultMargin).biggest;
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    canvas.save();
    final _maxValue = state.maxValue - state.minValue;
    final _height = ((size.height) - lineWidth);
    final scale = _height / _maxValue;
    final gridPath = Path();

    for (var i = 0; i * scale * axisStep <= scale * _maxValue; i++) {
      if (showLines) {
        gridPath.moveTo(0.0, size.height - (lineWidth / 2 + axisStep * i * scale));
        gridPath.lineTo((size.width), size.height - (lineWidth / 2 + axisStep * i * scale));
      }

      String _text;

      if (!showTopValue && i == _maxValue / axisStep) {
        _text = null;
      } else {
        final _defaultValue = (axisStep * i + state.minValue).toInt();
        final _value = axisValue.call(_defaultValue);
        _text = _value.toString();
      }

      if (_text == null) {
        continue;
      }

      final _textPainter = TextPainter(
        text: TextSpan(
          text: _text,
          style: legendFontStyle,
        ),
        textAlign: valuesAlign,
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(
          maxWidth: size.width,
          minWidth: size.width,
        );

      _textPainter.paint(
          canvas, Offset(0.0, _height - axisStep * i * scale - (_textPainter.height + (valuesPadding.bottom ?? 0.0))));
    }

    canvas.drawPath(gridPath, _paint);

    canvas.restore();
  }

  @override
  FixedHorizontalAxisDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is FixedHorizontalAxisDecoration) {
      return FixedHorizontalAxisDecoration._lerp(
        showValues: t < 0.5 ? showValues : endValue.showValues,
        showTopValue: t < 0.5 ? showTopValue : endValue.showTopValue,
        valuesAlign: t < 0.5 ? valuesAlign : endValue.valuesAlign,
        valuesPadding: EdgeInsets.lerp(valuesPadding, endValue.valuesPadding, t),
        lineColor: Color.lerp(lineColor, endValue.lineColor, t) ?? endValue.lineColor,
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t) ?? endValue.lineWidth,
        axisStep: lerpDouble(axisStep, endValue.axisStep, t) ?? endValue.axisStep,
        textScale: lerpDouble(textScale, endValue.textScale, t) ?? endValue.textScale,
        legendFontStyle: TextStyle.lerp(legendFontStyle, endValue.legendFontStyle, t),
        axisValue: t > 0.5 ? endValue.axisValue : axisValue,
        showLines: t > 0.5 ? endValue.showLines : showLines,
      );
    }

    return this;
  }
}
