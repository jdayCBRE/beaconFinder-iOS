//
//  CLLocationViewController.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 1/23/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import UIKit
import CoreLocation


class RangingViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var mapView: MapView!
	@IBOutlet weak var statusLabel: UILabel!
	
	let buildingWidth: CGFloat = 48.8879814  // meters, X axis, landscape
	let buildingLength: CGFloat = 37.2897966 // meters, Y axis, landscape
	
	let scaleFactor: CGFloat = 15
	let aspectRatio: CGFloat = 24 / 19
	
	var regionIdentifier: UUID?
	
	let activeBeacons = [
		Beacon(minor: 1043, coordinate: Coordinate(x: 5.0, y: 10.5)),
		Beacon(minor: 1052, coordinate: Coordinate(x: 1.0, y: 3.5)),
		Beacon(minor: 1053, coordinate: Coordinate(x: 1.0, y: 1.5)),
		Beacon(minor: 1056, coordinate: Coordinate(x: 8.5, y: 1.5)),
		Beacon(minor: 1059, coordinate: Coordinate(x: 16.0, y: 3.0)),
		Beacon(minor: 1078, coordinate: Coordinate(x: 8.0, y: 7.0)),
		Beacon(minor: 1079, coordinate: Coordinate(x: 8.0, y: 10.0)),
		Beacon(minor: 1080, coordinate: Coordinate(x: 3.0, y: 7.0)),
		Beacon(minor: 1086, coordinate: Coordinate(x: 15.0, y: 5.0)),
		Beacon(minor: 1271, coordinate: Coordinate(x: 6.0, y: 5.0)),
		Beacon(minor: 1312, coordinate: Coordinate(x: 6.0, y: 1.0)),
		Beacon(minor: 1318, coordinate: Coordinate(x: 9.5, y: 1.5)),
		Beacon(minor: 1519, coordinate: Coordinate(x: 6.0, y: 2.5)),
		]
	
	lazy var beaconManager: BeaconManager = {
		let manager = BeaconManager(regionIdentifier: regionIdentifier!)
		manager.delegate = self
		return manager
	}()
	
	let blueDot = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
	
	fileprivate var beacons = [CLBeacon]() {
		didSet {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	
	
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.tableFooterView = UIView(frame: .zero)
		setupMapView()
		
		blueDot.layer.cornerRadius = 15
		blueDot.backgroundColor = .blue
		
		beaconManager.start()
	}
	
	
	
	
	// MARK: - Private Functions
	
	private func setupMapView() {
		let beaconSize = CGSize(width: 20, height: 20)
		
		activeBeacons.forEach { beacon in
			let beaconCenter = CGPoint(x: beacon.coordinate.x * scaleFactor, y: beacon.coordinate.y * scaleFactor * aspectRatio)
			let beaconFrame = CGRect(origin: .zero, size: beaconSize)
			let beaconView = BeaconView(frame: beaconFrame)
			beaconView.center = beaconCenter.transformY(factor: mapView.bounds.size.height)
			beaconView.layer.cornerRadius = beaconSize.width / 2
			beaconView.backgroundColor = .green
			beaconView.tag = beacon.minor
			mapView.addSubview(beaconView)
		}
	}
	
	fileprivate func updateStatusLabel(with text: String) {
		print(text)
		
		DispatchQueue.main.async {
			self.statusLabel.text = text
		}
	}
}

extension RangingViewController: BeaconManagerDelegate {
	func statusUpdate(with status: String) {
		updateStatusLabel(with: status)
	}
	
	func update(beacons: [CLBeacon]) {
		DispatchQueue.main.async {
			self.beacons = beacons
		}
		
		guard let beacon1 = beacon(for: beacons[0].minor.intValue, distance: beacons[0].accuracy),
			let beacon2 = beacon(for: beacons[1].minor.intValue, distance: beacons[1].accuracy),
			let beacon3 = beacon(for: beacons[2].minor.intValue, distance: beacons[2].accuracy) else {
				statusUpdate(with: "Found some unknown beacon")
				
				DispatchQueue.main.async {
					if self.blueDot.superview != nil {
						self.blueDot.removeFromSuperview()
					}
					
					self.resetBeaconViews()
				}
				
				return
		}
		
		let bestGuessLocation = BeaconManager.trilaterate(beacon1: beacon1, beacon2: beacon2, beacon3: beacon3)
		
		guard !bestGuessLocation.x.isNaN && !bestGuessLocation.y.isNaN else { return }
		
		// flip the Y coordinate before drawing on the map
		let centerPoint = CGPoint(x: max(bestGuessLocation.x, 0), y: min(max((mapView.bounds.size.height - bestGuessLocation.y), 0), mapView.bounds.size.height))
		
		DispatchQueue.main.async {
			self.resetBeaconViews()
			
			if self.blueDot.superview == nil {
				self.mapView.addSubview(self.blueDot)
			}
			
			for subview in self.mapView.subviews {
				if let beaconView = subview as? BeaconView {
					if let beacon = beacons.filter({ $0.minor.intValue == beaconView.tag }).first {
						beaconView.backgroundColor = .purple
						let radius = CGFloat(beacon.accuracy) * 2
						beaconView.showRadius(radius)
					}
				}
			}
			
			self.blueDot.center = centerPoint
		}
	}
	
	private func resetBeaconViews() {
		for subview in self.mapView.subviews {
			if let beaconView = subview as? BeaconView {
				beaconView.backgroundColor = .green
				beaconView.removeRadius()
			}
		}
	}
	
	private func beacon(for minor: Int, distance: Double) -> BeaconReading? {
		guard let found = activeBeacons.first(where: { beacon -> Bool in
			return beacon.minor == minor
		}) else {
			return nil
		}

		let adjustedX = found.coordinate.x * scaleFactor
		let adjustedY = found.coordinate.y * scaleFactor * aspectRatio
		let adjustedDistance = CGFloat(distance) * 2
		return BeaconReading(location: Coordinate(x: adjustedX, y: adjustedY), distance: adjustedDistance)
	}
}

extension RangingViewController: UITableViewDataSource, UITableViewDelegate {
	
	
	// MARK: - UITableView Datasource
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return beacons.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCellIdentifier") as! BeaconTableViewCell
		return cell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = cell as? BeaconTableViewCell else { return }
		
		let beacon = beacons[indexPath.row]
		cell.beaconLabel.text = "Beacon \(indexPath.row + 1)"
		cell.regionLabel.text = beaconManager.regionName //beacon.proximityUUID.uuidString
		cell.majorLabel.text = NumberFormatters.intFormatter.string(from: beacon.major)
		cell.minorLabel.text = NumberFormatters.intFormatter.string(from: beacon.minor)
		cell.proximityLabel.text = beacon.proximity.name
		cell.rssiLabel.text = NumberFormatters.intFormatter.string(from: NSNumber(value: beacon.rssi))
		cell.accuracyLabel.text = NumberFormatters.decimalFormatter.string(from: NSNumber(value: beacon.accuracy))
	}
	
	
	// MARK: - UITableView Delegate
	
}
