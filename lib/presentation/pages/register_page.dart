import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/register/register_bloc.dart';
import '../../data/models/request/register_model.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? passwordController;
  final formKey = GlobalKey<FormState>();

  String? validateName(String name) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (name.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
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
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController!.dispose();
    emailController!.dispose();
    passwordController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'REGISTER',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text("Register here to create account"),
              const SizedBox(height: 50),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: TextFormField(
                  validator: (name) => validateName(name!),
                  controller: nameController,
                  cursorColor: Colors.orange,
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Name'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
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
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Email'),
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
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Password'),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterLoaded) {
                    nameController!.clear();
                    emailController!.clear();
                    passwordController!.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.blue,
                          content: Text(
                              'success register')),
                    );
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const LoginPage();
                    }));
                  }
                },
                builder: (context, state) {
                  if (state is RegisterLoading) {
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
                          if (formKey.currentState!.validate()) {
                            final requestModel = RegisterModel(
                              name: nameController!.text,
                              email: emailController!.text,
                              password: passwordController!.text,
                            );

                            context
                                .read<RegisterBloc>()
                                .add(SaveRegisterEvent(request: requestModel));
                          }
                        },
                        child: const Text(
                          "Register",
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
                text: 'Sudah punya akun? ',
                style: const TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text: ' Login',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) {
                                return const LoginPage();
                              }),
                              (route) => false
                          );
                        })
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
