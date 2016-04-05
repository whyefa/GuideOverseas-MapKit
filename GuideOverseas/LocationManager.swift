
//
//  LocationManager.swift
//  GuideOverseas
//
//  Created by iOS on 15/6/15.
//  Copyright (c) 2015年 com.haitaolvyou. All rights reserved.
//

import UIKit
import MapKit


protocol LocationDelegate {
    func locationDidUpdate();
    func headingDidUpdate();
}


let singleManager = LocationManager()

class LocationManager: NSObject,CLLocationManagerDelegate {
    var manager:CLLocationManager!
    var delegate:LocationDelegate?
    
    override init() {
        super.init()
        manager = CLLocationManager()
        if #available(iOS 8.0, *) {
            manager.requestAlwaysAuthorization()
            manager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    // dispatch_once  执行且在整个程序的声明周期中，仅执行一次某一个block对象
    class var sharedInstance : LocationManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : LocationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationManager()
        }
        return Static.instance!
    }
    
    /***
    + (LocationManager *)sharedManager {
        static LocationManager *sharedAccountManagerInstance = nil;
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            sharedAccountManagerInstance = [[self alloc] init];
        });
        return sharedAccountManagerInstance;
    }
    */
    
    // global constant 全局变量
//    class var sharedManager: LocationManager {
//        return singleManager
//    }
    
    /*
    static LocationManager *DefaultManager = nil;
    
    + (LocationManager *)defaultManager  {
            if (!DefaultManager)
                DefaultManager = [[self allocWithZone:NULL] init];
            return DefaultManager;
    }




*/
    
    // struct
//    class var sharedLocationManager : LocationManager {
//        struct Static {
//            static let instance : LocationManager = LocationManager()
//        }
//        return Static.instance
//    }
    
    //MARK: CLLocationManager 代理
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.delegate?.locationDidUpdate()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.delegate?.headingDidUpdate()
    }

    func start() {
        LocationManager.sharedInstance.manager.startUpdatingLocation()
    }
}
