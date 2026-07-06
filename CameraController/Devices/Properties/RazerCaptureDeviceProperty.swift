//
//  RazerCaptureDeviceProperty.swift
//  CameraController
//
//  Observable wrapper around the Razer Kiyo Pro extension unit. Setting any
//  published value fires the matching vendor command on a background task, mirroring
//  the other *CaptureDeviceProperty wrappers. Extension unit commands are write-only
//  (the camera doesn't report the current value back), so state is tracked locally.
//
//  Copyright © 2024 Itaysoft. All rights reserved.
//

import Foundation
import Combine
import UVC

final class RazerCaptureDeviceProperty: ObservableObject {
    private let control: UVCExtensionControl

    let isCapable: Bool

    @Published var hdrEnabled: Bool {
        didSet {
            guard !isApplying else { return }
            Task { control.setHDR(hdrEnabled) }
        }
    }

    @Published var hdrMode: RazerHDRMode {
        didSet {
            guard !isApplying else { return }
            Task { control.setHDRMode(hdrMode) }
        }
    }

    @Published var fov: RazerFOV {
        didSet {
            guard !isApplying else { return }
            Task { control.setFOV(fov) }
        }
    }

    @Published var afMode: RazerAFMode {
        didSet {
            guard !isApplying else { return }
            Task { control.setAFMode(afMode) }
        }
    }

    // Suppresses command sending while values are being restored programmatically
    // (profiles / apply-on-startup), which then applies them explicitly via `apply()`.
    private var isApplying = false

    init(_ control: UVCExtensionControl) {
        self.control = control
        self.isCapable = control.isCapable
        // Sensible defaults; the camera doesn't expose the current XU state to read back.
        self.hdrEnabled = false
        self.hdrMode = .dark
        self.fov = .wide
        self.afMode = .responsive
    }

    /// Writes the current values to the camera in one shot, without relying on the
    /// per-property didSet handlers.
    func apply() {
        Task {
            control.setHDR(hdrEnabled)
            control.setHDRMode(hdrMode)
            control.setFOV(fov)
            control.setAFMode(afMode)
        }
    }

    /// Persists the current HDR/FoV/AF configuration to the camera's non-volatile memory.
    func saveToCamera() {
        Task { control.saveToCamera() }
    }

    func set(hdr: Bool, hdrMode: RazerHDRMode, fov: RazerFOV, afMode: RazerAFMode) {
        isApplying = true
        self.hdrEnabled = hdr
        self.hdrMode = hdrMode
        self.fov = fov
        self.afMode = afMode
        isApplying = false
        apply()
    }
}
