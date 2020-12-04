//
//  MapPin.swift
//  CoffeeQuest
//
//  Created by SungHo Han on 2020/12/04.
//

import Foundation
import MapKit

public class BusinessMapViewModel: NSObject {
    
    // MARK: - Properties
    public let coordinate: CLLocationCoordinate2D
    public let name: String
    public let rating: Double
    
    // MARK: - Object Lifecycle
    public init(coordinate: CLLocationCoordinate2D,
                name: String,
                rating: Double) {
        self.coordinate = coordinate
        self.name = name
        self.rating = rating
    }
}

// MARK: - MKAnnotaion
extension BusinessMapViewModel: MKAnnotation {
    public var title: String? {
        return name
    }
}

