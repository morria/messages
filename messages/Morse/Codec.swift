//
//  Encode.swift
//  messages
//
//  Created by Andrew Morrison on 2/16/25.
//

public class Encode {
    private static let morseCode: [Character: String] = [
        "A": ".-",    "B": "-...",  "C": "-.-.",  "D": "-..",
        "E": ".",     "F": "..-.",  "G": "--.",   "H": "....",
        "I": "..",    "J": ".---",  "K": "-.-",   "L": ".-..",
        "M": "--",    "N": "-.",    "O": "---",   "P": ".--.",
        "Q": "--.-",  "R": ".-.",   "S": "...",   "T": "-",
        "U": "..-",   "V": "...-",  "W": ".--",   "X": "-..-",
        "Y": "-.--",  "Z": "--..",  "1": ".----", "2": "..---",
        "3": "...--", "4": "....-", "5": ".....", "6": "-....",
        "7": "--...", "8": "---..", "9": "----.", "0": "-----",
        " ": " "
    ]
    
    private static let morseCodeReversed = morseCode.reduce(into: [String: Character]()) { $0[$1.value] = $1.key }
    
    /**
     * Encode the given text in morse as dots, dashes and space.
     */
    static func encode(text: String) -> String {
        return text.uppercased().compactMap { morseCode[$0] }.joined(separator: " ")
    }
    
    static func decode(_ morse: String) -> String {
        return morse.components(separatedBy: "   ").map {
            $0.split(separator: " ").map {
                morseCodeReversed[String($0)]!
            }
        }.map {
            String($0)
        }.joined(separator: " ")
    }
}

