import 'package:flutter/material.dart';
import '../../builder/special_pattern.dart';
import '../../resources/basic_resources.dart';
import '../../resources/fonts.dart';
import 'package:string_validator/string_validator.dart';
import './pattern.dart';
import 'package:get/get.dart';
import '../model/locator.dart';

String? _validate(String inType, bool isReq, String? value,
    {String? label, Map<String, dynamic>? map}) {
  if (value == null) {
    if (!isReq) {
      return null;
    }
    return model.map["text"]["requiredField"];
  }
  if (value.isEmpty || value.isBlank!) {
    if (!isReq) {
      return null;
    }
    return model.map["text"]["requiredField"];
  }
  switch (inType) {
    case "int":
    case "intS":
      if (isInt(value)) {
        return null;
      }
      break;
    case "dec":
      double? d = double.tryParse(value);
      if (d != null) {
        return null;
      }
      break;
    case "email":
      if (isEmail(value)) {
        return null;
      }
      break;
    case "url":
      if (isURL(value)) {
        return null;
      }
      break;
    case "phone":
      if (value.isPhoneNumber) {
        return null;
      }
      break;
    case "password":
      if (pwre.hasMatch(value)) {
        GlobalKey<FormState> key = map!["_key"]!;
        key.currentState!.save();
        return null;
      }
      break;
    case "cpassword":
      Map<String, dynamic> fm = map!["_formData"]!;
      String? pw = fm["_password"];
      if (value == pw) {
        return null;
      }
      return model.map["text"]["pwNotMatch"];
    default:
      return null;
  }
  String l = label ?? model.map["text"]["thisField"];
  return model.map["text"]["invalidInput"] + l;
}

Widget _getPWField(Map<String, dynamic> map) {
  String name = map["_name"]!;
  Map<String, dynamic> fm = map["_formData"]!;
  bool isReq = map["_isReq"] ?? false;
  String label = map["_label"] ?? name;
  return Padding(
      padding: EdgeInsets.all(size10),
      child: TextFormField(
        enabled: map["_enabled"] ?? true,
        validator: (s) => _validate(name, isReq, s, label: label, map: map),
        obscureText: map["_obscure"],
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          labelText: map["_label"],
          helperText: "",
          hintText: model.map["text"]["password"],
          suffixIcon: map["_suffixIcon"],
        ),
        onSaved: (v) {
          fm[name] = v;
        },
      ));
}

Widget _getField(Map<String, dynamic> map) {
  String name = map["_name"]!;
  String label = map["_label"] ?? name;
  Map<String, dynamic> fm = map["_formData"]!;
  String type = map["_inputType"] ?? "text";
  bool isReq = map["_isReq"] ?? false;
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: size10),
      child: TextFormField(
        enabled: map["_enabled"] ?? true,
        maxLines: map["_maxLines"] ?? 1,
        validator: (s) => _validate(name, isReq, s, label: label),
        keyboardType: _getInputType(type),
        decoration: InputDecoration(
          labelText: label,
          helperText: map["_help"] ?? "",
          hintText: map["_hint"] ?? label,
          suffix: map["_suffix"],
          suffixIcon: map["_suffixIcon"],
        ),
        onSaved: (v) {
          fm[name] = v;
        },
      ));
}

class FormWidget extends StatefulWidget {
  final Map<String, dynamic> map;
  const FormWidget(this.map, {Key? key}) : super(key: key);

  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  late GlobalKey<FormState> _formKey;
  late Map<String, dynamic> map;
  bool obscure = true;
  IconButton? iconB;
  final List<Widget> _c = [];

  @override
  void initState() {
    map = widget.map;
    _formKey = map["_key"];
    List<dynamic> flds = map["_formFields"]!;
    Map<String, dynamic> fm = map["_formData"]!;
    for (var m in flds) {
      if (m is Map<String, dynamic>) {
        String type = m["_inputType"] ?? "text";
        m["_formData"] = fm;
        if ((type == "password") || (type == "cpassword")) {
          m["_key"] = _formKey;
          m["_suffixIcon"] = IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.blue,
              ),
              onPressed: () => setState(() => m["_obscure"] = !m["_obscure"]));
          _c.add(_getPWField(m));
        } else {
          _c.add(_getField(m));
        }
      } else {
        Widget w = getPatternWidget(m)!;
        _c.add(w);
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _c.removeRange(0, _c.length);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(child: Column(children: _c), height: 300.0),
    );
  }
}

TextInputType _getInputType(String type) {
  switch (type) {
    case "int":
      return TextInputType.number;
    case "intS":
      return const TextInputType.numberWithOptions(signed: true);
    case "dec":
      return const TextInputType.numberWithOptions(signed: true, decimal: true);
    case "email":
      return TextInputType.emailAddress;
    case "url":
      return TextInputType.url;
    case "phone":
      return TextInputType.phone;
    default:
      return TextInputType.text;
  }
}

class FormPattern extends ProcessPattern {
  FormPattern(Map<String, dynamic> map) : super(map);
  @override
  Widget getWidget({String? name}) {
    map["_key"] = GlobalKey<FormState>();
    Widget? w = getPatternWidget(map["_title"]);
    return Column(
      children: (w == null)
          ? [FormWidget(map), _getSendButton(map)]
          : [w, FormWidget(map), _getSendButton(map)],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}

Widget _getSendButton(Map<String, dynamic> map) {
  String send = model.map["text"]["send"];
  Widget txt = Text(
    send,
    style: controlButtonTextStyle,
  );
  Map<String, dynamic> iMap = {
    "_child": txt,
    "_height": 0.07143 * model.scaleHeight,
    "_width": 0.872 * model.scaleWidth,
    "_beginColor": colorMap["btnBlue"],
    "_endColor": colorMap["btnBlueGradEnd"],
  };
  ColorButton cb = ColorButton(iMap);
  return GestureDetector(
      onTap: () {
        GlobalKey<FormState> k = map["_key"]!;
        if (k.currentState!.validate()) {
          k.currentState!.save();
          tapAction(map);
        }
      },
      child: cb);
}
