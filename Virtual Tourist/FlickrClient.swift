//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Olivia Murphy on 8/24/16.
//  Copyright © 2016 Murphy. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient: NSObject {
    
    var stack: CoreDataStack!

    func getPhotos(latitude: Double, longitude: Double, pin: Pin, completionHandlerForPhotos: (result: [Photos]?, error: String?) -> Void) {
        
        taskForGETMethod(latitude, longitude: longitude) { (results, error) in
            
            if let error = error {
                completionHandlerForPhotos(result: nil, error: error)
            } else {
                
                var finalPhotos: [Photos] = []
                
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                self.stack = delegate.stack
                
                let photos = results["photos"] as! [String: AnyObject]
                
                let photo = photos["photo"] as! [[String: AnyObject]]
                
                for p in photo {
                    let farm = p["farm"]
                    let server = p["server"]
                    let id = p["id"]
                    let secret = p["secret"]
            
                    let url = "http://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_m.jpg"
                    
                    let data = NSData(contentsOfURL: NSURL(string: url)!)
                    
                    let photo = Photos(url: url, data: data, context: self.stack.context)
                    
                    photo.pin = pin
                    
                    finalPhotos.append(photo)
                }
                completionHandlerForPhotos(result: finalPhotos, error: nil)
            }
        }
    }
    
    func taskForGETMethod(latitude: Double, longitude: Double, completionHandlerForGET: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        
        let page = 1
        //arc4random_uniform(191) + 1
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=7eaeeb9b2a2b5fb73118f4802fa13b65&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1&per_page=21&page=\(page)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        let session = NSURLSession.sharedSession()
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                completionHandlerForGET(result: nil, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if ((response as? NSHTTPURLResponse)?.statusCode == 403) {
                    sendError("403")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: String?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerForConvertData(result: nil, error: "Could not parse data")
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}