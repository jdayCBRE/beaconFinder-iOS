//
//  CLProximity.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 1/24/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import CoreLocation


extension CLProximity {
	var name: String {
		switch self {
		case .unknown: 		return "unknown"
		case .immediate: 	return "immediate"
		case .near: 		return "near"
		case .far: 			return "far"
		}
	}
}
