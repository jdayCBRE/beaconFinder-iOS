//
//  BeaconManager.swift
//  KontaktExample
//
//  Created by Day, Jeff @ Dallas on 1/24/19.
//  Copyright © 2019 Day, Jeff @ Dallas. All rights reserved.
//

import CoreLocation
import UIKit


protocol BeaconManagerDelegate: class {
	func statusUpdate(with status: String)
	func update(beacons: [CLBeacon])
}

class BeaconManager: NSObject {
	
	weak var delegate: BeaconManagerDelegate?
	
	let proximityUUID = UUID(uuidString: "whatever")
	
	lazy var locationManager: CLLocationManager = {
		let manager = CLLocationManager()
		manager.delegate = self
		return manager
	}()
	
	let regionName = "Current Region"
	var regionIdentifier: UUID
	
	var beaconRegion: CLBeaconRegion? {
		let region = CLBeaconRegion(proximityUUID: regionIdentifier, identifier: regionName)
		return region
	}
	
	
	 init(regionIdentifier: UUID) {
		self.regionIdentifier = regionIdentifier
		super.init()
		
		checkPermissions()
	}
	
	func start() {
		
	}
	
	
	
	// MARK: - Fileprivate Functions
	
	fileprivate func checkPermissions() {
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			// NOTE: if you want to do any beacon monitoring in the background, need the ALWAYS authorization
			locationManager.requestAlwaysAuthorization()
			//			locationManager.requestWhenInUseAuthorization()
			
		case .denied, .restricted:
			let status = "bluetooth access is denied, please turn on in settings to continue"
			delegate?.statusUpdate(with: status)
			
		case .authorizedWhenInUse, .authorizedAlways:
			startMonitoring()
		}
	}
	
	fileprivate func startMonitoring() {
		if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
			let monitoringStatus = "location authorized, trying to start monitoring"
			delegate?.statusUpdate(with: monitoringStatus)
			
			if let region = beaconRegion {
				
				// NOTE: You'd want to start monitoring for any regions known to be nearby
				locationManager.startMonitoring(for: region)
				locationManager.requestState(for: region)
			} else {
				let noIdentifierStatus = "unable to get a proximityIdentifier"
				delegate?.statusUpdate(with: noIdentifierStatus)
			}
		} else {
			if let region = beaconRegion {
				let monitoringUnavailableStatus = "location authorized, but monitoring not available. starting ranging instead"
				delegate?.statusUpdate(with: monitoringUnavailableStatus)
				locationManager.startRangingBeacons(in: region)
			}
		}
	}
}

extension BeaconManager: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .notDetermined:
			// manager.requestWhenInUseAuthorization()
			manager.requestAlwaysAuthorization()
			
		case .denied, .restricted:
			let bluetoothAccessDeniedStatus = "bluetooth access is denied, please turn on in settings to continue"
			delegate?.statusUpdate(with: bluetoothAccessDeniedStatus)
			
		case .authorizedWhenInUse, .authorizedAlways:
			startMonitoring()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		let startedMonitoringStatus = "started monitoring for region: \(region.identifier)"
		delegate?.statusUpdate(with: startedMonitoringStatus)
	}
	
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		// state [0, 1, 2] = [unknown, inside, outside]
		let stateDeterminedStatus = "state determined for region (\(region.identifier)): \(state.rawValue)"
		delegate?.statusUpdate(with: stateDeterminedStatus)
		
		guard let region = region as? CLBeaconRegion else {
			let unableToConvertStatus = "\(#function) unable to convert CLRegion to CLBeaconRegion"
			delegate?.statusUpdate(with: unableToConvertStatus)
			return
		}
		
		if state == .inside {
			manager.startRangingBeacons(in: region)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		let monitoringFailedStatus = "monitoring failed for region (\(region?.identifier ?? "")), error: \(error.localizedDescription)"
		delegate?.statusUpdate(with: monitoringFailedStatus)
	}
	
	
	
	
	// MARK: - Beacon Region Stuff
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		let regionEnteredStatus = "Good news, you have entered region: \(region.identifier)"
		delegate?.statusUpdate(with: regionEnteredStatus)
		
		guard let region = region as? CLBeaconRegion else {
			let unableToConvertStatus = "\(#function) unable to convert CLRegion to CLBeaconRegion"
			delegate?.statusUpdate(with: unableToConvertStatus)
			return
		}
		
		manager.startRangingBeacons(in: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		let exitedRegionStatus = "Womp womp, you have exited region: \(region.identifier)"
		delegate?.statusUpdate(with: exitedRegionStatus)
		
		guard let region = region as? CLBeaconRegion else {
			let unableToConvertStatus = "\(#function) unable to convert CLRegion to CLBeaconRegion"
			delegate?.statusUpdate(with: unableToConvertStatus)
			return
		}
		
		manager.stopRangingBeacons(in: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		
		// TODO: if we're ranging only (authorizedWhenInUse), need a flag to determine the first becacon region we get back
		//          - continue ranging for that region, but stop for all others?
		//          - what if you go to another region (floor?), how do you start ranging for that again?
		//          - could clicking the find my location button on the map force everything to start again and figure out where you are?
		//
		
		print("**** new beacon update")
		beacons.forEach { beacon in
			// proximity [0, 1, 2, 3] = [unknown, immediate, near, far]
			let rangedBeaconStatus = "beacon(\(beacon.major), \(beacon.minor)): \(beacon.proximity.rawValue) proximity, \(beacon.rssi) signal strength, accuracy: \(beacon.accuracy)"
			delegate?.statusUpdate(with: rangedBeaconStatus)
			
			// beacon.accuracy: CLLocationAccuracy
			// The accuracy of the proximity value, measured in meters from the beacon.
			//    - this is being calculated by apple with a best guess based on RSSI?
			//    - can vary based on things like humidity and people/objects being in the way
			//    - data science to the rescue?
		}
		
		var rangedBeacons = [CLBeacon]()
		let filteredBeacons = beacons.filter { $0.proximity != .unknown && $0.minor.intValue != 1191 && $0.minor.intValue != 1070 && $0.minor.intValue != 1067 }
		guard filteredBeacons.count > 3 else { return }
		
		let beacon0 = filteredBeacons[0]
		let beacon1 = filteredBeacons[1]
		let beacon2 = filteredBeacons[2]
		
		rangedBeacons.append(beacon0)
		rangedBeacons.append(beacon1)
		rangedBeacons.append(beacon2)
		
		delegate?.update(beacons: rangedBeacons)
	}
}

extension BeaconManager {
	
	class func trilaterate(beacon1: BeaconReading, beacon2: BeaconReading, beacon3: BeaconReading) -> Coordinate {
		var temp: CGFloat = 0
		
		// (P2 - P1) / numpy.linalg.norm(P2 - P1)
		let tx = pow(beacon2.location.x - beacon1.location.x, 2)
		let ty = pow(beacon1.location.y - beacon1.location.y, 2)
		temp = tx + ty
		
		let ux = (beacon2.location.x - beacon1.location.x) / sqrt(temp)
		let uy = (beacon2.location.y - beacon2.location.y) / sqrt(temp)
		let ex = Coordinate(x: ux, y: uy)
		
		
		// i = dot(ex, P3 - P1)
		let ix = beacon3.location.x - beacon1.location.x
		let iy = beacon3.location.y - beacon1.location.y
		let p3p1 = Coordinate(x: ix, y: iy)
		
		var iVal: CGFloat = 0
		let iValx = ex.x * p3p1.x
		let iValy = ex.y * p3p1.y
		iVal = iValx + iValy
		
		
		// ey = (P3 - P1 - i*ex) / numpy.linalg.norm(P3 - P1 - i*ex)
		var p3pli: CGFloat = 0
		let p3plix = pow((beacon3.location.x - beacon1.location.x - (ex.x * iVal)), 2)
		let p3pliy = pow((beacon3.location.y - beacon1.location.y - (ex.y * iVal)), 2)
		p3pli = p3plix + p3pliy
		
		let eyyX = (beacon3.location.x - beacon1.location.x - (ex.x * iVal)) / sqrt(p3pli)
		let eyyY = (beacon3.location.y - beacon1.location.y - (ex.y * iVal)) / sqrt(p3pli)
		let ey = Coordinate(x: eyyX, y: eyyY)
		
		
		// ez = numpy.cross(ex, ey)
		// if 2-dimensional vector, ez = 0
		var ez: CGFloat = 0
		var ezx = ex.y * ez - ez * ey.y
		var ezy = ez * ey.x - ex.x * ez
		var ezz = ex.x * ey.y - ex.y * ey.x
		
		// d = numpy.linalg.norm(P2 - P1)
		var d: CGFloat = sqrt(temp)
		
		// j = dot(ey, P3 - P1)
		var j: CGFloat = 0
		let jx = ey.x * p3p1.x
		let jy = ey.y * p3p1.y
		j = jx + jy
		
		// x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
		let x = (pow(beacon1.distance, 2) - pow(beacon2.distance, 2) + pow(d, 2)) / (2 * d)
		
		// y = ((pow(DistA,2) - pow(DistC,2) + pow(i,2) + pow(j,2))/(2*j)) - ((i/j)*x)
		let y = ((pow(beacon1.distance, 2) - pow(beacon3.distance, 2) + pow(iVal, 2) + pow(j, 2)) / (2 * j)) - ((iVal / j) * x)
		
		// z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
		// if 2-dimensional vector then z = 0
		// NOTE (JD): (using 2D vectors for this application)
		let z: CGFloat = 0
		
		
		// triPt = P1 + x*ex + e*ey + z*ez
		let triPtX = beacon1.location.x + (ex.x * x) + (ey.x * y) + (ez * z)
		let triPtY = beacon1.location.y + (ex.y * x) + (ey.y * y) + (ez * z)
		let triPt = Coordinate(x: triPtX, y: triPtY)
		
		return triPt
	}
}
