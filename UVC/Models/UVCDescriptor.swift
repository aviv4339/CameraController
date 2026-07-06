//
//  UVCDescriptor.swift
//  CameraController
//
//  Created by Itay Brenner on 7/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

struct UVCDescriptor {
    let processingUnitID: Int
    let cameraTerminalID: Int
    let interfaceID: Int
    // Unit ID of the Razer Kiyo Pro vendor extension unit, or -1 if not present.
    let extensionUnitID: Int
}
