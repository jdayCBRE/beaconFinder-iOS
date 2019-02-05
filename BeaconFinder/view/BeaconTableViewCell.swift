//
//  BeaconTableViewCell.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 1/24/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import UIKit


class BeaconTableViewCell: UITableViewCell {
	
	@IBOutlet weak var beaconLabel: UILabel!
	@IBOutlet weak var regionLabel: UILabel!
	@IBOutlet weak var majorLabel: UILabel!
	@IBOutlet weak var minorLabel: UILabel!
	@IBOutlet weak var proximityLabel: UILabel!
	@IBOutlet weak var rssiLabel: UILabel!
	@IBOutlet weak var accuracyLabel: UILabel!
}
