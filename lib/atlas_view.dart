import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class AtlasView extends StatefulWidget {
  const AtlasView({super.key});

  @override
  State<AtlasView> createState() => _AtlasViewState();
}

class _AtlasViewState extends State<AtlasView>
    with SingleTickerProviderStateMixin {
  late final _images = Images(prefix: '');
  late final _imageFuture = _images.load('assets/tiles.png');

  static const defaultColor = Color(0x00000000);

  static const _size = Size(400, 600);

  Offset _cameraOffset = Offset(
    _size.width / 2,
    _size.height / 2,
  );
  double _scale = 4;

  bool _useSpriteBatch = false;

  static const tiles = [
    Rect.fromLTWH(0, 0, 16, 16),
    Rect.fromLTWH(16, 0, 16, 16),
    Rect.fromLTWH(32, 0, 16, 16),

    //
    Rect.fromLTWH(0, 16, 16, 16),
    Rect.fromLTWH(16, 16, 16, 16),
    Rect.fromLTWH(32, 16, 16, 16),
    //
    //
    Rect.fromLTWH(0, 16, 16, 16),
    Rect.fromLTWH(16, 16, 16, 16),
    Rect.fromLTWH(32, 16, 16, 16),
    //
    //
    Rect.fromLTWH(0, 16, 16, 16),
    Rect.fromLTWH(16, 16, 16, 16),
    Rect.fromLTWH(32, 16, 16, 16),
    //

    Rect.fromLTWH(0, 32, 16, 16),
    Rect.fromLTWH(16, 32, 16, 16),
    Rect.fromLTWH(32, 32, 16, 16),
  ];

  final transforms = [
    RSTransform(1, 0, 0, 0),
    RSTransform(1, 0, 16, 0),
    RSTransform(1, 0, 32, 0),
    //
    RSTransform(1, 0, 0, 16),
    RSTransform(1, 0, 16, 16),
    RSTransform(1, 0, 32, 16),
    //
    //
    RSTransform(1, 0, 0, 32),
    RSTransform(1, 0, 16, 32),
    RSTransform(1, 0, 32, 32),
    //
    //
    RSTransform(1, 0, 0, 48),
    RSTransform(1, 0, 16, 48),
    RSTransform(1, 0, 32, 48),
    //
    RSTransform(1, 0, 0, 64),
    RSTransform(1, 0, 16, 64),
    RSTransform(1, 0, 32, 64),
  ];

  late final colors = List.generate(tiles.length, (index) => defaultColor);

  static const _cameraSteps = 4.0;

  late final _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..addListener(_update)
        ..addStatusListener(_statusChange);

  late int _lastMillis;

  var _animationDirection = Offset.zero;
  void _update() {
    final now = DateTime.now().millisecondsSinceEpoch;

    final delta = now - _lastMillis;
    _lastMillis = now;

    final dt = delta / 1000;

    final newOffset = Offset(
      _cameraOffset.dx + _animationDirection.dx * 100 * dt,
      _cameraOffset.dy + _animationDirection.dy * 100 * dt,
    );

    setState(() {
      _cameraOffset = newOffset;
    });
  }

  void _statusChange(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      _setAnimationTarget();
    }
  }

  void _setAnimationTarget() {
    final random = math.Random();
    final direction = Offset(
      random.nextDouble() * (random.nextBool() ? 1 : -1),
      random.nextDouble() * (random.nextBool() ? 1 : -1),
    );

    setState(() {
      _animationDirection = direction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        children: [
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _scale -= .2;
              });
            },
            icon: const Icon(Icons.zoom_out),
            label: const Text('Zoom out'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _scale += .2;
              });
            },
            icon: const Icon(Icons.zoom_in),
            label: const Text('Zoom in'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _cameraOffset += const Offset(-_cameraSteps, 0);
              });
            },
            icon: const Icon(Icons.arrow_left),
            label: const Text('Move left'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _cameraOffset += const Offset(_cameraSteps, 0);
              });
            },
            icon: const Icon(Icons.arrow_right),
            label: const Text('Move right'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _cameraOffset += const Offset(0, -_cameraSteps);
              });
            },
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Move up'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _cameraOffset += const Offset(0, _cameraSteps);
              });
            },
            icon: const Icon(Icons.arrow_downward),
            label: const Text('Move down'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _useSpriteBatch = !_useSpriteBatch;
              });
            },
            icon: const Icon(Icons.layers),
            label: Text(
              _useSpriteBatch ? 'Using SpriteBatch' : 'Using drawAtlas',
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              _lastMillis = DateTime.now().millisecondsSinceEpoch;
              if (_controller.isCompleted) {
                _controller.reset();
              }
              _controller.forward();
            },
            icon: const Icon(Icons.face),
            label: const Text('Animate'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;

          if (data == null) {
            return const Center(
              child: Text('Image failed'),
            );
          }

          return Center(
            child: SizedBox(
              width: _size.width,
              height: _size.height,
              child: ColoredBox(
                color: Colors.white,
                child: CustomPaint(
                  painter: _useSpriteBatch
                      ? SpriteBatchPainter(
                          image: data,
                          rects: tiles,
                          transforms: transforms,
                          scale: _scale,
                          camera: _cameraOffset,
                        )
                      : AtlasPainter(
                          image: data,
                          colors: colors,
                          rects: tiles,
                          transforms: transforms,
                          scale: _scale,
                          camera: _cameraOffset,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AtlasPainter extends CustomPainter {
  AtlasPainter({
    required this.image,
    required this.colors,
    required this.rects,
    required this.transforms,
    required this.scale,
    required this.camera,
  });

  final ui.Image image;
  final List<Color> colors;
  final List<Rect> rects;
  final List<RSTransform> transforms;
  final double scale;
  final Offset camera;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 40, 40),
      Paint()..color = Colors.blue,
    );

    canvas.save();
    canvas.translate(camera.dx, camera.dy);
    canvas.scale(scale, scale);

    canvas.drawAtlas(
      image,
      transforms,
      rects,
      colors,
      BlendMode.srcOver,
      null,
      Paint()
        ..filterQuality = FilterQuality.none
        ..isAntiAlias = false,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(AtlasPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.colors != colors ||
        oldDelegate.rects != rects ||
        oldDelegate.transforms != transforms ||
        oldDelegate.scale != scale ||
        oldDelegate.camera != camera;
  }
}

class SpriteBatchPainter extends CustomPainter {
  SpriteBatchPainter({
    required this.image,
    required this.rects,
    required this.transforms,
    required this.scale,
    required this.camera,
  }) {
    _spriteBatch = SpriteBatch(image);

    for (var i = 0; i < rects.length; i++) {
      _spriteBatch.addTransform(
        source: rects[i],
        transform: transforms[i],
      );
    }
  }

  late final SpriteBatch _spriteBatch;
  final ui.Image image;
  final List<Rect> rects;
  final List<RSTransform> transforms;
  final double scale;
  final Offset camera;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 40, 40),
      Paint()..color = Colors.red,
    );
    canvas.save();
    canvas.translate(camera.dx, camera.dy);
    canvas.scale(scale, scale);

    _spriteBatch.render(
      canvas,
      paint: Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(AtlasPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.rects != rects ||
        oldDelegate.transforms != transforms ||
        oldDelegate.scale != scale ||
        oldDelegate.camera != camera;
  }
}
