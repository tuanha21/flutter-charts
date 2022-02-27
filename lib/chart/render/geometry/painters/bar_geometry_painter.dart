part of charts_painter;

/// Paint bar value item. This is painter used for [BarValue] and [CandleValue]
///
/// Bar value:
///    ┌───────────┐ --> Max value in set or from [ChartData.maxValue]
///    │           │
///    │   ┌───┐   │ --> Bar value
///    │   │   │   │
///    │   │   │   │
///    │   │   │   │
///    │   │   │   │
///    └───┴───┴───┘ --> 0 or [ChartData.minValue]
///
/// Candle value:
///    ┌───────────┐ --> Max value in set or [ChartData.maxValue]
///    │           │
///    │   ┌───┐   │ --> Candle max value
///    │   │   │   │
///    │   │   │   │
///    │   └───┘   │ --> Candle min value
///    │           │
///    └───────────┘ --> 0 or [ChartData.minValue]
///
class BarGeometryPainter<T> extends GeometryPainter<T> {
  /// Constructor for Bar painter
  BarGeometryPainter(
      ChartItem<T> item, ChartData<T?> data, ItemOptions itemOptions)
      : super(item, data, itemOptions);

  @override
  void draw(Canvas canvas, Size size, Paint paint) {
    final _maxValue = data.maxValue - data.minValue;
    final _highValue =
        (data.highValue ?? data.maxValue) - (data.lowValue ?? data.minValue);

    final _valueMultiplier = size.height / _maxValue;
    final _verticalMultiplier = size.height / _highValue;

    final _minValue = (data.minValue * _valueMultiplier);
    final _lowValue = ((data.lowValue ?? data.minValue) * _verticalMultiplier);

    final _radius = itemOptions is BarItemOptions
        ? ((itemOptions as BarItemOptions).radius ?? BorderRadius.zero)
        : BorderRadius.zero;

    final _valueWidth = valueWidth(size);
    final _stickWidth = stickWidth(size);

    final _itemMaxValue = item.max ?? 0.0;
    final _stickMaxValue = item.high ?? _itemMaxValue;

    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item.isEmpty || _itemMaxValue < data.minValue) {
      return;
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(
            0.0,
            _maxValue * _valueMultiplier -
                max(data.minValue, item.min ?? 0.0) * _valueMultiplier +
                _minValue,
          ),
          Offset(
            _valueWidth,
            _maxValue * _valueMultiplier -
                _itemMaxValue * _valueMultiplier +
                _minValue,
          ),
        ),
        bottomLeft:
            _itemMaxValue.isNegative ? _radius.topLeft : _radius.bottomLeft,
        bottomRight:
            _itemMaxValue.isNegative ? _radius.topRight : _radius.bottomRight,
        topLeft:
            _itemMaxValue.isNegative ? _radius.bottomLeft : _radius.topLeft,
        topRight:
            _itemMaxValue.isNegative ? _radius.bottomRight : _radius.topRight,
      ),
      paint,
    );

    if (item.isCandleItem) {
      canvas.drawLine(
        Offset(
          _valueWidth / 2,
          _highValue * _verticalMultiplier -
              max(data.lowValue ?? data.minValue, item.min ?? 0.0) *
                  _verticalMultiplier +
              _lowValue,
        ),
        Offset(
          _valueWidth / 2,
          _highValue * _verticalMultiplier -
              _stickMaxValue * _verticalMultiplier +
              _minValue,
        ),
        paint..strokeWidth = _stickWidth,
      );
    }

    final _border = itemOptions is BarItemOptions
        ? (itemOptions as BarItemOptions).border
        : null;

    if (_border != null && _border.style == BorderStyle.solid) {
      final _borderPaint = Paint();
      _borderPaint.style = PaintingStyle.stroke;
      _borderPaint.color = _border.color;
      _borderPaint.strokeWidth = _border.width;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(
              0.0,
              max(data.minValue, item.min ?? 0.0) * _valueMultiplier +
                  _minValue,
            ),
            Offset(
              _valueWidth,
              _itemMaxValue * _valueMultiplier + _minValue,
            ),
          ),
          bottomLeft:
              _itemMaxValue.isNegative ? _radius.topLeft : _radius.bottomLeft,
          bottomRight:
              _itemMaxValue.isNegative ? _radius.topRight : _radius.bottomRight,
          topLeft:
              _itemMaxValue.isNegative ? _radius.bottomLeft : _radius.topLeft,
          topRight:
              _itemMaxValue.isNegative ? _radius.bottomRight : _radius.topRight,
        ),
        _borderPaint,
      );
    }
  }
}
