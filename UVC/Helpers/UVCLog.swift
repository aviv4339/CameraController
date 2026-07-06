//
//  UVCLog.swift
//  UVC
//
//  Verbose logging for USB control transfers, used to debug vendor extension
//  unit commands (e.g. the Razer Kiyo Pro) against real hardware. Off by default;
//  opt in at runtime with:
//    defaults write com.itaysoft.CameraController uvcVerboseLogging -bool YES
//
//  Copyright © 2024 Itaysoft. All rights reserved.
//

import Foundation
import os

enum UVCLog {
    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "uvcVerboseLogging")
    }

    private static let logger = Logger(subsystem: "com.itaysoft.CameraController", category: "UVC")

    static func request(selector: Int, unit: Int, interface: Int, payload: [UInt8], success: Bool) {
        guard isEnabled else { return }
        let bytes = payload.map { String(format: "%02x", $0) }.joined(separator: " ")
        logger.notice("""
            SET_CUR selector=0x\(String(selector, radix: 16), privacy: .public) \
            unit=\(unit, privacy: .public) interface=\(interface, privacy: .public) \
            payload=[\(bytes, privacy: .public)] success=\(success, privacy: .public)
            """)
    }

    static func info(_ message: String) {
        guard isEnabled else { return }
        logger.notice("\(message, privacy: .public)")
    }

    static func controlRequest(type: UInt8, selector: Int, unit: Int, interface: Int, returnCode: Int32) {
        guard isEnabled else { return }
        logger.notice("""
            CTRL req=0x\(String(type, radix: 16), privacy: .public) \
            selector=0x\(String(selector, radix: 16), privacy: .public) \
            unit=\(unit, privacy: .public) interface=\(interface, privacy: .public) \
            ioreturn=0x\(String(UInt32(bitPattern: returnCode), radix: 16), privacy: .public)
            """)
    }
}
