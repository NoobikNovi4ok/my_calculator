import 'dart:math'; // Для использования математических функций
import 'dart:convert'; // Для работы с JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Для HTTP-запросов
import 'package:flutter_markdown/flutter_markdown.dart'; // Для отображения Markdown

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _expression = ''; // Текущее выражение (например, "5 + 3")
  double _result = 0; // Результат вычислений
  String _operation = ''; // Текущая операция
  String _markdownContent = 'Загрузка...'; // Содержимое Markdown

  @override
  void initState() {
    super.initState();
    _loadMarkdownFromCDN(); // Загружаем документацию при запуске
  }

  // Загрузка Markdown-файла с CDN
  Future<void> _loadMarkdownFromCDN() async {
    final url = Uri.parse('https://raw.githubusercontent.com/NoobikNovi4ok/my_calculator/refs/heads/main/README.md'); // Укажите вашу ссылку на CDN
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _markdownContent = utf8.decode(response.bodyBytes); // Декодируем содержимое
        });
      } else {
        setState(() {
          _markdownContent = 'Ошибка загрузки документации.';
        });
      }
    } catch (e) {
      setState(() {
        _markdownContent = 'Ошибка подключения: $e';
      });
    }
  }

  // Добавление символа в поле ввода
  void _addInput(String value) {
    setState(() {
      _expression += value;
    });
  }

  // Выполнение операции
  void _performOperation(String operation) {
    setState(() {
      if (_expression.isNotEmpty) {
        _result = double.parse(_expression);
        _expression += ' $operation ';
        _operation = operation;
      }
    });
  }

  // Вычисление результата
  void _calculateResult() {
    setState(() {
      if (_expression.isNotEmpty && _operation.isNotEmpty) {
        List<String> parts = _expression.split(' ');
        double secondNumber = double.parse(parts[2]);
        switch (_operation) {
          case '+':
            _result += secondNumber;
            break;
          case '-':
            _result -= secondNumber;
            break;
          case '*':
            _result *= secondNumber;
            break;
          case '/':
            if (secondNumber != 0) {
              _result /= secondNumber;
            } else {
              _result = 0; // Защита от деления на ноль
            }
            break;
          case 'log':
            if (secondNumber > 0 && _result > 0) {
              _result = _logBase(_result, secondNumber);
            } else {
              _result = 0; // Логарифм не определен для <= 0
            }
            break;
        }
        _expression = _formatResult(_result); // Форматируем результат
        _operation = '';
      }
    });
  }

  // Вычисление квадратного корня
  void _calculateSquareRoot() {
    setState(() {
      if (_expression.isNotEmpty) {
        double number = double.parse(_expression);
        if (number >= 0) {
          _result = sqrt(number); // Квадратный корень
          _expression = _formatResult(_result); // Форматируем результат
        } else {
          _result = 0; // Корень из отрицательного числа не определен
          _expression = 'Ошибка';
        }
      }
    });
  }

  // Очистка поля ввода
  void _clearInput() {
    setState(() {
      _expression = '';
      _result = 0;
      _operation = '';
    });
  }

  // Вычисление логарифма по произвольному основанию
  double _logBase(double x, double base) {
    return (x > 0 && base > 0 && base != 1)
        ? (log(x) / log(base))
        : 0; // Защита от некорректных значений
  }

  // Форматирование результата
  String _formatResult(double result) {
    if (result == result.roundToDouble()) {
      // Если число целое, возвращаем его без дробной части
      return result.toInt().toString();
    } else {
      // Иначе округляем до 6 знаков после запятой
      return result.toStringAsFixed(6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Калькулятор'),
      ),
      body: Column(
        children: [
          // Поле для отображения текущего выражения
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              alignment: Alignment.bottomRight,
              child: Text(
                _expression,
                style: const TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ),
          ),
          // Поле для отображения результата
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              alignment: Alignment.bottomRight,
              child: FittedBox(
                fit: BoxFit.scaleDown, // Масштабируем текст, если он не помещается
                child: Text(
                  _expression.isEmpty ? _formatResult(_result) : '',
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          // Кнопка для открытия документации
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Документация'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 400,
                    child: Markdown(
                      data: _markdownContent, // Отображаем Markdown
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Закрыть'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Показать документацию'),
          ),
          // Отступ между результатом и кнопками
          const SizedBox(height: 16),
          // Кнопки
          Expanded(
            child: Container(
              color: Colors.grey[300], // Серый фон для области кнопок
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Первая строка (AC, log, √, /)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        'AC',
                        _clearInput,
                        Colors.white,
                        Colors.black,
                        Colors.black,
                      ),
                      _buildButton(
                        'log',
                        () => _performOperation('log'),
                        Colors.white,
                        Colors.black,
                        Colors.black,
                      ),
                      _buildButton(
                        '√',
                        _calculateSquareRoot,
                        Colors.white,
                        Colors.black,
                        Colors.black,
                      ),
                      _buildButton(
                        '/',
                        () => _performOperation('/'),
                        Colors.orange,
                        Colors.white,
                        Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Отступ между строками
                  // Вторая строка (7, 8, 9, *)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        '7',
                        () => _addInput('7'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '8',
                        () => _addInput('8'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '9',
                        () => _addInput('9'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '*',
                        () => _performOperation('*'),
                        Colors.orange,
                        Colors.white,
                        Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Отступ между строками
                  // Третья строка (4, 5, 6, -)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        '4',
                        () => _addInput('4'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '5',
                        () => _addInput('5'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '6',
                        () => _addInput('6'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '-',
                        () => _performOperation('-'),
                        Colors.orange,
                        Colors.white,
                        Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Отступ между строками
                  // Четвертая строка (1, 2, 3, +)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        '1',
                        () => _addInput('1'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '2',
                        () => _addInput('2'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '3',
                        () => _addInput('3'),
                        Colors.grey[700]!,
                        Colors.white,
                        Colors.orange,
                      ),
                      _buildButton(
                        '+',
                        () => _performOperation('+'),
                        Colors.orange,
                        Colors.white,
                        Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Отступ между строками
                  // Пятая строка (0, ., =)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Кнопка "0" шириной в две кнопки
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5 - 32, // Ширина двух кнопок
                        height: 100,
                        child: ElevatedButton(
                          onPressed: () => _addInput('0'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.orange, width: 2),
                            ),
                          ),
                          child: const Text(
                            '0',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                      // Кнопка "."
                      _buildButton(
                        '.',
                        () => _addInput('.'),
                        Colors.white,
                        Colors.black,
                        Colors.black,
                      ),
                      // Кнопка "="
                      _buildButton(
                        '=',
                        _calculateResult,
                        Colors.orange,
                        Colors.white,
                        Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательный метод для создания кнопок
  Widget _buildButton(
    String text,
    VoidCallback onPressed,
    Color backgroundColor,
    Color textColor,
    Color borderColor,
  ) {
    return SizedBox(
      width: 100,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Уменьшенная степень округления
            side: BorderSide(color: borderColor, width: 2),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}