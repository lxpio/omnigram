import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculator_input.freezed.dart';
part 'calculator_input.g.dart';

@freezed
abstract class CalculatorInput with _$CalculatorInput {
  const factory CalculatorInput({
    String? expression,
  }) = _CalculatorInput;
  const CalculatorInput._();

  factory CalculatorInput.fromJson(Map<String, dynamic> json) =>
      _$CalculatorInputFromJson(json);
}
