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
    
//    public static func debToDylib(debPath: URL, to destination: URL) throws {
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: "/usr/bin/ar")
//        process.arguments = ["x", debPath.path]
//        process.currentDirectoryURL = destination
//        try process.run()
//        process.waitUntilExit()
//    }
//
//    public static func debToLzma(debPath: URL, to destination: URL) throws {
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: "/usr/bin/ar")
//        process.arguments = ["x", debPath.path]
//        process.currentDirectoryURL = destination
//        try process.run()
//        process.waitUntilExit()
//    }
//
//    public static func unzipLzma(debPath: URL, to destination: URL) throws {
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
//        process.arguments = ["x", debPath.path]
//        process.currentDirectoryURL = destination
//        try process.run()
//        process.waitUntilExit()
//    }

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

enum DebExtractionError: Error {
    case arExtractionFailed
    case tarExtractionFailed
    case dylibNotFound
    case fileOperationFailed(String)
}

public class DebExtractor {
    public static func debToDylib(debPath: URL, to destination: URL) throws -> String {
        // 创建临时工作目录
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        do {
            // 第一步：解压deb文件
            try extractDeb(debPath: debPath, to: tempDir)
            
            // 第二步：解压data.tar.*文件
            try extractTar(in: tempDir)
            
            // 第三步：查找并移动dylib文件
            let filename = try findAndMoveDylib(from: tempDir, to: destination)
            
            // 清理临时文件
            try FileManager.default.removeItem(at: tempDir)
            return filename
        } catch {
            // 清理临时文件
            try? FileManager.default.removeItem(at: tempDir)
            throw error
        }
    }
    
    private static func extractDeb(debPath: URL, to destination: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ar")
        process.arguments = ["x", debPath.path]
        process.currentDirectoryURL = destination
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw DebExtractionError.arExtractionFailed
        }
    }
    
    private static func extractTar(in directory: URL) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        
        // 查找data.tar.*文件
        guard let tarFile = contents.first(where: { $0.lastPathComponent.starts(with: "data.tar") }) else {
            throw DebExtractionError.fileOperationFailed("data.tar.* file not found")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
        process.arguments = ["xf", tarFile.path]
        process.currentDirectoryURL = directory
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw DebExtractionError.tarExtractionFailed
        }
    }
    
    private static func findAndMoveDylib(from sourceDir: URL, to destinationDir: URL) throws -> String {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(at: sourceDir, includingPropertiesForKeys: [.isRegularFileKey])
        var dylibFound = false
        
        while let fileURL = enumerator?.nextObject() as? URL {
            let fileExtension = fileURL.pathExtension.lowercased()
            if fileExtension == "dylib" {
                let fileName = fileURL.lastPathComponent
                let destinationURL = destinationDir.appendingPathComponent(fileName)
                
                try fileManager.copyItem(at: fileURL, to: destinationURL)
                return fileName
            }
        }
        
        if !dylibFound {
            throw DebExtractionError.dylibNotFound
        }
    }
}
