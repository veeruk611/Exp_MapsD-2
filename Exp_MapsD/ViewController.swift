//
//  ViewController.swift
//  Exp_MapsD
//
//  Created by Manjunadh Bommisetty on 22/01/20.
//  Copyright © 2020 BRN. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UITextFieldDelegate,GMSAutocompleteViewControllerDelegate {
    
    
    
    var selectedTF:String = ""

    @IBOutlet weak var sourceTF: UITextField!
    
    @IBOutlet weak var destinationTF: UITextField!
    
    
    var acvc = GMSAutocompleteViewController()
    
    var sourceLoc = CLLocation()
    var destinationLoc = CLLocation()
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceTF.delegate = self
        destinationTF.delegate = self
        acvc.delegate = self
        
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        //let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //view = mapView
        
        mapView.camera = camera
        

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(textField == sourceTF)
        {
            selectedTF = "source"
            textField.resignFirstResponder()
            
            present(acvc, animated: true, completion: nil)
            
            
        }else if(textField == destinationTF)
        {
            selectedTF = "destination"
            textField.resignFirstResponder()
            
            present(acvc, animated: true, completion: nil)
            
        }
        
        
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("success in selection")
        
        dismiss(animated: true, completion: nil)
        
        if(selectedTF == "source")
        {
            sourceTF.text = place.name!
            
            sourceLoc = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }else if(selectedTF == "destination")
        {
            destinationTF.text = place.name!
            
            destinationLoc = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("failed")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        
        print("cancelled")
    }
    
    
    @IBAction func onGetDirections(_ sender: Any)
    {
        
        
        drawPath(startLocation: sourceLoc, endLocation: destinationLoc)
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        mapView.clear()
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: startLocation.coordinate.latitude, longitude: startLocation.coordinate.longitude)
        marker.title = sourceTF.text!
        marker.snippet = sourceTF.text!
        marker.map = mapView
        
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: endLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude)
        marker2.title = destinationTF.text!
        marker2.snippet = destinationTF.text!
        marker2.map = mapView
        
        
        
        
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDuBvXGuYzrnh51qC3brdG0OQCsXFHCNLU"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            do{
            let json = try JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.mapView
            }
                
                let camera = GMSCameraPosition.camera(withLatitude: self.sourceLoc.coordinate.latitude, longitude: self.sourceLoc.coordinate.longitude, zoom: 5.0
            )
                
                self.mapView.camera = camera
            }catch
            {
                print("unable to create route")
            }
            
        }
    }
    


}

