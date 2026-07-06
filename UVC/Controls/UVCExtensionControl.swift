//
//  UVCExtensionControl.swift
//  UVC
//
//  Transport for UVC vendor Extension Unit (XU) commands. Unlike the standard
//  controls, an extension unit command is a raw multi-byte payload sent via
//  SET_CUR to the vendor's unit ID. Capability is determined purely by whether
//  the unit was discovered in the descriptors (GET_INFO is not reliable for XUs).
//
//  Copyright © 2024 Itaysoft. All rights reserved.
//

import Foundation

enum UVCExtensionSelector: Int, Selector {
    // Razer Kiyo Pro EU1 selectors.
    case setISP = 0x01
    case getISPResult = 0x02

    func raw() -> Int {
        return self.rawValue
    }
}

public final class UVCExtensionControl: UVCControl {
    // 8-byte command payloads.
    private static let payloadSize = 8

    init(_ interface: USBInterfacePointer, _ unitId: Int, _ interfaceId: Int) {
        super.init(interface, UVCExtensionControl.payloadSize, UVCExtensionSelector.setISP, unitId, interfaceId)
        // The unit is only ever assigned a non-negative ID when the vendor GUID matched
        // during descriptor parsing, so its mere presence means the control is usable.
        isCapable = unitId >= 0
    }

    /// Sends one or more command payloads in order. Multi-step commands (e.g. the
    /// Kiyo Pro's medium/narrow field-of-view) require two writes back-to-back.
    @discardableResult
    func send(_ payloads: [[UInt8]]) -> Bool {
        var success = true
        for payload in payloads {
            success = setRawData(payload) && success
        }
        return success
    }
}
