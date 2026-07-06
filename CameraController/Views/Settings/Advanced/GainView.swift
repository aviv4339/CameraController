//
//  GainView.swift
//  CameraController
//
//  Dedicated gain slider so gain can be tuned independently of the exposure mode
//  (useful for low-light adjustment while auto-exposure stays on).
//
//  Copyright © 2024 Itaysoft. All rights reserved.
//

import SwiftUI

struct GainView: View {
    @ObservedObject var gain: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.gain = controller.gain
    }

    var body: some View {
        GenericControl(value: $gain.sliderValue,
                       step: gain.resolution,
                       range: gain.minimum...gain.maximum,
                       title: "Gain",
                       imageName: "camera.aperture",
                       auto: nil)
    }
}
