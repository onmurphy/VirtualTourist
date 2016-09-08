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

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var pin: Pin!
    
    var URLs = [String]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        FlickrClient.sharedInstance().getPhotos(Double(pin.latitude!), longitude: Double(pin.longitude!)) { (result, error) in
            if let error = error {
                print(error)
            } else {
                
                self.addAnnotation()
                
                self.mapView.delegate = self
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                
                self.navigationController?.navigationBarHidden = false
                
                self.URLs = result!
                
                self.collectionView.reloadData()
            }
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.URLs.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //delete photo
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCollectionViewCell
        
        let url = NSURL(string: self.URLs[indexPath.item])
        let data = NSData(contentsOfURL: url!)
        cell.imageView.image = UIImage(data: data!)
        return cell
    }
}