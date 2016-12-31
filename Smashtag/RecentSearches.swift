//
//  RecentSearches.swift
//  Smashtag
//
//  Created by Lesly Garcia.
//  Copyright © 2016 Lesly Garcia. All rights reserved.
//

import Foundation

class RecentSearches {
    
    private struct Const {
        static let ValuesKey = "RecentSearches.Values"
        static let NumberOfSearches = 200
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var values: [String] {
        get { return defaults.objectForKey(Const.ValuesKey) as? [String] ?? [] }
        set { defaults.setObject(newValue, forKey: Const.ValuesKey) }
    }
    
    func add(search: String) {
        var currentSearches = values
        if let index = currentSearches.indexOf(search) {
            currentSearches.removeAtIndex(index)
        }
        currentSearches.insert(search, atIndex: 0)
        while currentSearches.count > Const.NumberOfSearches {
            currentSearches.removeLast()
        }
        values = currentSearches
    }
}
