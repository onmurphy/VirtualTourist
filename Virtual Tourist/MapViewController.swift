//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Olivia Murphy on 8/22/16.
//  Copyright © 2016 Murphy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var stack: CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = delegate.stack
        
        self.mapView.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.dropPin(_:)))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        
        loadPins()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore") == true) {
            let coordinate = CLLocationCoordinate2DMake(NSUserDefaults.standardUserDefaults().doubleForKey("mapLat"), NSUserDefaults.standardUserDefaults().doubleForKey("mapLong"))
            
            let span = MKCoordinateSpanMake(NSUserDefaults.standardUserDefaults().doubleForKey("mapLatDelta"), NSUserDefaults.standardUserDefaults().doubleForKey("mapLongDelta"))
            
            let region = MKCoordinateRegion(center: coordinate, span: span)
            
            self.mapView.setRegion(region, animated: true)

        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
        }
    }

    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = false
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        let reuseId = "pin"
    
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        var pin : Pin!
        
        let lat = view.annotation?.coordinate.latitude
        let long = view.annotation?.coordinate.longitude
        
        do {
            let fr = NSFetchRequest(entityName: "Pin")
            let pred = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [lat!, long!])
            fr.predicate = pred
            
            let pins = try stack.context.executeFetchRequest(fr) as? [Pin]

            pin = pins![0]
        } catch let error {
            print (error)
        }
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        vc.pin = pin
        vc.mapView = mapView
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let centerCoordinate = mapView.region.center
        
        let lat = centerCoordinate.latitude
        let long = centerCoordinate.longitude
        
        let latDelta = mapView.region.span.latitudeDelta
        let longDelta = mapView.region.span.longitudeDelta
        
        NSUserDefaults.standardUserDefaults().setDouble(lat, forKey: "mapLat")
        NSUserDefaults.standardUserDefaults().setDouble(long, forKey: "mapLong")
        
        NSUserDefaults.standardUserDefaults().setDouble(latDelta, forKey: "mapLatDelta")
        NSUserDefaults.standardUserDefaults().setDouble(longDelta, forKey: "mapLongDelta")
    }
    
    func dropPin(gestureRecognizer:UIGestureRecognizer) {
        
        if gestureRecognizer.state == .Began {
            let touchPoint = gestureRecognizer.locationInView(self.mapView)
            let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            let newAnotation = MKPointAnnotation()
            newAnotation.coordinate = newCoord
            mapView.addAnnotation(newAnotation)
            
            let pin = Pin(lat: newCoord.latitude, long: newCoord.longitude, context: stack.context)
            
            do{
                try self.stack.context.save()
            }catch{
                fatalError("Error while saving main context: \(error)")
            }
        }
        
    }
    
    func loadPins() {
        do {
            let fr = NSFetchRequest(entityName: "Pin")
            
            let pins = try stack.context.executeFetchRequest(fr) as? [Pin]
            
            for pin in pins! {
                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(pin.latitude!), CLLocationDegrees(pin.longitude!))
                
                let newAnotation = MKPointAnnotation()
                newAnotation.coordinate = coordinate
                mapView.addAnnotation(newAnotation)
            }
        } catch let error {
            print (error)
        }
    }

}

