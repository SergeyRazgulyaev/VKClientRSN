//
//  LoggerExtension.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 13.07.2021.
//  Copyright © 2021 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let viewCycle = Logger(subsystem: subsystem, category: "viewCycle")
}
