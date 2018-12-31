//
//  StringExtension.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/30/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

//https://gist.github.com/devnull255/acfc7034331fda9fb9cc03650e3dcf2e
extension String {
    // charAt(at:) returns a character at an integer (zero-based) position.
    // example:
    // let str = "hello"
    // var second = str.charAt(at: 1)
    //  -> "e"
    func charAt(at: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: at)
        return self[charIndex]
    }
}
