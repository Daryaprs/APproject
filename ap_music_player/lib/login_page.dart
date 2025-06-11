import 'package:flutter/material.dart';
import 'package:ap_music_player/home_page.dart';
import 'User.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  bool completeUserName = false;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void showToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return _ToastWidget(message: message);
      },
    );


    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2)).then((_) => overlayEntry.remove());
  }

  //این تابع به تغییرات نیاز دارد
  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/home');
      User loginUser = User(username: userNameController.text, password: passwordController.text);
      sendLoginData(loginUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueAccent = Colors.blueAccent.shade700;
    final blueAccentLight = Colors.blueAccent.shade200;



    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: blueAccent)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: blueAccent),
      ),
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 350,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: blueAccent.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: blueAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: userNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: blueAccent),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blueAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blueAccent, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            showToast('Please enter your username!');
                            return '';
                          }
                          else
                            completeUserName = true;
                          return null;
                        }
                        ),
                        SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: blueAccent),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blueAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blueAccent, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                        validator: (value) {
                        if(completeUserName){
                          if (value == null || value.isEmpty) {
                            showToast('Please enter your password!');
                            return '';
                          }
                        }
                          return null;
                        }
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueAccent,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        elevation: 5,
                      ),
                      onPressed: _login,
                      child: Icon(Icons.play_arrow, size: 32, color: Colors.white),
                    ),

                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(color: blueAccent),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: -45,
              right: -45,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * 3.1415926,
                    child: child,
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        blueAccent,
                        blueAccentLight,
                      ],
                      center: Alignment(-0.3, -0.3),
                      radius: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blueAccent.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _CircleLinePainter(),
                    child: Center(
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // یک خط دایره‌ای کوتاه برای نمایش چرخش
    double startAngle = 0;
    double sweepAngle = 3.14 / 3; // 60 درجه

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _ToastWidget extends StatefulWidget {
  final String message;
  const _ToastWidget({Key? key, required this.message}) : super(key: key);

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset(0, 0)).animate(_fadeAnimation);

    _controller.forward();
    Future.delayed(Duration(milliseconds: 1600), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: MediaQuery.of(context).size.width * 0.15,
      width: MediaQuery.of(context).size.width * 0.7,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.blueAccent.shade700.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.8),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.message,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

