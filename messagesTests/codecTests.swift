//
//  decoderTests.swift
//  messages
//
//  Created by Andrew Morrison on 2/16/25.
//

import XCTest
@testable import messages

class CodecTest: XCTestCase {
    
    func testRunEncode() {
        XCTAssertEqual(Encode.encode(text: "SOS"), "... --- ...")
    }
}
