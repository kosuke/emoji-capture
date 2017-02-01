//
//  Emoji.swift
//  EmojiCapture
//
//  Created by Kosuke Katsuki on 1/28/17.
//  Copyright © 2017 Kosuke Katsuki. All rights reserved.
//

import Foundation

struct EmojiHelper {
    
    // Emoji Combining Sequence
    // http://www.unicode.org/Public/emoji/4.0//emoji-sequences.txt
    static func isEmojiCombining(_ string: String) -> Bool {
        var it = string.utf16.makeIterator();
        if let first = it.next()?.littleEndian,
            let second = it.next()?.littleEndian,
            let third = it.next()?.littleEndian {
            return (0x0023 <= first && first <= 0x0039)
                && second == 0xfe0f
                && third == 0x20E3
        }
        return false
    }
    
    // Flags
    // https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    static func isFlag(_ string: String) -> Bool {
        var it = string.unicodeScalars.makeIterator();
        if let first = it.next()?.value,
            let second = it.next()?.value {
            // imperfect check
            return (0x1f1e6 <= first && first <= 0x1f1ff)
                && (0x1f1e6 <= second && second <= 0x1f1ff)
        }
        return false
    }
    
    static let characters = "©️®️‼️⁉️™️ℹ️↔️↕️↖️↗️↘️↙️↩️↪️⌚⌛⌨️⏏️⏩⏪⏫⏬"
        + "⏭️⏮️⏯️⏰⏱️⏲️⏳⏸️⏹️⏺️Ⓜ️▪️▫️▶️◀️◻️◼️◽◾☀️☁️☂️☃️☄️☎️☑️☔☕☘️☝️"
        + "☠️☢️☣️☦️☪️☮️☯️☸️☹️☺️♀️♂️♈♉♊♋♌♍♎♏♐♑♒♓♠️♣️♥️♦️♨️♻️"
        + "♿⚒️⚓⚔️⚕️⚖️⚗️⚙️⚛️⚜️⚠️⚡⚪⚫⚰️⚱️⚽⚾⛄⛅⛈️⛎⛏️⛑️⛓️⛔⛩️⛪⛰️⛱️"
        + "⛲⛳⛴️⛵⛷️⛸️⛹️⛺⛽✂️✅✈️✉️✊✋✌️✍️✏️✒️✔️✖️✝️✡️✨✳️✴️❄️❇️❌❎"
        + "❓❔❕❗❣️❤️➕➖➗➡️➰➿⤴️⤵️⬅️⬆️⬇️⬛⬜⭐⭕〰️〽️㊗️㊙️"
    
    static let nonsurrogates: Set<UInt32> = {
        var result: Set<UInt32> = []
        for c in characters.characters {
            if let s = String(c).unicodeScalars.first?.value {
                result.insert(s)
            }
        }
        return result
    }()
    
    // Check the code point range approximately
    // https://en.wikipedia.org/wiki/Emoji#Unicode_blocks
    static func isEmojiCodePoint(_ s: String) -> Bool {
        if let v = s.unicodeScalars.first?.value {
            return (v == 0x000a9 || v == 0x000ae) // ©️, ®️
                || (0x1f004 <= v && v <= 0x1f9c0) // 🀄 - 🧀
                || nonsurrogates.contains(v)      // ‼️ - ㊙️ (0x0203C, 0x03299)
            
        }
        return false
    }
    
    static func isEmoji(_ s: String) -> Bool {
        return isEmojiCodePoint(s) || isFlag(s) || isEmojiCombining(s)
    }
    
    static func isFullWidth(_ s: String) -> Bool {
        let scalars = s.utf16
        let high = scalars[scalars.startIndex].littleEndian
        return 0x0800 <= high && high <= 0x0fff
            || 0x1000 <= high && high <= 0xcfff
            || 0xd000 <= high && high <= 0xd7ff
            || 0xf900 <= high && high <= 0xffff
    }
}
