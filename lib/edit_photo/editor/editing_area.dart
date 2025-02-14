import 'package:flutter/cupertino.dart';

import '../photo_editor.dart';

class EditingArea extends StatefulWidget {
  const EditingArea({Key? key, required this.editingAreaSize, required this.aspectRatio}) : super(key: key);

  final Size editingAreaSize;
  final double aspectRatio;

  @override
  State<EditingArea> createState() => _EditingAreaState();
}

class _EditingAreaState extends State<EditingArea> {
  OverlaidWidget? _activeItem;
  late Offset _initPos;
  late Offset _currentPos;
  late double _currentScale;
  late double _currentRotation;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final editingArea = widget.editingAreaSize;
    final photoAspectRatio = widget.aspectRatio;

    return Container();
    //   Stack(children: <Widget>[
    //   // Photo Editing area
    //   GestureDetector(
    //       behavior: HitTestBehavior.translucent,
    //       onTap: () {
    //         _animateHidePanel();
    //       },
    //       onScaleStart: (details) {
    //         _initPos = details.focalPoint;
    //         if (_activeItem == null) return;
    //
    //         _currentPos = _activeItem!.position;
    //         _currentScale = _activeItem!.scale;
    //         _currentRotation = _activeItem!.rotation;
    //         setState(() {
    //           _hideMenu = true;
    //           _hideDelete = false;
    //         });
    //       },
    //       onScaleUpdate: (details) {
    //         final delta = details.focalPoint - _initPos;
    //         if (_activeItem == null) {
    //           if (delta.dy < -5) {
    //             _animateShowPanel();
    //           }
    //           return;
    //         }
    //         final left = (delta.dx / editingArea.width) + _currentPos.dx;
    //         final top = (delta.dy / editingArea.height) + _currentPos.dy;
    //
    //         setState(() {
    //           _activeItem!.position = Offset(left, top);
    //           _activeItem!.rotation = details.rotation + _currentRotation;
    //           _activeItem!.scale = details.scale * _currentScale;
    //           _hideMenu = true;
    //
    //           final dx = details.focalPoint.dx;
    //           final dy = details.focalPoint.dy;
    //
    //           // If picture size is big, the delete button is shown
    //           // overlaying on top of picture, else the button is on the
    //           // black bar.
    //           if (screenSize.height - 50 <
    //               screenSize.height / 2 + editingArea.height / 2) {
    //             // It would be more natural to delete the widget, if the
    //             // widget is dragged to the center, touching the delete
    //             // button.
    //             if (dx >= screenSize.width * 0.25 &&
    //                 dx <= screenSize.width * 0.75 &&
    //                 dy > screenSize.height - 50) {
    //               _nearDelete = true;
    //               return;
    //             }
    //           } else {
    //             // The delete button is on the black bar, just drag to the
    //             // black bar, then that widget is deleted.
    //             if (dy > screenSize.height / 2 + editingArea.height / 2) {
    //               _nearDelete = true;
    //               return;
    //             }
    //           }
    //           _nearDelete = false;
    //         });
    //       },
    //       child: Align(
    //         alignment: (() {
    //           if ((photoAspectRatio - 9 / 16).abs() < 0.1) {
    //             return AlignmentDirectional.topCenter;
    //           }
    //
    //           return AlignmentDirectional.center;
    //         }()),
    //         child: SizedBox(
    //             width: editingArea.width,
    //             height: editingArea.height,
    //             child: ClipRRect(
    //               borderRadius: BorderRadius.circular(16.0),
    //               child: RepaintBoundary(
    //                   key: _globalKey,
    //                   child: Stack(clipBehavior: Clip.antiAlias, children: <
    //                       Widget>[
    //                     FutureBuilder<Color>(
    //                         future: _dominantColorFuture,
    //                         builder: (BuildContext context,
    //                             AsyncSnapshot<Color> snapshot) {
    //                           if (snapshot.hasData) {
    //                             return Container(color: snapshot.data);
    //                           } else {
    //                             return Container(color: Colors.black);
    //                           }
    //                         }),
    //                     Transform.scale(
    //                       // TODO: Implement Zoom
    //                         scale: 1,
    //                         child: Center(child: Image.file(widget.image))),
    //                     NotificationListener<ScrollNotification>(
    //                       onNotification: (scrollNotification) {
    //                         if (scrollNotification
    //                         is ScrollStartNotification) {
    //                           setState(() {
    //                             _hideMenu = true;
    //                           });
    //                         } else if (scrollNotification
    //                         is ScrollEndNotification) {
    //                           setState(() {
    //                             _hideMenu = false;
    //                           });
    //                         }
    //                         return true;
    //                       },
    //                       child: PageView.builder(
    //                         key: Key('$aqi$_placeName'),
    //                         controller: _pageController,
    //                         scrollDirection: Axis.horizontal,
    //                         physics: _isTemplateChangeAllowed == true
    //                             ? const AlwaysScrollableScrollPhysics()
    //                             : const NeverScrollableScrollPhysics(),
    //                         itemBuilder: (BuildContext context, int index) {
    //                           return Stack(
    //                             children: templates == null
    //                                 ? []
    //                                 : templates[index % templates.length]
    //                                 .map(_buildItemWidget)
    //                                 .toList(),
    //                           );
    //                         },
    //                       ),
    //                     )
    //                   ])),
    //             )),
    //       )),
    //   _hideMenu ? Container() : _getTopMenu(),
    //   _hideDelete ? Container() : _getDeleteButton(),
    //   _getAddWidgetMenu(aqi, placeName)
    // ]));
  }
}