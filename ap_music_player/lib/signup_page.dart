import 'package:flutter/material.dart';
import 'package:ap_music_player/Home_page.dart';
import 'User.dart';
import 'auth_service.dart';

class SignupPage extends StatefulWidget {
  final AuthService authService;
  SignupPage({required this.authService});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final phoneRegex = RegExp(r'^(\+98|0)?9\d{9}$');
  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');

  bool completeUserName = false;
  bool completePass = false;

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
    confirmPasswordController.dispose();
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

  //این تابع تغییرات نیاز دارد
  void _signup() async{
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Signup Success', style: TextStyle(color: Colors.redAccent)),
          content: Text('Account created for ${userNameController.text}!', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Colors.redAccent)),
            )
          ],
        ),
      );
      User signupUser = User(username: userNameController.text.trim(), password: passwordController.text);
      String signupResult = await widget.authService.signup(signupUser);
      Navigator.pushReplacementNamed(context, '/home');
      User loginUser = User(username: userNameController.text.trim(), password: passwordController.text);
      String loginResult = await widget.authService.login(signupUser);
      if (signupResult == 'signup_success') {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (signupResult == 'signup_fail') {
        showToast('Signup Failed.');
      } else {
        showToast('Network error.');
      }
    }
    }
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final user = User(
      username: userNameController.text.trim(),
      password: passwordController.text,
    );

    String result = await widget.authService.login(user);


    if (result == 'login_success') {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (result == 'login_failed') {
      showToast('Invalid username or password');
    } else if (result == 'timeout') {
      showToast('Server timeout. Try again.');
    } else {
      showToast('Network error.');
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(color: Colors.redAccent)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.redAccent),
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
                    color: Colors.redAccent.withOpacity(0.5),
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
                      "Create Account",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: userNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          showToast('Please enter a username!');
                          return '';
                        } else if (!(phoneRegex.hasMatch(value) || emailRegex.hasMatch(value))) {
                          showToast('Username must be a valid email or phone number.');
                          return '';
                        } else {
                          completeUserName = true;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: _inputDecoration('Password'),
                      validator: (value) {
                        if (completeUserName) {
                          if ((value == null || value.length < 8)) {
                            showToast('Password must be at least 8 characters long.');
                            return '';
                          } else if (value.contains(userNameController.text)) {
                            showToast('Password should not contain your username!');
                            return '';
                          } else if (!passwordRegex.hasMatch(value)) {
                            showToast('Password must include uppercase and lowercase letters and numbers.');
                            return '';
                          } else
                            completePass = true;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: _inputDecoration('Confirm Password'),
                      validator: (value) {
                        if(completePass && completeUserName){
                          if (value != passwordController.text) {
                            showToast('Passwords do not match!');
                            return '';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                      onPressed: _signup,
                      child: Icon(Icons.play_arrow, size: 32, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Already have an account? Log in",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // CD rotating + arc
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
                        Colors.redAccent.shade700,
                        Colors.redAccent.shade200,
                      ],
                      center: Alignment(-0.3, -0.3),
                      radius: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.6),
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

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.redAccent),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

// Toast widget
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
                color: Colors.redAccent.shade700.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.shade400.withOpacity(0.8),
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

// Painter for CD arc
class _CircleLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, 3.14 / 3, false, paint); // 60 درجه از دایره
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
