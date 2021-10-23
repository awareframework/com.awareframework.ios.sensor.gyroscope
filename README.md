# AWARE: Gyroscope

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.gyroscope.svg?style=flat)](https://travis-ci.org/awareframework/com.awareframework.ios.sensor.gyroscope)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.gyroscope.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.gyroscope)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.gyroscope.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.gyroscope)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.gyroscope.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.gyroscope)

This sensor module allows us to retrieve data from the onboard gyroscopes. The data is provided by iOS Core Motion Library. Please check the link below for details. 

> A gyroscope measures the rate at which a device rotates around a spatial axis. Many iOS devices have a three-axis gyroscope, which delivers rotation values in each of the three axes. Rotation values are measured in radians per second around the given axis. Rotation values may be positive or negative depending on the direction of rotation.

[ Apple | Getting Raw Gyroscope Events ] (https://developer.apple.com/documentation/coremotion/getting_raw_gyroscope_events)
[ Apple | Core Motion | CMGyroData ] (https://developer.apple.com/documentation/coremotion/cmgyrodata)

## Requirements
iOS 10 or later

## Installation

com.awareframework.ios.sensor.gyroscope is available through [CocoaPods](https://cocoapods.org). 

1. To install it, simply add the following line to your Podfile:
```ruby
pod 'com.awareframework.ios.sensor.gyroscope'
```

2. Import com.awareframework.ios.sensor.gyroscope library into your source code.
```swift
import com_awareframework_ios_sensor_gyroscope
```

## Public functions

### GyroscopeSensor

+ `init(config:GyroscopeSensor.Config?)` : Initializes the gyroscope sensor with the optional configuration.
+ `start()`: Starts the gyroscope sensor with the optional configuration.
+ `stop()`: Stops the service.

### GyroscopeSensor.Config

Class to hold the configuration of the sensor.

#### Fields
+ `sensorObserver: GyroscopeObserver`: Callback for live data updates.
+ `frequency: Int`: Data samples to collect per second (Hz). (default = 5)
+ `period: Double`: Period to save data in minutes. (default = 1)
+ `threshold: Double`: If set, do not record consecutive points if change in value is less than the set value.
+ `enabled: Boolean` Sensor is enabled or not. (default = `false`)
+ `debug: Boolean` enable/disable logging to Xcode console. (default = `false`)
+ `label: String` Label for the data. (default = "")
+ `deviceId: String` Id of the device that will be associated with the events and the sensor. (default = "")
+ `dbEncryptionKey` Encryption key for the database. (default = `null`)
+ `dbType: Engine` Which db engine to use for saving data. (default = `Engine.DatabaseType.NONE`)
+ `dbPath: String` Path of the database. (default = "aware_gyroscope")
+ `dbHost: String` Host for syncing the database. (default = `null`)

## Broadcasts

### Fired Broadcasts

+ `GyroscopeSensor.ACTION_AWARE_GYROSCOPE` fired when gyroscope saved data to db after the period ends.

### Received Broadcasts

+ `GyroscopeSensor.ACTION_AWARE_GYROSCOPE_START`: received broadcast to start the sensor.
+ `GyroscopeSensor.ACTION_AWARE_GYROSCOPE_STOP`: received broadcast to stop the sensor.
+ `GyroscopeSensor.ACTION_AWARE_GYROSCOPE_SYNC`: received broadcast to send sync attempt to the host.
+ `GyroscopeSensor.ACTION_AWARE_GYROSCOPE_SET_LABEL`: received broadcast to set the data label. Label is expected in the `GyroscopeSensor.EXTRA_LABEL` field of the intent extras.

## Data Representations

### Gyroscope Data

Contains the raw sensor data.

| Field     | Type   | Description                                                     |
| --------- | ------ | --------------------------------------------------------------- |
| x         | Double  | The value for the X-axis.                                                |
| y         | Double  | The value for the Y-axis.                                            |
| z         | Double  | The value for the Z-axis.                                               |
| label     | String | Customizable label. Useful for data calibration or traceability |
| deviceId  | String | AWARE device UUID                                               |
| label     | String | Customizable label. Useful for data calibration or traceability |
| timestamp | Int64   | unixtime milliseconds since 1970                                |
| timezone  | Int    | Raw timezone offset of the device                          |
| os        | String | Operating system of the device (ex. ios)                    |

## Example usage
```swift
let gyroSensor = GyroscopeSensor.init(GyroscopeSensor.Config().apply{ config in
    config.debug = true
    config.sensorObserver = Observer()
})
gyroSensor?.start()
```

```swift
class Observer:GyroscopeObserver {
    func onChanged(data: GyroscopeData) {
        // Your code here...
    }
}
```

## Author

Yuuki Nishiyama, yuukin@iis.u-tokyo.ac.jp

## License

Copyright (c) 2021 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

