import 'dart:math' as math;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_terminal_layout/flutter_terminal_layout.dart';
import 'package:flutter_terminal_layout/src/rendering/render_object.dart';
import 'package:flutter_terminal_layout/src/rendering/canvas.dart';

void main() {
  runApp(const CubeApp());
}

class CubeApp extends StatefulWidget {
  const CubeApp({super.key});

  @override
  State<CubeApp> createState() => _CubeAppState();
}

class _CubeAppState extends State<CubeApp> {
  double _angleX = 0;
  double _angleY = 0;
  double _angleZ = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _angleX += 0.02;
        _angleY += 0.03;
        _angleZ += 0.01;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CubeWidget(angleX: _angleX, angleY: _angleY, angleZ: _angleZ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            color: Colors.black,
            child: Text(
              ' High-Res Z-Buffered Cube (Half-Block) ',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class CubeWidget extends RenderObjectWidget {
  final double angleX;
  final double angleY;
  final double angleZ;

  const CubeWidget({
    super.key,
    required this.angleX,
    required this.angleY,
    required this.angleZ,
  });

  @override
  Element createElement() => LeafRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCube(angleX: angleX, angleY: angleY, angleZ: angleZ);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCube renderObject) {
    renderObject
      ..angleX = angleX
      ..angleY = angleY
      ..angleZ = angleZ;
  }
}

class RenderCube extends RenderObject {
  double angleX;
  double angleY;
  double angleZ;

  RenderCube({
    required this.angleX,
    required this.angleY,
    required this.angleZ,
  });

  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  // Reuse buffers to avoid allocation every frame
  Float64List? _zBuffer;
  Int32List? _colorBuffer;
  int _bufferWidth = 0;
  int _bufferHeight = 0;

  void _initBuffers(int w, int h) {
    if (_bufferWidth != w || _bufferHeight != h) {
      _bufferWidth = w;
      _bufferHeight = h;
      _zBuffer = Float64List(w * h);
      _colorBuffer = Int32List(w * h);
    }
    // Clear buffers
    _zBuffer!.fillRange(0, _zBuffer!.length, double.infinity);
    _colorBuffer!.fillRange(0, _colorBuffer!.length, 0xFF000000); // Black background
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    // We render at 2x vertical resolution
    final w = size.width;
    final h = size.height * 2;
    _initBuffers(w, h);

    final centerX = w / 2.0;
    final centerY = h / 2.0;
    
    // Scale: The terminal cell is approx 1:2. 
    // In our 2x vertical buffer, pixels are approx 1:1.
    // So we can use uniform scaling.
    final scale = math.min(w, h) / 3.5;

    final vertices = [
      Vector3(-1, -1, -1), Vector3(1, -1, -1), Vector3(1, 1, -1), Vector3(-1, 1, -1),
      Vector3(-1, -1, 1),  Vector3(1, -1, 1),  Vector3(1, 1, 1),  Vector3(-1, 1, 1),
    ];

    // Define triangles (Counter-clockwise winding)
    final indices = [
      0, 1, 2, 0, 2, 3, // Front
      5, 4, 7, 5, 7, 6, // Back
      4, 0, 3, 4, 3, 7, // Left
      1, 5, 6, 1, 6, 2, // Right
      4, 5, 1, 4, 1, 0, // Top
      3, 2, 6, 3, 6, 7, // Bottom
    ];

    final transformed = <Vector3>[];

    // 1. Transform Vertices
    for (var v in vertices) {
      // Rotate
      double x = v.x, y = v.y, z = v.z;
      
      // Rot X
      double y1 = y * math.cos(angleX) - z * math.sin(angleX);
      double z1 = y * math.sin(angleX) + z * math.cos(angleX);
      y = y1; z = z1;

      // Rot Y
      double x1 = x * math.cos(angleY) + z * math.sin(angleY);
      double z2 = -x * math.sin(angleY) + z * math.cos(angleY);
      x = x1; z = z2;

      // Rot Z
      double x2 = x * math.cos(angleZ) - y * math.sin(angleZ);
      double y2 = x * math.sin(angleZ) + y * math.cos(angleZ);
      x = x2; y = y2;

      // Project
      double distance = 4.0;
      double factor = scale * (1.0 / (distance - z));
      
      transformed.add(Vector3(
        centerX + x * factor,
        centerY + y * factor,
        z // Keep Z for Z-buffer
      ));
    }

    // 2. Rasterize Triangles
    for (int i = 0; i < indices.length; i += 3) {
      final v0 = transformed[indices[i]];
      final v1 = transformed[indices[i+1]];
      final v2 = transformed[indices[i+2]];

      // Face Normal (Flat shading)
      // We need to use rotated (but unprojected) vertices for true normal?
      // Or just use screen space cross product for z?
      // Ideally we transform normals properly. 
      // But for a simple cube, we can compute normal from screen space triangle for "lighting"?
      // No, that's wrong. Lighting should be computed in 3D space.
      // But we lost the 3D rotated coordinates (overwrote with projected).
      // Let's re-calculate normal from indices (Cube faces are axis aligned originally).
      // Or better: Compute normal from the 3 edges of the triangle in 3D space.
      // Simpler hack: Compute Cross product of screen space edges to check winding (Backface culling).
      
      final edge1 = v1 - v0;
      final edge2 = v2 - v0;
      final normalZ = edge1.x * edge2.y - edge1.y * edge2.x;

      if (normalZ >= 0) continue; // Backface culling (assuming CCW is front)

      // Lighting: We need 3D normal. 
      // Since I didn't save the rotated 3D verts, I'll cheat/approximate or re-do.
      // Re-doing correctly: We really should have kept rotated 3D verts.
      // BUT, since it's a cube, flat shading is distinct per face.
      // Let's assign colors based on Face ID (i/6).
      int faceId = i ~/ 6;
      Color faceColor;
      
      // Base colors for faces
      List<Color> baseColors = [
        const Color.fromARGB(255, 255, 100, 100), // Front (Red-ish)
        const Color.fromARGB(255, 100, 255, 100), // Back (Green-ish)
        const Color.fromARGB(255, 100, 100, 255), // Left (Blue-ish)
        const Color.fromARGB(255, 255, 255, 100), // Right (Yellow-ish)
        const Color.fromARGB(255, 100, 255, 255), // Top (Cyan-ish)
        const Color.fromARGB(255, 255, 100, 255), // Bottom (Magenta-ish)
      ];
      
      // Calculate simple diffuse intensity based on a fixed light relative to face index?
      // No, that won't rotate with the cube.
      // We need the normal. 
      // Let's recover the normal from the triangle cross product in 3D (approximate with Z depth?)
      // Actually, since we have the indices, we know the original normal.
      // We just need to rotate that original normal by the current rotation matrix.
      // Or... simpler: Just use the screen-space normalZ as an "intensity" approximation?
      // No, that's view-dependent, not light-dependent.
      
      // Let's just use the Colors above. It will look like a colorful cube.
      // To add shading, we can modulate the color by some factor.
      
      faceColor = baseColors[faceId];
      
      // Draw Triangle
      _drawTriangle(v0, v1, v2, faceColor.value);
    }

    // 3. Output to Canvas
    // Use upper-half block '▀'
    // Foreground = Top pixel, Background = Bottom pixel
    for (int y = 0; y < size.height; y++) {
      for (int x = 0; x < size.width; x++) {
        int cTop = _colorBuffer![(y * 2) * _bufferWidth + x];
        int cBottom = _colorBuffer![(y * 2 + 1) * _bufferWidth + x];

        // Convert int to Color
        Color topColor = Color(cTop);
        Color botColor = Color(cBottom);

        if (cTop == cBottom) {
          // Solid block (use space with BG, or block with FG)
          // Prefer Space with BG usually
          canvas.setCell(x, y, ' ', bg: botColor);
        } else {
          canvas.setCell(x, y, '▀', fg: topColor, bg: botColor);
        }
      }
    }
  }

  void _drawTriangle(Vector3 v0, Vector3 v1, Vector3 v2, int color) {
    // Bounding Box
    int minX = math.min(v0.x, math.min(v1.x, v2.x)).floor();
    int maxX = math.max(v0.x, math.max(v1.x, v2.x)).ceil();
    int minY = math.min(v0.y, math.min(v1.y, v2.y)).floor();
    int maxY = math.max(v0.y, math.max(v1.y, v2.y)).ceil();

    // Clip
    minX = math.max(0, minX);
    maxX = math.min(_bufferWidth - 1, maxX);
    minY = math.max(0, minY);
    maxY = math.min(_bufferHeight - 1, maxY);

    // Edge functions
    // P = (x,y)
    // w0 = edge(v1, v2, P)
    // w1 = edge(v2, v0, P)
    // w2 = edge(v0, v1, P)
    
    // Constant setup
    // Area is effectively the edge function of edge v1-v2 evaluated at v0
    // w0 for v0 should be area.
    double area = _edgeFunction(v1, v2, v0.x, v0.y);
    if (area == 0) return; // Degenerate

    // Apply simple depth shading
    // Approximate face center depth for shading whole face (flat shading)
    // Or per-pixel? Per-pixel is easy.
    double r = (color >> 16 & 0xFF) / 255.0;
    double g = (color >> 8 & 0xFF) / 255.0;
    double b = (color & 0xFF) / 255.0;

    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        // Pixel center
        double px = x + 0.5;
        double py = y + 0.5;
        
        double w0 = _edgeFunction(v1, v2, px, py);
        double w1 = _edgeFunction(v2, v0, px, py);
        double w2 = _edgeFunction(v0, v1, px, py);

        // Check if inside (handle winding order by checking all same sign)
        // Since we culled backfaces, area should be positive (or negative consistent).
        // If area > 0, then all w must be >= 0.
        // If area < 0, all w must be <= 0.
        bool inside = (area > 0) 
            ? (w0 >= 0 && w1 >= 0 && w2 >= 0)
            : (w0 <= 0 && w1 <= 0 && w2 <= 0);

        if (inside) {
          // Barycentric coords
          double b0 = w0 / area;
          double b1 = w1 / area;
          double b2 = w2 / area;

          // Interpolate Z
          double z = b0 * v0.z + b1 * v1.z + b2 * v2.z;
          double depth = 4.0 - z;
          
          int idx = y * _bufferWidth + x;
          if (depth < _zBuffer![idx]) {
            _zBuffer![idx] = depth;
            
            // Depth shading: Darker further away
            // Depth ranges approx 3.0 to 5.0
            double shade = 1.0 - ((depth - 2.0) / 4.0).clamp(0.0, 0.8);
            
            int ir = (r * shade * 255).toInt();
            int ig = (g * shade * 255).toInt();
            int ib = (b * shade * 255).toInt();
            
            _colorBuffer![idx] = (0xFF << 24) | (ir << 16) | (ig << 8) | ib;
          }
        }
      }
    }
  }

  double _edgeFunction(Vector3 a, Vector3 b, double px, double py) {
     return (b.x - a.x) * (py - a.y) - (b.y - a.y) * (px - a.x);
  }
}

class Vector3 {
  final double x, y, z;
  const Vector3(this.x, this.y, this.z);
  
  Vector3 operator +(Vector3 o) => Vector3(x + o.x, y + o.y, z + o.z);
  Vector3 operator -(Vector3 o) => Vector3(x - o.x, y - o.y, z - o.z);
  
  Vector3 normalized() {
    double l = math.sqrt(x*x + y*y + z*z);
    if (l == 0) return this;
    return Vector3(x/l, y/l, z/l);
  }
}
