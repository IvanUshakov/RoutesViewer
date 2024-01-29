//
//  GradidentPolylineRenderer.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 30.01.2024.
//

import Foundation
import MapKit

class GradidentPolylineRenderer: MKPolylineRenderer {
    let gradientPolyline: GradientPolyline

    var drawBorder: Bool = false
    var borderWidth: CGFloat = 1

    var drawArrows: Bool = false
    var arrowIconDistance: CGFloat = 70

    var drawGradient: Bool = false

    init(gradientPolyline: GradientPolyline) {
        self.gradientPolyline = gradientPolyline
        super.init(overlay: gradientPolyline)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard rect(for: mapRect).intersects(self.path.boundingBox) else { return }
        let borderWidth: CGFloat = self.lineWidth / zoomScale
        let fillWidth: CGFloat = abs(self.lineWidth - self.borderWidth) / zoomScale

        let fillWidthSquared = pow(fillWidth, 2)
        let arrowDistanceSquared: CGFloat = pow(self.arrowIconDistance / zoomScale, 2)
        let arrowPath = arrowPath(size: fillWidth)

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
                    if let strokeColor, drawBorder {
                        context.addPath(path)
                        context.setLineWidth(borderWidth)
                        context.setStrokeColor(strokeColor.cgColor)
                        context.strokePath()
                    }

                    // Drawing fill
                    // Fill is drawn on top of the previous path to prevent next border from overlapping fill
                    if let prevPath, let fillColor, !drawGradient {
                        context.addPath(prevPath)
                        context.setLineWidth(fillWidth)
                        context.setStrokeColor(fillColor.cgColor)
                        context.strokePath()
                    }

                    // Draw gradient
                    // Gradient is drawn on top of the previous path to prevent next border from overlapping gradient
                    if let prevPath, drawGradient {
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

                // Drawing arrows
                // Arrows is drawn on top of the previous path to prevent next border and fill from overlapping arrows
                if drawArrows {
                    let distanceSquared = CGPointDistanceSquared(from: prevIconPoint, to: prevPoint)
                    if distanceSquared > arrowDistanceSquared {
                        let angle = atan2(currentPoint.y - prevIconPoint.y, currentPoint.x - prevIconPoint.x)
                        context.translateBy(x: prevIconPoint.x, y: prevIconPoint.y)
                        context.rotate(by: angle)
                        context.addPath(arrowPath)
                        context.setFillColor(.white)
                        if !drawGradient {
                            context.setBlendMode(.difference)
                        }
                        context.fillPath()
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

    func arrowPath(size: CGFloat) -> CGPath {
        let arrowPath = CGMutablePath()
        arrowPath.move(to: .init(x: -size / 2, y: -size / 2))
        arrowPath.addLine(to: .init(x: 0, y: 0))
        arrowPath.addLine(to: .init(x: -size / 2, y: size / 2))

        arrowPath.addLine(to: .init(x: size / 2, y: size / 2))
        arrowPath.addLine(to: .init(x: size, y: 0))
        arrowPath.addLine(to: .init(x: size / 2, y: -size / 2))
        arrowPath.closeSubpath()
        return arrowPath
    }

    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
}

