//
//  Coordinate.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 2/5/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import UIKit


struct Coordinate {
	let x: CGFloat
	let y: CGFloat
	
	func transformY(factor: CGFloat) -> Coordinate {
		return Coordinate(x: x, y: factor - y)
	}
}
