import 'dart:async';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/ai/tools/ai_tool_registry.dart';
import 'package:omnigram/service/ai/tools/input/calculator_input.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:math_expressions/math_expressions.dart';

import 'base_tool.dart';

class CalculatorTool
    extends RepositoryTool<CalculatorInput, Map<String, dynamic>> {
  CalculatorTool()
      : super(
          name: 'calculator',
          description:
              'Evaluate straightforward arithmetic expressions when you need an exact numeric answer. Supports numbers and the operators +, -, *, /, and ^. Returns the original expression along with the computed result as a string.',
          inputJsonSchema: const {
            'type': 'object',
            'properties': {
              'expression': {
                'type': 'string',
                'description':
                    'Required. Plain-text arithmetic expression to compute. No variables or functions are supported.',
              },
            },
            'required': ['expression'],
          },
          timeout: const Duration(seconds: 2),
        );

  @override
  CalculatorInput parseInput(Map<String, dynamic> json) {
    return CalculatorInput.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> run(CalculatorInput input) async {
    final expression = input.expression?.trim() ?? '';
    if (expression.isEmpty) {
      throw ArgumentError('Expression cannot be empty');
    }

    final result = _evaluateExpression(expression);
    return {
      'expression': expression,
      'result': result,
    };
  }

  @override
  bool shouldLogError(Object error) {
    return error is! TimeoutException;
  }

  String _evaluateExpression(String expression) {
    AnxLog.info('Evaluating expression: $expression');
    final parser = ShuntingYardParser();
    final parsed = parser.parse(expression);
    final evaluation = parsed.evaluate(EvaluationType.REAL, ContextModel());
    if (evaluation is num && evaluation != 0) {
      final rounded = _roundIfClose(evaluation.toDouble());
      return rounded.toString();
    }
    return evaluation.toString();
  }

  double _roundIfClose(double value) {
    const epsilon = 1e-10;
    final rounded = value.roundToDouble();
    return (value - rounded).abs() < epsilon ? rounded : value;
  }
}

final AiToolDefinition calculatorToolDefinition = AiToolDefinition(
  id: 'calculator',
  displayNameBuilder: (L10n l10n) => l10n.aiToolCalculatorName,
  descriptionBuilder: (L10n l10n) => l10n.aiToolCalculatorDescription,
  build: (context) => CalculatorTool().tool,
);
