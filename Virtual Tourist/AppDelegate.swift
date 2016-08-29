//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Olivia Murphy on 8/22/16.
//  Copyright © 2016 Murphy. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let stack = CoreDataStack(modelName: "Model")!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        stack.autoSave(60)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        do {
          try stack.saveContext()
        }
        catch {
            print ("Error saving context")
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        do {
            try stack.saveContext()
        }
        catch {
            print ("Error saving context")
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

