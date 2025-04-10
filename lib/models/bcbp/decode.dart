import 'type.dart';
import 'field_lengths.dart';
import 'utils.dart';

class SectionDecoder {
  String? barcodeString;
  int currentIndex = 0;

  SectionDecoder(this.barcodeString);

  String? _getNextField(int? length) {
    if (barcodeString == null) {
      return null;
    }

    final barcodeLength = barcodeString!.length;
    if (currentIndex >= barcodeLength) {
      return null;
    }

    String? value;
    final start = currentIndex;
    if (length == null) {
      value = barcodeString!.substring(start);
    } else {
      value = barcodeString!.substring(start, start + length <= barcodeLength ? start + length : barcodeLength);
    }

    currentIndex += length ?? barcodeLength;
    final trimmedValue = value.trimRight();
    if (trimmedValue.isEmpty) {
      return null;
    }
    return trimmedValue;
  }

  String? getNextString(int length) {
    return _getNextField(length);
  }

  int? getNextNumber(int length) {
    final value = _getNextField(length);
    if (value == null) {
      return null;
    }
    return int.tryParse(value);
  }

  DateTime? getNextDate(int length, bool hasYearPrefix, {int? referenceYear}) {
    final value = _getNextField(length);
    if (value == null || value.contains(RegExp(r'\D'))) {
      return null;
    }
    return dayOfYearToDate(value, hasYearPrefix, referenceYear: referenceYear);
  }

  bool? getNextBoolean() {
    final value = _getNextField(1);
    if (value == null) {
      return null;
    }
    return value == "Y";
  }

  int getNextSectionSize() {
    return hexToNumber(_getNextField(2) ?? "00");
  }

  String? getRemainingString() {
    return _getNextField(null);
  }
}

BarcodedBoardingPass decode(String barcodeString, {int? referenceYear}) {
  final bcbp = BarcodedBoardingPass(
    data: BoardingPassData(),
    meta: BoardingPassMetaData(),
  );

  final mainSection = SectionDecoder(barcodeString);

  bcbp.meta!.formatCode = mainSection.getNextString(FieldLengths.FORMAT_CODE);
  bcbp.meta!.numberOfLegs = mainSection.getNextNumber(FieldLengths.NUMBER_OF_LEGS) ?? 0;
  bcbp.data!.passengerName = mainSection.getNextString(FieldLengths.PASSENGER_NAME);
  bcbp.meta!.electronicTicketIndicator = mainSection.getNextString(FieldLengths.ELECTRONIC_TICKET_INDICATOR);

  List<Leg> legs = [];
  bcbp.data!.legs = legs;

  bool addedUniqueFields = false;

  for (int legIndex = 0; legIndex < bcbp.meta!.numberOfLegs!; legIndex++) {
    final leg = Leg(
      operatingCarrierPNR: mainSection.getNextString(FieldLengths.OPERATING_CARRIER_PNR),
      departureAirport: mainSection.getNextString(FieldLengths.DEPARTURE_AIRPORT),
      arrivalAirport: mainSection.getNextString(FieldLengths.ARRIVAL_AIRPORT),
      operatingCarrierDesignator: mainSection.getNextString(FieldLengths.OPERATING_CARRIER_DESIGNATOR),
      flightNumber: mainSection.getNextString(FieldLengths.FLIGHT_NUMBER),
      flightDate: mainSection.getNextDate(
          FieldLengths.FLIGHT_DATE,
          false,
          referenceYear: referenceYear
      ),
      compartmentCode: mainSection.getNextString(FieldLengths.COMPARTMENT_CODE),
      seatNumber: mainSection.getNextString(FieldLengths.SEAT_NUMBER),
      checkInSequenceNumber: mainSection.getNextString(FieldLengths.CHECK_IN_SEQUENCE_NUMBER),
      passengerStatus: mainSection.getNextString(FieldLengths.PASSENGER_STATUS),
    );

    final conditionalSectionSize = mainSection.getNextSectionSize();
    final conditionalSection = SectionDecoder(
      mainSection.getNextString(conditionalSectionSize),
    );

    if (!addedUniqueFields) {
      bcbp.meta!.versionNumberIndicator = conditionalSection.getNextString(
          FieldLengths.VERSION_NUMBER_INDICATOR
      );
      bcbp.meta!.versionNumber = conditionalSection.getNextNumber(
          FieldLengths.VERSION_NUMBER
      );

      final sectionASize = conditionalSection.getNextSectionSize();
      final sectionA = SectionDecoder(
          conditionalSection.getNextString(sectionASize)
      );
      bcbp.data!.passengerDescription = sectionA.getNextString(
          FieldLengths.PASSENGER_DESCRIPTION
      );
      bcbp.data!.checkInSource = sectionA.getNextString(
          FieldLengths.CHECK_IN_SOURCE
      );
      bcbp.data!.boardingPassIssuanceSource = sectionA.getNextString(
          FieldLengths.BOARDING_PASS_ISSUANCE_SOURCE
      );
      bcbp.data!.issuanceDate = sectionA.getNextDate(
          FieldLengths.ISSUANCE_DATE,
          true,
          referenceYear: referenceYear
      );
      bcbp.data!.documentType = sectionA.getNextString(
          FieldLengths.DOCUMENT_TYPE
      );
      bcbp.data!.boardingPassIssuerDesignator = sectionA.getNextString(
          FieldLengths.BOARDING_PASS_ISSUER_DESIGNATOR
      );
      bcbp.data!.baggageTagNumber = sectionA.getNextString(
          FieldLengths.BAGGAGE_TAG_NUMBER
      );
      bcbp.data!.firstBaggageTagNumber = sectionA.getNextString(
          FieldLengths.FIRST_BAGGAGE_TAG_NUMBER
      );
      bcbp.data!.secondBaggageTagNumber = sectionA.getNextString(
          FieldLengths.SECOND_BAGGAGE_TAG_NUMBER
      );

      addedUniqueFields = true;
    }

    final sectionBSize = conditionalSection.getNextSectionSize();
    final sectionB = SectionDecoder(
        conditionalSection.getNextString(sectionBSize)
    );

    // Cập nhật các trường trong leg từ sectionB
    final updatedLeg = Leg(
      operatingCarrierPNR: leg.operatingCarrierPNR,
      departureAirport: leg.departureAirport,
      arrivalAirport: leg.arrivalAirport,
      operatingCarrierDesignator: leg.operatingCarrierDesignator,
      flightNumber: leg.flightNumber,
      flightDate: leg.flightDate,
      compartmentCode: leg.compartmentCode,
      seatNumber: leg.seatNumber,
      checkInSequenceNumber: leg.checkInSequenceNumber,
      passengerStatus: leg.passengerStatus,
      airlineNumericCode: sectionB.getNextString(FieldLengths.AIRLINE_NUMERIC_CODE),
      serialNumber: sectionB.getNextString(FieldLengths.SERIAL_NUMBER),
      selecteeIndicator: sectionB.getNextString(FieldLengths.SELECTEE_INDICATOR),
      internationalDocumentationVerification: sectionB.getNextString(
          FieldLengths.INTERNATIONAL_DOCUMENTATION_VERIFICATION
      ),
      marketingCarrierDesignator: sectionB.getNextString(
          FieldLengths.MARKETING_CARRIER_DESIGNATOR
      ),
      frequentFlyerAirlineDesignator: sectionB.getNextString(
          FieldLengths.FREQUENT_FLYER_AIRLINE_DESIGNATOR
      ),
      frequentFlyerNumber: sectionB.getNextString(
          FieldLengths.FREQUENT_FLYER_NUMBER
      ),
      idIndicator: sectionB.getNextString(FieldLengths.ID_INDICATOR),
      freeBaggageAllowance: sectionB.getNextString(
          FieldLengths.FREE_BAGGAGE_ALLOWANCE
      ),
      fastTrack: sectionB.getNextBoolean(),
      airlineInfo: conditionalSection.getRemainingString(),
    );

    bcbp.data!.legs!.add(updatedLeg);
  }

  bcbp.meta!.securityDataIndicator = mainSection.getNextString(
      FieldLengths.SECURITY_DATA_INDICATOR
  );
  bcbp.data!.securityDataType = mainSection.getNextString(
      FieldLengths.SECURITY_DATA_TYPE
  );

  final securitySectionSize = mainSection.getNextSectionSize();
  final securitySection = SectionDecoder(
      mainSection.getNextString(securitySectionSize)
  );
  bcbp.data!.securityData = securitySection.getNextString(FieldLengths.SECURITY_DATA);

  if (bcbp.data!.issuanceDate != null) {
    final issuanceYear = bcbp.data!.issuanceDate!.year;
    for (Leg leg in bcbp.data!.legs!) {
      if (leg.flightDate != null) {
        final dayOfYear = dateToDayOfYear(leg.flightDate!);
        DateTime updatedFlightDate = dayOfYearToDate(dayOfYear, false, referenceYear: issuanceYear);
        if (updatedFlightDate.isBefore(bcbp.data!.issuanceDate!)) {
          updatedFlightDate = dayOfYearToDate(dayOfYear, false, referenceYear: issuanceYear + 1);
        }

        // Cập nhật leg với ngày bay mới
        final index = bcbp.data!.legs!.indexOf(leg);
        bcbp.data!.legs![index] = Leg(
          operatingCarrierPNR: leg.operatingCarrierPNR,
          departureAirport: leg.departureAirport,
          arrivalAirport: leg.arrivalAirport,
          operatingCarrierDesignator: leg.operatingCarrierDesignator,
          flightNumber: leg.flightNumber,
          flightDate: updatedFlightDate,
          compartmentCode: leg.compartmentCode,
          seatNumber: leg.seatNumber,
          checkInSequenceNumber: leg.checkInSequenceNumber,
          passengerStatus: leg.passengerStatus,
          airlineNumericCode: leg.airlineNumericCode,
          serialNumber: leg.serialNumber,
          selecteeIndicator: leg.selecteeIndicator,
          internationalDocumentationVerification: leg.internationalDocumentationVerification,
          marketingCarrierDesignator: leg.marketingCarrierDesignator,
          frequentFlyerAirlineDesignator: leg.frequentFlyerAirlineDesignator,
          frequentFlyerNumber: leg.frequentFlyerNumber,
          idIndicator: leg.idIndicator,
          freeBaggageAllowance: leg.freeBaggageAllowance,
          fastTrack: leg.fastTrack,
          airlineInfo: leg.airlineInfo,
        );
      }
    }
  }

  return bcbp;
}
