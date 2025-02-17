//
//  Utils.swift
//  InjectiPA
//
//  Created by TrialMacApp on 2025-02-17.
//

import SwiftUI

class Utils {
    public static func unzipIPA(ipaPath: URL, to destination: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", ipaPath.path, "-d", destination.path]
        try process.run()
        process.waitUntilExit()
    }

    public static func zipFolder(sourceURL: URL, to destinationURL: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.arguments = ["-r", destinationURL.path, "."]
        process.currentDirectoryURL = sourceURL
        try process.run()
        process.waitUntilExit()
    }

    public static func getExecutableName(_ appPath: String) -> String? {
        let infoPlistPath = "\(appPath)/Info.plist"
        let url = URL(fileURLWithPath: infoPlistPath)

        guard let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let executableName = plist["CFBundleExecutable"] as? String
        else {
            return nil
        }

        return executableName
    }
}
