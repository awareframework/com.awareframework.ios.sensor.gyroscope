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
        let frequency = 10
        var sensor = GyroscopeSensor(GyroscopeSensor.Config())
        XCTAssertEqual(sensor.CONFIG.frequency, 5)

        sensor = GyroscopeSensor(GyroscopeSensor.Config().apply { config in
            config.frequency = frequency
        })
        XCTAssertEqual(sensor.CONFIG.frequency, frequency)

        sensor = GyroscopeSensor(GyroscopeSensor.Config(["frequency": frequency]))
        XCTAssertEqual(sensor.CONFIG.frequency, frequency)
    }

    func testGyroscopeData() {
        let data = GyroscopeData(x: 1, y: 2, z: 3, timestamp: 4, eventTimestamp: 5, accuracy: 0)
        let dict = data.toDictionary()
        XCTAssertEqual(dict["x"] as? Double, 1)
        XCTAssertEqual(dict["y"] as? Double, 2)
        XCTAssertEqual(dict["z"] as? Double, 3)
        XCTAssertEqual(dict["timestamp"] as? Int64, 4)
    }
}
