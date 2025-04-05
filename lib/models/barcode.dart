import 'dart:convert';
import 'dart:typed_data';

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
  final jsonData = jsonDecode(rawValue);
  BarcodeType type = BarcodeType.unknown;
  BarcodeValue? value;
  for (var e in BarcodeType.values) {
    try {
      switch (e) {
        case BarcodeType.unknown:
          break;
        case BarcodeType.contactInfo:
          value = BarcodeContactInfo.fromJson(jsonData);
          break;
        case BarcodeType.email:
          value = BarcodeEmail.fromJson(jsonData);
          break;
        case BarcodeType.isbn:
        // TODO: Handle this case.
          break;
        case BarcodeType.phone:
          value = BarcodePhone.fromJson(jsonData);
          break;
        case BarcodeType.product:
        // TODO: Handle this case.
          break;
        case BarcodeType.sms:
        // TODO: Handle this case.
          break;
        case BarcodeType.text:
        // TODO: Handle this case.
          break;
        case BarcodeType.url:
          value = BarcodeUrl.fromJson(jsonData);
          break;
        case BarcodeType.wifi:
          value = BarcodeWifi.fromJson(jsonData);
          break;
        case BarcodeType.geoCoordinates:
        // TODO: Handle this case.
          break;
        case BarcodeType.calendarEvent:
        // TODO: Handle this case.
          break;
        case BarcodeType.driverLicense:
          value = BarcodeDriverLicense.fromJson(jsonData);
          break;
        case BarcodeType.boardingPass:
        // TODO: Handle this case.
          break;
      }
      type = BarcodeType.wifi;
    } catch (_) {}
  }

  return {type: value};
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

  /// Barcode value type for contact info.
  contactInfo,

  /// Barcode value type for email addresses.
  email,

  /// Barcode value type for ISBNs.
  isbn,

  /// Barcode value type for phone numbers.
  phone,

  /// Barcode value type for product codes.
  product,

  /// Barcode value type for SMS details.
  sms,

  /// Barcode value type for plain text.
  text,

  /// Barcode value type for URLs/bookmarks.
  url,

  /// Barcode value type for Wi-Fi access point details.
  wifi,

  /// Barcode value type for geo coordinates.
  geoCoordinates,

  /// Barcode value type for calendar events.
  calendarEvent,

  /// Barcode value type for driver's license data.
  driverLicense,

  /// Barcode value type for boarding pass.
  boardingPass,
}

abstract class BarcodeValue {}

/// Stores wifi info obtained from a barcode.
class BarcodeWifi extends BarcodeValue {
  /// SSID of the wifi.
  final String? ssid;

  /// Password of the wifi.
  final String? password;

  /// Encryption type of wifi.
  final int? encryptionType;

  /// Constructor to create an instance of [BarcodeWifi].
  BarcodeWifi({this.ssid, this.password, this.encryptionType});

  /// Returns an instance of [BarcodeWifi] from a given [json].
  factory BarcodeWifi.fromJson(Map<dynamic, dynamic> json) => BarcodeWifi(
        ssid: json['ssid'],
        password: json['password'],
        encryptionType: json['encryption'],
      );
}

/// Stores url info of the bookmark obtained from a barcode.
class BarcodeUrl extends BarcodeValue {
  /// String having the url address of bookmark.
  final String? url;

  /// Title of the bookmark.
  final String? title;

  /// Constructor to create an instance of [BarcodeUrl].
  BarcodeUrl({this.url, this.title});

  /// Returns an instance of [BarcodeUrl] from a given [json].
  factory BarcodeUrl.fromJson(Map<dynamic, dynamic> json) => BarcodeUrl(
        url: json['url'],
        title: json['title'],
      );
}

/// The type of email for [BarcodeEmail.type].
enum BarcodeEmailType {
  /// Unknown email type.
  unknown,

  /// Barcode work email type.
  work,

  /// Barcode home email type.
  home,
}

/// Stores an email message obtained from a barcode.
class BarcodeEmail extends BarcodeValue {
  /// Type of the email sent.
  final BarcodeEmailType? type;

  /// Email address of sender.
  final String? address;

  /// Body of the email.
  final String? body;

  /// Subject of email.
  final String? subject;

  /// Constructor to create an instance of [BarcodeEmail].
  BarcodeEmail({this.type, this.address, this.body, this.subject});

  /// Returns an instance of [BarcodeEmail] from a given [json].
  factory BarcodeEmail.fromJson(Map<dynamic, dynamic> json) => BarcodeEmail(
        type: BarcodeEmailType.values[json['emailType']],
        address: json['address'],
        body: json['body'],
        subject: json['subject'],
      );
}

/// The type of phone number for [BarcodePhone.type].
enum BarcodePhoneType {
  /// Unknown phone type.
  unknown,

  /// Barcode work phone type.
  work,

  /// Barcode home phone type.
  home,

  /// Barcode fax phone type.
  fax,

  /// Barcode mobile phone type.
  mobile,
}

/// Stores a phone number obtained from a barcode.
class BarcodePhone extends BarcodeValue {
  /// Type of the phone number.
  final BarcodePhoneType? type;

  /// Phone number.
  final String? number;

  /// Constructor to create an instance of [BarcodePhone].
  BarcodePhone({this.type, this.number});

  /// Returns an instance of [BarcodePhone] from a given [json].
  factory BarcodePhone.fromJson(Map<dynamic, dynamic> json) => BarcodePhone(
        type: BarcodePhoneType.values[json['phoneType']],
        number: json['number'],
      );
}

/// Stores an SMS message obtained from a barcode.
class BarcodeSMS extends BarcodeValue {
  /// Message present in the SMS.
  final String? message;

  /// Phone number of the sender.
  final String? phoneNumber;

  /// Constructor to create an instance of [BarcodeSMS].
  BarcodeSMS({this.message, this.phoneNumber});

  /// Returns an instance of [BarcodeSMS] from a given [json].
  factory BarcodeSMS.fromJson(Map<dynamic, dynamic> json) => BarcodeSMS(
        message: json['message'],
        phoneNumber: json['number'],
      );
}

/// Stores GPS coordinates obtained from a barcode.
class BarcodeGeoPoint extends BarcodeValue {
  /// Latitude co-ordinates of the location.
  final double? latitude;

  //// Longitude co-ordinates of the location.
  final double? longitude;

  /// Constructor to create an instance of [BarcodeGeoPoint].
  BarcodeGeoPoint({this.latitude, this.longitude});

  /// Returns an instance of [BarcodeGeoPoint] from a given [json].
  factory BarcodeGeoPoint.fromJson(Map<dynamic, dynamic> json) =>
      BarcodeGeoPoint(
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}

/// Stores driver’s license or ID card data representation obtained from a barcode.
class BarcodeDriverLicense extends BarcodeValue {
  /// City of holder's address.
  final String? addressCity;

  /// State of the holder's address.
  final String? addressState;

  /// Zip code code of the holder's address.
  final String? addressZip;

  /// Street of the holder's address.
  final String? addressStreet;

  /// Date on which the license was issued.
  final String? issueDate;

  /// Birth date of the card holder.
  final String? birthDate;

  /// Expiry date of the license.
  final String? expiryDate;

  /// Gender of the holder.
  final String? gender;

  /// Driver license ID.
  final String? licenseNumber;

  /// First name of the holder.
  final String? firstName;

  /// Last name of the holder.
  final String? lastName;

  /// Country of the holder.
  final String? country;

  /// Constructor to create an instance of [BarcodeDriverLicense].
  BarcodeDriverLicense({
    this.addressCity,
    this.addressState,
    this.addressZip,
    this.addressStreet,
    this.issueDate,
    this.birthDate,
    this.expiryDate,
    this.gender,
    this.licenseNumber,
    this.firstName,
    this.lastName,
    this.country,
  });

  /// Returns an instance of [BarcodeDriverLicense] from a given [json].
  factory BarcodeDriverLicense.fromJson(Map<dynamic, dynamic> json) =>
      BarcodeDriverLicense(
        addressCity: json['addressCity'],
        addressState: json['addressState'],
        addressZip: json['addressZip'],
        addressStreet: json['addressStreet'],
        issueDate: json['issueDate'],
        birthDate: json['birthDate'],
        expiryDate: json['expiryDate'],
        gender: json['gender'],
        licenseNumber: json['licenseNumber'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        country: json['country'],
      );
}

/// Stores a person’s or organization’s business card obtained from a barcode.
class BarcodeContactInfo extends BarcodeValue {
  /// Contact person's addresses.
  final List<BarcodeAddress> addresses;

  /// Email addresses of the contact person.
  final List<BarcodeEmail> emails;

  /// Phone numbers of the contact person.
  final List<BarcodePhone> phoneNumbers;

  /// First name of the contact person.
  final String? firstName;

  /// Middle name of the person.
  final String? middleName;

  /// Last name of the person.
  final String? lastName;

  /// Properly formatted name of the person.
  final String? formattedName;

  /// Name prefix.
  final String? prefix;

  /// Name pronunciation.
  final String? pronunciation;

  /// Job title.
  final String? jobTitle;

  /// Organization of the contact person.
  final String? organizationName;

  /// Url's of contact person.
  final List<String> urls;

  /// Constructor to create an instance of [BarcodeContactInfo].
  BarcodeContactInfo({
    required this.addresses,
    required this.emails,
    required this.phoneNumbers,
    required this.urls,
    this.firstName,
    this.middleName,
    this.lastName,
    this.formattedName,
    this.prefix,
    this.pronunciation,
    this.jobTitle,
    this.organizationName,
  });

  /// Returns an instance of [BarcodeContactInfo] from a given [json].
  factory BarcodeContactInfo.fromJson(Map<dynamic, dynamic> json) =>
      BarcodeContactInfo(
        addresses: _getBarcodeAddresses(json),
        emails: _getBarcodeEmails(json),
        phoneNumbers: _getBarcodePhones(json),
        firstName: json['firstName'],
        middleName: json['middleName'],
        lastName: json['lastName'],
        formattedName: json['formattedName'],
        prefix: json['prefix'],
        pronunciation: json['pronunciation'],
        jobTitle: json['jobTitle'],
        organizationName: json['organization'],
        urls: _getUrls(json['urls']),
      );
}

/// Stores a calendar event obtained from a barcode.
class BarcodeCalenderEvent extends BarcodeValue {
  /// Description of the event.
  final String? description;

  /// Location of the event.
  final String? location;

  /// Status of the event -> whether the event is completed or not.
  final String? status;

  /// A short summary of the event.
  final String? summary;

  /// A person or the organisation who is organising the event.
  final String? organizer;

  /// Start DateTime of the calender event.
  final DateTime? start;

  /// End DateTime of the calender event.
  final DateTime? end;

  /// Constructor to create an instance of [BarcodeCalenderEvent].
  BarcodeCalenderEvent({
    this.description,
    this.location,
    this.status,
    this.summary,
    this.organizer,
    this.start,
    this.end,
  });

  /// Returns an instance of [BarcodeCalenderEvent] from a given [json].
  factory BarcodeCalenderEvent.fromJson(Map<dynamic, dynamic> json) =>
      BarcodeCalenderEvent(
        description: json['description'],
        location: json['location'],
        status: json['status'],
        summary: json['summary'],
        organizer: json['organizer'],
        start: _getDateTime(json['start']),
        end: _getDateTime(json['end']),
      );
}

/// Address type constants for [BarcodeAddress.type]
enum BarcodeAddressType {
  /// Barcode unknown address type.
  unknown,

  /// Barcode work address type.
  work,

  /// Barcode home address type.
  home,
}

/// Stores an address obtained from a barcode.
class BarcodeAddress {
  /// Address lines found.
  final List<String> addressLines;

  /// The address type.
  final BarcodeAddressType? type;

  /// Constructor to create an instance of [BarcodeAddress].
  BarcodeAddress({required this.addressLines, this.type});

  /// Returns an instance of [BarcodeAddress] from a given [json].
  factory BarcodeAddress.fromJson(Map<dynamic, dynamic> json) {
    final lines = <String>[];
    for (final dynamic line in json['addressLines']) {
      lines.add(line);
    }
    return BarcodeAddress(
      addressLines: lines,
      type: BarcodeAddressType.values[json['addressType']],
    );
  }
}

DateTime? _getDateTime(dynamic barcodeData) {
  if (barcodeData is double) {
    return DateTime.fromMillisecondsSinceEpoch(barcodeData.toInt() * 1000);
  } else if (barcodeData is String) {
    return DateTime.parse(barcodeData);
  }
  return null;
}

List<BarcodeAddress> _getBarcodeAddresses(dynamic json) {
  final list = <BarcodeAddress>[];
  json['addresses']?.forEach((address) {
    list.add(BarcodeAddress.fromJson(address));
  });
  return list;
}

List<BarcodeEmail> _getBarcodeEmails(dynamic json) {
  final list = <BarcodeEmail>[];
  json['emails']?.forEach((email) {
    email['type'] = BarcodeType.email.index;
    email['format'] = json['format'];
    list.add(BarcodeEmail.fromJson(email));
  });
  return list;
}

List<BarcodePhone> _getBarcodePhones(dynamic json) {
  final list = <BarcodePhone>[];
  json['phones']?.forEach((phone) {
    phone['type'] = BarcodeType.phone.index;
    phone['format'] = json['format'];
    list.add(BarcodePhone.fromJson(phone));
  });
  return list;
}

List<String> _getUrls(dynamic json) {
  final list = <String>[];
  json.forEach((url) {
    list.add(url.toString());
  });
  return list;
}
