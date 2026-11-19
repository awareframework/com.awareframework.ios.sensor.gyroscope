import XCTest
import com_awareframework_ios_sensor_gyroscope
import com_awareframework_ios_core

final class Tests: XCTestCase {

    func testControllers() {
        let sensor = GyroscopeSensor(GyroscopeSensor.Config().apply { config in
            config.debug = true
        })

        let expectSetLabel = expectation(description: "set label")
        let newLabel = "hello"
        let labelObserver = NotificationCenter.default.addObserver(
            forName: .actionAwareGyroscopeSetLabel, object: nil, queue: .main) { notification in
            XCTAssertEqual(
                (notification.userInfo as? [String: String])?[GyroscopeSensor.EXTRA_LABEL],
                newLabel)
            expectSetLabel.fulfill()
        }
        sensor.set(label: newLabel)
        wait(for: [expectSetLabel], timeout: 5)
        NotificationCenter.default.removeObserver(labelObserver)

        let expectSync = expectation(description: "sync")
        let syncObserver = NotificationCenter.default.addObserver(
            forName: .actionAwareGyroscopeSync, object: nil, queue: .main) { _ in
            expectSync.fulfill()
        }
        sensor.sync()
        wait(for: [expectSync], timeout: 5)
        NotificationCenter.default.removeObserver(syncObserver)
    }

    func testConfig() {
        let samplingFrequencyHz = 10
        var sensor = GyroscopeSensor(GyroscopeSensor.Config())
        XCTAssertEqual(sensor.CONFIG.samplingFrequencyHz, 5)

        sensor = GyroscopeSensor(GyroscopeSensor.Config().apply { config in
            config.samplingFrequencyHz = samplingFrequencyHz
        })
        XCTAssertEqual(sensor.CONFIG.samplingFrequencyHz, samplingFrequencyHz)

        sensor = GyroscopeSensor(GyroscopeSensor.Config(["samplingFrequencyHz": samplingFrequencyHz]))
        XCTAssertEqual(sensor.CONFIG.samplingFrequencyHz, samplingFrequencyHz)
    }

    func testGyroscopeData() {
        let data = GyroscopeData(x: 1, y: 2, z: 3, timestamp: 4, eventTimestamp: 5, accuracy: 0)
        let dict = data.toDictionary()
        XCTAssertEqual(dict["x"] as? Double, 1)
        XCTAssertEqual(dict["y"] as? Double, 2)
        XCTAssertEqual(dict["z"] as? Double, 3)
        XCTAssertEqual(dict["timestamp"] as? Int64, 4)
    }

    /// The sensor creates its own table: rows can be saved and read back for sync without the app
    /// creating the table (it used to be missing, so every save failed and nothing was synced)
    func testSensorCreatesItsTable() {
        let sensor = GyroscopeSensor(GyroscopeSensor.Config().apply { config in
            config.dbPath = "create_table_test_\(UUID().uuidString)"
        })
        XCTAssertEqual(sensor.CONFIG.dbTableName, GyroscopeData.databaseTableName)
        guard let engine = sensor.dbEngine else { return XCTFail("no engine") }
        let saved = expectation(description: "saved")
        engine.save([GyroscopeData()]) { error in
            XCTAssertNil(error)
            saved.fulfill()
        }
        wait(for: [saved], timeout: 5)
        XCTAssertEqual(engine.count(filter: nil), 1)
        XCTAssertEqual(engine.fetch(filter: nil, limit: nil)?.count, 1, "rows can be read for sync")
    }

    /// Up to 1.6.2 the table was in aware.sqlite. Rows not uploaded yet move to aware_gyroscope.sqlite
    func testRowsInThePreviousDatabaseMove() throws {
        func engine(_ path: String) throws -> SQLiteEngine {
            let e = try XCTUnwrap(Engine.Builder().setPath(path).setType(.sqlite)
                .setTableName(GyroscopeData.databaseTableName).build() as? SQLiteEngine)
            try GyroscopeData.createTable(queue: try XCTUnwrap(e.getSQLiteInstance()))
            return e
        }
        let old = try engine("aware")
        let saved = expectation(description: "saved")
        old.save([GyroscopeData(), GyroscopeData(), GyroscopeData()]) { error in
            XCTAssertNil(error)
            saved.fulfill()
        }
        wait(for: [saved], timeout: 5)
        let before = try engine(GyroscopeSensor.Config.defaultDbPath).count(filter: nil)

        let sensor = GyroscopeSensor()
        XCTAssertEqual(sensor.CONFIG.dbPath, "aware_gyroscope")
        XCTAssertEqual(sensor.dbEngine?.count(filter: nil), before + 3, "the rows moved")
        XCTAssertFalse(try old.getAllTableNames().contains(GyroscopeData.databaseTableName), "the old table is dropped")
    }
}
