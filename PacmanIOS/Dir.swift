//
//  Dir.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

enum Dir {
    case l
    case r
    case u
    case d
    case none
    
    func getX() -> Int {
        switch self {
        case .l:
            return -1
        case .r:
            return 1
        default:
            return 0
        }
    }
    
    func getY() -> Int {
        switch self {
        case .u:
            return -1
        case .d:
            return 1
        default:
            return 0
        }
    }
    
    func isOpp(_ o: Dir) -> Bool {
        return getX() == -o.getX() && getY() == -o.getY()
    }
    
    func getOpp() -> Dir {
        switch self {
        case .l:
            return .r
        case .r:
            return .l
        case .u:
            return .d
        case .d:
            return .u
        default:
            return .none
        }
    }
}
