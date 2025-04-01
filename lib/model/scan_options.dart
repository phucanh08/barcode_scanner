import '../gen/protos/protos.pb.dart';

class ScanOptions {
  const ScanOptions({
    this.restrictFormat = const [],
  });
  final List<BarcodeFormat> restrictFormat;
}
