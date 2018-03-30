//
//  MainTest.swift
//  EmojiCapture
//
//  Created by Kosuke Katsuki on 1/30/17.
//  Copyright © 2017 Kosuke Katsuki. All rights reserved.
//

import XCTest

class MainTest: XCTestCase {
    
    var testDir: String = ""
    
    override func setUp() {
        super.setUp()
        testDir = ProcessInfo.processInfo.environment["TMPDIR"]!
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCapture() {
        let fontPath = "" //Specify path to external emoji font
        let font: NSFont? = {
            if fontPath != "" {
            let url = Foundation.URL(fileURLWithPath: fontPath)
                return loadFont(from: url, in: 48)
            }
            return nil
        }()
        let call : (String, String) -> Void = {
            let file = self.testDir + "/" + $1
            capture($0, to: URL(fileURLWithPath: file),
                        with: (48, 40), //(48, 40), (24, 20)
                        using: font)
            NSWorkspace.shared.openFile(file)
        }
        call("🔌", "test0.png")
        //call("😀_--aあ＃あ＃a-+", "test1.png")
        //call("🌚三三   ✋🏽👮🏽👾💦三", "test2.png")
        //call("📴    📱      📱\n"
        //    + "🙅🏻     👋🏽👮🏽    👋🏽👾", "test3.png")
        //call("╋　┏\n"
        //    + "╋━┛", "test4.png")
        //call("✌️","peace1.png")
        //call("✌🏽🌚","peace2.png")
    }
}
