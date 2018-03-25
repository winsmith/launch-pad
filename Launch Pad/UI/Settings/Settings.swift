//
//  Settings.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 25.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public class Settings {
    static let standard = Settings()
    private static let userDefaults = UserDefaults.standard

    static var shouldDisplayDebugInformation: Bool {
        get {
            return userDefaults.bool(forKey: SettingsKeys.shouldDisplayDebugInformation.rawValue)
        }

        set(newValue) {
            userDefaults.set(newValue, forKey: SettingsKeys.shouldDisplayDebugInformation.rawValue)
        }
    }

    private enum SettingsKeys: String {
        case shouldDisplayDebugInformation = "org.breakthesystem.LaunchPad.shouldDisplayDebugInformation"
    }
}

