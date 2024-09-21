import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'dart:io';

void main() {
  runApp(NightcoreApp());
}

class NightcoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nightcore Maker',
      theme: ThemeData.dark(),
      home: NightcoreGenerator(),
    );
  }
}

class NightcoreGenerator extends StatefulWidget {
  @override
  _NightcoreGeneratorState createState() => _NightcoreGeneratorState();
}

class _NightcoreGeneratorState extends State<NightcoreGenerator> {
  String? _audioPath;
  String? _backgroundPath;
  String? _rhythmImagePath;
  String? _outputDirectory;
  double _progress = 0.0;
  bool _isGenerating = false;

  // MP3ファイルを選択
  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
      });
    }
  }

  // 背景画像を選択
  Future<void> _pickBackgroundImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _backgroundPath = result.files.single.path;
      });
    }
  }

  // 伸縮する画像を選択
  Future<void> _pickRhythmImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _rhythmImagePath = result.files.single.path;
      });
    }
  }

  // 出力ディレクトリを選択
  Future<void> _pickOutputDirectory() async {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      setState(() {
        _outputDirectory = directory;
      });
    }
  }

  // Nightcore生成
  void _generateNightcore() {
    if (_audioPath == null || _backgroundPath == null || _rhythmImagePath == null || _outputDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('全てのファイルを選択してください。')));
      return;
    }

    setState(() {
      _isGenerating = true;
      _progress = 0.0;
    });

    String outputPath = '$_outputDirectory/nightcore_output.mp4';
    String ffmpegCmd = '''
      -i $_audioPath -i $_backgroundPath -i $_rhythmImagePath
      -filter_complex "[1:v]scale=1920:1080[bg]; 
      [2:v]scale=iw*1.5:ih*1.5,zoompan=z='min(zoom+0.0015,1.5)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',scale=1920:1080[rhythm]; 
      [0:a]asetrate=44100*1.25,atempo=1.25[a]; 
      [bg][rhythm]overlay=shortest=1,format=yuv420p[v]" 
      -map "[v]" -map "[a]" -y $outputPath
    ''';

    FFmpegKit.executeAsync(ffmpegCmd, (session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nightcore動画が正常に生成されました。')));
      } else {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('動画生成に失敗しました。')));
      }
    }, (log) {
      print(log.getMessage());
      // 進捗を仮に更新（正確な進捗はFFmpegからは得られませんが、ログから推測して更新することが可能）
      setState(() {
        _progress += 0.01; // 仮の進捗更新
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nightcore Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickAudio,
              child: Text(_audioPath == null ? 'MP3を選択' : 'MP3選択済み: ${_audioPath!.split('/').last}'),
            ),
            ElevatedButton(
              onPressed: _pickBackgroundImage,
              child: Text(_backgroundPath == null ? '背景画像を選択' : '背景画像選択済み: ${_backgroundPath!.split('/').last}'),
            ),
            ElevatedButton(
              onPressed: _pickRhythmImage,
              child: Text(_rhythmImagePath == null ? 'リズムに合わせる画像を選択' : 'リズム画像選択済み: ${_rhythmImagePath!.split('/').last}'),
            ),
            ElevatedButton(
              onPressed: _pickOutputDirectory,
              child: Text(_outputDirectory == null ? '出力ディレクトリを選択' : '出力先: $_outputDirectory'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateNightcore,
              child: Text('Nightcore動画を生成'),
            ),
            SizedBox(height: 20),
            if (_isGenerating)
              Column(
                children: [
                  LinearProgressIndicator(value: _progress),
                  SizedBox(height: 10),
                  Text('生成中: ${(_progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
