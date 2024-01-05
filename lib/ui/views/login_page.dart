import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './/auth_manager.dart';
import './/instance_manager.dart';

class LoginPageController extends GetxController {
  final pending = false.obs;
  void busy() {
    pending.value = true;
  }

  void finished() {
    pending.value = false;
  }

  final authState = AuthState.init.obs;
  final errorMsg = "".obs;
  void mirrorState(AuthState original) {
    authState.value = original;
  }

  void showError(String message) {
    errorMsg.value = message;
    authState.value = AuthState.error;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  TextEditingController loginName =
      TextEditingController(); // Also used for registration
  TextEditingController loginPassword =
      TextEditingController(); // Also used for registration
  TextEditingController registerConfirm = TextEditingController();
  TextEditingController registerDisplayName = TextEditingController();
  bool rememberLogin = true;

  late AnimationController _animationController; // Animations for hero icon
  final LoginPageController controller = LoginPageController();

  @override
  void dispose() {
    loginName.dispose();
    loginPassword.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.mirrorState(AuthManager().state);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    const imgTitle = Image(
      image: AssetImage('assets/images/SiriusGeoText.png'),
    );
    const imgHero = Image(
      image: AssetImage('assets/images/LogoGlobe-trimmed.png'),
    );
    const imgBackCircles = Image(
      image: AssetImage('assets/images/top_background_circles.png'),
    );

    final rowHero = Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Stack(children: [
        Row(children: const [
          Expanded(flex: 5, child: Padding(
            child: imgHero,
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0))
          ),
          Expanded(flex: 7, child: Padding(
            child: imgTitle,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0))
          ),
        ]),
      ])
    );

    List<Widget> stateWidgets = [];
    debugPrint("Building context for authState: " +
        controller.authState.value.toString());
    switch (controller.authState.value) {
      case AuthState.init:
        stateWidgets = _buildLogin(context);
        break;
      case AuthState.register:
        stateWidgets = _buildRegister(context);
        break;
      case AuthState.forgot:
        break;
      default:
        debugPrint("Default fallthrough!");
        break;
    }

    final loginBottomContainer = Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
      child: Stack(children: [
        Container(
          color: Colors.transparent,
          height: 800,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
          child: Column(
            children: [...stateWidgets],
          ),
        ),
      ]),
    );

    return Material(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(52, 166, 229, 1),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 64, 0, 0),
                child: Column(
                  children: [rowHero, loginBottomContainer],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLogin(BuildContext context) {
    final txtLoginName = TextFormField(
      controller: loginName,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.mail_outline, color: Colors.black54),
        hintText: "Enter your email address",
        labelText: "Login email",
        labelStyle: TextStyle(color: Colors.black54),
        fillColor: Color(0xFFEAEAEA),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      style: const TextStyle(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        return (value != null && value.contains('@'))
            ? null
            : "Please enter an email address.";
      },
      onChanged: (value) {
        //setState(() {});
      },
    );

    final txtLoginPassword = TextFormField(
      controller: loginPassword,
      obscureText: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.password, color: Colors.black54),
        hintText: "Enter your password",
        labelText: 'Password',
        labelStyle: TextStyle(
          color: Colors.black54,
        ),
        fillColor: Color(0xFFEAEAEA),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        return (value != null && value != "")
            ? null
            : "Please enter your password.";
      },
      onChanged: (value) {
        //setState(() {});
      },
    );

    final lnkForgotPassword = RichText(
      text: TextSpan(
        style: const TextStyle(
          decoration: TextDecoration.underline,
          color: Color(0xFF00344F),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        text: "Forgot Password?",
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            AuthManager().forgotPassword();
            controller.mirrorState(AuthManager().state);
          },
      ),
    );

    final chkRememberLogin = CheckboxListTile(
        title: const Text("Remember login"),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.only(right: 5),
        visualDensity: VisualDensity.compact,
        value: rememberLogin,
        onChanged: (value) {
          setState(() {
            rememberLogin = value ?? false;
          });
        });

    final btnRunLogin = TextButton(
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF1F8ECA), Color(0xAA1F8ECA)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          constraints: const BoxConstraints(
              minWidth: 110.0, maxWidth: 220.0, minHeight: 54.0),
          alignment: Alignment.center,
          child: Text(
            controller.pending.value ? "Loading..." : "LOGIN",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        if (controller.pending.value) {
          return;
        }
        if (loginName.text.isEmpty ||
            loginPassword.text.isEmpty ||
            !loginName.text.isEmail) {
          return;
        }
        InstanceManager().setupInstance("geo.siriustechnology.net", {});
        AuthManager().runLogin(loginName.text, loginPassword.text).then((_) {
          if (AuthManager().state == AuthState.complete) {
            Get.toNamed("/home");
          }
        }).catchError((ex) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: ex is NotFoundException
                    ? const Text("Incorrect username or password")
                    : const Text('Error attempting login'),
                content: ex is NotFoundException
                    ? const Text("Please check your inputs and try again.")
                    : Text(ex.toString()),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
      },
    );

    final lnkSignUp = RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF00344F),
          fontSize: 18,
        ),
        text: "Don't have an account yet? ",
        children: [
          TextSpan(
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Color(0xFF00344F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            text: "Sign-Up",
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                setState(() {
                  AuthManager().requestRegistration();
                  controller.mirrorState(AuthManager().state);
                });
              },
          )
        ],
      ),
    );

    final orSeparator = RichText(
      text: const TextSpan(
        text: "- Or -",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 18,
        ),
      ),
    );

    final btnLoginWithGoogle = TextButton.icon(
      icon: Image.asset("assets/images/google.png",
          cacheHeight: 40, cacheWidth: 40),
      label: Container(
        child: const Text(
          "Sign in with Google",
          style: TextStyle(fontSize: 18),
        ),
        width: 200,
        height: 30,
        alignment: Alignment.center,
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF00344F),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Colors.grey,
            )),
      ),
      onPressed: () {
        AuthManager().loginAsGoogle();
      },
    );

    final btnLoginWithApple = TextButton.icon(
      icon: Image.asset("assets/images/apple.png",
          cacheHeight: 40, cacheWidth: 40),
      label: Container(
        child: const Text(
          "Sign in with Apple",
          style: TextStyle(fontSize: 18),
        ),
        width: 200,
        height: 30,
        alignment: Alignment.center,
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF00344F),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Colors.grey,
            )),
      ),
      onPressed: () {},
    );

    final btnLoginWithFacebook = TextButton.icon(
      icon: Image.asset("assets/images/facebook.png",
          cacheHeight: 40, cacheWidth: 40),
      label: Container(
        child: const Text(
          "Sign in with Facebook",
          style: TextStyle(fontSize: 18),
        ),
        width: 200,
        height: 30,
        alignment: Alignment.center,
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF00344F),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Colors.grey,
            )),
      ),
      onPressed: () {},
    );

    final btnLoginAsGuest = TextButton.icon(
      icon: const Icon(Icons.login, size: 40),
      label: Container(
        child: const Text(
          "Try out as a guest",
          style: TextStyle(fontSize: 18),
        ),
        width: 200,
        height: 30,
        alignment: Alignment.center,
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF00344F),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Colors.grey,
            )),
      ),
      onPressed: () {
        InstanceManager().setupInstance("geo.siriustechnology.net", {});
        AuthManager().loginAsGuest();
        Get.toNamed("/home");
      },
    );

    return [
      const Padding(padding: EdgeInsets.all(1)),
      txtLoginName,
      const Padding(padding: EdgeInsets.all(10)),
      txtLoginPassword,
      const Padding(padding: EdgeInsets.all(5)),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Expanded(child: chkRememberLogin), lnkForgotPassword],
      ),
      const Padding(padding: EdgeInsets.all(5)),
      btnRunLogin,
      const Padding(padding: EdgeInsets.all(10)),
      lnkSignUp,
      const Padding(padding: EdgeInsets.all(10)),
      orSeparator,
      const Padding(padding: EdgeInsets.all(5)),
      btnLoginAsGuest,
      const Padding(padding: EdgeInsets.all(7)),
      btnLoginWithGoogle,
      const Padding(padding: EdgeInsets.all(1.5)),
      btnLoginWithApple,
      const Padding(padding: EdgeInsets.all(1.5)),
      btnLoginWithFacebook,
    ];
  }

  List<Widget> _buildRegister(BuildContext context) {
    final lblCreateYourAccount = RichText(
      text: const TextSpan(
        style: TextStyle(
          color: Color(0xFF00344F),
          fontSize: 24,
        ),
        text: "Create Your ",
        children: [
          TextSpan(
            style: TextStyle(
              color: Color(0xFF00344F),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            text: "Account",
          )
        ],
      ),
    );

    final txtRegisterName = TextFormField(
      controller: loginName,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.mail_outline, color: Colors.black54),
        hintText: "Enter your email address",
        labelText: "Registration email",
        labelStyle: TextStyle(color: Colors.black54),
        fillColor: Color(0xFFEAEAEA),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      style: const TextStyle(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        return (value != null && value.contains('@'))
            ? null
            : "Please enter an email address.";
      },
      onChanged: (value) {
        //setState(() {});
      },
    );

    final txtRegisterPassword = TextFormField(
      controller: loginPassword,
      obscureText: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.password, color: Colors.black54),
        hintText: "Enter your password",
        labelText: 'Password',
        labelStyle: TextStyle(
          color: Colors.black54,
        ),
        fillColor: Color(0xFFEAEAEA),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        return (value != null && value != "")
            ? null
            : "Please enter your password.";
      },
      onChanged: (value) {
        //setState(() {});
      },
    );

    final txtRegisterConfirm = TextFormField(
      controller: registerConfirm,
      obscureText: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.password, color: Colors.black54),
        hintText: "Enter your password again",
        labelText: 'Confirm password',
        labelStyle: TextStyle(
          color: Colors.black54,
        ),
        fillColor: Color(0xFFEAEAEA),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        return (value != null && value != "")
            ? null
            : "Please enter your password.";
      },
      onChanged: (value) {
        //setState(() {});
      },
    );

    final txtRegisterDisplayName = TextFormField(
      controller: registerDisplayName,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.perm_identity, color: Colors.black54),
        hintText: "Enter a display name",
        labelText: "Display name",
        labelStyle: TextStyle(color: Colors.black54),
        fillColor: Color(0xFFEAEAEA),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      style: const TextStyle(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? value) {
        return (value != null && value != "")
            ? null
            : "Please enter a valid name.";
      },
      onChanged: (value) {
        //setState(() {});
      },
    );

    final btnRunRegister = TextButton(
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF50C995), Color(0xFF62E0AA)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          constraints: const BoxConstraints(
              minWidth: 110.0, maxWidth: 220.0, minHeight: 54.0),
          alignment: Alignment.center,
          child: Text(
            controller.pending.value ? "Loading..." : "SIGN-UP",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        if (controller.pending.value) {
          return;
        }
        if (loginName.text.isEmpty ||
            loginPassword.text.isEmpty ||
            !loginName.text.isEmail) {
          return;
        }
        InstanceManager().setupInstance("geo.siriustechnology.net", {});
        AuthManager().runLogin(loginName.text, loginPassword.text).then((_) {
          if (AuthManager().state == AuthState.complete) {
            Get.toNamed("/home");
          }
        }).catchError((ex) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: ex is NotFoundException
                    ? const Text("Incorrect username or password")
                    : const Text('Error attempting login'),
                content: ex is NotFoundException
                    ? const Text("Please check your inputs and try again.")
                    : Text(ex.toString()),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
      },
    );

    final lnkAlreadyHaveAccount = RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF00344F),
          fontSize: 18,
        ),
        text: "Already have an account? ",
        children: [
          TextSpan(
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Color(0xFF00344F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            text: "Login",
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                setState(() {
                  AuthManager().abortRegistration();
                  controller.mirrorState(AuthManager().state);
                });
              },
          )
        ],
      ),
    );

    return [
      lblCreateYourAccount,
      const Padding(padding: EdgeInsets.all(5)),
      txtRegisterName,
      const Padding(padding: EdgeInsets.all(10)),
      txtRegisterPassword,
      const Padding(padding: EdgeInsets.all(3)),
      txtRegisterConfirm,
      const Padding(padding: EdgeInsets.all(10)),
      txtRegisterDisplayName,
      const Padding(padding: EdgeInsets.all(5)),
      btnRunRegister,
      const Padding(padding: EdgeInsets.all(3)),
      lnkAlreadyHaveAccount,
    ];
  }
}

/*

class LoginPage extends StatelessWidget {
  final ResxController resxController = ResxController();
  LoginPage({Key? key}) : super(key: key);
  late Widget splashW;

  @override
  Widget build(BuildContext context) {
    if (model.stateData["mainWidget"] != null) {
      return _getWidget(context);
    }
    model.init(context);
    splashW = SingleChildScrollView(
        child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/SCircles.png"),
                  fit: BoxFit.cover,
                ),
                gradient: blueGradient),
            height: model.screenHeight,
            width: model.screenWidth,
            alignment: Alignment.center,
            child: SizedBox(
              height: 0.7 * model.screenHeight,
              width: 0.7 * model.screenWidth,
              child: Column(
                children: [
                  Image.asset("assets/images/LogoGlobe.png"),
                  Image.asset("assets/images/SiriusGeoText.png"),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            )));
    return _getWidget(context);
  }

  Widget _getWidget(BuildContext context) {
    if (model.stateData["mainWidget"] != null) {
      model.addCount();
      debugPrint("Non-future call count: " + model.count.toString());
      return model.stateData["mainWidget"];
    }
    return FutureBuilder<Map<String, dynamic>>(
        future: model.getMap(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) debugPrint(snapshot.error.toString());

          return snapshot.hasData
              ? _getBodyUi(model, snapshot.data!)
          // : const Center(
          //     child: CircularProgressIndicator(),
          //   );
              : splashW;
        });
  }

  Widget _getBodyUi(MainModel model, Map<String, dynamic> map) {
    model.addCount();
    model.appActions = AgentActions();
    Agent a = model.appActions.getAgent("pattern");

    ProcessEvent event = ProcessEvent("mainView");
    var p = a.process(event);

    debugPrint("Future call count: " + model.count.toString());
    Widget w = (p is ProcessPattern) ? p.getWidget() : p;
    model.stateData["mainWidget"] = w;
    return w;
  }
}
*/
