//
//  droppablePin.swift
//  potHoleCity
//
//  Created by Victoria George on 10/16/17.
//  Copyright © 2017 Victoria George. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String

    
    init(coordinate: CLLocationCoordinate2D, identifier: String){
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()
    }
}

