//
//  BarcodeScannerViewControllerDelegate.swift
//  Pods
//
//  Created by TTGP-oaidq-mac on 31/3/25.
//

import Foundation

protocol BarcodeScannerViewControllerDelegate {
    func didScanBarcodeWithResult(_ controller: BarcodeScannerViewController?,
                                  scanResult: ScanResult
    )
    
    func didFailWithErrorCode(_ controller: BarcodeScannerViewController?,
                              errorCode: String
    )
}
