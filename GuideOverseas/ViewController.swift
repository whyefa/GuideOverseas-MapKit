//
//  ViewController.swift
//  GuideOverseas
//
//  Created by iOS on 15/6/15.
//  Copyright (c) 2015年 com.haitaolvyou. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,MKMapViewDelegate,LocationDelegate{
    var anno: MKPointAnnotation?
    var anno1: MKPointAnnotation?

    var mapView: MKMapView!
    var button: UIButton!
    var tap: UITapGestureRecognizer?
    var rallyPoint: MKPointAnnotation?
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.sharedInstance.delegate = self
        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true
//        if #available(iOS 9.0, *) {
//            mapView.showsTraffic = true
//        } else {
//            // Fallback on earlier versions
//        }
        mapView.showsPointsOfInterest = true
        self.view .addSubview(mapView!)
        
        
        button = UIButton(type:UIButtonType.Custom)
        button.setTitle("路径规划", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        button.frame = CGRectMake(10, self.view.frame.size.height-50, 80, 40)
        button.addTarget(self, action: "planPath", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        
        tap = UITapGestureRecognizer(target: self, action: "tapMapView:")
        mapView.addGestureRecognizer(tap!)
        /** 百度坐标转换测试*/
        /*
        anno1 = MKPointAnnotation()
        anno1?.title = "百度定位"
        var loc = CLLocation(latitude: 39.997287, longitude: 116.344078)
        var newLoc = loc.locationMarsFromBaidu()
        anno1?.coordinate = newLoc.coordinate
        mapView?.addAnnotation(anno1)
        */
        let infoBtn = UIButton(type:UIButtonType.Custom)
        infoBtn.setTitle("需求", forState: UIControlState.Normal)
        infoBtn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        infoBtn.addTarget(self, action: "showMessage", forControlEvents: UIControlEvents.TouchUpInside)
        infoBtn.frame = CGRectMake(10, 20, 80, 40)
        infoBtn.tintColor = UIColor.orangeColor()
        self.view.addSubview(infoBtn)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func showMessage() {
        let alert = UIAlertView(title: "打开应用后,截取以下相关图片", message: "查看地图在国外建筑,街道,标志建筑,等信息的详细程度。\n查看苹果地图框架,在国外是否是使用高德地图数据。\n查看用户位置在国外显示是否准确。\n查看大头针和'当前位置'是否重合", delegate: self, cancelButtonTitle: "确定")
        alert.show()
        
    }

    func tapMapView(gesture: UITapGestureRecognizer) {
        self.mapView.removeOverlays(mapView.overlays)
        let point: CGPoint = gesture.locationInView(self.view)
        let tcoor = mapView.convertPoint(point, toCoordinateFromView: mapView)
        if anno1 == nil {
            self.anno1 = MKPointAnnotation()
            self.anno1!.coordinate = tcoor
            self.mapView.addAnnotation(self.anno1!)
        }
        anno1!.coordinate = tcoor
    }
    
    // MARK: 地图代理
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        struct StaticLStruct {
            static var predicate: dispatch_once_t = 0
        }
        dispatch_once(&StaticLStruct.predicate, { () -> Void in
            self.mapView.selectAnnotation(self.mapView.userLocation, animated: true)
        })
        
    }
    
    
    // MARK: LocationManager 代理
    func locationDidUpdate() {
        struct StaticStruct {
            static var predicate : dispatch_once_t = 0
        }
        dispatch_once(&StaticStruct.predicate) {
            let span = MKCoordinateSpanMake(0.003, 0.003)
            let loc = LocationManager.sharedInstance.manager.location!.locationMarsFromEarth()
            let region = MKCoordinateRegionMake(loc.coordinate, span)
            self.mapView?.setRegion(region, animated: false)
        }
        if anno == nil {
            anno = MKPointAnnotation()
            anno?.title = "GPRS 定位"
            mapView?.addAnnotation(anno!)
        }
        // Location 转换
//        let marsLocation = LocationManager.sharedInstance.manager.location!.locationMarsFromEarth()
//        self.streetOfLocation(marsLocation)
        self.streetOfLocation(LocationManager.sharedInstance.manager.location!)
        anno?.coordinate = LocationManager.sharedInstance.manager.location!.coordinate
        
    }
    func headingDidUpdate() {
        
    }
    
    // MARK: 地图代理
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(anno) {
            let viewIdentifier = "viewId"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(viewIdentifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: viewIdentifier)
//                annotationView!.image = UIImage(named: "pink")
                annotationView!.pinColor = MKPinAnnotationColor.Purple
                annotationView!.canShowCallout = true
                
            }
            return annotationView
        }else if annotation.isEqual(anno1) {
            let viewIdentifier = "viewId"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(viewIdentifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: viewIdentifier)
                //                annotationView!.image = UIImage(named: "pink")
                annotationView!.pinColor = MKPinAnnotationColor.Green
                annotationView!.canShowCallout = true
                
            }
            return annotationView
        }else if annotation.isEqual(anno1) {
            let vID = "arrow"
            var av = mapView.dequeueReusableAnnotationViewWithIdentifier(vID)
            if av == nil {
                av = MKAnnotationView(annotation: anno1, reuseIdentifier: vID)
                av?.image = UIImage(named: "location")
            }
            return av
        }else if annotation.isKindOfClass(MKUserLocation) {
            print(123)
             mapView.setCamera(mapView.camera, animated: true)
            
        }
        
        return nil
    }
    //MARK: 反地理编码
    func streetOfLocation(location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            if error != nil {
                print("reverse geodcode fail: \(error!.localizedDescription)")
                return
            }else {
                let pm = placeMarks as NSArray?
                
                if pm!.count > 0
                {
                    let p = pm?.objectAtIndex(0)  as! CLPlacemark
                    self.anno?.subtitle = p.name
                }
            }

        })
    }
    


    //MARK: 线路规划

    func planPath() {
        
        if anno1 == nil {
            return
        }

        let fromCoordinate = mapView.userLocation.location!.coordinate
        let toCoordinate = anno1?.coordinate
        let fromPlaceMark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlaceMark = MKPlacemark(coordinate: toCoordinate!, addressDictionary: nil)
        let fromItem = MKMapItem(placemark: fromPlaceMark)
        let toItem = MKMapItem(placemark: toPlaceMark)
        self.findDirection(fromItem, destination: toItem)
    }
    func findDirection(source: MKMapItem, destination:MKMapItem) {
        let request = MKDirectionsRequest()
        request.destination = destination
        request.transportType = MKDirectionsTransportType.Walking
        request.source = source
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if  (error != nil) {
                print(error)
            }else {
                let route: MKRoute = response!.routes[0] as MKRoute
                self.mapView.addOverlay(route.polyline)
            }
        }
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor.orangeColor()
        return renderer
    }
    func setMapRegionWithLocation() {
        let span = MKCoordinateSpanMake(0.003, 0.003)
        let loc = mapView.userLocation.location
        let region = MKCoordinateRegionMake(loc!.coordinate, span)
        self.mapView?.setRegion(region, animated: false)
    }

        //MARK: 屏幕旋转
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        mapView.frame = self.view.bounds
        button.frame = CGRectMake(10, self.view.bounds.size.height-50, 50, 40)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}

