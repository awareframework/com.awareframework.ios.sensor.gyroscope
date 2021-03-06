//
//  GyroscopeSensor.swift
//  com.aware.ios.sensor.gyroscope
//
//  Created by Yuuki Nishiyama on 2018/10/26.
//

import UIKit
import CoreMotion
import com_awareframework_ios_sensor_core

extension Notification.Name{
    public static let actionAwareGyroscope         = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE)
    public static let actionAwareGyroscopeStart    = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_START)
    public static let actionAwareGyroscopeStop     = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_STOP)
    public static let actionAwareGyroscopeSync     = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_SYNC)
    public static let actionAwareGyroscopeSyncCompletion  = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_SYNC_COMPLETION)
    public static let actionAwareGyroscopeSetLabel = Notification.Name(GyroscopeSensor.ACTION_AWARE_GYROSCOPE_SET_LABEL)
}

public protocol GyroscopeObserver{
    func onDataChanged(data:GyroscopeData)
}

public extension GyroscopeSensor{
    static let TAG = "AWARE::Gyroscope"
    
    static let ACTION_AWARE_GYROSCOPE = "ACTION_AWARE_GYROSCOPE"
    
    static let ACTION_AWARE_GYROSCOPE_START = "com.awareframework.ios.sensor.gyroscope.SENSOR_START"
    static let ACTION_AWARE_GYROSCOPE_STOP = "com.awareframework.ios.sensor.gyroscope.SENSOR_STOP"
    
    static let ACTION_AWARE_GYROSCOPE_SET_LABEL = "com.awareframework.ios.sensor.gyroscope.ACTION_AWARE_GYROSCOPE_SET_LABEL"
    static let EXTRA_LABEL = "label"
    
    static let ACTION_AWARE_GYROSCOPE_SYNC = "com.awareframework.ios.sensor.gyroscope.SENSOR_SYNC"
    static let ACTION_AWARE_GYROSCOPE_SYNC_COMPLETION = "com.awareframework.ios.sensor.gyroscope.SENSOR_SYNC_COMPLETION"
    static let EXTRA_STATUS = "status"
    static let EXTRA_ERROR = "error"
}

public class GyroscopeSensor: AwareSensor {
    
    public var CONFIG = GyroscopeSensor.Config()
    public var motion = CMMotionManager()
    public var LAST_DATA:CMGyroData?
    var LAST_TS:Double   = Date().timeIntervalSince1970
    var LAST_SAVE:Double = Date().timeIntervalSince1970
    public var dataBuffer = Array<GyroscopeData>()
    
    public class Config:SensorConfig{
        /**
         * The defualt value of Android is 200000 microsecond.
         * The value means 5Hz
         */
        public var frequency:Int  = 5 // Hz
        public var period:Double  = 1 // min
        /**
         * Accelerometer threshold (Double).  Do not record consecutive points if
         * change in value of all axes is less than this.
         */
        public var threshold: Double = 0
        
        public var sensorObserver:GyroscopeObserver?
        
        public override func set(config: Dictionary<String, Any>) {
            
            super.set(config: config)
            
            if let frequency = config["frequency"] as? Int {
                self.frequency = frequency
            }
            
            if let period = config["period"] as? Double {
                self.period = period
            }
            
            if let threshold = config["threshold"] as? Double {
                self.threshold = threshold
            }
        }
        
        public func apply(closure: (_ config: GyroscopeSensor.Config) -> Void) -> Self{
            closure(self)
            return self
        }
        
    }
    
    public override convenience init(){
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
            self.motion.gyroUpdateInterval = 1.0/Double(CONFIG.frequency)
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
                    data.label = self.CONFIG.label
                
                    if let observer = self.CONFIG.sensorObserver {
                        observer.onDataChanged(data: data)
                    }
                    
                    self.dataBuffer.append(data)
                    
                    if self.dataBuffer.count < Int(self.CONFIG.frequency) && currentTime < self.LAST_SAVE + (self.CONFIG.period * 60) {
                        return
                    }
                    
                    let dataArray = Array(self.dataBuffer)
                    
                    let queue = DispatchQueue(label:"com.awareframework.ios.sensor.gyroscope.save.queue")
                    queue.async {
                        if let engine = self.dbEngine{
                            engine.save(dataArray){ error in
                                if error == nil {
                                    DispatchQueue.main.async {
                                        self.notificationCenter.post(name: .actionAwareGyroscope, object: self)
                                    }
                                }else{
                                    if self.CONFIG.debug { print(error!) }
                                }
                            }
                        }
                    }
                    self.dataBuffer.removeAll()
                    self.LAST_SAVE = currentTime
                }
            }
            
            if self.CONFIG.debug{ print(GyroscopeSensor.TAG, "Gyroscope sensor active: \(self.CONFIG.frequency) hz") }
            self.notificationCenter.post(name: .actionAwareGyroscopeStart, object: self)
        }
    }
    
    public override func stop() {
        if self.motion.isGyroAvailable{
            if self.motion.isGyroActive{
                self.motion.stopGyroUpdates()
                if self.CONFIG.debug{ print(GyroscopeSensor.TAG, "Gyroscope sensor terminated") }
                self.notificationCenter.post(name: .actionAwareGyroscopeStop, object: self)
            }
        }
    }
    
    public override func sync(force: Bool = false) {
        if let engine = self.dbEngine{
            engine.startSync(GyroscopeData.TABLE_NAME, GyroscopeData.self, DbSyncConfig.init().apply{ config in
                config.debug = self.CONFIG.debug
                config.dispatchQueue = DispatchQueue(label: "com.awareframework.ios.sensor.gyroscope.sync.queue")
                config.completionHandler = { (status, error) in
                    var userInfo: Dictionary<String,Any> = [GyroscopeSensor.EXTRA_STATUS :status]
                    if let e = error {
                        userInfo[GyroscopeSensor.EXTRA_ERROR] = e
                    }
                    self.notificationCenter.post(name: .actionAwareGyroscopeSyncCompletion ,
                                                 object: self,
                                                 userInfo:userInfo)
                }
            })
            self.notificationCenter.post(name: .actionAwareGyroscopeSync, object: self)
        }
    }
    
    public override func set(label:String) {
        self.CONFIG.label = label
        self.notificationCenter.post(name: .actionAwareGyroscopeSetLabel, object: self, userInfo:[GyroscopeSensor.EXTRA_LABEL:label])
    }
}
