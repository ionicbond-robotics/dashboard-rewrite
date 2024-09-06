import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_color_picker.dart';
import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';

import 'package:elastic_dashboard/services/nt4_client.dart';
import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

class DigitalInputModel extends NTWidgetModel {
  @override
  String type = DigitalInput.widgetType;

  String get valueTopic => '$topic/Value';

  Color _trueColor = Colors.green, _falseColor = Colors.red;

  get trueColor => _trueColor;

  set trueColor(value) {
    _trueColor = value;
    refresh();
  }

  get falseColor => _falseColor;

  set falseColor(value) {
    _falseColor = value;
    refresh();
  }

  late NT4Subscription valueSubscription;

  DigitalInputModel({
    required super.ntConnection,
    required super.preferences,
    required super.topic,
    Color trueColor = Colors.green,
    Color falseColor = Colors.red,
    super.dataType,
    super.period,
  })  : _falseColor = falseColor,
        _trueColor = trueColor,
        super();

  DigitalInputModel.fromJson({
    required super.ntConnection,
    required super.preferences,
    required Map<String, dynamic> jsonData,
  }) : super.fromJson(jsonData: jsonData) {
    int? trueColorValue =
        tryCast(jsonData['true_color']) ?? tryCast(jsonData['colorWhenTrue']);
    int? falseColorValue =
        tryCast(jsonData['false_color']) ?? tryCast(jsonData['colorWhenFalse']);

    if (trueColorValue == null) {
      String? hexString = tryCast(jsonData['colorWhenTrue']);

      if (hexString != null) {
        hexString = hexString.toUpperCase().replaceAll('#', '');

        if (hexString.length == 6) {
          hexString = 'FF$hexString';
        }

        trueColorValue = int.tryParse(hexString, radix: 16);
      }
    }

    if (falseColorValue == null) {
      String? hexString = tryCast(jsonData['colorWhenFalse']);

      if (hexString != null) {
        hexString = hexString.toUpperCase().replaceAll('#', '');

        if (hexString.length == 6) {
          hexString = 'FF$hexString';
        }

        falseColorValue = int.tryParse(hexString, radix: 16);
      }
    }

    _trueColor = Color(trueColorValue ?? Colors.green.value);
    _falseColor = Color(falseColorValue ?? Colors.red.value);
  }

  @override
  void init() {
    super.init();

    valueSubscription = ntConnection.subscribe(valueTopic, super.period);
  }

  @override
  void resetSubscription() {
    ntConnection.unSubscribe(valueSubscription);

    valueSubscription = ntConnection.subscribe(valueTopic, super.period);

    super.resetSubscription();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'true_color': _trueColor,
      'false_color': _falseColor,
    };
  }

  @override
  List<Widget> getEditProperties(BuildContext context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          DialogColorPicker(
            onColorPicked: (Color color) {
              trueColor = color;
            },
            label: 'True Color',
            initialColor: _trueColor,
            defaultColor: Colors.green,
          ),
          const SizedBox(width: 10),
          DialogColorPicker(
            onColorPicked: (Color color) {
              falseColor = color;
            },
            label: 'False Color',
            initialColor: _falseColor,
            defaultColor: Colors.red,
          ),
        ],
      ),
    ];
  }

  @override
  void unSubscribe() {
    ntConnection.unSubscribe(valueSubscription);

    super.unSubscribe();
  }
}

class DigitalInput extends NTWidget {
  static const String widgetType = 'Digital Input';

  const DigitalInput({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    DigitalInputModel model = cast(context.watch<NTWidgetModel>());

    return StreamBuilder(
      stream: model.valueSubscription.periodicStream(yieldAll: false),
      initialData: model.ntConnection.getLastAnnouncedValue(model.valueTopic),
      builder: (context, snapshot) {
        bool value = tryCast(snapshot.data) ?? false;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: (value) ? model.trueColor : model.falseColor,
          ),
        );
      },
    );
  }
}
