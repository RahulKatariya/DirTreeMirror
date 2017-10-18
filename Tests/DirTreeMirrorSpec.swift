//
//  DirTreeMirrorSpec.swift
//  DirTreeMirror
//
//  Created by Rahul Katariya on 14/10/17.
//  Copyright © 2017 RahulKatariya. All rights reserved.
//

import Quick
import Nimble
@testable import DirTreeMirror

class DirTreeMirrorSpec: QuickSpec {
    
    override func spec() {
        
        let baseUrl = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Developer/RahulKatariya/DirTreeMirror/Tests/Fixtures")
        let sourceUrl = baseUrl.appendingPathComponent("Source", isDirectory: true)
        let destinationUrl = baseUrl.appendingPathComponent("Destination", isDirectory: true)
        let dirTreeMirror = DirTreeMirror(sourceUrl: sourceUrl, destinationUrl: destinationUrl)
        
        var directories: [String] {
            return ["Directory", "Directory/SubDirectory", "Directory/SubDirectory2", "Directory2/SubDirectory"]
        }
        
        var files: [String] {
            return ["Directory/Podfile", "Directory/SubDirectory/Cartfile", "Directory/SubDirectory/Cartfile.private", "Directory/SubDirectory/Cartfile.resolved"]
        }
        
        beforeSuite {
            try? FileManager.default.removeItem(at: baseUrl)
            directories.forEach {
                let url = sourceUrl.appendingPathComponent($0, isDirectory: true)
                try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            files.forEach {
                let url = sourceUrl.appendingPathComponent($0)
                FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
            }
        }
        
        describe("DirTreeMirror") {
            
            it("create files") {
                dirTreeMirror.bootstrap { _, destinationUrl in
                    let success = FileManager.default.createFile(atPath: destinationUrl.path, contents: nil, attributes: nil)
                    if !success { fatalError("Couldn't create file at path \(destinationUrl.path)") }
                }
                var flag = directories.reduce(true) {
                    let url = destinationUrl.appendingPathComponent($1, isDirectory: true)
                    return FileManager.default.fileExists(atPath: url.path) && url.hasDirectoryPath && $0
                }
                flag = files.reduce(flag) {
                    let url = destinationUrl.appendingPathComponent($1, isDirectory: false)
                    return FileManager.default.fileExists(atPath: url.path) && !url.hasDirectoryPath && $0
                }
                expect(flag).to(beTruthy())
            }
            
        }
        
    }
    
}
