//
//  ContentViewModel.swift
//  Rope
//
//  Created by Дарья Леонова on 02.02.2025.
//

import Combine
import SwiftUI

@Observable
final class ContentViewModel {

    // MARK: - Internal Properties

    var startPoint: CGPoint { CGPoint(x: 0, y: ropeHeight / 2) }
    var endPoint: CGPoint { CGPoint(x: ropeWidth, y: ropeHeight / 2) }
    var basePoints = Array(repeating: CGPoint.zero, count: 6)

    var ropeWidth: CGFloat = 0
    var ropeHeight: CGFloat = 0

    // MARK: - Private Properties

    private let motionManager = MotionManager()
    private var cancellable = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        subscribeOnMotion()
    }

    // MARK: - Internal Methods

    func onAppear() {
        randomizeControlPoints(isLeft: true)
        subscribeOnMotion()
    }

    func onSizeDidChange(_ size: CGRect) {
        // coeffs accordingly to the image
        ropeWidth = max(1.0, size.width * 0.366)
        ropeHeight = max(1.0, size.width * 0.214)

        motionManager.stopAccelerometers()
        motionManager.startAccelerometers(in: .init(origin: .zero, size: .init(width: ropeWidth, height: ropeHeight)))
    }

    // MARK: - Private Methods

    private func subscribeOnMotion() {
        motionManager.lastVirtualBallPositionPublisher
            .sink { [weak self] position in
                guard let self else {
                    return
                }
                randomizeControlPoints(isLeft: position.x < ropeWidth / 2)
            }
            .store(in: &cancellable)
    }

    private func randomizeControlPoints(isLeft: Bool) {
        let xRange = 0...ropeWidth
        // put control points above/below center
        let yRange = isLeft ? 0...(ropeHeight / 2) : (ropeHeight / 2)...ropeHeight
        basePoints = (0...5).map { _ in CGPoint(x: CGFloat.random(in: xRange), y: CGFloat.random(in: yRange)) }
    }

}
