import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _isHovering = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLoading =
      ValueNotifier<bool>(false); // Track loading state

  void _performLogin(BuildContext context) async {
    _isLoading.value = true; // Show progress indicator

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Successfully logged in, navigate to the home page
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      // Handle login failure
      print('Login failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: Check your email or password'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoading.value = false; // Hide progress indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            fontSize: 26.0,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 7, 107, 35),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/vddm_logo.png', height: 180.0),
                    SizedBox(height: 20),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Color.fromARGB(255, 7, 107, 35),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromARGB(255, 7, 107, 35),
                          ),
                          fillColor: Colors.white.withOpacity(0.5),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 7, 107, 35),
                                width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 7, 107, 35),
                                width: 2),
                          ),
                          focusedBorder:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 7, 107, 35), width: 2),
                      ),
                        ),
                        style: TextStyle(fontSize: 20.0, color: Colors.black),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.password,
                            color: Color.fromARGB(255, 7, 107, 35),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromARGB(255, 7, 107, 35),
                          ),
                          fillColor: Colors.white.withOpacity(0.5),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 7, 107, 35),
                                width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 7, 107, 35),
                                width: 2),
                          ),
                          focusedBorder:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 7, 107, 35), width: 2),
                          ),
                        ),
                        style: TextStyle(fontSize: 20.0, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _performLogin(context),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 7, 107, 35),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color.fromARGB(255, 7, 107, 35),
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(255, 7, 107, 35),
                      ),
                    ),
                    MouseRegion(
                      onEnter: (_) => _isHovering.value = true,
                      onExit: (_) => _isHovering.value = false,
                      child: ValueListenableBuilder(
                        valueListenable: _isHovering,
                        builder: (context, isHovering, child) {
                          return TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupPage()),
                              );
                            },
                            child: Text(
                              'Signup',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color.fromARGB(255, 7, 107, 35),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, child) {
              return isLoading
                  ? Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 7, 107, 35)),
                        ),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
