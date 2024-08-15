import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:elastic_dashboard/services/nt_connection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:elastic_dashboard/services/record.dart';

import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';

class RecordingButton extends StatefulWidget {
  void Function()? initState;
  void Function()? dispose;
  void Function()? startRecording;
  void Function()? stopRecording;
  Stopwatch stopwatch;

  RecordingButton(
      {required this.stopwatch,
      this.initState,
      this.dispose,
      this.startRecording,
      this.stopRecording});

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    widget.initState;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
    widget.dispose;
  }

  void _startRecording() {
    setState(() {
      RecordingManger.isRecording = true;
      _animationController.repeat(reverse: true);
    });
    widget.stopwatch.reset();
    widget.stopwatch.start();
    widget.startRecording;
  }

  void _stopRecording() {
    setState(() {
      RecordingManger.isRecording = false;
      _animationController.stop();
      _animationController.reset();
    });
    widget.stopwatch.stop();
    widget.stopRecording?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ElevatedButton.icon(
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all(
                RecordingManger.isRecording
                    ? ColorTween(
                        begin: Colors.red,
                        end: Colors.black,
                      ).animate(_animationController).value
                    : Colors.white,
              ),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            icon: RecordingManger.isRecording
                ? const Icon(Icons.circle)
                : const Icon(Icons.circle_outlined),
            onPressed:
                RecordingManger.isRecording ? _stopRecording : _startRecording,
            label: Text(RecordingManger.isRecording ? 'Recording' : 'Record'),
          );
        },
      ),
    );
  }
}

class RecordingManger extends StatelessWidget {
  static List<Record> TopicRecord = [];
  static Stopwatch stopwatch = Stopwatch();
  static bool _isRecording = false;

  static bool get isRecording {
    return _isRecording;
  }

  static void set isRecording(bool value) {
    _isRecording = value;
  }

  RecordingButton? recordingbutton;
  NTConnection? ntConnection; 

  RecordingManger(this.ntConnection, {super.key}) {
    recordingbutton = RecordingButton(
        stopwatch: stopwatch, stopRecording: this.stopRecording, startRecording: startRecord,);
  }

  void startRecord(){
    recording();
  }

  void stopRecording() {
    // print(jsonEncode(TopicRecord));
    // print(DateTime.now().toIso8601String().substring(0,19));
    selectFolder().whenComplete(() {
      TopicRecord.clear();
    });
  }

  void recordPeriodically(String Topic, String data) {
    if (_isRecording) {
      iterate(Topic, data);
    }
  }

  static void iterate(String topic, String data) {
    Record? rec =
        TopicRecord.firstWhereOrNull((element) => element.getTopic() == topic);

    if (rec == null) {
      TopicRecord.add(Record(Topic: topic, timecode: [
        TimeCode(sender: data, time: stopwatch.elapsed.inMilliseconds)
      ]));
    } else {
      if (rec.gettimecode().last.getTime() !=
              stopwatch.elapsed.inMilliseconds &&
          rec.gettimecode().last.getSender() != data)
        rec.addTimeCode(
            TimeCode(sender: data, time: stopwatch.elapsed.inMilliseconds));
    }
  }

  Future<void> selectFolder() async {
    // פתח את בוחר הקבצים
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      // שמור את הקובץ בתיקייה שנבחרה
      final file = File(
          "$directoryPath/${DateTime.now().toIso8601String().substring(0, 19)}.json");
      final jsonString = jsonEncode(TopicRecord);
      await file.writeAsString(jsonString);
      print('File saved to $directoryPath');
    } else {
      print('No directory selected');
    }
    return;
  }


  Future<void> recording () async {
    while (_isRecording) {

      // dynamic values = ntConnection.getntClient().announcedTopics.values.map((topic) {
      //   // recordPeriodically (topic.name ,ntConnection.getLastAnnouncedValue(topic.name).toString());
      //   print("${topic.name }: ${ntConnection.getLastAnnouncedValue(topic.name).toString()}");
      //   });
      // // for (var value in values) {
      // //   print(value);
      // //   recordPeriodically(value, value);
      // // }

      await Future.delayed(Duration(seconds: 1));

      
    }
  }

  @override
  Widget build(BuildContext context) {
    return recordingbutton!;
  }
}

class Play extends StatelessWidget {
  List<Record>? TopicRecord;

  Future<void> selectFile() async {
    // פתח את בוחר הקבצים
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['json']);

    if (result != null) {
      // קבל את הקובץ שנבחר
      File file = File(result.files.single.path!);

      final jsonString = await file.readAsString();

      List<dynamic> jsonData = json.decode(jsonString);
      try {
        TopicRecord =
            jsonData.map((_record) => Record.fromJson(_record)).toList();
      } catch (e) {
        TopicRecord = null;
        print(e);
      }
    }
    return;
  }

  Widget _Dragging() {
    return SizedBox(
      width: 300, // קביעת רוחב קבוע
      height: 200, // קביעת גובה קבוע
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.play_circle_outline),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.stop_circle_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.pause_circle_outline),
              ),
            ],
          ),
          SizedBox(height: 20),
          TimelineSlider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimelineProvider(),
      child: AlertDialog(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
        content: _Dragging(),
      ),
    );
  }
}

class TimelineSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimelineProvider>(
      builder: (context, provider, child) {
        return FlutterSlider(
          values: [provider.currentTime],
          max: provider.timestamps.last,
          min: provider.timestamps.first,
          handler: FlutterSliderHandler(
            child: Material(
              type: MaterialType.circle,
              color: Colors.blue,
              elevation: 3,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),
          onDragging: (handlerIndex, lowerValue, upperValue) {
            provider.setCurrentTime(lowerValue as double);
          },
        );
      },
    );
  }
}

class TimelineProvider with ChangeNotifier {
  double _currentTime = 0;
  List<double> _timestamps = [0, 1, 2, 3, 4, 5]; // זמנים לדוגמה

  double get currentTime => _currentTime;
  List<double> get timestamps => _timestamps;

  void setCurrentTime(double time) {
    _currentTime = time;
    notifyListeners();
  }
}
