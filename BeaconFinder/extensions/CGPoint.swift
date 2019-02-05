//
//  CGPoint.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 2/5/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import UIKit


extension CGPoint {
	func transformY(factor: CGFloat) -> CGPoint {
		return CGPoint(x: x, y: factor - y)
	}
}
