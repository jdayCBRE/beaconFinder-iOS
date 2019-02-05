//
//  BeaconView.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 2/5/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import UIKit


class BeaconView: UIView {
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		layer.masksToBounds = false
	}
	
	func showRadius(_ radius: CGFloat) {
		let diameter = max((50 - radius) * 2, bounds.size.height + 3)
		let radiusFrame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
		let radiusView = UIView(frame: radiusFrame)
		radiusView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
		radiusView.backgroundColor = .clear
		radiusView.layer.cornerRadius = diameter / 2
		radiusView.layer.borderColor = UIColor.darkGray.cgColor
		radiusView.layer.borderWidth = 1.0
		radiusView.layer.masksToBounds = false
		addSubview(radiusView)
	}
	
	func removeRadius() {
		for subview in subviews {
			subview.removeFromSuperview()
		}
	}
}
