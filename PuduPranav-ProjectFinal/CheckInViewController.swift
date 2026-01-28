// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import MapKit
import CoreLocation

class CheckInViewController: UIViewController {

    // MARK: - Properties
    var challenge: Challenge!
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private let maxCheckInDistance: CLLocationDistance = 150 // meters
    private var hasLocation: Bool {
        return challenge.locationLatitude != nil && challenge.locationLongitude != nil
    }

    // MARK: - UI Elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stakeLabel: UILabel!
    @IBOutlet weak var checkInButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Check-In"
        setupUI()

        if hasLocation {
            // Challenge has a location - set up location tracking
            setupLocationManager()
            setupChallengeLocation()
        } else {
            // No location - allow check-in from anywhere
            setupNoLocationMode()
        }

        checkInButton.addTarget(self, action: #selector(checkInButtonTapped), for: .touchUpInside)
    }

    private func setupUI() {
        // Display stake info
        stakeLabel.text = "Stake: \(challenge.stakeAmount) tokens"

        if hasLocation {
            mapView.showsUserLocation = true
            distanceLabel.text = "Locating..."
            checkInButton.isEnabled = false
            checkInButton.alpha = 0.5
            checkInButton.setTitle("Confirm Check-In", for: .normal)
        }
    }

    private func setupNoLocationMode() {
        // Hide map and distance label for no-location challenges
        mapView.isHidden = true
        distanceLabel.isHidden = false
        distanceLabel.text = "This challenge has no location — you may check in from anywhere."
        distanceLabel.textColor = UIColor(named: "AppPrimaryBrown")
        distanceLabel.textAlignment = .center
        distanceLabel.numberOfLines = 0

        // Enable check-in button immediately
        checkInButton.isEnabled = true
        checkInButton.alpha = 1.0
        checkInButton.setTitle("Confirm Check-In", for: .normal)
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Request authorization
        let authStatus = locationManager.authorizationStatus
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showAlert(title: "Location Access Denied", message: "Please enable location services in Settings to check in.")
        @unknown default:
            break
        }
    }

    private func setupChallengeLocation() {
        guard let latitude = challenge.locationLatitude,
              let longitude = challenge.locationLongitude else {
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        // Add annotation for challenge location
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = challenge.locationName ?? "Challenge Location"
        annotation.subtitle = challenge.name
        mapView.addAnnotation(annotation)

        // Center map on challenge location
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: false)
    }

    private func updateDistanceLabel() {
        guard hasLocation,
              let currentLocation = currentLocation,
              let latitude = challenge.locationLatitude,
              let longitude = challenge.locationLongitude else {
            distanceLabel.text = "Locating..."
            return
        }

        let challengeLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = currentLocation.distance(from: challengeLocation)
        let distanceInMeters = Int(distance)

        if distance <= maxCheckInDistance {
            let locationName = challenge.locationName ?? "the challenge location"
            distanceLabel.text = "You're at \(locationName)!\n(\(distanceInMeters) m)"
            distanceLabel.textColor = .systemGreen
            checkInButton.isEnabled = true
            checkInButton.alpha = 1.0
            checkInButton.setTitle("Confirm Check-In", for: .normal)
        } else {
            distanceLabel.text = "Distance: \(distanceInMeters) meters away\nMust be within 150m to check in"
            distanceLabel.textColor = .systemRed
            checkInButton.isEnabled = true
            checkInButton.alpha = 1.0
            checkInButton.setTitle("Too Far — View Location", for: .normal)
        }
    }

    @objc private func checkInButtonTapped() {
        if !hasLocation {
            // No location required - check in immediately
            performCheckIn(latitude: nil, longitude: nil)
            return
        }

        // Has location - validate distance
        guard let currentLocation = currentLocation else {
            showAlert(title: "Error", message: "Unable to get your current location")
            return
        }

        guard let latitude = challenge.locationLatitude,
              let longitude = challenge.locationLongitude else {
            return
        }

        let challengeLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = currentLocation.distance(from: challengeLocation)

        if distance <= maxCheckInDistance {
            // Within range - perform check-in
            performCheckIn(
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            )
        } else {
            // Too far - recenter map on challenge location
            let region = MKCoordinateRegion(
                center: challengeLocation.coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
            mapView.setRegion(region, animated: true)
        }
    }

    private func performCheckIn(latitude: Double?, longitude: Double?) {
        // Show loading
        checkInButton.isEnabled = false
        checkInButton.setTitle("Checking In...", for: .normal)

        // Save check-in to Firestore
        FirebaseService.shared.saveCheckIn(
            challengeId: challenge.id,
            latitude: latitude,
            longitude: longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.checkInButton.isEnabled = true
                self?.checkInButton.setTitle("Confirm Check-In", for: .normal)

                switch result {
                case .success:
                    let title = self?.hasLocation == true ? "Check-In Successful" : "Check-In Complete"
                    let message = self?.hasLocation == true
                        ? "You checked in at the challenge location and earned tokens!"
                        : "You successfully checked in to this challenge!"

                    self?.showAlert(title: title, message: message) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Failed to check in: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension CheckInViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        updateDistanceLabel()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Location Error", message: "Unable to get your location: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authStatus = manager.authorizationStatus
        switch authStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showAlert(title: "Location Access Denied", message: "Please enable location services in Settings to check in.")
        default:
            break
        }
    }
}
