import 'dart:async';

import 'package:app/main.dart';
import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:app/EditPhoto/PhotoEditor.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum SupportedAspectRatio {
  nineBySixteen(9 / 16),
  threeByFour(3 / 4),
  fourByFive(4 / 5),
  square(1.0);

  const SupportedAspectRatio(this.value);

  final double value;
}

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  CameraController? controller;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  double _initZoomLevel = 1.0;

  SupportedAspectRatio _currentAspectRatio = SupportedAspectRatio.threeByFour;

  FlashMode? _currentFlashMode;
  bool _isRearCameraSelected = true;

  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }
    // Instantiate the camera controller
    final CameraController cameraController = CameraController(
        cameraDescription, ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg);

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
      await cameraController
          .lockCaptureOrientation(DeviceOrientation.portraitUp);
      cameraController
          .getMaxZoomLevel()
          .then((value) => _maxAvailableZoom = value);

      cameraController
          .getMinZoomLevel()
          .then((value) => _minAvailableZoom = value);

      setState(() {
        _currentFlashMode = controller!.value.flashMode;
      });
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          // Handle access errors here.
          break;
        default:
          // Handle other errors here.
          print('Error initializing camera: $e');
          break;
      }
    }
  }

  // Running the camera is a memory-hungry task.
  // This method handles freeing up the resources.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera is inactive
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void initState() {
    initCamera();
    super.initState();
  }

  void initCamera() {
    // Hide the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    // Index 0 of cameras list — back camera
    // Index 1 of cameras list — front camera
    onNewCameraSelected(cameras[0]);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    WidgetsBinding.instance.removeObserver(this);
    if (controller != null && controller!.value.isInitialized) {
      controller?.dispose();
    }
    super.dispose();
  }

  Future<void> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }

    try {
      showLoaderDialog(context);
      XFile rawImage = await cameraController.takePicture();
      File imageFile = File(rawImage.path);

      int currentUnix = DateTime.now().millisecondsSinceEpoch;
      final directory = await getApplicationDocumentsDirectory();
      String fileFormat = imageFile.path.split('.').last;

      img.Image cropped =
          await cropPortraitImage(imageFile, _currentAspectRatio);
      var jpg = img.encodeJpg(cropped);
      File croppedFile = await File(
        '${directory.path}/$currentUnix.$fileFormat',
      ).writeAsBytes(jpg);

      controller?.dispose();
      if (!mounted) return;
      Navigator.pop(context); // to dismiss loader dialog
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => PhotoEditor(image: croppedFile)))
          .then((_) {
        if (mounted) initCamera();
      });
    } catch (e) {
      print('Error occurred while taking picture: $e');
    }
  }

  Future<img.Image> cropPortraitImage(
      File imageFile, SupportedAspectRatio aspectRatio) async {
    var bytes = await imageFile.readAsBytes();
    img.Image? src = img.decodeImage(bytes);

    double widthRatio;
    double heightRatio;

    if (aspectRatio == SupportedAspectRatio.nineBySixteen) {
      widthRatio = 9.0;
      heightRatio = 16.0;
    } else if (aspectRatio == SupportedAspectRatio.threeByFour) {
      widthRatio = 3.0;
      heightRatio = 4.0;
    } else if (aspectRatio == SupportedAspectRatio.fourByFive) {
      widthRatio = 4.0;
      heightRatio = 5.0;
    } else {
      widthRatio = 1.0;
      heightRatio = 1.0;
    }

    var cropWidth = src!.width;
    var cropHeight = (src.width / widthRatio) * heightRatio;
    int offsetX = 0;
    int offsetY = (src.height ~/ 2) - (cropHeight ~/ 2);

    img.Image destImage = img.copyCrop(src,
        x: offsetX, y: offsetY, width: cropWidth, height: cropHeight.round());

    return destImage;
  }

  Future<void> _onImageLibPressed() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final data = await readExifFromBytes(await pickedFile.readAsBytes());
        if (data.isEmpty) {
          print("No EXIF information found");
          return;
        }
        // TODO: read GPS information from photo and pass it to the editor
        // GPS value should be in this
        for (final entry in data.entries) {
          print("${entry.key}: ${entry.value}");
        }

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhotoEditor(image: File(pickedFile.path))),
        );
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }

    // TODO: Get geolocation from EXIF
  }

  void flipCamera() async {
    onNewCameraSelected(
      cameras[_isRearCameraSelected ? 1 : 0],
    );
    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return Scaffold(body: Container());
    } else {
      // get screen size
      final size = MediaQuery.of(context).size;

      return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(children: <Widget>[
            Align(
              alignment:
                  _currentAspectRatio == SupportedAspectRatio.nineBySixteen
                      ? Alignment.bottomCenter
                      : Alignment.center,
              child: Transform.scale(
                scale: 1.0,
                child: AspectRatio(
                  aspectRatio: _currentAspectRatio.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: SizedBox(
                            width: size.width,
                            height: size.width /
                                (1 / cameraController.value.aspectRatio),
                            child: cameraController.buildPreview()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
                alignment: AlignmentDirectional.topCenter,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.close, size: 40),
                          ),
                          getAspectRatioButton(),
                          getFlashButton(),
                        ]))),
            Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 24.0),
                    child: Material(
                        color: Colors.transparent,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              getImagePickerButton(),
                              getCaptureButton(),
                              getFlipCameraButton()
                            ])))),
            GestureDetector(
                onScaleStart: (ScaleStartDetails scaleStartDetails) {
              _initZoomLevel = _currentZoomLevel;
            }, onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) async {
              // don't update the UI if the scale didn't change
              if (scaleUpdateDetails.scale == 1.0) {
                return;
              }
              setState(() {
                _currentZoomLevel = (_initZoomLevel * scaleUpdateDetails.scale)
                    .clamp(_minAvailableZoom, _maxAvailableZoom);
              });
              await cameraController.setZoomLevel(_currentZoomLevel);
            }),
          ]));
    }
  }

  Widget getFlashButton() {
    Widget button;
    if (_currentFlashMode == FlashMode.off) {
      button = const Icon(Icons.flash_off, size: 32);
    } else if (_currentFlashMode == FlashMode.auto) {
      button = const Icon(Icons.flash_auto, size: 32);
    } else if (_currentFlashMode == FlashMode.always) {
      button = const Icon(
        Icons.flash_on,
        size: 32,
        color: Colors.amber,
      );
    } else {
      button = const Icon(Icons.flash_off, size: 32);
    }

    return InkWell(
      onTap: () async {
        FlashMode? newMode = _currentFlashMode;
        if (_currentFlashMode == FlashMode.off) {
          newMode = FlashMode.auto;
        } else if (_currentFlashMode == FlashMode.auto) {
          newMode = FlashMode.always;
        } else if (_currentFlashMode == FlashMode.always) {
          newMode = FlashMode.off;
        }

        setState(() {
          _currentFlashMode = newMode;
        });
        await controller!.setFlashMode(newMode!);
      },
      child: button,
    );
  }

  Widget getAspectRatioButton() {
    Widget button;
    TextStyle textStyle = const TextStyle(fontSize: 24);
    if (_currentAspectRatio == SupportedAspectRatio.nineBySixteen) {
      button = Text("9:16", style: textStyle);
    } else if (_currentAspectRatio == SupportedAspectRatio.threeByFour) {
      button = Text("3:4", style: textStyle);
    } else if (_currentAspectRatio == SupportedAspectRatio.fourByFive) {
      button = Text("4:5", style: textStyle);
    } else {
      button = Text("1:1", style: textStyle);
    }

    return InkWell(
      onTap: () async {
        SupportedAspectRatio newAspectRatio;
        if (_currentAspectRatio == SupportedAspectRatio.nineBySixteen) {
          newAspectRatio = SupportedAspectRatio.threeByFour;
        } else if (_currentAspectRatio == SupportedAspectRatio.threeByFour) {
          newAspectRatio = SupportedAspectRatio.fourByFive;
        } else if (_currentAspectRatio == SupportedAspectRatio.fourByFive) {
          newAspectRatio = SupportedAspectRatio.square;
        } else {
          newAspectRatio = SupportedAspectRatio.nineBySixteen;
        }

        setState(() {
          _currentAspectRatio = newAspectRatio;
        });
      },
      child: button,
    );
  }

  Widget getImagePickerButton() {
    return InkWell(
      onTap: () {
        _onImageLibPressed();
      },
      child: const Icon(
        Icons.photo,
        size: 60,
      ),
    );
  }

  Widget getCaptureButton() {
    bool isPressed = false;
    return InkWell(
      onTap: (() {
        if (!isPressed) {
          isPressed = true;
          takePicture();
        }
      }),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.circle, color: Colors.white38, size: 90),
          Icon(Icons.circle, color: Colors.white, size: 80),
        ],
      ),
    );
  }

  Widget getFlipCameraButton() {
    return InkWell(
        onTap: () {
          flipCamera();
        },
        child: Stack(alignment: Alignment.center, children: const [
          Icon(Icons.circle, color: Color(0xFF323232), size: 60),
          Icon(
            Icons.autorenew,
            size: 40,
          ),
        ]));
  }
}

// https://stackoverflow.com/questions/51415236/show-circular-progress-dialog-in-login-screen-in-flutter-how-to-implement-progr
showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(
            margin: const EdgeInsets.only(left: 24),
            child: const Text("Loading...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      //prevent Back button press
      return WillPopScope(onWillPop: () async => false, child: alert);
    },
  );
}
