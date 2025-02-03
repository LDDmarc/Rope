//
//  File.swift
//  Rope
//
//  Created by Дарья Леонова on 02.02.2025.
//

import SwiftUI

extension CGPoint: @retroactive AdditiveArithmetic {}

extension CGPoint: @retroactive VectorArithmetic {
    public static var zero: CGPoint {
        CGPoint(x: 0, y: 0)
    }

    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }

    public static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }

    public mutating func scale(by rhs: Double) {
        x.scale(by: rhs)
        y.scale(by: rhs)
    }

    public var magnitudeSquared: Double {
        Double(x * x + y * y)
    }
}
