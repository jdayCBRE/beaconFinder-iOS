//
//  BeaconReading.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 2/5/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import UIKit


struct BeaconReading: CustomStringConvertible {
	let location: Coordinate
	let distance: CGFloat
	
	var description: String {
		return "Location(\(location.x), \(location.y)), Distance: \(distance)"
	}
	
	init(location: Coordinate, distance: CGFloat) {
		self.location = Coordinate(x: max(location.x, 0), y: max(location.y, 0))
		self.distance = distance
	}
}
