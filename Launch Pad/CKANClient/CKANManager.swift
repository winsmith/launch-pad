//
//  CKAN.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 22.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public class CKANManager {
    // MARK: - Notifications
    static let allModulesUpdatedNotification = Notification.Name("allModulesUpdated")
    static let singleModuleUpdatedNotification = Notification.Name("singleModuleUpdated")

    // MARK: - Properties
    // MARK: Public
    public var notificationCenter = NotificationCenter.default

    public private(set) var modules = [Module]() {
        didSet {
            guard modules != oldValue else { return }
            postAllModulesUpdatedNotification()
        }
    }

    // MARK: Private

    // MARK: - Init
    init(baseURL: String) {
        refreshModules()
    }

    // MARK: - Refreshments
    public func refreshModules() {
    }

    // MARK: - Notifications
    private func postAllModulesUpdatedNotification() {
        notificationCenter.post(name: CKANManager.allModulesUpdatedNotification, object: self)
    }

    private func postSingleModuleUpdate(_ module: Module) {
        notificationCenter.post(name: CKANManager.singleModuleUpdatedNotification, object: self, userInfo: ["key": module.key])
    }

    // MARK: - Filtering
    public func modulesFilteredBy(_ searchString: String) -> [Module] {
        return modules.filter { $0.name.lowercased().range(of:searchString.lowercased()) != nil }
    }

    // MARK: - Installing, Upgrading and Uninstalling
    
}
