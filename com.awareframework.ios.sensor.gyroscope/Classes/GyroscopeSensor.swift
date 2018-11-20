//
//  GyroscopeSensor.swift
//  com.aware.ios.sensor.gyroscope
//
//  Created by Yuuki Nishiyama on 2018/10/26.
//

import UIKit
import SwiftyJSON
import CoreMotion
import com_awareframework_ios_sensor_core

extension Notification.Name{
    public static let actionAwareGyroscope         = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE)
    public static let actionAwareGyroscopeStart    = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_START)
    public static let actionAwareGyroscopeStop     = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_STOP)
    public static let actionAwareGyroscopeSync     = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_SYNC)
    public static let actionAwareGyroscopeSetLabel = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_SET_LABEL)
}

public protocol GyroscopeObserver{
    func onChanged(data:GyroscopeData)
}

public extension GyroscopeSensor{
    public static let TAG = "AWARE::Gyroscope"
    
    public static let ACTION_AWARE_GYROSCOPE = "ACTION_AWARE_GYROSCOPE"
    
    public static let ACTION_AWARE_GYROSCOPE_START = "com.awareframework.android.sensor.gyroscope.SENSOR_START"
    public static let ACTION_AWARE_GYROSCOPE_STOP = "com.awareframework.android.sensor.gyroscope.SENSOR_STOP"
    
    public static let ACTION_AWARE_GYROSCOPE_SET_LABEL = "com.awareframework.android.sensor.gyroscope.ACTION_AWARE_GYROSCOPE_SET_LABEL"
    public static let EXTRA_LABEL = "label"
    
    public static let ACTION_AWARE_GYROSCOPE_SYNC = "com.awareframework.android.sensor.gyroscope.SENSOR_SYNC"
}

public class GyroscopeSensor: AwareSensor {
    
    var CONFIG = GyroscopeSensor.Config()
    var motion = CMMotionManager()
    var LAST_DATA:CMGyroData?
    var LAST_TS:Double   = 0.0
    var LAST_SAVE:Double = 0.0
    public var dataBuffer = Array<GyroscopeData>()
    
    public class Config:SensorConfig{
        /**
         * The defualt value of Android is 200000 microsecond.
         * The value means 5Hz
         */
        public var frequency:Double  = 5 // Hz
        public var period:Double     = 0 // min
        /**
         * Accelerometer threshold (Double).  Do not record consecutive points if
         * change in value of all axes is less than this.
         */
        public var threshold: Double = 0
        public var sensorObserver:GyroscopeObserver?
        
        
        public override init(){}
        
        public init(_ json:JSON){
            
        }
        
        public func apply(closure: (_ config: GyroscopeSensor.Config) -> Void) -> Self{
            closure(self)
            return self
        }
        
    }
    
    override convenience init(){
        self.init(GyroscopeSensor.Config())
    }
    
    public init(_ config:GyroscopeSensor.Config){
        super.init()
        self.CONFIG = config
        self.initializeDbEngine(config: config)
        if config.debug{ print(GyroscopeSensor.TAG, "Gyroscope sensor is created.") }
    }
    
    public override func start() {
        if self.motion.isGyroAvailable {
            self.motion.gyroUpdateInterval = 1.0/CONFIG.frequency
            self.motion.startGyroUpdates(to: .main) { (gyroScopeData, error) in
                if let gyroData = gyroScopeData{
                    let x = gyroData.rotationRate.x
                    let y = gyroData.rotationRate.y
                    let z = gyroData.rotationRate.z
                    if let lastData = self.LAST_DATA {
                        if self.CONFIG.threshold > 0 &&
                            abs(x - lastData.rotationRate.x) < self.CONFIG.threshold &&
                            abs(y - lastData.rotationRate.y) < self.CONFIG.threshold &&
                            abs(z - lastData.rotationRate.z) < self.CONFIG.threshold {
                                return
                        }
                    }
                    
                    self.LAST_DATA = gyroData
                    
                    let currentTime:Double = Date().timeIntervalSince1970
                    self.LAST_TS = currentTime
                    
                    let data = GyroscopeData()
                    data.timestamp = Int64(currentTime*1000)
                    data.x = gyroData.rotationRate.x
                    data.y = gyroData.rotationRate.y
                    data.z = gyroData.rotationRate.z
                    data.eventTimestamp = Int64(gyroData.timestamp*1000)
                
                    if let observer = self.CONFIG.sensorObserver {
                        observer.onChanged(data: data)
                    }
                    
                    self.dataBuffer.append(data)
                    
                    if self.dataBuffer.count < Int(self.CONFIG.frequency) && currentTime > self.LAST_SAVE + (self.CONFIG.period * 60) {
                        return
                    }
                    
                    let dataArray = Array(self.dataBuffer)
                    self.dbEngine?.save(dataArray, GyroscopeData.TABLE_NAME)
                    self.notificationCenter.post(name: .actionAwareGyroscope, object: nil)
                    
                    self.dataBuffer.removeAll()
                    self.LAST_SAVE = currentTime
                }
            }
            
            if self.CONFIG.debug{ print(GyroscopeSensor.TAG, "Gyroscope sensor active: \(self.CONFIG.frequency) hz") }
            self.notificationCenter.post(name: .actionAwareGyroscopeStart, object:nil)
        }
    }
    
    public override func stop() {
        if self.motion.isGyroAvailable{
            if self.motion.isGyroActive{
                self.motion.stopGyroUpdates()
                if self.CONFIG.debug{ print(GyroscopeSensor.TAG, "Gyroscope sensor terminated") }
                self.notificationCenter.post(name: .actionAwareGyroscopeStop, object:nil)
            }
        }
    }
    
    public override func sync(force: Bool = false) {
        if let engine = self.dbEngine{
            engine.startSync(GyroscopeData.TABLE_NAME, DbSyncConfig.init().apply{ config in
                
            })
            self.notificationCenter.post(name: .actionAwareGyroscopeSync, object:nil)
        }
    }
}
