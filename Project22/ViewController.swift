//
//  ViewController.swift
//  Project22
//
//  Created by Максим Зыкин on 19.11.2023.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var circleRange: UIView!
    @IBOutlet var idLabel: UILabel!
    
    var locationManager: CLLocationManager?
    var beaconDetected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleRange.layer.cornerRadius = 128
        circleRange.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        monitorBeacon(with: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: 123, minor: 456, identifier: "MyBeacon")
    }
    
    func monitorBeacon(with uuid: String, major: Int, minor: Int, identifier: String) {
        let uuid = UUID(uuidString: uuid)!
        let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: uuid, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor))
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconIdentityConstraint, identifier: identifier)
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: beaconIdentityConstraint)
    }
    
    func update(distance: CLProximity, id: String) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                self.circleRange.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.idLabel.text = id
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
                self.circleRange.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)            
                self.idLabel.text = id
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
                self.circleRange.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                self.idLabel.text = id
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                self.circleRange.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.idLabel.text = ""
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            if !beaconDetected {
                beaconDetected = true
                showAlert()
            }
            update(distance: beacon.proximity, id: beacon.description)
        } else {
            update(distance: .unknown, id: "")
        }
    }
    
    func showAlert() {
        let ac = UIAlertController(title: "Notice", message: "Your beacon is detected", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

