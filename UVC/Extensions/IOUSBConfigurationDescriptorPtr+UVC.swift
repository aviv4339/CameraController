//
//  IOUSBConfigurationDescriptorPtr+UVC.swift
//  CameraController
//
//  Created by Itay Brenner on 7/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation
import IOKit

extension IOUSBConfigurationDescriptorPtr {
    func proccessDescriptor() -> UVCDescriptor {
        var processingUnitID = -1
        var cameraTerminalID = -1
        var interfaceID = -1
        var extensionUnitID = -1

        let basePointer = UnsafeMutablePointer<UInt8>(OpaquePointer(self))
        browseDescriptor(basePointer, &processingUnitID, &cameraTerminalID, &interfaceID, &extensionUnitID)

        return UVCDescriptor(processingUnitID: processingUnitID,
                             cameraTerminalID: cameraTerminalID,
                             interfaceID: interfaceID,
                             extensionUnitID: extensionUnitID)
    }

    // Finds the VideoControl unit/terminal IDs by locating the VideoControl interface and
    // walking its class-specific descriptors.
    //
    // We cannot rely on the configuration descriptor header: on some cameras (e.g. the Razer
    // Kiyo Pro) GetConfigurationDescriptorPtr returns a buffer whose leading bytes are not a
    // clean config descriptor, so bLength / wTotalLength read as garbage that varies per
    // launch. Instead we scan a small window for the standard VideoControl interface
    // descriptor by its fixed shape (bLength 9, interface type, video class, VideoControl
    // subclass), then bound the unit walk by the VideoControl header's own wTotalLength,
    // which lives inside the real descriptor data and is reliable.
    private func browseDescriptor(_ base: UnsafeMutablePointer<UInt8>,
                                  _ processingUnitID: inout Int,
                                  _ cameraTerminalID: inout Int,
                                  _ interfaceID: inout Int,
                                  _ extensionUnitID: inout Int) {
        // Window is intentionally small (the VideoControl interface is one of the first
        // descriptors) so we never read far past the mapped descriptor buffer.
        let scanLimit = 512

        var vcInterfaceOffset = -1
        var index = 0
        while index + 9 <= scanLimit {
            let header = InterfaceDescriptorPointer(OpaquePointer(base.advanced(by: index)))
            if header.pointee.bLength == 9 && header.pointee.bDescriptorType == kUSBInterfaceDesc {
                let intDesc = UnsafeMutablePointer<IOUSBInterfaceDescriptor>(OpaquePointer(base.advanced(by: index)))
                if intDesc.pointee.bInterfaceClass == UVCConstants.classVideo
                    && intDesc.pointee.bInterfaceSubClass == UVCConstants.subclassVideoControl {
                    vcInterfaceOffset = index
                    interfaceID = Int(intDesc.pointee.bInterfaceNumber)
                    break
                }
            }
            index += 1
        }

        guard vcInterfaceOffset >= 0 else {
            return
        }

        // The class-specific VideoControl header immediately follows the 9-byte interface descriptor.
        let vcHeaderOffset = vcInterfaceOffset + 9
        let vcHeader = InterfaceDescriptorPointer(OpaquePointer(base.advanced(by: vcHeaderOffset)))
        guard vcHeader.pointee.bDescriptorType == UVCConstants.descriptorTypeInterface else {
            return
        }

        // VideoControl header wTotalLength (bytes 5..6) bounds all the unit/terminal descriptors.
        let vcTotalLength = Int(base[vcHeaderOffset + 5]) | (Int(base[vcHeaderOffset + 6]) << 8)
        let blockEnd = vcHeaderOffset + max(vcTotalLength, 9)

        var offset = vcHeaderOffset
        while offset + 3 <= blockEnd {
            let descriptorPointer = InterfaceDescriptorPointer(OpaquePointer(base.advanced(by: offset)))
            let bLength = Int(descriptorPointer.pointee.bLength)
            if bLength < 3 || offset + bLength > blockEnd {
                break
            }

            if descriptorPointer.pointee.bDescriptorType == UVCConstants.descriptorTypeInterface {
                getDeviceId(descriptorPointer, base.advanced(by: offset), bLength,
                            &processingUnitID, &cameraTerminalID, &extensionUnitID)
            }

            offset += bLength
        }
    }

    private func getDeviceId(_ descriptorPointer: InterfaceDescriptorPointer,
                             _ currentPointer: UnsafeMutablePointer<UInt8>,
                             _ bLength: Int,
                             _ processingUnitID: inout Int,
                             _ cameraTerminalID: inout Int,
                             _ extensionUnitID: inout Int) {
        let unitType = UVCConstants.DescriptorSubtype(rawValue: descriptorPointer.pointee.bDescriptorSubType)
        switch unitType {
        case .processingUnit:
            let puPointer = ProcessingUnitDescriptorPointer(OpaquePointer(currentPointer))
            processingUnitID = Int(puPointer.pointee.bUnitID)
        case .inputTerminal:
            let ctPointer = CameraTerminalDescriptorPointer(OpaquePointer(currentPointer))
            cameraTerminalID = Int(ctPointer.pointee.bTerminalID)
        case .extensionUnit:
            // VC_EXTENSION_UNIT layout: bUnitID at offset 3, guidExtensionCode (16 bytes) at offset 4.
            // Only capture the unit ID when the GUID matches the Razer Kiyo Pro extension unit.
            guard bLength >= 4 + RazerCommand.guid.count else {
                break
            }
            var guid = [UInt8](repeating: 0, count: RazerCommand.guid.count)
            for index in 0..<guid.count {
                guid[index] = currentPointer[4 + index]
            }
            if guid == RazerCommand.guid {
                extensionUnitID = Int(currentPointer[3])
            }
        case .none:
            break
        case .selectorUnit:
            break
        }
    }
}
