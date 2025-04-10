import 'dart:typed_data';

import 'package:bcbp/bcbp.dart' show bcbpDecode;
import '../gen/protos/protos.pb.dart' show BarcodeResult;

class Barcode {
  final BarcodeFormat format;
  final String rawValue;
  final Uint8List? rawBytes;
  final BarcodeType type;
  final BarcodeValue? value;
  final int timestamp;

  const Barcode._({
    required this.format,
    required this.rawValue,
    required this.rawBytes,
    required this.type,
    required this.value,
    required this.timestamp,
  });

  factory Barcode.fromProtos(BarcodeResult protoData) {
    final format = BarcodeFormat.values.byName(protoData.format.name);
    final String rawValue = protoData.rawValue;
    final typeAndValue = typeAndValueFromString(rawValue);

    return Barcode._(
      format: format,
      rawValue: rawValue,
      rawBytes: Uint8List.fromList(protoData.rawBytes),
      type: typeAndValue.keys.first,
      value: typeAndValue.values.first,
      timestamp: protoData.timestamp.toInt(),
    );
  }
}

Map<BarcodeType, BarcodeValue?> typeAndValueFromString(String rawValue) {
  try {
    for (var e in BarcodeType.values) {
      switch (e) {
        case BarcodeType.boardingPass:
          final value = BarcodeBoardingPass.fromRawData(rawValue);
          if (value != null) return {BarcodeType.boardingPass: value};
          break;
        case BarcodeType.wifi:
          final value = BarcodeWifi.fromRawData(rawValue);
          if (value != null) return {BarcodeType.wifi: value};
          break;
        default:
          break;
      }
    }
  } catch (_) {}

  return {BarcodeType.unknown: null};
}

enum BarcodeFormat {
  all,

  // 1D Barcode
  code39,
  code93,
  code128,
  itf,
  upce,
  ean8,
  ean13,
  codaBar,
  gs1DataBar,
  gs1DataBarExtended,

  // 2D Barcode
  qr,
  pdf417,
  dataMatrix,
  aztec,
  unknown,
}

enum BarcodeType {
  /// Unknown Barcode value types.
  unknown,

  /// Barcode value type for Wi-Fi access point details.
  wifi,

  /// Barcode value type for boarding pass.
  boardingPass,
}

abstract class BarcodeValue {}

class BarcodeBoardingPass extends BarcodeValue {
  /// passengerName
  final String? passengerName;

  /// PNR
  final String? operatingCarrierPNR;

  /// IATA departure Airport
  final String? departureAirport;

  /// IATA arrival Airport
  final String? arrivalAirport;

  final String? flightNumber;

  final DateTime? flightDate;

  final String? seatNumber;

  final DateTime? issuanceDate;

  final String? compartmentCode;

  final String? checkInSequenceNumber;

  final String? airlineNumericCode;

  BarcodeBoardingPass({
    required this.passengerName,
    required this.operatingCarrierPNR,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.flightNumber,
    required this.flightDate,
    required this.seatNumber,
    required this.issuanceDate,
    required this.compartmentCode,
    required this.checkInSequenceNumber,
    required this.airlineNumericCode,
  });

  static BarcodeBoardingPass? fromRawData(String? data) {
    try {
      final result = bcbpDecode(data ?? "");
      final legs = result.data?.legs ?? [];
      if (legs.isEmpty) {
        return null;
      }
      return BarcodeBoardingPass(
        passengerName: result.data?.passengerName,
        operatingCarrierPNR: legs.first.operatingCarrierPNR,
        departureAirport: legs.first.departureAirport,
        arrivalAirport: legs.first.arrivalAirport,
        flightNumber: legs.first.flightNumber,
        flightDate: legs.first.flightDate,
        seatNumber: legs.first.seatNumber,
        issuanceDate: result.data?.issuanceDate,
        compartmentCode: legs.first.compartmentCode,
        checkInSequenceNumber: legs.first.checkInSequenceNumber,
        airlineNumericCode: legs.first.airlineNumericCode,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Stores wifi info obtained from a barcode.
class BarcodeWifi extends BarcodeValue {
  /// SSID of the wifi.
  final String? ssid;

  /// Password of the wifi.
  final String? password;

  /// Encryption type of wifi.
  final String? encryptionType;

  final bool? hidden;

  /// Constructor to create an instance of [BarcodeWifi].
  BarcodeWifi({this.ssid, this.password, this.encryptionType, this.hidden});

  /// Returns an instance of [BarcodeWifi] from a given [json].
  factory BarcodeWifi.fromJson(Map<dynamic, dynamic> json) => BarcodeWifi(
        ssid: json['ssid'],
        password: json['password'],
        encryptionType: json['type'],
        hidden: json['hidden'] == true,
      );

  static BarcodeWifi? fromRawData(String? data) {
    try {
      final wifiData = data ?? "";

      if (!wifiData.startsWith('WIFI:')) {
        return null;
      }

      final regex = RegExp(r'([TSPH]):([^;]*)');
      final matches = regex.allMatches(wifiData);

      final Map<String, String> keyMap = {
        'T': 'type',
        'S': 'ssid',
        'P': 'password',
        'H': 'hidden',
      };

      final resultJson = <String, String>{};
      for (final match in matches) {
        final key = match.group(1);
        final value = match.group(2);
        if (key != null && value != null) {
          resultJson[keyMap[key] ?? key] = value;
        }
      }

      return BarcodeWifi.fromJson(resultJson);
    } catch (_) {
      return null;
    }
  }
}
