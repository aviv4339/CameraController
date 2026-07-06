//
//  StartupSettingsStore.swift
//  CameraController
//
//  Persists the last-used DeviceSettings per camera (keyed by AVCaptureDevice
//  uniqueID) so they can be re-applied on startup / reconnect. Standard UVC controls
//  are volatile and reset when a camera is unplugged, so this restores them.
//
//  Copyright © 2024 Itaysoft. All rights reserved.
//

import Foundation

enum StartupSettingsStore {
    private static let key = "startupSettings"

    private static func load() -> [String: DeviceSettings] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: DeviceSettings].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private static func store(_ dictionary: [String: DeviceSettings]) {
        if let encoded = try? JSONEncoder().encode(dictionary) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    static func settings(for uniqueID: String) -> DeviceSettings? {
        return load()[uniqueID]
    }

    static func save(_ settings: DeviceSettings, for uniqueID: String) {
        var dictionary = load()
        dictionary[uniqueID] = settings
        store(dictionary)
    }
}
