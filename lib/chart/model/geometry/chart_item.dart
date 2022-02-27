part of charts_painter;

/// Default `ChartItem`
class ChartItem<T> {
  /// Protected constructor for animations
  @protected
  ChartItem(this.value, this.min, this.max, {this.high, this.low});

  /// Minimum chart item value
  final double? min;

  /// Maximum item value
  final double? max;

  /// High value for candle chart
  final double? high;

  /// Low value for candle chart
  final double? low;

  /// Items can have value attached to them `T`
  final T? value;

  /// Check if current item is empty
  bool get isEmpty => (max ?? 0) == 0 && (min ?? 0) == 0;

  /// Check if current item in type candle
  bool get isCandleItem => !((high ?? 0) == 0 && (low ?? 0) == 0);

  /// Animate to [endValue] with factor `t`
  ChartItem<T?> animateTo(ChartItem<T?> endValue, double t) {
    return ChartItem<T?>(
      endValue.value,
      lerpDouble(min, endValue.min, t),
      lerpDouble(max, endValue.max, t),
      high: lerpDouble(high, endValue.high, t),
      low: lerpDouble(low, endValue.low, t),
    );
  }

  /// Animate from [startValue] to this with factor `t`
  ChartItem<T?> animateFrom(ChartItem<T?> startValue, double t) {
    return animateTo(startValue, 1 - t);
  }

  @override
  int get hashCode => hashValues(min, max) ^ value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ChartItem) {
      return other.hashCode == hashCode;
    }

    return false;
  }

  /// Add two [ChartItem]'s together
  /// `T` value is taken from [other]
  ChartItem<T?> operator +(Object other) {
    if (other is ChartItem<T?>) {
      return ChartItem<T?>(
        other.value,
        (other.min ?? 0.0) + (min ?? 0.0),
        (other.max ?? 0.0) + (max ?? 0.0),
      );
    }

    return this;
  }

  /// Multiply [ChartItem] with another [ChartItem] of number
  ChartItem<T?> operator *(Object? other) {
    if (other is ChartItem<T?>) {
      return ChartItem<T?>(
        other.value,
        (other.min ?? 0.0) * (min ?? 0.0),
        (other.max ?? 0.0) * (max ?? 0.0),
      );
    } else if (other is num) {
      return ChartItem<T>(
        value,
        other.toDouble() * (min ?? 0.0),
        other.toDouble() * (max ?? 0.0),
      );
    }

    return this;
  }

  @override
  String toString() {
    return 'ChartItem(min: $min, max: $max, value: $value)';
  }
}
