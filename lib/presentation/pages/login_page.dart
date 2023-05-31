import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/login/login_bloc.dart';
import '../../bloc/user/register/register_bloc.dart';
import '../../data/localsources/auth_local_storage.dart';
import '../../data/models/request/login_model.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController? emailController;
  TextEditingController? passwordController;
  final formKey = GlobalKey<FormState>();

  void isLogin() async {
    final isTokenExist = await AuthLocalStorage().isTokenExist();
    if (isTokenExist) {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return const HomePage();
      }), (route) => false);
    }
  }

  String? validateEmail(String email) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (email.isEmpty) {
      return "Email cannot be empty";
    } else if (!regex.hasMatch(email)) {
      return 'Email is invalid';
    }
    return null;
  }

  String? validatePassword(String pass) {
    if (pass.isEmpty) {
      return "Password cannot be empty";
    } else if (pass.length < 6) {
      return 'Minimum password contain 6 characters';
    }
    return null;
  }

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();

    isLogin();
    Future.delayed(const Duration(seconds: 2));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    emailController!.dispose();
    passwordController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'SIGN IN',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    const Text("You haven't signed in yet"),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                      padding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: TextFormField(
                        validator: (email) => validateEmail(email!),
                        controller: emailController,
                        cursorColor: Colors.orange,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.3))
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(30, 0, 30, 15),
                      padding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: TextFormField(
                        obscureText: true,
                        validator: (pass) => validatePassword(pass!),
                        controller: passwordController,
                        cursorColor: Colors.orange,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.3))
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    BlocConsumer<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is LoginLoaded) {
                          emailController!.clear();
                          passwordController!.clear();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: Colors.blue,
                                content: Text('Success Login')),
                          );

                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) {
                            return const HomePage();
                          }), (route) => false);
                        }
                        else if(state is LoginError){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.blue,
                                content: Text(state.message)),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is LoginLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return SizedBox(
                          width: 150,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.orange.shade900)),
                              onPressed: () {
                                print('test');
                                print(emailController!.text);
                                print(passwordController!.text);

                                if (formKey.currentState!.validate()) {
                                  final requestModel = LoginModel(
                                    email: emailController!.text,
                                    password: passwordController!.text,
                                  );

                                  context
                                      .read<LoginBloc>()
                                      .add(DoLoginEvent(loginModel: requestModel));
                                }
                              },
                              child: const Text(
                                "Log In",
                                style: TextStyle(color: Colors.white),
                              )),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RichText(
                        text: TextSpan(
                      text: 'Belum punya akun? ',
                      style: const TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: ' Register',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const RegisterPage();
                                }));
                              })
                      ],
                    )),
                  ],
                ),
              ),
          ),
          ),
        ),
      resizeToAvoidBottomInset: true,
    );
  }
}
