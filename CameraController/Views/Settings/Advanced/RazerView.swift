//
//  RazerView.swift
//  CameraController
//
//  Razer Kiyo Pro vendor controls: HDR, HDR mode, field of view and autofocus mode,
//  plus a button to persist them to the camera's non-volatile memory.
//
//  Copyright © 2024 Itaysoft. All rights reserved.
//

import SwiftUI
import UVC

struct RazerView: View {
    @ObservedObject var razer: RazerCaptureDeviceProperty

    init(razer: RazerCaptureDeviceProperty) {
        self.razer = razer
    }

    var body: some View {
        SectionView {
            SectionTitle(title: "Razer Kiyo Pro",
                         image: Image(systemName: "sparkles")) {
                if razer.hdrEnabled {
                    AutoBadge()
                        .transition(.opacity)
                }
            }

            HStack {
                Text("HDR")
                    .fontWeight(.heavy)
                Spacer()
                Toggle(isOn: $razer.hdrEnabled)
            }

            if razer.hdrEnabled {
                Picker("HDR Mode", selection: $razer.hdrMode) {
                    ForEach(RazerHDRMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Picker("Field of View", selection: $razer.fov) {
                ForEach(RazerFOV.allCases) { fov in
                    Text(fov.title).tag(fov)
                }
            }
            .pickerStyle(.segmented)

            Picker("Autofocus", selection: $razer.afMode) {
                ForEach(RazerAFMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Spacer()
                Button("Save to Camera") {
                    razer.saveToCamera()
                }
                .help("Persist HDR / Field of View / Autofocus to the camera so they survive unplug and reboot.")
            }
        }
    }
}
