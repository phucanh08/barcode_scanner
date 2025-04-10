class Leg {
  String? operatingCarrierPNR;
  String? departureAirport;
  String? arrivalAirport;
  String? operatingCarrierDesignator;
  String? flightNumber;
  DateTime? flightDate;
  String? compartmentCode;
  String? seatNumber;
  String? checkInSequenceNumber;
  String? passengerStatus;
  String? airlineNumericCode;
  String? serialNumber;
  String? selecteeIndicator;
  String? internationalDocumentationVerification;
  String? marketingCarrierDesignator;
  String? frequentFlyerAirlineDesignator;
  String? frequentFlyerNumber;
  String? idIndicator;
  String? freeBaggageAllowance;
  bool? fastTrack;
  String? airlineInfo;

  Leg({
    this.operatingCarrierPNR,
    this.departureAirport,
    this.arrivalAirport,
    this.operatingCarrierDesignator,
    this.flightNumber,
    this.flightDate,
    this.compartmentCode,
    this.seatNumber,
    this.checkInSequenceNumber,
    this.passengerStatus,
    this.airlineNumericCode,
    this.serialNumber,
    this.selecteeIndicator,
    this.internationalDocumentationVerification,
    this.marketingCarrierDesignator,
    this.frequentFlyerAirlineDesignator,
    this.frequentFlyerNumber,
    this.idIndicator,
    this.freeBaggageAllowance,
    this.fastTrack,
    this.airlineInfo,
  });
}

class BoardingPassData {
  List<Leg>? legs;
  String? passengerName;
  String? passengerDescription;
  String? checkInSource;
  String? boardingPassIssuanceSource;
  DateTime? issuanceDate;
  String? documentType;
  String? boardingPassIssuerDesignator;
  String? baggageTagNumber;
  String? firstBaggageTagNumber;
  String? secondBaggageTagNumber;
  String? securityDataType;
  String? securityData;

  BoardingPassData({
    this.legs,
    this.passengerName,
    this.passengerDescription,
    this.checkInSource,
    this.boardingPassIssuanceSource,
    this.issuanceDate,
    this.documentType,
    this.boardingPassIssuerDesignator,
    this.baggageTagNumber,
    this.firstBaggageTagNumber,
    this.secondBaggageTagNumber,
    this.securityDataType,
    this.securityData,
  });
}

class BoardingPassMetaData {
  String? formatCode;
  int? numberOfLegs;
  String? electronicTicketIndicator;
  String? versionNumberIndicator;
  int? versionNumber;
  String? securityDataIndicator;

  BoardingPassMetaData({
    this.formatCode,
    this.numberOfLegs,
    this.electronicTicketIndicator,
    this.versionNumberIndicator,
    this.versionNumber,
    this.securityDataIndicator,
  });
}

class BarcodedBoardingPass {
  BoardingPassData? data;
  BoardingPassMetaData? meta;

  BarcodedBoardingPass({
    this.data,
    this.meta,
  });
}
