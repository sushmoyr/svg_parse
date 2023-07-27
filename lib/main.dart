import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:xml/xml.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Path> paths = [];

  @override
  void initState() {
    super.initState();
    parseSvg();
  }

  void parseSvg() async {
    String svgFileString =
        await rootBundle.loadString('assets/shape_design.svg');
    // final Uri uri =
    //     Uri.parse('https://dd.xeronce.com/uploads/shape_design.svg');
    // final response = await get(uri);
    // String svgFileString = response.body;
    // print(response.body);

    // print(svgFileString);
    XmlDocument document = XmlDocument.parse(svgFileString);
    List<Path> paths = [];
    document.findAllElements('path').forEach((element) {
      // String pathData = element.attributes
      var dAttrs =
          element.attributes.where((attr) => attr.name.local == 'd').first;
      String pathData = dAttrs.value;

      Path path = parseSvgPath(pathData);
      paths.add(path);
    });
    setState(() {
      this.paths = paths;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox.square(
          dimension: 200,
          child: ClipPath(
            clipper: ShapeClipper(paths),
            child: CustomPaint(
              foregroundPainter: ShapePainter(
                paths,
              ),
              painter: ShapePainter(paths),
              child: Image.network(
                'https://picsum.photos/200/300',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      // body: SizedBox.expand(
      //   child: Center(
      //     child: SizedBox.square(
      //       dimension: 200,
      //       child: ClipPath(
      //         clipper: ShapeClipper(paths),
      //         child: Image.network(
      //           'https://picsum.photos/200/300',
      //           fit: BoxFit.cover,
      //         ),
      //         // size: Size.infinite,
      //         // painter: ShapePainter(paths),
      //       ),
      //     ),
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Path> paths;

  ShapePainter(
    this.paths,
  );

  @override
  void paint(Canvas canvas, Size size) {
    print(paths);
    Path path = Path();
    for (var value in paths) {
      path.addPath(value, Offset.zero);
    }

    canvas.clipPath(path);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // for (var element in paths) {
    //   print(element);
    //   // element.addRect(Rect.fromCenter(
    //   //     center: size.center(Offset.zero), width: 123, height: 123));
    //   canvas.drawPath(
    //       element,
    //       Paint()
    //         ..color = Colors.black
    //         ..style = PaintingStyle.fill
    //         ..strokeWidth = 2);
    // }
    // print("Inside painter $size");
    // Paint paint = Paint()
    //   ..color = Colors.black
    //   ..style = PaintingStyle.fill
    //   ..strokeWidth = 2;
    // Path element = Path();
    // element.addRect(Rect.fromCenter(
    //     center: size.center(Offset.zero), width: 123, height: 123));
    // canvas.drawPath(element, paint);
    // canvas.drawCircle(size.center(Offset.zero), 60, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ShapeClipper extends CustomClipper<Path> {
  final List<Path> paths;

  ShapeClipper(this.paths);

  @override
  Path getClip(Size size) {
    Path path = Path();
    Rect rect = Rect.zero;
    for (var value in paths) {
      path.extendWithPath(value, Offset.zero);
      rect = rect.expandToInclude(value.getBounds());
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
