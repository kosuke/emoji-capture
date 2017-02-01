//
//  main.swift
//  EmojiCapture
//
//  Created by Kosuke Katsuki on 1/27/17.
//  Copyright © 2017 Kosuke Katsuki. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics

extension String {
    func isEmoji() -> Bool {
        return EmojiHelper.isEmoji(self)
    }
    
    func isFullWidth() -> Bool {
        return EmojiHelper.isFullWidth(self)
    }
}

// MARK: -

func calculateDimensions(_ text: String) -> (rows: Int, halfColnmns: Int) {
    var rows = 0
    var columns = 0
    var longestColumns = 0
    var index = text.startIndex // because Swift 3...
    while index < text.endIndex {
        let range = text.rangeOfComposedCharacterSequence(at: index)
        let s = text.substring(with: range)
        if s == "\n" {
            rows += 1
            longestColumns = max(columns, longestColumns)
            columns = 0
        } else if s.isEmoji() || s.isFullWidth() {
            columns += 2
        } else {
            columns += 1
        }
        index = range.upperBound
    }
    rows += 1
    longestColumns = max(columns, longestColumns)
    return (Int(rows), Int(longestColumns))
}

func createBlankImage(_ width: Int, height: Int) -> CGContext {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let context = CGContext(data: nil, width: width, height: height,
                            bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace,
                            bitmapInfo: bitmapInfo.rawValue)
    context?.translateBy(x: 0, y: CGFloat(height));
    context?.setFillColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    return context!
}

func calculateOffsets(_ fullFont: NSFont, _ halfFont: NSFont)
    -> (full: CGFloat, half: CGFloat) {
    let options : NSStringDrawingOptions = [.usesDeviceMetrics]
    // Baseline offset
    let s = NSAttributedString(string: "😀",
                               attributes: [NSFontAttributeName : fullFont])
    let bounds = s.boundingRect(with: NSSize.zero, options: options)
    // Centering smaller font
    let offset = (fullFont.pointSize - halfFont.pointSize) / 2
    return (full: -bounds.minY, half: -bounds.minY + offset)
}

func draw(text: String, fonts: (full: NSFont, half: NSFont),
          cellSize: Float) {
    // Cache attributed strings
    var map = [String: NSAttributedString]()
    let attribute = { (s: String, font: NSFont) -> NSAttributedString in
        if let v = map[s] {
            return v
        }
        let a = [NSFontAttributeName : font]
        let v = NSAttributedString(string: s, attributes: a)
        map[s] = v
        return v
    }
    // Drawing characters
    let offsets = calculateOffsets(fonts.full, fonts.half)
    var row = 0
    var halfColumn = 0
    var index = text.startIndex // because Swift 3...
    while index < text.endIndex {
        let range = text.rangeOfComposedCharacterSequence(at: index)
        let s = text.substring(with: range)
        // New line
        if s == "\n" {
            row += 1
            halfColumn = 0
            index = range.upperBound
            continue
        }
        // Draw
        let full = s.isEmoji() || s.isFullWidth()
        let font = full ? fonts.full : fonts.half
        let x = CGFloat(Float(halfColumn) * cellSize / 2)
        let y = -CGFloat(Float(row + 1) * cellSize)
            + (full ? offsets.full : offsets.half)
        let options : NSStringDrawingOptions = [.usesDeviceMetrics]
        let string = attribute(s, font)
        string.draw(with: NSRect(x: x,
                                 y: y,
                                 width:  CGFloat(font.pointSize),
                                 height: CGFloat(font.pointSize)),
                    options: options)
        // Move
        if full {
            halfColumn += 2
        } else {
            halfColumn += 1
        }
        index = range.upperBound
    }
}

// MARK: -

func capture(_ text: String, to url: URL, with fontSize: (Int, Int),
             using emojiFont: NSFont? = nil) {
    let (cellSize, smallSize) = fontSize
    let fullFont = emojiFont ?? NSFont(name: "PT Mono", size: CGFloat(cellSize))!
    let halfFont = NSFont(name: "PT Mono", size: CGFloat(smallSize))!
    let dimensions = calculateDimensions(text)
    let context = createBlankImage(dimensions.halfColnmns * cellSize / 2,
                                   height: dimensions.rows * cellSize)
    let nsgc = NSGraphicsContext(cgContext: context, flipped: false)
    NSGraphicsContext.setCurrent(nsgc)
    draw(text:text, fonts: (full: fullFont, half: halfFont), cellSize: Float(cellSize))
    let img = context.makeImage()! as CGImage
    let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil)!
    CGImageDestinationAddImage(destination, img, nil)
    CGImageDestinationFinalize(destination)
}

// MARK: -

func loadFont(from url: URL, in size: Int) -> NSFont? {
    guard let dataProvider = CGDataProvider(url: url as CFURL) else {
        return nil;
    }
    let cgFont = CGFont(dataProvider);
    let cfFont = CTFontCreateWithGraphicsFont(cgFont, CGFloat(size), nil, nil);
    return cfFont as NSFont;
}

func readPair(_ command: String, from args: inout [String]) -> String? {
    if let i = args.index(where: {$0 == command}) {
        if i + 1 < args.count {
            let value = args[i + 1]
            args.remove(at: i + 1)
            args.remove(at: i)
            return value
        } else {
            print("Missing value for " + command + " option")
            exit(1)
        }
    }
    return nil
}

func printUsage() {
    print("Usage: EmojiCapture [option] -o <output_file> text")
    print("Options: ")
    print("--font : Specify path to alternative emoji font")
    print("--size : Font size for emojis/full width characters")
    print("--half : Font size for smaller characters including alphabets")
}

// MARK: Main

var args = CommandLine.arguments

// Show usage
if args.contains("--help") {
    printUsage()
    exit(0)
}

// Font size (optional)
let fontSize = Int(readPair("--size", from: &args) ?? "48")!

// Small font size (optional)
let halfFontSize = Int(readPair("--half", from: &args) ?? "40")!

// Font (optional; apply old emoji font)
let font: NSFont? = {
    if let fontPath = readPair("--font", from: &args) {
        let url = Foundation.URL(fileURLWithPath: fontPath)
        guard let font = loadFont(from: url, in: fontSize) else {
            exit(1)
        }
        return font
    }
    return nil
}()

// Output (required)
guard let outputFile = readPair("-o", from: &args) else {
    print("Output file is unspecified");
    printUsage()
    exit(1)
}
let url = URL(fileURLWithPath: outputFile)

// Text (required)
guard args.count >= 2 else {
    print("Text is unspecified");
    printUsage()
    exit(1)
}
let text = args[1]

capture(text, to: url, with: (fontSize, halfFontSize), using: font)
