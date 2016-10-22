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
    @IBOutlet weak var newButton: UIBarButtonItem!
    
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
        
        let fr = NSFetchRequest(entityName: "Photos")

        do {
            let result = try self.stack.context.executeFetchRequest(fr)
            
            if result.count != 0 {
                for managedObject in result {
                    print(managedObject.pin)
                    guard managedObject.pin == pin else {
                        continue
                    }
                    photos.append(managedObject as! Photos)
                }
            } else {
                getNewPhotos()
            }            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
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
        newButton.enabled = false
        
        for photo in photos {
            self.stack.context.deleteObject(photo)
        }
        
        photos.removeAll()
        
        FlickrClient.sharedInstance().getPhotos(Double(pin.latitude!), longitude: Double(pin.longitude!), pin: pin) { (result, error) in
            if let error = error {
                print(error)
            } else {
                if result!.count == 0 {
                    
                    let alertController = UIAlertController(title: "", message:
                        "No images found for this location", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photos = result!
                        self.collectionView.reloadData()
                        self.newButton.enabled = true
                    }
                }
             }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.stack.context.deleteObject(photos[indexPath.item])
        
        self.photos.removeAtIndex(indexPath.item)
        
        self.collectionView.deleteItemsAtIndexPaths([indexPath])
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCollectionViewCell
        
        cell.imageView.image = UIImage(named: "placeholder")
        cell.indicator.startAnimating()
        
        
        if photos[indexPath.item].data == nil {
            
            FlickrClient.sharedInstance().requestPhotoData(photos, indexPath: indexPath) { (result, error) in
                
                self.photos[indexPath.item].data = result
            
                dispatch_async(dispatch_get_main_queue()) {
                    cell.indicator.stopAnimating()
                    cell.indicator.hidden = true
                    cell.imageView!.image = UIImage(data: result) }
            }
        
        }
        
        else {
            cell.indicator.stopAnimating()
            cell.indicator.hidden = true
            cell.imageView.image = UIImage(data: photos[indexPath.item].data!)
        }

        return cell
    }
}
