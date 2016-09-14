//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Olivia Murphy on 8/23/16.
//  Copyright © 2016 Murphy. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var pin: Pin!
    
    var photos = [Photos]()
    
    var URLs = [String]()
    
    var stack: CoreDataStack!
    
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func newCollectionClicked() {
        getNewPhotos()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.addAnnotation()
        
        self.mapView.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = delegate.stack
        
        if photos.count == 0 {
            getNewPhotos()
        }
    }
    
    func addAnnotation() {
        let newAnotation = MKPointAnnotation()
        
        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(pin.latitude!), CLLocationDegrees(pin.longitude!))
        
        let span = MKCoordinateSpanMake(NSUserDefaults.standardUserDefaults().doubleForKey("mapLatDelta"), NSUserDefaults.standardUserDefaults().doubleForKey("mapLongDelta"))
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mapView.setRegion(region, animated: true)
        
        newAnotation.coordinate = coordinate
        mapView.addAnnotation(newAnotation)
    }
    
    func getNewPhotos () {
        FlickrClient.sharedInstance().getPhotos(Double(pin.latitude!), longitude: Double(pin.longitude!), pin: pin) { (result, error) in
            if let error = error {
                print(error)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.photos = result!
                    self.collectionView.reloadData()
                }
             }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.photos.removeAtIndex(indexPath.item)
        
        self.collectionView.deleteItemsAtIndexPaths([indexPath])
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCollectionViewCell
        
        cell.imageView.image = UIImage(named: "placeholder")
        cell.indicator.startAnimating()
        
        
        if photos[indexPath.item].data == nil {
            
            let requestURL: NSURL = NSURL(string: photos[indexPath.item].url!)!
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL) { (data, response, error) in
                
                guard (error == nil) else {
                    print("There was an error with your request: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data was returned by the request!")
                    return
                }
                
                self.photos[indexPath.item].data = data

                dispatch_async(dispatch_get_main_queue()) {
                    cell.indicator.stopAnimating()
                    cell.indicator.hidden = true
                    cell.imageView!.image = UIImage(data: data)}
                }
            
            task.resume()
        }
        
        else {
            cell.indicator.stopAnimating()
            cell.indicator.hidden = true
            cell.imageView.image = UIImage(data: photos[indexPath.item].data!)
            //stop activity indicator

        }

        return cell
    }
}