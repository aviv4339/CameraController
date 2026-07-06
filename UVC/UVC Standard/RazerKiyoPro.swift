//
//  RazerKiyoPro.swift
//  UVC
//
//  Razer Kiyo Pro vendor Extension Unit protocol: the extension unit GUID plus the
//  8-byte command payloads for HDR, HDR mode, field of view, autofocus mode and the
//  persist-to-camera command. Payloads verified against the open-source
//  `soyersoyer/kiyoproctrls` project.
//
//  Copyright © 2024 Itaysoft. All rights reserved.
//

import Foundation

public enum RazerFOV: Int, CaseIterable, Identifiable {
    case wide
    case medium
    case narrow

    public var id: Int { rawValue }
    public var title: String {
        switch self {
        case .wide: return "Wide"
        case .medium: return "Medium"
        case .narrow: return "Narrow"
        }
    }
}

public enum RazerHDRMode: Int, CaseIterable, Identifiable {
    case dark
    case bright

    public var id: Int { rawValue }
    public var title: String {
        switch self {
        case .dark: return "Dark"
        case .bright: return "Bright"
        }
    }
}

public enum RazerAFMode: Int, CaseIterable, Identifiable {
    case responsive
    case passive

    public var id: Int { rawValue }
    public var title: String {
        switch self {
        case .responsive: return "Responsive"
        case .passive: return "Passive"
        }
    }
}

enum RazerCommand {
    // Extension unit GUID: d0 9e e4 23 78 11 31 4f ae 52 d2 fb 8a 8d 3b 48
    static let guid: [UInt8] = [
        0xd0, 0x9e, 0xe4, 0x23, 0x78, 0x11, 0x31, 0x4f,
        0xae, 0x52, 0xd2, 0xfb, 0x8a, 0x8d, 0x3b, 0x48
    ]

    static func hdr(_ enabled: Bool) -> [[UInt8]] {
        return [[0xff, 0x02, enabled ? 0x01 : 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]]
    }

    static func hdrMode(_ mode: RazerHDRMode) -> [[UInt8]] {
        return [[0xff, 0x07, UInt8(mode.rawValue), 0x00, 0x00, 0x00, 0x00, 0x00]]
    }

    static func afMode(_ mode: RazerAFMode) -> [[UInt8]] {
        return [[0xff, 0x06, UInt8(mode.rawValue), 0x00, 0x00, 0x00, 0x00, 0x00]]
    }

    static func fov(_ fov: RazerFOV) -> [[UInt8]] {
        switch fov {
        case .wide:
            return [[0xff, 0x01, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00]]
        case .medium:
            return [[0xff, 0x01, 0x00, 0x03, 0x01, 0x00, 0x00, 0x00],
                    [0xff, 0x01, 0x01, 0x03, 0x01, 0x00, 0x00, 0x00]]
        case .narrow:
            return [[0xff, 0x01, 0x00, 0x03, 0x02, 0x00, 0x00, 0x00],
                    [0xff, 0x01, 0x01, 0x03, 0x02, 0x00, 0x00, 0x00]]
        }
    }

    // Persists the current HDR/FoV/AF configuration to the camera's non-volatile
    // memory so it survives unplug/reboot.
    static let save: [[UInt8]] = [[0xc0, 0x03, 0xa8, 0x00, 0x00, 0x00, 0x00, 0x00]]
}

// Typed Razer API over the generic extension-unit transport. Keeps all byte-level
// protocol details inside the UVC framework.
public extension UVCExtensionControl {
    @discardableResult
    func setHDR(_ enabled: Bool) -> Bool {
        return send(RazerCommand.hdr(enabled))
    }

    @discardableResult
    func setHDRMode(_ mode: RazerHDRMode) -> Bool {
        return send(RazerCommand.hdrMode(mode))
    }

    @discardableResult
    func setAFMode(_ mode: RazerAFMode) -> Bool {
        return send(RazerCommand.afMode(mode))
    }

    @discardableResult
    func setFOV(_ fov: RazerFOV) -> Bool {
        return send(RazerCommand.fov(fov))
    }

    @discardableResult
    func saveToCamera() -> Bool {
        return send(RazerCommand.save)
    }
}
