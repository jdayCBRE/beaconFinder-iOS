//
//  NumberFormatters.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 1/24/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import Foundation


class NumberFormatters {
	static var decimalFormatter: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 6
		formatter.maximumFractionDigits = 6
		return formatter
	}
	
	static var intFormatter: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		return formatter
	}
}
