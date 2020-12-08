//
//  ViewController.swift
//  CoffeeQuest
//
//  Created by SungHo Han on 2020/12/04.
//

import MapKit
import YelpAPI
import UIKit

// test

class ViewController: UIViewController {
    
    // MARK: - Properties
    private var businesses: [YLPBusiness] = []
    private let client = YLPClient(apiKey: YelpAPIKey)
    private let locationManager = CLLocationManager()
    
    // MARK: - Outlets
    @IBOutlet public var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Actions
    @IBAction func businessFilterToggleChanged(_ sender: UISwitch) {
        
    }


}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        centerMap(on: userLocation.coordinate)
    }
    
    private func centerMap(on coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 3000
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
        searchForBusinesses()
    }
    
    private func searchForBusinesses() {
        let coordinate = mapView.userLocation.coordinate
        guard coordinate.latitude != 0, coordinate.longitude != 0 else {
            return
        }
        
        let yelpCoordinate = YLPCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        client.search(with: yelpCoordinate,
                      term: "coffee",
                      limit: 35,
                      offset: 0,
                      sort: .bestMatched) { [weak self] (searchResult, error) in
            guard let self = self else { return }
            guard let searchResult = searchResult,
                  error == nil else {
                print("Search failed: \(String(describing: error?.localizedDescription))")
                return
            }
            self.businesses = searchResult.businesses
            DispatchQueue.main.async {
                self.addAnnotations()
            }
        }
        
    }
    
    private func addAnnotations() {
        for business in businesses {
            guard let yelpCoordinate = business.location.coordinate else {
                continue
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: yelpCoordinate.latitude, longitude: yelpCoordinate.longitude)
            let name = business.name
            let rating = business.rating
            let image: UIImage
            
            switch rating {
            case 0.0..<3.5:
                image = UIImage(named: "bad")!
            case 3.5..<4.0:
                image = UIImage(named: "meh")!
            case 4.0..<4.75:
                image = UIImage(named: "good")!
            case 4.75...5.0:
                image = UIImage(named: "great")!
            default:
                image = UIImage(named: "bad")!
            }
            
            let annotation = BusinessMapViewModel(coordinate: coordinate, name: name, rating: rating, image: image)
            
            mapView.addAnnotation(annotation)
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let viewModel = annotation as? BusinessMapViewModel else {
            return nil
        }
        
        let identifier = "business"
        let annotationView: MKAnnotationView
        
        if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView = existingView
        } else {
            annotationView = MKAnnotationView(annotation: viewModel, reuseIdentifier: identifier)
        }
        
        annotationView.image = viewModel.image
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    
}

