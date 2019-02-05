//
//  IntroViewController.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 1/23/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import UIKit


class IntroViewController: UIViewController {
	
	@IBOutlet weak var regionTextField: UITextField!
	
	@IBAction func startMonitoringButtonTapped(_ sender: Any) {
		guard let regionIdentifier = UUID(uuidString: regionTextField.text ?? "") else {
			fatalError("invalid region identifier")
		}
		
		let locationVC = storyboard?.instantiateViewController(withIdentifier: "LocationVC") as! RangingViewController
		locationVC.regionIdentifier = regionIdentifier
		navigationController?.pushViewController(locationVC, animated: true)
	}
}
