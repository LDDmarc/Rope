//
//  Rope.swift
//  Rope
//
//  Created by Дарья Леонова on 02.02.2025.
//

import SwiftUI

struct Rope: Shape {

    // Package the six control points into nested AnimatablePair structures.
        var animatableData: AnimatablePair<
            CGPoint,
            AnimatablePair<
                CGPoint,
                AnimatablePair<
                    CGPoint,
                    AnimatablePair<
                        CGPoint,
                        AnimatablePair<CGPoint, CGPoint>
                    >
                >
            >
        > {
            get {
                AnimatablePair(
                    basePoints[0],
                    AnimatablePair(
                        basePoints[1],
                        AnimatablePair(
                            basePoints[2],
                            AnimatablePair(
                                basePoints[3],
                                AnimatablePair(basePoints[4], basePoints[5])
                            )
                        )
                    )
                )
            }
            set {
                basePoints[0] = newValue.first
                let pair2 = newValue.second
                basePoints[1] = pair2.first
                let pair3 = pair2.second
                basePoints[2] = pair3.first
                let pair4 = pair3.second
                basePoints[3] = pair4.first
                let pair5 = pair4.second
                basePoints[4] = pair5.first
                basePoints[5] = pair5.second
            }
        }

    // Fixed endpoints for the Bézier curve.
    private let P0: CGPoint
    private let P7: CGPoint
    private var basePoints: [CGPoint]

    // Target arc length for the curve.
    private let fixedArcLength: CGFloat

    // MARK: - Init

    init?(
        start: CGPoint,
        end: CGPoint,
        basePoints: [CGPoint]
    ) {
        guard basePoints.count == 6 else { return nil }
        self.P0 = start
        self.P7 = end
        self.basePoints = basePoints
        self.fixedArcLength = (end.x - start.x) * 1.5

    }

    // MARK: - Internal Methods

    func path(in rect: CGRect) -> Path {
        let lambda = computeLambda()
        let adjustedControls = basePoints.map { adjustedPoint(for: $0, lambda: lambda) }

        // Build the full set of control points for the degree‑7 curve.
        let controlPoints: [CGPoint] = [P0] + adjustedControls + [P7]

        // Sample points along the curve.
        let curvePoints = computeBezierCurvePoints(controlPoints: controlPoints, steps: 300)

        // Draw the Bézier curve (blue).
        var curvePath = Path()
        if let first = curvePoints.first {
            curvePath.move(to: first)
        }
        for pt in curvePoints.dropFirst() {
            curvePath.addLine(to: pt)
        }
        return curvePath
    }

}

// MARK: - Private Methods

private extension Rope {

    // MARK: - Bézier Curve Functions

    /// Computes a point on a degree‑7 Bézier curve for a given parameter t (0 ≤ t ≤ 1).
    ///
    /// The curve is defined as:
    /// \[
    /// B(t) = \sum_{i=0}^{7} \binom{7}{i} (1-t)^{7-i} t^i P_i,
    /// \]
    /// using the provided control points.
    func computeBezierPoint(t: CGFloat, controlPoints: [CGPoint]) -> CGPoint {
        // Precomputed binomial coefficients for degree 7: [1, 7, 21, 35, 35, 21, 7, 1]
        let coeffs: [CGFloat] = [1, 7, 21, 35, 35, 21, 7, 1]

        var x: CGFloat = 0
        var y: CGFloat = 0

        for i in 0..<controlPoints.count {
            let binCoeff = coeffs[i]
            let term = binCoeff * pow((1 - t), CGFloat(7 - i)) * pow(t, CGFloat(i))
            x += term * controlPoints[i].x
            y += term * controlPoints[i].y
        }
        return CGPoint(x: x, y: y)
    }

    /// Samples the Bézier curve at a given number of steps and returns an array of points.
    func computeBezierCurvePoints(controlPoints: [CGPoint], steps: Int) -> [CGPoint] {
        (0...steps).reduce(into: [CGPoint]()) { partialResult, i in
            let t = CGFloat(i) / CGFloat(steps)
            partialResult.append(computeBezierPoint(t: t, controlPoints: controlPoints))
        }
    }

    /// Numerically approximates the arc length of the Bézier curve by sampling points.
    func bezierArcLength(controlPoints: [CGPoint], steps: Int) -> CGFloat {
        let pts = computeBezierCurvePoints(controlPoints: controlPoints, steps: steps)
        var length: CGFloat = 0.0
        for i in 1..<pts.count {
            let dx = pts[i].x - pts[i-1].x
            let dy = pts[i].y - pts[i-1].y
            length += sqrt(dx * dx + dy * dy)
        }
        return length
    }

    // MARK: - Fixed Arc Length Adjustment

    /// Adjusts a given inner control point by scaling its offset from its projection onto the line (P0, P7).
    func adjustedPoint(for basePoint: CGPoint, lambda: CGFloat) -> CGPoint {
        // Compute t: the parameter such that Lerp(P0, P7, t) is the projection of basePoint onto the line P0-P7.
        let v = CGPoint(x: P7.x - P0.x, y: P7.y - P0.y)
        let vMagSq = v.x * v.x + v.y * v.y
        // Dot product of (basePoint - P0) and v:
        let dot = (basePoint.x - P0.x) * v.x + (basePoint.y - P0.y) * v.y
        let t = vMagSq != 0 ? dot / vMagSq : 0.0
        // The projection on the line:
        let L = CGPoint(x: P0.x + t * v.x, y: P0.y + t * v.y)
        // Adjusted point: move the basePoint toward or away from L by lambda.
        let dx = basePoint.x - L.x
        let dy = basePoint.y - L.y
        return CGPoint(x: L.x + lambda * dx, y: L.y + lambda * dy)
    }

    /// Computes a lambda scaling factor (via binary search) so that the Bézier curve has arc length ≈ fixedArcLength.
    ///
    /// We adjust only the inner control points.
    func computeLambda() -> CGFloat {
        // We'll search for lambda in a reasonable range.
        var lower: CGFloat = 0.1
        var upper: CGFloat = 5.0
        var lambda: CGFloat = 1.0

        for _ in 0..<20 {
            lambda = (lower + upper) / 2.0
            let adjustedControls = basePoints.map { adjustedPoint(for: $0, lambda: lambda) }
            let controlPoints = [P0] + adjustedControls + [P7]
            let currentLength = bezierArcLength(controlPoints: controlPoints, steps: 300)

            if currentLength < fixedArcLength {
                lower = lambda
            } else {
                upper = lambda
            }
        }
        return lambda
    }
}
