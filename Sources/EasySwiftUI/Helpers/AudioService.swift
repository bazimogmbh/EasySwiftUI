//
//  AudioService.swift
//
//
//  Created by Jenya Korsun on 20.09.2024.
//

import AVFoundation

public final class AudioService {
    public static func playSystemSound(_ id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}
