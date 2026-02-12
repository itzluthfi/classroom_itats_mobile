import 'package:classroom_itats_mobile/auth/bloc/login/login_bloc.dart';
import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';

class LoginForm extends StatefulWidget {
  final UserRepository userRepository;

  const LoginForm({super.key, required this.userRepository});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _nameController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _setUserNamePassword();
  }

  _setUserNamePassword() async {
    const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true));

    _nameController.text = await storage.read(key: "name") ?? "";
    _passController.text = await storage.read(key: "pass") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(LoginButtonPressed(
          name: _nameController.text, pass: _passController.text));
    }

    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Mohon maaf, login gagal dilakukan: ${state.error}'),
              duration: const Duration(milliseconds: 1500),
              width: 280.0, // Width of the SnackBar.
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0, // Inner padding for SnackBar content.
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: GlobalKey<FormState>(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/application_images/Logo_Classroom_Square-no_bg.png',
                    width: 350,
                    height: 250,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    label: "NPM/NIP",
                    controller: _nameController,
                    isPassword: false,
                    width: 320,
                    height: 60,
                  ),
                ],
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    label: "Password",
                    controller: _passController,
                    isPassword: true,
                    width: 320,
                    height: 60,
                  ),
                ],
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Placeholder(
                    color: Colors.transparent,
                    child: state is LoginLoading
                        ? const SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _onLoginButtonPressed,
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(320, 50),
                              surfaceTintColor: Colors.white,
                              backgroundColor: const Color(0xFF0072BB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Login'),
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
