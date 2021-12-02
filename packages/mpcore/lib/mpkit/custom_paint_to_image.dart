part of 'mpkit.dart';

class MPCustomPaintToImage {
  static final Map<String, Completer<Uint8List>> _fetchHandlers = {};

  static void receivedFetchImageResult(Map params) {
    String seqId = params['seqId'];
    String base64EncodedData = params['data'];
    final data = base64.decode(base64EncodedData);
    _fetchHandlers[seqId]?.complete(data);
  }
}

Future<Uint8List> fetchImageFromCustomPaint(GlobalKey customPaintKey) {
  if (customPaintKey.currentContext?.widget is! CustomPaint) {
    throw 'Should provide a valid GlobalKey attached to CustomPaint.';
  }
  final completer = Completer<Uint8List>();
  final seqId = math.Random().nextDouble().toString();
  MPCustomPaintToImage._fetchHandlers[seqId] = completer;
  MPChannel.postMessage(
    json.encode({
      'type': 'custom_paint',
      'flow': 'request',
      'message': {
        'event': 'fetchImage',
        'seqId': seqId,
        'target': customPaintKey.currentContext.hashCode,
      },
    }),
    forLastConnection: true,
  );
  return completer.future;
}
