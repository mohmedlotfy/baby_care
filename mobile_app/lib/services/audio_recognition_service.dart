import 'dart:async';
import 'package:tflite_audio/tflite_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecognitionResult {
  final String recognition;
  final String status;
  final bool isRecording;

  AudioRecognitionResult({
    required this.recognition,
    required this.status,
    this.isRecording = false,
  });
}

class AudioRecognitionService {
  static final AudioRecognitionService _instance = AudioRecognitionService._internal();
  factory AudioRecognitionService() => _instance;

  final _resultController = StreamController<AudioRecognitionResult>.broadcast();
  Stream<AudioRecognitionResult> get resultStream => _resultController.stream;

  bool _isRecording = false;
  bool get isRecording => _isRecording;
  
  Timer? _silenceTimer;
  AudioRecognitionResult? _lastResult;
  bool _isModelLoaded = false;

  AudioRecognitionService._internal() {
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      TfliteAudio.loadModel(
        model: 'assets/models/yamnet.tflite',
        label: 'assets/models/labels.txt',
        inputType: 'rawAudio',
        numThreads: 1,
        isAsset: true,
      );
      _isModelLoaded = true;
      print("AI Model loaded successfully");
    } catch (e) {
      print("Error loading AI model: $e");
    }
  }

  /// Request microphone permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Starts the audio recognition process
  void startRecognition() async {
    if (_isRecording) return;
    
    // Forcibly stop any previous session first
    try {
      TfliteAudio.stopAudioRecognition();
    } catch (_) {}

    if (!_isModelLoaded) {
      _initModel();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!await requestPermissions()) {
      _resultController.add(AudioRecognitionResult(
        recognition: 'Permission Denied',
        status: 'Microphone access required',
      ));
      return;
    }

    _isRecording = true;
    _lastResult = null;
    
    print("Starting audio recognition stream...");

    try {
      TfliteAudio.startAudioRecognition(
        sampleRate: 16000,
        bufferSize: 2000, // Smaller buffer for faster hardware response
        audioLength: 15600,
        numOfInferences: 10000, // Keep it running
        detectionThreshold: 0.1, // More sensitive
      ).listen((event) {
        if (event == null) return;
        
        final recognition = event['recognitionResult'] as String? ?? 'Normal/Ambient Noise';
        final status = _applyReasoningLogic(recognition);
        
        print("AI Heard: $recognition -> $status");

        _lastResult = AudioRecognitionResult(
          recognition: recognition,
          status: status,
          isRecording: true,
        );

        _resultController.add(_lastResult!);

        if (status != 'Normal/Ambient Noise') {
          _resetSilenceTimer();
        }
      }, onError: (error) {
        print("Stream Error: $error");
        stopRecognition();
      }).onDone(() {
        print("Stream completed.");
        stopRecognition();
      });
    } catch (e) {
      print("Failed to start recognition: $e");
      _isRecording = false;
    }

    _resetSilenceTimer();
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 10), () {
      if (_isRecording) {
        print("Silence detected for 10 seconds. Stopping...");
        stopRecognition();
      }
    });
  }

  /// Stops the audio recognition process and returns the last result
  AudioRecognitionResult? stopRecognition() {
    TfliteAudio.stopAudioRecognition();
    _silenceTimer?.cancel();
    _isRecording = false;
    
    final finalResult = AudioRecognitionResult(
      recognition: _lastResult?.recognition ?? 'Stopped',
      status: _lastResult?.status ?? 'Normal/Ambient Noise',
      isRecording: false,
    );
    
    _resultController.add(finalResult);
    return _lastResult;
  }

  /// Reasoning Logic based on the model's output
  String _applyReasoningLogic(String label) {
    final lowercaseLabel = label.toLowerCase();
    
    // Pain/Colic labels: Screaming (17), Shout (18), Yell (19)
    if (lowercaseLabel.contains('screaming') || 
        lowercaseLabel.contains('shout') || 
        lowercaseLabel.contains('yell')) {
      return 'Potential Pain/Colic';
    } 
    // Sleepy/Tired labels: Whimper (11), Wail (12), Sigh (13)
    else if (lowercaseLabel.contains('whimper') || 
             lowercaseLabel.contains('wail') || 
             lowercaseLabel.contains('sigh')) {
      return 'Sleepy/Tired';
    } 
    // Hungry/Diaper labels: Sobbing (14), Crying (20)
    else if (lowercaseLabel.contains('crying') || 
             lowercaseLabel.contains('sobbing')) {
      return 'Hungry or Needs Diaper Change';
    } 
    else {
      return 'Normal/Ambient Noise';
    }
  }

  void dispose() {
    _resultController.close();
  }
}
