import 'package:alignedstories/home/gallery.dart';
import 'package:alignedstories/home/gallery_logic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alignedstories/auth/authentication_logic.dart';


class ImageZoomPage extends StatefulWidget {
  final ZoomedImg img;
  final bool ref;
  const ImageZoomPage({ Key? key, required this.img, required this.ref}) : super(key: key);


  @override
  _ImageZoomPageState createState() => _ImageZoomPageState();
}

class _ImageZoomPageState extends State<ImageZoomPage> {
  late bool isRef;
  final GlobalKey _canvasKey = new GlobalKey();
  double _brushRadius = 35;

  Widget refBody() {
    return Column(
      children: [
        Provider<List<Offset>>(
          create: (context) => <Offset>[],
          child: Builder(
            builder: (context) {
              return GestureDetector(
                child: CustomPaint(
                  foregroundPainter: MaskPainter(mask: context.read<List<Offset>>(),brushRadius: _brushRadius),
                  child: widget.img,
                  key: _canvasKey,
                ),
                onPanDown: (detailData){
                  context.read<List<Offset>>().add(detailData.localPosition);
                  _canvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
                },
                onPanUpdate: (detailData){
                  context.read<List<Offset>>().add(detailData.localPosition);
                  _canvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
                }
              );
            }
          ),
        ),
        Card(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Brush over the reference object'),
              ),
              Card(
                child: ListTile(
                  trailing: const Icon(Icons.brush),
                  title: Slider(
                    value: _brushRadius,
                    min: 20,
                    max: 50,
                    divisions: 30,
                    label: _brushRadius.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _brushRadius = value;
                      });
                    },
                  ),
                  onTap: null,
                  leading: const Text('Brush size'),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Save reference'),
                  trailing: const Icon(Icons.save_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved reference object   ✔️'),
                        duration: Duration(seconds: 1),
                      )
                    );
                  },
                ),
              )
            ]
          ),
        )
      ],
    );
  }

  Widget nonRefBody() {
    return Column(
      children: [
        widget.img,
        Card(
          child: ListTile(
            title: const Text('Set as reference'),
            onTap: () async {
              await context.read<GalleryService>().changeRef(
                newRefURL: widget.img.id, 
                uid: context.read<AuthenticationService>().currentUser!.uid
              );
              setState(() {
                isRef = true;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget getBody() {
    return isRef ? refBody() : nonRefBody();
  }

  @override
  void initState() {
    isRef = widget.ref;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: getBody())
    );
  }
}

class MaskPainter extends CustomPainter {
  final List<Offset> mask;
  final double brushRadius;

  MaskPainter({required this.mask, required this.brushRadius});

  @override
  void paint(Canvas canvas, Size size) {
    Paint myPaint = Paint()
      ..color = Colors.lightGreen.withOpacity(0.5);
    for (Offset pt in mask) {
      canvas.drawCircle(pt, brushRadius, myPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}