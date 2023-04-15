//
//  PropertyPackage.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation

final class PropertyPackage<T> {
    
    typealias Receiver = (T) -> Void
    var receiver : Receiver?
    
    var value : T {
        didSet {
            receiver?(value)
        }
    }
    
    init(_ value : T) {
        self.value = value
    }
    
    func associate( receiver : Receiver? ) {
        self.receiver = receiver
        receiver?(value)
    }
}
