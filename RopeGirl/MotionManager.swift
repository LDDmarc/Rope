//
//  MotionManager.swift
//  Rope
//
//  Created by Дарья Леонова on 02.02.2025.
//

import Foundation
import CoreMotion
import Combine

final class MotionManager {

    var lastVirtualBallPositionPublisher = CurrentValueSubject<CGPoint, Never>(.zero)

    private let motion = CMMotionManager()
    private var timer: Timer?

    func startAccelerometers(in rect: CGRect) {
        let updateInterval = 1.0 / 50.0  // 50 Hz
        
        // Make sure the accelerometer hardware is available.
        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = updateInterval
            motion.startAccelerometerUpdates()

            timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
                guard
                    let self,
                    let acceleration = motion.accelerometerData?.acceleration
                else {
                    return
                }

                let x = acceleration.x
                let y = acceleration.y
                let z = acceleration.z

                let totalAcceleration = sqrt(x * x + y * y + z * z)

                guard totalAcceleration > 2 else {
                    return
                }

                let sensitivity = 15.0
                var newPosition = CGPoint.zero
                newPosition.x = x * sensitivity
                newPosition.y = y * (-sensitivity)

                newPosition.x = max(0, min(lastVirtualBallPositionPublisher.value.x + newPosition.x, rect.width))
                newPosition.y = max(0, min(lastVirtualBallPositionPublisher.value.y + newPosition.y, rect.height))

                lastVirtualBallPositionPublisher.send(newPosition)
            }
        }
    }

    func stopAccelerometers() {
        timer?.invalidate()
        timer = nil
    }
}
