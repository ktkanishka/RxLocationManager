//
//  BeaconRangingService.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

//MARK: BeaconRangingServiceConfigurable
public protocol BeaconRangingServiceConfigurable{
    var rangedRegions: Set<CLRegion> {get}
    func startRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService
    func stopRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService
    func stopRangingBeaconsInAllRegions() -> BeaconRangingService
}
//MARK: BeaconRangingService
public protocol BeaconRangingService: BeaconRangingServiceConfigurable{
    var ranging: Observable<([CLBeacon], CLBeaconRegion)>{get}
    var rangingError: Observable<(CLBeaconRegion, NSError)>{get}
}
//MARK: DefaultBeaconRagningService
class DefaultBeaconRangingService: BeaconRangingService{
    private let locMgr: Bridge = Bridge(bridgedManager: CLLocationManager())
    
    private var observers = [(id:Int, observer: AnyObserver<([CLBeacon], CLBeaconRegion)>)]()
    private var errorObservers = [(id:Int, observer: AnyObserver<(CLBeaconRegion, NSError)>)]()
    
    var rangedRegions: Set<CLRegion> {
        get{
            return locMgr.manager.rangedRegions
        }
    }
    var ranging: Observable<([CLBeacon], CLBeaconRegion)>{
        get{
            return Observable.create{
                observer in
                var ownerService:DefaultBeaconRangingService! = self
                let id = nextId()
                ownerService.observers.append((id, observer))
                return AnonymousDisposable{
                    ownerService.observers.removeAtIndex(ownerService.observers.indexOf{$0.id == id}!)
                    ownerService = nil
                }
            }
        }
    }
    var rangingError: Observable<(CLBeaconRegion, NSError)>{
        get{
            return Observable.create{
                observer in
                var ownerService:DefaultBeaconRangingService! = self
                let id = nextId()
                ownerService.errorObservers.append((id, observer))
                return AnonymousDisposable{
                    ownerService.errorObservers.removeAtIndex(ownerService.errorObservers.indexOf{$0.id == id}!)
                    ownerService = nil
                }
            }
        }
    }
    
    init(){
        locMgr.didRangeBeaconsInRegion = {
            [weak self]
            mgr, beacons, region in
            if let copyOfObservers = self?.observers{
                for (_, observer) in copyOfObservers{
                    observer.onNext((beacons, region))
                }
            }
        }
        
        locMgr.rangingBeaconsDidFailForRegion = {
            [weak self]
            mgr, region, error in
            if let copyOfErrorObservers = self?.errorObservers{
                for (_, observer) in copyOfErrorObservers{
                    observer.onNext((region, error))
                }
            }
        }
    }
    
    func startRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService {
        for region in regions{
            locMgr.manager.startRangingBeaconsInRegion(region)
        }
        return self
    }
    
    func stopRangingBeaconsInRegions(regions: [CLBeaconRegion]) -> BeaconRangingService {
        for region in regions{
            locMgr.manager.stopRangingBeaconsInRegion(region)
        }
        return self
    }
    
    func stopRangingBeaconsInAllRegions() -> BeaconRangingService {
        for region in rangedRegions as! Set<CLBeaconRegion>{
            locMgr.manager.stopRangingBeaconsInRegion(region)
        }
        return self
    }
    
    deinit{
        stopRangingBeaconsInAllRegions()
    }
}