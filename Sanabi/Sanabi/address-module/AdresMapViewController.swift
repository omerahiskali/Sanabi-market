//
//  AdresMapViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 29.05.2023.
//

import UIKit
import MapKit
import CoreLocation

class AdresMapViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var firstAddressLine: UILabel!
    @IBOutlet weak var secondAddressLine: UILabel!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var cancelImage: UIImageView!
    
    // MARK: - Variables
    
    let locationManager = CLLocationManager()
    var pinAnnotation: MKPointAnnotation?
    var longPressGesture: UILongPressGestureRecognizer?
    
    // MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomMenuView.layer.cornerRadius = 25
        bottomMenuView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomMenuView.clipsToBounds = true

        bottomMenuView.layer.shadowColor = UIColor.black.cgColor
        bottomMenuView.layer.shadowOffset = CGSize(width: 0, height: 3)
        bottomMenuView.layer.shadowOpacity = 0.8
        bottomMenuView.layer.shadowRadius = 4.0
        bottomMenuView.layer.masksToBounds = false
        
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        cancelImage.layer.cornerRadius = cancelImage.bounds.height / 2
        cancelImage.clipsToBounds = true
        cancelImage.layer.shadowColor = UIColor.black.cgColor
        cancelImage.layer.shadowOpacity = 0.4
        cancelImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        cancelImage.layer.shadowRadius = 4
        cancelImage.layer.masksToBounds = false

        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        addPinAtCurrentLocation()
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture!)
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs
    
    func addPinAtCurrentLocation() {
        guard let userLocation = mapView.userLocation.location else {
            print("Konum bilgisi alınamadı")
            return
        }
        
        updatePinLocation(userLocation)
        
        getAddressFromLocation(userLocation) { (address) in
            self.firstAddressLine.text = "\(address.subLocality ?? "") Mah. \(address.thoroughfare ?? "") No: \(address.subThoroughfare ?? "")"
            self.secondAddressLine.text = "\(address.locality ?? "") \(address.administrativeArea ?? "") \(address.postalCode ?? "")"
        }
    }
    
    func updatePinLocation(_ location: CLLocation) {
        if let pinAnnotation = pinAnnotation {
            mapView.removeAnnotation(pinAnnotation)
        }
        
        pinAnnotation = MKPointAnnotation()
        pinAnnotation?.coordinate = location.coordinate
        mapView.addAnnotation(pinAnnotation!)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
    }
    
    func getAddressFromLocation(_ location: CLLocation, completion: @escaping (CLPlacemark) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Adres alınamadı: \(error.localizedDescription)")
                //completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                completion(placemark)
            }
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let touchPoint = gesture.location(in: mapView)
            let newCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            updatePinLocation(newLocation)
        } else if gesture.state == .changed {
            let touchPoint = gesture.location(in: mapView)
            let newCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            pinAnnotation?.coordinate = newCoordinate
        } else if gesture.state == .ended {
            if let pinAnnotation = pinAnnotation {
                let pinLocation = CLLocation(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude)
                getAddressFromLocation(pinLocation) { (address) in
                    self.firstAddressLine.text = "\(address.subLocality ?? "") Mah. \(address.thoroughfare ?? "") No: \(address.subThoroughfare ?? "")"
                    self.secondAddressLine.text = "\(address.locality ?? "") \(address.administrativeArea ?? "") \(address.postalCode ?? "")"
                }
            }
        }
    }
    
    @objc func cancelImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        if let pinAnnotation = pinAnnotation {
            let pinLocation = CLLocation(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude)
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(pinLocation) { (placemarks, error) in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    print("Adres bulunamadı.")
                    return
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let modalVC = storyboard.instantiateViewController(withIdentifier: "adresKayitVC") as? AdresKayitViewController {
                    modalVC.placemark = placemark
                    modalVC.pinLocation = pinLocation
                    
                    modalVC.modalTransitionStyle = .coverVertical
                    modalVC.modalPresentationStyle = .fullScreen
                    
                    self.present(modalVC, animated: true, completion: nil)
                }
               
            }
        }
    }
    

}

//MARK: - Extensions

extension AdresMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "MarkerAnnotationView"
        
        var markerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if markerAnnotationView == nil {
            markerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            markerAnnotationView?.canShowCallout = false
        } else {
            markerAnnotationView?.annotation = annotation
        }
        
        return markerAnnotationView
    }
}

extension AdresMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else {
            return
        }
        
        updatePinLocation(userLocation)
        
        getAddressFromLocation(userLocation) { (address) in
            self.firstAddressLine.text = "\(address.subLocality ?? "") Mah. \(address.thoroughfare ?? "") No: \(address.subThoroughfare ?? "")"
            self.secondAddressLine.text = "\(address.locality ?? "") \(address.administrativeArea ?? "") \(address.postalCode ?? "")"
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum hizmetleri alınamadı: \(error.localizedDescription)")
    }
}
