//
//  EmojiCaptureTests.swift
//  EmojiCaptureTests
//
//  Created by Kosuke Katsuki on 1/27/17.
//  Copyright © 2017 Kosuke Katsuki. All rights reserved.
//

import XCTest

class EmojiCaptureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCalculateDimensions() {
        // Alphabets
        XCTAssert((rows: 1, halfColumns: 0) == calculateDimensions(""))
        XCTAssert((rows: 1, halfColumns: 1) == calculateDimensions("a"))
        XCTAssert((rows: 1, halfColumns: 3) == calculateDimensions("abc"))
        
        // Multiple lines
        XCTAssert((rows: 2, halfColumns: 3) == calculateDimensions("abc\nd"))
        XCTAssert((rows: 3, halfColumns: 4) == calculateDimensions("abc\nd\nefgh"))
        XCTAssert((rows: 3, halfColumns: 5) == calculateDimensions("abc\ndefgh\nij"))
        
        // Emojis 1
        XCTAssert((rows: 1, halfColumns: 2) == calculateDimensions("😀"))
        XCTAssert((rows: 1, halfColumns: 2) == calculateDimensions("⌚"))
        XCTAssert((rows: 1, halfColumns: 2) == calculateDimensions("🇨🇦"))
        XCTAssert((rows: 1, halfColumns: 4) == calculateDimensions("😀🇨🇦"))
        XCTAssert((rows: 1, halfColumns: 7) == calculateDimensions("😀.🇨🇦.."))
        
        // Emojis 2
        XCTAssert((rows: 1, halfColumns: 2) == calculateDimensions("👮🏽"))
        XCTAssert((rows: 1, halfColumns: 2) == calculateDimensions("☝🏾"))
        XCTAssert((rows: 1, halfColumns: 4) == calculateDimensions("☝🏾👮🏽"))
        XCTAssert((rows: 1, halfColumns: 7) == calculateDimensions("☝🏾.👮🏽.."))

        // Emojis 3 (v4)
        XCTAssert((rows: 1, halfColumns: 2) == calculateDimensions("👩🏽"))
    }
    
    func checkEmoji(_ text: String) {
        var index = text.startIndex
        while index < text.endIndex {
            let range = text.rangeOfComposedCharacterSequence(at: index)
            let s = text.substring(with: range)
            XCTAssertTrue(s.isEmoji(), s)
            index = range.upperBound
        }
    }
    
    func testIsEmoji() {
        checkEmoji(EmojiSet.activity)
        checkEmoji(EmojiSet.animalsAndNature)
        checkEmoji(EmojiSet.flags)
        checkEmoji(EmojiSet.foodAndDrink)
        checkEmoji(EmojiSet.objects)
        checkEmoji(EmojiSet.smileyAndPeople)
        checkEmoji(EmojiSet.symbols)
        checkEmoji(EmojiSet.travelAndPlaces)
        XCTAssertFalse("あ".isEmoji())
        XCTAssertFalse("鬼".isEmoji())
        XCTAssertFalse("A".isEmoji())
    }
}
