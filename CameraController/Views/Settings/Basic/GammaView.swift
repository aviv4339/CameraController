//
//  GammaView.swift
//  CameraController
//
//  Copyright © 2024 Itaysoft. All rights reserved.
//

import SwiftUI

struct GammaView: View {
    @ObservedObject var gamma: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.gamma = controller.gamma
    }

    var body: some View {
        GenericControl(value: $gamma.sliderValue,
                       step: gamma.resolution,
                       range: gamma.minimum...gamma.maximum,
                       title: "Gamma",
                       imageName: "circle.lefthalf.filled",
                       auto: nil)
    }
}
