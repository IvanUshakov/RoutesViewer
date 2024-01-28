//
//  GradientPolyline.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 21.01.2024.
//

import Foundation
import MapKit

class GradientPolyline: MKPolyline {
    static let maxHue = 0.25
    static let minHue = 0.0

    var hues: [CGFloat] = []

    convenience init(points: [Point], maxVelocity: Double, minVelocity: Double = 0) {
        let coordinates = points.map(\.coordinates)
        self.init(coordinates: coordinates, count: coordinates.count)

        let hueRange = (Self.maxHue - Self.minHue)
        let velocityRange = (maxVelocity - minVelocity)
        hues = points.map { CGFloat(Self.minHue + (($0.velocity - minVelocity) * hueRange) / velocityRange) }
    }
}

extension GradientPolyline {
    struct Point {
        let coordinates: CLLocationCoordinate2D
        let velocity: Double
    }
}

class GradidentPolylineRenderer: MKPolylineRenderer {
    let gradientPolyline: GradientPolyline

    var borderWidth: CGFloat = 1
    var arrowIcon: NSImage?
    var arrowIconDistance: CGFloat = 70
    var gradient: Bool = true // TODO: rename

    init(gradientPolyline: GradientPolyline) {
        self.gradientPolyline = gradientPolyline
        super.init(overlay: gradientPolyline)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard rect(for: mapRect).intersects(self.path.boundingBox) else { return }
        let borderWidth: CGFloat = self.lineWidth / zoomScale
        let fillWidth: CGFloat = abs(self.lineWidth - self.borderWidth) / zoomScale
        let fillWidthSquared = pow(fillWidth, 2)

        let iconDistanceSquared: CGFloat = pow(self.arrowIconDistance / zoomScale, 2)
        var iconDrawRect = NSRect(origin: .zero, size: CGSize(width: fillWidth, height: fillWidth))
        let iconImage = arrowIcon?.cgImage(forProposedRect: &iconDrawRect, context: .current, hints: nil)

        var index = 0
        var prevIndex = 0
        var prevPrevIndex = 0
        var prevPoint = CGPoint.zero
        var prevPrevPoint = CGPoint.zero
        var prevPath: CGPath?
        var prevIconPoint = CGPoint.zero
        self.path.applyWithBlock { element in
            defer {
                index += 1
            }

            let currentPoint = element.pointee.points.pointee

            switch element.pointee.type {
            case .moveToPoint:
                prevPoint = currentPoint
            case .addLineToPoint:
                let distanceSquared = CGPointDistanceSquared(from: prevPoint, to: currentPoint)
                context.saveGState()
                context.setLineJoin(.round)
                context.setLineCap(.round)

                // Create path
                let path = CGMutablePath()
                path.move(to: prevPoint)
                path.addLine(to: currentPoint)
                path.closeSubpath()

                // Filtering part of a path to fix border overlap on a fill
                if distanceSquared > fillWidthSquared {
                    // Drawing border
                    if let strokeColor {
                        context.addPath(path)
                        context.setLineWidth(borderWidth)
                        context.setStrokeColor(strokeColor.cgColor)
                        context.strokePath()
                    }

                    // Drawing fill
                    // Fill is drawn on top of the previous path to prevent next border from overlapping fill
                    if let prevPath, let fillColor, !gradient {
                        context.addPath(prevPath)
                        context.setLineWidth(fillWidth)
                        context.setStrokeColor(fillColor.cgColor)
                        context.strokePath()
                    }

                    // Draw gradient
                    // Gradient is drawn on top of the previous path to prevent next border from overlapping gradient
                    if let prevPath, gradient {
                        let prevPrevColor = NSColor(hue: gradientPolyline.hues[prevPrevIndex], saturation: 0.9, brightness: 0.9, alpha: 1).cgColor
                        let prevColor = NSColor(hue: gradientPolyline.hues[prevIndex], saturation: 0.9, brightness: 0.9, alpha: 1).cgColor
                        let colors = [prevPrevColor, prevColor] as CFArray
                        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: [0, 1])

                        context.addPath(prevPath)
                        context.setLineWidth(fillWidth)
                        context.replacePathWithStrokedPath()
                        context.clip()
                        context.drawLinearGradient(gradient!, start: prevPrevPoint, end: prevPoint, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
                        context.resetClip()
                    }

                    prevPrevIndex = prevIndex
                    prevIndex = index
                    prevPrevPoint = prevPoint
                    prevPoint = currentPoint
                    prevPath = path
                }

                // Drawing icons
                // Icons is drawn on top of the previous path to prevent next border and fill from overlapping icon
                if let iconImage {
                    let distanceSquared = CGPointDistanceSquared(from: prevIconPoint, to: prevPoint)
                    if distanceSquared > iconDistanceSquared {
                        let bearing = atan2(prevPoint.y - prevIconPoint.y, prevPoint.x - prevIconPoint.x) // TODO: fix angle calculation
                        let scaleTransform = CGAffineTransform(scaleX: 1, y: -1)
                        let rotateTransform = scaleTransform.rotated(by: -bearing)
                        let transformed = prevIconPoint.applying(rotateTransform)
                        let newPoint = CGPoint(x: transformed.x - iconDrawRect.midX, y: transformed.y - iconDrawRect.midY)
                        context.scaleBy(x: 1, y: -1)
                        context.rotate(by: -bearing)
                        if !gradient {
                            context.setBlendMode(.difference)
                        }
                        context.draw(iconImage, in: NSRect(origin: newPoint, size: iconDrawRect.size))
                        prevIconPoint = prevPoint
                    }
                }

                context.restoreGState()
            case .addQuadCurveToPoint: break
            case .addCurveToPoint: break
            case .closeSubpath: break
            @unknown default: break
            }
        }
    }

    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
}
