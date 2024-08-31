import 'package:flutter/material.dart';

import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elastic_dashboard/services/ip_address_util.dart';
import 'package:elastic_dashboard/services/settings.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_color_picker.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_dropdown_chooser.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_text_input.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_toggle_switch.dart';
import 'package:elastic_dashboard/widgets/settings_dialog.dart';
import '../test_util.dart';
import 'settings_dialog_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FakeSettingsMethods>()])
class FakeSettingsMethods {
  void changeColor() {}

  void changeIPAddress() {}

  void changeTeamNumber() {}

  void changeIPAddressMode() {}

  void changeShowGrid() {}

  void changeGridSize() {}

  void changeCornerRadius() {}

  void changeDSAutoResize() {}

  void changeRememberWindow() {}

  void changeLockLayout() {}

  void changeDefaultPeriod() {}

  void changeDefaultGraphPeriod() {}

  void changeThemeVariant() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late MockFakeSettingsMethods fakeSettings;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.ipAddress: '127.0.0.1',
      PrefKeys.teamNumber: 353,
      PrefKeys.ipAddressMode: IPAddressMode.driverStation.index,
      PrefKeys.teamColor: Colors.blueAccent.value,
      PrefKeys.showGrid: false,
      PrefKeys.gridSize: 128,
      PrefKeys.cornerRadius: 15.0,
      PrefKeys.autoResizeToDS: false,
      PrefKeys.rememberWindowPosition: false,
      PrefKeys.layoutLocked: false,
      PrefKeys.defaultPeriod: 0.10,
      PrefKeys.defaultGraphPeriod: 0.033,
      PrefKeys.themeVariant: FlexSchemeVariant.chroma.variantName,
    });

    preferences = await SharedPreferences.getInstance();

    fakeSettings = MockFakeSettingsMethods();
  });

  setUp(() {
    reset(fakeSettings);
  });

  testWidgets('Settings Dialog', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Team Number'), findsOneWidget);
    expect(find.text('Team Color'), findsOneWidget);
    expect(find.text('IP Address Mode'), findsOneWidget);
    expect(find.text('IP Address'), findsOneWidget);
    expect(find.text('Show Grid'), findsWidgets);
    expect(find.text('Grid Size'), findsWidgets);
    expect(find.text('Corner Radius'), findsOneWidget);
    expect(find.text('Resize to Driver Station Height'), findsOneWidget);
    expect(find.text('Remember Window Position'), findsOneWidget);
    expect(find.text('Lock Layout'), findsOneWidget);
    expect(find.text('Default Period'), findsOneWidget);
    expect(find.text('Default Graph Period'), findsOneWidget);
    expect(find.text('Theme Variant'), findsOneWidget);

    final assetsFolderButton =
        find.widgetWithIcon(IconButton, Icons.folder_outlined);
    expect(assetsFolderButton, findsOneWidget);

    final closeButton = find.widgetWithText(TextButton, 'Close');

    expect(closeButton, findsOneWidget);

    await widgetTester.tap(closeButton);
    await widgetTester.pumpAndSettle();
  });

  testWidgets('Change team number', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onTeamNumberChanged: (data) async {
            fakeSettings.changeTeamNumber();

            await preferences.setInt(PrefKeys.teamNumber, int.parse(data!));
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final teamNumberField = find.widgetWithText(DialogTextInput, 'Team Number');

    expect(teamNumberField, findsOneWidget);
    expect(find.descendant(of: teamNumberField, matching: find.text('353')),
        findsOneWidget);

    await widgetTester.enterText(teamNumberField, '2601');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pump();

    expect(preferences.getInt(PrefKeys.teamNumber), 2601);
    expect(preferences.getString(PrefKeys.ipAddress), '127.0.0.1');
    verify(fakeSettings.changeTeamNumber()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Change team color', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOnlineNT4(),
          preferences: preferences,
          onColorChanged: (color) async {
            fakeSettings.changeColor();

            await preferences.setInt(PrefKeys.teamColor, color.value);
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final teamColorBox = find.byType(DialogColorPicker);

    expect(teamColorBox, findsOneWidget);

    final teamColorButton = find.byType(ElevatedButton);

    expect(teamColorButton, findsOneWidget);

    // For some reason the widgetTester.tap() won't work...
    ElevatedButton elevatedColorButton =
        teamColorButton.evaluate().first.widget as ElevatedButton;

    elevatedColorButton.onPressed?.call();

    await widgetTester.pumpAndSettle();

    expect(find.text('Select Color', skipOffstage: false), findsOneWidget);
    expect(find.byType(ColorPicker), findsOneWidget);

    final hexInput = find.widgetWithText(TextField, 'Hex Code');

    expect(hexInput, findsOneWidget);

    await widgetTester.enterText(hexInput, '0000FF');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pump();

    final saveButton = find.text('Save');

    expect(saveButton, findsOneWidget);
    await widgetTester.tap(saveButton);

    expect(preferences.getInt(PrefKeys.teamColor),
        const Color.fromARGB(255, 0, 0, 255).value);
    verify(fakeSettings.changeColor()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Change theme variant', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          onThemeVariantChanged: (variant) async {
            fakeSettings.changeThemeVariant();

            await preferences.setString(
                PrefKeys.themeVariant, variant.variantName);
          },
          preferences: preferences,
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final themeVariantDropdown =
        find.widgetWithText(DialogDropdownChooser<String>, 'Chroma');

    expect(themeVariantDropdown, findsOneWidget);

    await widgetTester.tap(themeVariantDropdown);
    await widgetTester.pumpAndSettle();

    expect(find.text('Chroma'), findsNWidgets(2));
    expect(find.text('Material-3 Legacy (Default)'), findsOneWidget);
    expect(find.text('Material-3 Legacy'), findsNothing);

    await widgetTester.tap(find.text('Material-3 Legacy (Default)'));
    await widgetTester.pumpAndSettle();

    expect(preferences.getString(PrefKeys.themeVariant),
        FlexSchemeVariant.material3Legacy.variantName);

    verify(fakeSettings.changeThemeVariant()).called(1);

    final newThemeVariantDropdown = find.widgetWithText(
        DialogDropdownChooser<String>, 'Material-3 Legacy (Default)');

    expect(newThemeVariantDropdown, findsOneWidget);

    // Now the safety mecahnism to add unknown variants should activate
    await widgetTester.tap(newThemeVariantDropdown);
    await widgetTester.pumpAndSettle();

    expect(find.text('Material-3 Legacy (Default)'), findsNWidgets(2));
    expect(find.text('Material-3 Legacy'), findsOneWidget);
  });

  testWidgets('Toggle grid', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onGridToggle: (value) async {
            fakeSettings.changeShowGrid();

            await preferences.setBool(PrefKeys.showGrid, value);
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final gridSwitch = find.widgetWithText(DialogToggleSwitch, 'Show Grid');

    expect(gridSwitch, findsOneWidget);

    // Widget tester.tap will not work for some reason
    final switchWidget = find
        .descendant(of: gridSwitch, matching: find.byType(Switch))
        .evaluate()
        .first
        .widget as Switch;

    switchWidget.onChanged?.call(true);
    await widgetTester.pumpAndSettle();

    expect(preferences.getBool(PrefKeys.showGrid), true);

    switchWidget.onChanged?.call(false);
    await widgetTester.pumpAndSettle();

    expect(preferences.getBool(PrefKeys.showGrid), false);
    verify(fakeSettings.changeShowGrid()).called(2);
  });

  testWidgets('Change grid size', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onGridSizeChanged: (gridSize) async {
            fakeSettings.changeGridSize();

            await preferences.setInt(PrefKeys.gridSize, int.parse(gridSize!));
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final gridSizeField = find.widgetWithText(DialogTextInput, 'Grid Size');

    expect(gridSizeField, findsOneWidget);

    await widgetTester.enterText(gridSizeField, '64');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pumpAndSettle();

    expect(preferences.getInt(PrefKeys.gridSize), 64);
    verify(fakeSettings.changeGridSize()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Change corner radius', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;
    createMockOfflineNT4();

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onCornerRadiusChanged: (radius) async {
            fakeSettings.changeCornerRadius();

            await preferences.setDouble(
                PrefKeys.cornerRadius, double.parse(radius!));
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final cornerRadiusField =
        find.widgetWithText(DialogTextInput, 'Corner Radius');

    expect(cornerRadiusField, findsOneWidget);

    await widgetTester.enterText(cornerRadiusField, '25.0');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pumpAndSettle();

    expect(preferences.getDouble(PrefKeys.cornerRadius), 25.0);
    verify(fakeSettings.changeCornerRadius()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Toggle driver station auto resize', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onResizeToDSChanged: (value) async {
            fakeSettings.changeDSAutoResize();

            await preferences.setBool(PrefKeys.autoResizeToDS, value);
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final autoResizeSwitch = find.widgetWithText(
        DialogToggleSwitch, 'Resize to Driver Station Height');

    expect(autoResizeSwitch, findsOneWidget);

    // Widget tester.tap will not work for some reason
    final switchWidget = find
        .descendant(of: autoResizeSwitch, matching: find.byType(Switch))
        .evaluate()
        .first
        .widget as Switch;

    switchWidget.onChanged?.call(true);
    await widgetTester.pumpAndSettle();

    expect(preferences.getBool(PrefKeys.autoResizeToDS), true);

    switchWidget.onChanged?.call(false);
    await widgetTester.pumpAndSettle();

    expect(preferences.getBool(PrefKeys.autoResizeToDS), false);
    verify(fakeSettings.changeDSAutoResize()).called(2);
  });

  testWidgets('Toggle remember window position', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onRememberWindowPositionChanged: (value) async {
            fakeSettings.changeRememberWindow();

            await preferences.setBool(PrefKeys.rememberWindowPosition, value);
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final windowSwitch =
        find.widgetWithText(DialogToggleSwitch, 'Remember Window Position');

    expect(windowSwitch, findsOneWidget);

    // Widget tester.tap will not work for some reason
    final switchWidget = find
        .descendant(of: windowSwitch, matching: find.byType(Switch))
        .evaluate()
        .first
        .widget as Switch;

    switchWidget.onChanged?.call(true);
    await widgetTester.pumpAndSettle();

    expect(preferences.getBool(PrefKeys.rememberWindowPosition), true);

    switchWidget.onChanged?.call(false);
    await widgetTester.pumpAndSettle();

    expect(preferences.getBool(PrefKeys.rememberWindowPosition), false);
    verify(fakeSettings.changeRememberWindow()).called(2);
  });

  testWidgets('Toggle lock layout', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          preferences: preferences,
          ntConnection: createMockOfflineNT4(),
          onLayoutLock: (value) async {
            fakeSettings.changeLockLayout();

            await preferences.setBool(PrefKeys.layoutLocked, value);
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final lockLayoutSwitch =
        find.widgetWithText(DialogToggleSwitch, 'Lock Layout');

    expect(lockLayoutSwitch, findsOneWidget);

    // Widget tester.tap will not work for some reason
    final switchWidget = find
        .descendant(of: lockLayoutSwitch, matching: find.byType(Switch))
        .evaluate()
        .first
        .widget as Switch;

    switchWidget.onChanged?.call(true);
    await widgetTester.pumpAndSettle();

    expect(preferences.getBool(PrefKeys.layoutLocked), true);

    switchWidget.onChanged?.call(false);
    await widgetTester.pumpAndSettle();

    expect(preferences.getBool(PrefKeys.layoutLocked), false);
    verify(fakeSettings.changeLockLayout()).called(2);
  });

  testWidgets('Change IP address mode', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onIPAddressModeChanged: (mode) {
            fakeSettings.changeIPAddressMode();
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final ipAddressMode = find.byType(DialogDropdownChooser<IPAddressMode>);

    expect(ipAddressMode, findsOneWidget);

    expect(find.text('Driver Station'), findsOneWidget);

    await widgetTester.tap(ipAddressMode);
    await widgetTester.pumpAndSettle();

    expect(find.text('Team Number (10.TE.AM.2)'), findsOneWidget);

    await widgetTester.tap(find.text('Team Number (10.TE.AM.2)'));
    await widgetTester.pumpAndSettle();

    expect(find.text('Driver Station'), findsNothing);
    expect(find.text('Team Number (10.TE.AM.2)'), findsOneWidget);

    await widgetTester.tap(find.text('Team Number (10.TE.AM.2)'));
    await widgetTester.pumpAndSettle();

    expect(find.text('Driver Station'), findsOneWidget);

    await widgetTester.tap(find.text('Driver Station'));
    await widgetTester.pumpAndSettle();

    verify(fakeSettings.changeIPAddressMode()).called(2);
  });

  testWidgets('Change IP address', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onIPAddressChanged: (data) async {
            fakeSettings.changeIPAddress();

            await preferences.setString(PrefKeys.ipAddress, data!);
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final ipAddressField = find.widgetWithText(DialogTextInput, 'IP Address');

    expect(ipAddressField, findsOneWidget);

    await widgetTester.enterText(ipAddressField, '10.3.53.2');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pump();

    expect(preferences.getString(PrefKeys.ipAddress), '10.3.53.2');
    verify(fakeSettings.changeIPAddress()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Change default period', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onDefaultPeriodChanged: (period) async {
            fakeSettings.changeDefaultPeriod();

            await preferences.setDouble(
                PrefKeys.defaultPeriod, double.parse(period!));
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final periodField = find.widgetWithText(DialogTextInput, 'Default Period');

    expect(periodField, findsOneWidget);

    await widgetTester.enterText(periodField, '0.05');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pumpAndSettle();

    expect(preferences.getDouble(PrefKeys.defaultPeriod), 0.05);
    verify(fakeSettings.changeDefaultPeriod()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Change default graph period', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          ntConnection: createMockOfflineNT4(),
          preferences: preferences,
          onDefaultGraphPeriodChanged: (period) async {
            fakeSettings.changeDefaultGraphPeriod();

            await preferences.setDouble(
                PrefKeys.defaultGraphPeriod, double.parse(period!));
          },
        ),
      ),
    ));

    await widgetTester.pumpAndSettle();

    final periodField =
        find.widgetWithText(DialogTextInput, 'Default Graph Period');

    expect(periodField, findsOneWidget);

    await widgetTester.enterText(periodField, '0.05');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pumpAndSettle();

    expect(preferences.getDouble(PrefKeys.defaultGraphPeriod), 0.05);
    verify(fakeSettings.changeDefaultGraphPeriod())
        .called(greaterThanOrEqualTo(1));
  });
}
