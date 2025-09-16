import 'dart:ui';
import 'package:math_expressions/math_expressions.dart' hide Stack;
import 'package:app/import_export.dart';

// ---------- CONTROLLER ----------
class CalcController extends GetxController {
  final input = ''.obs;
  final result = '0'.obs;
  final history = <String>[].obs;
  final isDark = false.obs;

  // For animated background toggle
  final bgPhase = 0.obs;

  // toggle theme
  void toggleTheme() => isDark.value = !isDark.value;

  // append a char (digit or operator)
  void append(String s) {
    // prevent invalid sequences
    if (s == '.' && input.endsWith('.')) return;
    // don't start with operator except '-'
    if (input.isEmpty && '+×÷*/'.contains(s)) return;

    // avoid two operators in a row (allow negative)
    if (input.value.isNotEmpty &&
        _isOperator(input.value[input.value.length - 1]) &&
        _isOperator(s)) {
      input.value =
          input.value.substring(0, input.value.length - 1) + s;
      return;
    }


    input.value += s;
  }

  bool _isOperator(String s) {
    return s == '+' || s == '-' || s == '×' || s == '÷' || s == '*' || s == '/';
  }

  void clearAll() {
    input.value = '';
    result.value = '0';
  }

  void delete() {
    if (input.isNotEmpty) {
      input.value = input.value.substring(0, input.value.length - 1);
    }
  }

  void percent() {
    // if input empty return
    if (input.isEmpty) return;
    try {
      final expr = _toEvaluable(input.value);
      final Parser p = Parser();
      Expression exp = p.parse(expr);
      final ContextModel cm = ContextModel();
      final val = exp.evaluate(EvaluationType.REAL, cm);
      final perc = val / 100.0;
      result.value = _formatNumber(perc);
      // also push as result (but not into input)
    } catch (e) {
      result.value = 'Error';
    }
  }

  Future<void> evaluate() async {
    if (input.isEmpty) return;
    try {
      final expr = _toEvaluable(input.value);
      final Parser p = Parser();
      Expression exp = p.parse(expr);
      final ContextModel cm = ContextModel();
      final val = exp.evaluate(EvaluationType.REAL, cm);
      final out = _formatNumber(val);
      // push to history
      history.insert(0, "${input.value} = $out");
      result.value = out;
      // optionally set input to out for chaining
      input.value = out;
    } catch (e) {
      result.value = 'Error';
    }
  }

  // convert visual operators to evaluable ones
  String _toEvaluable(String s) {
    return s.replaceAll('×', '*').replaceAll('÷', '/');
  }

  String _formatNumber(num v) {
    // trim trailing .0
    final s = v.toString();
    if (s.contains('.') && s.endsWith('0')) {
      // round to up to 8 decimals, strip trailing zeros
      return v.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  // animate background phase
  void nextBgPhase() {
    bgPhase.value = (bgPhase.value + 1) % 3;
  }
}

// ---------- MAIN ----------
void main() {
  runApp(MyApp());
}

// ---------- APP ----------
class MyApp extends StatelessWidget {
  final CalcController c = Get.put(CalcController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Animated Calculator',
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: c.isDark.value ? ThemeMode.dark : ThemeMode.light,
        home: calculatornewPage(),
      );
    });
  }
}

// ---------- THEMES ----------
final _lightTheme = ThemeData.light().copyWith(
  textTheme: GoogleFonts.poppinsTextTheme(),
  primaryColor: Colors.teal,
  scaffoldBackgroundColor: Colors.grey[100],
  brightness: Brightness.light,
);

final _darkTheme = ThemeData.dark().copyWith(
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  primaryColor: Colors.tealAccent,
  scaffoldBackgroundColor: Color(0xFF0F1113),
  brightness: Brightness.dark,
);

// ---------- HOME PAGE ----------
class calculatornewPage extends StatefulWidget {
  @override
  State<calculatornewPage> createState() => _HomePageState();
}

class _HomePageState extends State<calculatornewPage> with SingleTickerProviderStateMixin {
  final CalcController c = Get.find();
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    // loop animation for background phase change
    _animController = AnimationController(vsync: this, duration: Duration(seconds: 6))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          c.nextBgPhase();
          _animController.forward(from: 0);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = c.isDark.value;
      return Scaffold(
        body: Stack(
          children: [
            // Animated gradient background
            AnimatedBackground(phase: c.bgPhase.value, isDark: isDark),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _TopBar(),
                  SizedBox(height: 16),
                  Expanded(child: _DisplayCard()),
                  _KeypadArea(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ---------- Animated Background ----------
class AnimatedBackground extends StatelessWidget {
  final int phase;
  final bool isDark;
  const AnimatedBackground({required this.phase, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // choose palettes per phase
    final palettes = [
      [Colors.teal.shade400, Colors.cyan.shade300, Colors.indigo.shade200],
      [Colors.purple.shade400, Colors.pink.shade300, Colors.orange.shade200],
      [Colors.green.shade600, Colors.lime.shade300, Colors.blue.shade200],
    ];
    final colors = palettes[phase % palettes.length];

    return AnimatedContainer(
      duration: Duration(seconds: 6),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.9 + phase * 0.3, -1),
          end: Alignment(1, 1),
          colors: isDark
              ? colors.map((c) => c.withOpacity(0.18)).toList()
              : colors.map((c) => c.withOpacity(0.95)).toList(),
        ),
      ),
      child: Stack(
        children: [
          // subtle moving circles
          Positioned(
            top: 40.0 + phase * 10,
            left: -60 + phase * 20.0,
            child: _BlurCircle(size: 220, color: Colors.white.withOpacity(isDark ? 0.03 : 0.06)),
          ),
          Positioned(
            bottom: -40.0 + phase * 12,
            right: -80 + phase * 10.0,
            child: _BlurCircle(size: 200, color: Colors.white.withOpacity(isDark ? 0.03 : 0.05)),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurCircle({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: SizedBox()),
    );
  }
}

// ---------- Top bar ----------
class _TopBar extends StatelessWidget {
  final CalcController c = Get.find();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text(
            'Calc',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          Spacer(),
          IconButton(
            onPressed: () => Get.bottomSheet(_HistorySheet(), isScrollControlled: true, backgroundColor: Colors.transparent),
            icon: Icon(Icons.history, color: Colors.black),
            tooltip: 'History',
          ),
          SizedBox(width: 8),
          Obx(() => GestureDetector(
            onTap: c.toggleTheme,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: c.isDark.value ? Colors.white12 : Colors.black12,
              ),
              child: Icon(c.isDark.value ? Icons.dark_mode : Icons.light_mode, color: Colors.black),
            ),
          )),
        ],
      ),
    );
  }
}

// ---------- Display Card (glassy) ----------
class _DisplayCard extends StatelessWidget {
  final CalcController c = Get.find();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.94;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // glassy card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // small preview input
                    Obx(() => AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder: (w, a) => SlideTransition(position: Tween<Offset>(begin: Offset(0, .2), end: Offset(0,0)).animate(a), child: FadeTransition(opacity: a, child: w)),
                      child: Text(
                        c.input.value.isEmpty ? '0' : c.input.value,
                        key: ValueKey(c.input.value),
                        style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),
                      ),
                    )),
                    SizedBox(height: 10),
                    // result
                    Obx(() => AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder: (w, a) => SlideTransition(position: Tween<Offset>(begin: Offset(0, .1), end: Offset(0,0)).animate(a), child: FadeTransition(opacity: a, child: w)),
                      child: Text(
                        c.result.value,
                        key: ValueKey(c.result.value),
                        style: GoogleFonts.poppins(fontSize: 44, fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                    )),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${DateTime.now().toLocal().toString().split('.')[0]}', style: TextStyle(fontSize: 10, color: Colors.black)),
                        //Text('• Animated', style: TextStyle(fontSize: 10, color: Colors.black)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 18),
        ],
      ),
    );
  }
}

// ---------- Keypad ----------
class _KeypadArea extends StatelessWidget {
  final CalcController c = Get.find();

  final List<List<String>> keys = [
    ['AC', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['+/-', '0', '.', '='],
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isLarge = mq.size.height > 700;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: row.map((k) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: _CalcButton(
                      label: k,
                      onTap: () => _onKeyTap(k),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onKeyTap(String k) {
    if (k == 'AC') {
      c.clearAll();
      return;
    }
    if (k == '⌫') {
      c.delete();
      return;
    }
    if (k == '%') {
      c.percent();
      return;
    }
    if (k == '=') {
      c.evaluate();
      return;
    }
    if (k == '+/-') {
      // toggle sign of current number
      if (c.input.isEmpty) return;
      // naive implementation: prepend or remove leading '-'
      if (c.input.value.startsWith('-')) {
        c.input.value = c.input.value.substring(1);
      } else {
        c.input.value = '-${c.input.value}';
      }
      return;
    }
    // default: append char
    c.append(k);
  }
}

// ---------- Button Widget ----------
class _CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _CalcButton({required this.label, required this.onTap});

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton> {
  double _scale = 1.0;
  bool get _isOperator {
    return ['+', '-', '×', '÷', '='].contains(widget.label);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgGradient = _isOperator
        ? LinearGradient(colors: [Colors.cyan.shade300, Colors.cyan.shade900])
        : LinearGradient(colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)]);
    final glow = _isOperator ? Colors.orangeAccent.withOpacity(0.25) : Colors.black12;
    final textColor = _isOperator ? Colors.white : Colors.white70;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        duration: Duration(milliseconds: 80),
        scale: _scale,
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: glow, blurRadius: _isOperator ? 18 : 6, spreadRadius: _isOperator ? 2 : 0),
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: Offset(0, 4)),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.02)),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- History Sheet ----------
class _HistorySheet extends StatelessWidget {
  final CalcController c = Get.find();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, sc) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            children: [
              Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(8))),
              SizedBox(height: 12),
              Row(
                children: [
                  Text("History", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  Spacer(),
                  IconButton(onPressed: () => c.history.clear(), icon: Icon(Icons.delete_forever)),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  if (c.history.isEmpty) {
                    return Center(child: Text("No history yet", style: TextStyle(color: Colors.grey)));
                  }
                  return ListView.builder(
                    controller: sc,
                    itemCount: c.history.length,
                    itemBuilder: (context, i) {
                      final item = c.history[i];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        title: Text(item, style: TextStyle(fontSize: 16)),
                        onTap: () {
                          // on tapping history item, copy result to input for reuse
                          final parts = item.split('=');
                          if (parts.length == 2) {
                            final res = parts[1].trim();
                            c.input.value = res;
                            Get.back();
                          }
                        },
                      );
                    },
                  );
                }),
              )
            ],
          ),
        );
      },
    );
  }
}
