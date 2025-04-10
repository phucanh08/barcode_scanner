import 'type.dart';
import 'utils.dart';
import 'field_lengths.dart';

class FieldSize {
  final int size;
  final bool isDefined;

  FieldSize({required this.size, required this.isDefined});
}

class SectionBuilder {
  List<String> output = [];
  List<FieldSize> fieldSizes = [];

  void addField(
      dynamic field, [
        int? length,
        bool addYearPrefix = false,
      ]) {
    String value = "";

    if (field == null) {
      value = "";
    } else if (field is int) {
      value = field.toString();
    } else if (field is DateTime) {
      value = dateToDayOfYear(field, addYearPrefix: addYearPrefix);
    } else if (field is bool) {
      value = field ? "Y" : "N";
    } else {
      value = field.toString();
    }

    int valueLength = value.length;

    if (length != null) {
      if (valueLength > length) {
        value = value.substring(0, length);
      } else if (valueLength < length) {
        value = value.padRight(length);
      }
    }

    output.add(value);

    fieldSizes.add(FieldSize(
      size: length ?? value.length,
      isDefined: field != null,
    ));
  }

  void addSection(SectionBuilder section) {
    final sectionString = section.toString();

    bool foundLastValue = false;
    int sectionLength = 0;

    for (int i = section.fieldSizes.length - 1; i >= 0; i--) {
      final fieldSize = section.fieldSizes[i];
      if (!foundLastValue && fieldSize.isDefined) {
        foundLastValue = true;
      }

      if (foundLastValue) {
        sectionLength += fieldSize.size;
      }
    }

    addField(numberToHex(sectionLength), 2);
    addField(sectionString, sectionLength);
  }

  @override
  String toString() {
    return output.join("");
  }
}

String encode(BarcodedBoardingPass bcbp) {
  if (bcbp.meta != null) {
    bcbp.meta!.formatCode ??= "M";
    bcbp.meta!.numberOfLegs ??= bcbp.data?.legs?.length ?? 0;
    // bcbp.meta!.electronicTicketIndicator ??= "E";
    bcbp.meta!.versionNumberIndicator ??= ">";
    bcbp.meta!.versionNumber ??= 1;
    // bcbp.meta!.securityDataIndicator ??= "^";
  }

  final barcodeData = SectionBuilder();
  if (bcbp.data?.legs == null || bcbp.data!.legs!.isEmpty) {
    return "";
  }

  barcodeData.addField(bcbp.meta?.formatCode, FieldLengths.FORMAT_CODE);
  barcodeData.addField(bcbp.meta?.numberOfLegs, FieldLengths.NUMBER_OF_LEGS);
  barcodeData.addField(bcbp.data?.passengerName, FieldLengths.PASSENGER_NAME);
  barcodeData.addField(
    bcbp.meta?.electronicTicketIndicator,
    FieldLengths.ELECTRONIC_TICKET_INDICATOR,
  );

  bool addedUniqueFields = false;

  for (var leg in bcbp.data!.legs!) {
    barcodeData.addField(
      leg.operatingCarrierPNR,
      FieldLengths.OPERATING_CARRIER_PNR,
    );
    barcodeData.addField(leg.departureAirport, FieldLengths.DEPARTURE_AIRPORT);
    barcodeData.addField(leg.arrivalAirport, FieldLengths.ARRIVAL_AIRPORT);
    barcodeData.addField(
      leg.operatingCarrierDesignator,
      FieldLengths.OPERATING_CARRIER_DESIGNATOR,
    );
    barcodeData.addField(leg.flightNumber, FieldLengths.FLIGHT_NUMBER);
    barcodeData.addField(leg.flightDate, FieldLengths.FLIGHT_DATE);
    barcodeData.addField(leg.compartmentCode, FieldLengths.COMPARTMENT_CODE);
    barcodeData.addField(leg.seatNumber, FieldLengths.SEAT_NUMBER);
    barcodeData.addField(
      leg.checkInSequenceNumber,
      FieldLengths.CHECK_IN_SEQUENCE_NUMBER,
    );
    barcodeData.addField(leg.passengerStatus, FieldLengths.PASSENGER_STATUS);

    final conditionalSection = SectionBuilder();

    if (!addedUniqueFields) {
      conditionalSection.addField(
        bcbp.meta?.versionNumberIndicator,
        FieldLengths.VERSION_NUMBER_INDICATOR,
      );
      conditionalSection.addField(
        bcbp.meta?.versionNumber,
        FieldLengths.VERSION_NUMBER,
      );

      final sectionA = SectionBuilder();
      sectionA.addField(
        bcbp.data?.passengerDescription,
        FieldLengths.PASSENGER_DESCRIPTION,
      );
      sectionA.addField(
        bcbp.data?.checkInSource,
        FieldLengths.CHECK_IN_SOURCE,
      );
      sectionA.addField(
        bcbp.data?.boardingPassIssuanceSource,
        FieldLengths.BOARDING_PASS_ISSUANCE_SOURCE,
      );
      sectionA.addField(
        bcbp.data?.issuanceDate,
        FieldLengths.ISSUANCE_DATE,
        true,
      );
      sectionA.addField(
        bcbp.data?.documentType,
        FieldLengths.DOCUMENT_TYPE,
      );
      sectionA.addField(
        bcbp.data?.boardingPassIssuerDesignator,
        FieldLengths.BOARDING_PASS_ISSUER_DESIGNATOR,
      );
      sectionA.addField(
        bcbp.data?.baggageTagNumber,
        FieldLengths.BAGGAGE_TAG_NUMBER,
      );
      sectionA.addField(
        bcbp.data?.firstBaggageTagNumber,
        FieldLengths.FIRST_BAGGAGE_TAG_NUMBER,
      );
      sectionA.addField(
        bcbp.data?.secondBaggageTagNumber,
        FieldLengths.SECOND_BAGGAGE_TAG_NUMBER,
      );

      conditionalSection.addSection(sectionA);
      addedUniqueFields = true;
    }

    final sectionB = SectionBuilder();
    sectionB.addField(
      leg.airlineNumericCode,
      FieldLengths.AIRLINE_NUMERIC_CODE,
    );
    sectionB.addField(leg.serialNumber, FieldLengths.SERIAL_NUMBER);
    sectionB.addField(leg.selecteeIndicator, FieldLengths.SELECTEE_INDICATOR);
    sectionB.addField(
      leg.internationalDocumentationVerification,
      FieldLengths.INTERNATIONAL_DOCUMENTATION_VERIFICATION,
    );
    sectionB.addField(
      leg.marketingCarrierDesignator,
      FieldLengths.MARKETING_CARRIER_DESIGNATOR,
    );
    sectionB.addField(
      leg.frequentFlyerAirlineDesignator,
      FieldLengths.FREQUENT_FLYER_AIRLINE_DESIGNATOR,
    );
    sectionB.addField(
      leg.frequentFlyerNumber,
      FieldLengths.FREQUENT_FLYER_NUMBER,
    );
    sectionB.addField(leg.idIndicator, FieldLengths.ID_INDICATOR);
    sectionB.addField(
      leg.freeBaggageAllowance,
      FieldLengths.FREE_BAGGAGE_ALLOWANCE,
    );
    sectionB.addField(leg.fastTrack, FieldLengths.FAST_TRACK);
    conditionalSection.addSection(sectionB);
    conditionalSection.addField(leg.airlineInfo);
    barcodeData.addSection(conditionalSection);
  }

  if (bcbp.data?.securityData != null) {
    barcodeData.addField(
      bcbp.meta?.securityDataIndicator,
      FieldLengths.SECURITY_DATA_INDICATOR,
    );
    barcodeData.addField(
      bcbp.data?.securityDataType ?? "1",
      FieldLengths.SECURITY_DATA_TYPE,
    );
    final securitySection = SectionBuilder();
    securitySection.addField(
      bcbp.data?.securityData,
      FieldLengths.SECURITY_DATA,
    );
    barcodeData.addSection(securitySection);
  }

  return barcodeData.toString();
}