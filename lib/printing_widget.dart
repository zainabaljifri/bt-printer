import 'dart:convert';
import 'dart:io';
import 'dart:ui' as Image;
import 'package:blue_thermal_printing/blue_print.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as CustomImage;

GlobalKey _screenShotKey = GlobalKey();

late Uint8List theimageThatComesfromThePrinter;

FlutterBlue flutterBlue = FlutterBlue.instance;

class PrintingWidget extends StatefulWidget {
  const PrintingWidget({Key? key}) : super(key: key);

  @override
  _PrintingWidgetState createState() => _PrintingWidgetState();
}

class _PrintingWidgetState extends State<PrintingWidget> {
  ScreenshotController screenshotController = ScreenshotController();
  List<ScanResult>? scanResult;

  @override
  void initState() {
    super.initState();
    findDevices();
  }

  void findDevices() {
    flutterBlue.startScan(timeout: const Duration(seconds: 2));
    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResult = results;
      });
    });
    flutterBlue.stopScan();
  }

  void printWithDevice(BluetoothDevice device) async {
    // await device.connect();
    final gen = Generator(PaperSize.mm58, await CapabilityProfile.load());
    final printer = BluePrint();
    RenderRepaintBoundary boundary = _screenShotKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    Image.Image image = await boundary.toImage();
    ByteData? byteData =
        await image.toByteData(format: Image.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    CustomImage.Image imagePNG = CustomImage.decodePng(pngBytes)!;
    printer.add(gen.image(imagePNG));

    // printer.add(gen.image(image));
    // printer.add(gen.qrcode('https://google.com'));
    // printer.add(gen.text('Hello'));
    // printer.add(gen.text('World', styles: const PosStyles(bold: true)));
    // printer.add(gen.feed(1)); // for line spacing
    // Uint8List encoded = await CharsetConverter.encode(
    //     'windows-1256', "فاتورة ضريبة فاتورة ضريبة فاتورة ضريبة");
    // printer.add(gen.textEncoded(encoded));
    // String source = 'تجربة';
    // List<int> list = utf8.encode(source);
    // Uint8List bytess = Uint8List.fromList(list);
    // String outcome = utf8.decode(bytess);
    // printer.add(gen.textEncoded(
    //   Uint8List.fromList([
    //     ...[
    //       0x1C,
    //       0x26,
    //     ],
    //     ...utf8.encode('تجربى')
    //   ]),
    // styles: PosStyles(codeTable: 'CP1252')
    // ));
    // printer.add(gen.text(
    //   'Special 1: Iñtërnâtiônàlizætiøn',
    // styles: PosStyles(codeTable: 'CP936')
    // ));

    await printer.printData(device);
    device.disconnect();
  }

  Future<void> takeScreenshot() async {
    RenderRepaintBoundary boundary = _screenShotKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    Image.Image image = await boundary.toImage();
    ByteData? byteData =
        await image.toByteData(format: Image.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth devices')),
      body: ListView(
        children: [
          RepaintBoundary(
            key: _screenShotKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'شادي أيمن',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Text(
                  'شادي أيمن',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Text(
                  'شادي أيمن',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Text(
                  'شادي أيمن',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(scanResult![index].device.name),
                subtitle: Text(scanResult![index].device.id.id),
                onTap: () => printWithDevice(scanResult![index].device),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: scanResult?.length ?? 0,
          ),
        ],
      ),
    );
  }
}
