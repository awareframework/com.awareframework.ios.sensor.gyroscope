import Foundation
import com_awareframework_ios_core
import GRDB

public struct GyroscopeData: BaseDbModelSQLite {
    public var id: Int64?
    public var timestamp: Int64 = 0
    public var deviceId: String = AwareUtils.getCommonDeviceId()
    public var label: String = ""
    public var timezone: Int = AwareUtils.getTimeZone()
    public var os: String = "iOS"
    public var jsonVersion: Int = 1
    public static let databaseTableName = "ios_gyroscope"

    public var x: Double = 0.0
    public var y: Double = 0.0
    public var z: Double = 0.0
    public var eventTimestamp: Int64 = 0
    public var accuracy: Int = 0

    public init() {}
    public init(x: Double, y: Double, z: Double, timestamp: Int64,
                eventTimestamp: Int64 = 0, accuracy: Int = 0) {
        self.x = x; self.y = y; self.z = z
        self.timestamp = timestamp
        self.eventTimestamp = eventTimestamp
        self.accuracy = accuracy
    }
    public init(_ dict: Dictionary<String, Any>) {
        timestamp      = dict["timestamp"] as? Int64 ?? 0
        label          = dict["label"] as? String ?? ""
        deviceId       = dict["deviceId"] as? String ?? AwareUtils.getCommonDeviceId()
        x              = dict["x"] as? Double ?? 0
        y              = dict["y"] as? Double ?? 0
        z              = dict["z"] as? Double ?? 0
        eventTimestamp = dict["eventTimestamp"] as? Int64 ?? 0
        accuracy       = dict["accuracy"] as? Int ?? 0
    }

    public static func createTable(queue: DatabaseQueue) throws {
        try queue.write { db in
            try db.create(table: databaseTableName, ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("deviceId", .text).notNull()
                t.column("timestamp", .integer).notNull()
                t.column("label", .text).notNull()
                t.column("timezone", .integer).notNull()
                t.column("os", .text).notNull()
                t.column("jsonVersion", .integer).notNull()
                t.column("x", .double).notNull()
                t.column("y", .double).notNull()
                t.column("z", .double).notNull()
                t.column("eventTimestamp", .integer).notNull()
                t.column("accuracy", .integer).notNull()
            }
        }
    }

    public func toDictionary() -> Dictionary<String, Any> {
        ["id": id ?? -1, "timestamp": timestamp, "deviceId": deviceId, "label": label,
         "timezone": timezone, "os": os, "jsonVersion": jsonVersion,
         "x": x, "y": y, "z": z, "eventTimestamp": eventTimestamp, "accuracy": accuracy]
    }
}
