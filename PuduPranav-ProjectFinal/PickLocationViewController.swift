// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import MapKit
import CoreLocation

// Protocol for passing selected location back
protocol PickLocationDelegate: AnyObject {
    func didPickLocation(name: String, latitude: Double, longitude: Double)
}

class PickLocationViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: PickLocationDelegate?
    private var selectedCoordinate: CLLocationCoordinate2D?
    private var selectedLocationName: String?
    private let geocoder = CLGeocoder()

    // MARK: - UI Elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var saveLocationButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Pick Location"
        setupUI()
        setupMapView()
        setupNavigationBar()
    }

    private func setupUI() {
        instructionLabel.text = "Tap on the map to set the challenge location"
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = UIColor(named: "AppPrimaryBrown")

        coordinateLabel.text = "No location selected"
        coordinateLabel.textAlignment = .center
        coordinateLabel.font = UIFont.systemFont(ofSize: 12)
        coordinateLabel.textColor = .gray

        saveLocationButton.isEnabled = false
        saveLocationButton.alpha = 0.5
        saveLocationButton.setTitle("Save Location", for: .normal)
        saveLocationButton.addTarget(self, action: #selector(saveLocationTapped), for: .touchUpInside)
    }

    private func setupMapView() {
        mapView.delegate = self

        // Add tap gesture to map
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)

        // Set initial region (San Francisco)
        let initialCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let region = MKCoordinateRegion(
            center: initialCoordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        mapView.setRegion(region, animated: false)
    }

    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }

    // MARK: - Actions
    @objc private func mapTapped(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: mapView)
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)

        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)

        // Add new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Challenge Location"
        mapView.addAnnotation(annotation)

        // Save coordinate
        selectedCoordinate = coordinate

        // Update coordinate label
        coordinateLabel.text = String(format: "Lat: %.4f, Lon: %.4f", coordinate.latitude, coordinate.longitude)

        // Enable save button
        saveLocationButton.isEnabled = true
        saveLocationButton.alpha = 1.0

        // Reverse geocode to get location name
        reverseGeocodeCoordinate(coordinate)
    }

    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                self.selectedLocationName = "Custom Location"
                return
            }

            if let placemark = placemarks?.first {
                // Build a readable name from placemark
                var name = ""
                if let name_place = placemark.name {
                    name = name_place
                } else if let thoroughfare = placemark.thoroughfare {
                    name = thoroughfare
                    if let subThoroughfare = placemark.subThoroughfare {
                        name = "\(subThoroughfare) \(name)"
                    }
                } else if let locality = placemark.locality {
                    name = locality
                }

                self.selectedLocationName = name.isEmpty ? "Custom Location" : name

                // Update annotation title
                if let annotation = self.mapView.annotations.first as? MKPointAnnotation {
                    annotation.title = self.selectedLocationName
                }
            } else {
                self.selectedLocationName = "Custom Location"
            }
        }
    }

    @objc private func saveLocationTapped() {
        guard let coordinate = selectedCoordinate else {
            showAlert(title: "Error", message: "Please select a location on the map")
            return
        }

        let locationName = selectedLocationName ?? "Custom Location"

        // Call delegate
        delegate?.didPickLocation(
            name: locationName,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        // Pop view controller
        navigationController?.popViewController(animated: true)
    }

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension PickLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "LocationPin"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        annotationView?.markerTintColor = UIColor(named: "AppPrimaryBrown")

        return annotationView
    }
}
