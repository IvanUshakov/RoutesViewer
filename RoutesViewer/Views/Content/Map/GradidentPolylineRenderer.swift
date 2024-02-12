//
//  GradidentPolylineRenderer.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 30.01.2024.
//

import Foundation
import MapKit

extension GradidentPolylineRenderer {
    enum FillStyle {
        case gradient
        case color(CGColor)

        var fillColor: CGColor? {
            switch self {
            case .gradient: nil
            case .color(let color): color
            }
        }
    }

    struct PathElement { // todo: rename to PathSegment
        var start: CGPoint
        var startColor: CGColor
        var end: CGPoint
        var endColor: CGColor
        var fillPath: CGPath
        var borderPath: CGPath
        var shouldDrawArrow: Bool // TODO: cahnge to arrow path(CGPath) draw arrow on center of element
    }
}

class GradidentPolylineRenderer: MKOverlayRenderer {
    let gradientPolyline: GradientPolyline

    var borderWidth: CGFloat = 1
    var borderColor: CGColor?

    var fillWidth: CGFloat = 6 {
        didSet {
            cachedPathElemetsLock.around { // TODO: extract as invalidate
                self.cachedPathElemets = []
                self.cachedPathElemetsZoom = -1
                self.creatingPathElements = false
            }
        }
    }
    var fillStyle: FillStyle = .color(.black)

    var cachedPathElemets: [PathElement] = []
    var cachedPathElemetsZoom: MKZoomScale = -1
    var creatingPathElements: Bool = false
    var cachedPathElemetsLock = UnfairLock()

    init(gradientPolyline: GradientPolyline) {
        self.gradientPolyline = gradientPolyline
        super.init(overlay: gradientPolyline)
    }

    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool { // TODO: invalidate on zoom change
        print("canDraw: zoomScale: \(zoomScale)")
        cachedPathElemetsLock.lock()
        defer { cachedPathElemetsLock.unlock() }
        if !cachedPathElemets.isEmpty && cachedPathElemetsZoom == zoomScale { return true }
        if creatingPathElements { return false }
        creatingPathElements = true
        cachedPathElemetsZoom = zoomScale
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.createPathElements(zoomScale: zoomScale)
        }
        return false
    }

    func createPathElements(zoomScale: MKZoomScale) { //TODO: cancel than invalidated
        guard gradientPolyline.points.count > 2 else { return }

        let fillWidth = self.fillWidth / zoomScale
        let borderWidth = self.borderWidth / zoomScale

        let fillWidthSquared = pow(fillWidth, 2)
        let arrowIconDistance = 3 * fillWidthSquared

        var cachedPath: [PathElement] = []
        var prevCGPoint = self.point(for: gradientPolyline.points[0].coordinates)
        var prevColor = NSColor(hue: gradientPolyline.points[0].hue, saturation: 0.9, brightness: 0.9, alpha: 1).cgColor

        for index in 2..<gradientPolyline.points.count {
            let currentCGPoint = self.point(for: gradientPolyline.points[index].coordinates)
            let distanceSquared = CGPointDistanceSquared(from: prevCGPoint, to: currentCGPoint)

            guard distanceSquared > fillWidthSquared else { continue }
            let currentColor = NSColor(hue: gradientPolyline.points[index].hue, saturation: 0.9, brightness: 0.9, alpha: 1).cgColor
            defer {
                prevCGPoint = currentCGPoint
                prevColor = currentColor
            }

            let fillPath = linePath(start: prevCGPoint, end: currentCGPoint, width: fillWidth, startArc: cachedPath.isEmpty, endArk: true)
            var borderPath = linePath(start: prevCGPoint, end: currentCGPoint, width: fillWidth + borderWidth, startArc: false, endArk: true)
                .subtracting(fillPath)

            if !cachedPath.isEmpty {
                cachedPath[cachedPath.endIndex - 1].borderPath = cachedPath[cachedPath.endIndex - 1].borderPath
                    .subtracting(fillPath)
                    .subtracting(borderPath)

                cachedPath[cachedPath.endIndex - 1].fillPath = cachedPath[cachedPath.endIndex - 1].fillPath.subtracting(fillPath)
                borderPath = borderPath.subtracting(cachedPath[cachedPath.endIndex - 1].fillPath)
            }

            cachedPath.append(
                .init(
                    start: prevCGPoint,
                    startColor: prevColor,
                    end: currentCGPoint,
                    endColor: currentColor,
                    fillPath: fillPath,
                    borderPath: borderPath,
                    shouldDrawArrow: cachedPath.count % 4 == 0 // TODO: fix
                )
            )
        }

        cachedPathElemetsLock.around {
            self.cachedPathElemets = cachedPath
            self.creatingPathElements = false
        }

        self.setNeedsDisplay()
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let cachedPathElemets = cachedPathElemetsLock.around { self.cachedPathElemets }
        let fillColor = fillStyle.fillColor
        let arrowPath = arrowPath(size: self.fillWidth / zoomScale)

        for element in cachedPathElemets {
            context.saveGState()
            drawBorder(element.borderPath, borderColor: borderColor, borderWidth: borderWidth, in: context)
            if let fillColor {
                drawFill(element.fillPath, fillColor: fillColor, in: context)
            } else {
                drawGradient(element, in: context)
            }

            if element.shouldDrawArrow {
                drawArrow(currentPoint: element.end, iconPoint: element.start, arrowPath: arrowPath, in: context)
            }
            context.restoreGState()
        }
    }

//    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
//        guard rect(for: mapRect).intersects(self.path.boundingBox) else { return }
//        let strokeWidth: CGFloat = self.borderWidth / zoomScale
//        let strokeColor = self.strokeColor?.cgColor
//
//        let fillWidth: CGFloat = self.lineWidth / zoomScale
//        let fillColor = self.fillColor?.cgColor
//
//        let fillWidthSquared = pow(fillWidth, 2)
//        let arrowDistanceSquared: CGFloat = pow(self.arrowIconDistance / zoomScale, 2)
//        let arrowPath = arrowPath(size: fillWidth)
//
//        var index = 0
//        var prevIndex = 0
//        var prevPrevIndex = 0
//
//        var prevPoint = CGPoint.zero
//        var prevPrevPoint = CGPoint.zero
//        var prevIconPoint = CGPoint.zero
//
//        var prevPath: CGPath?
//
//        self.path.applyWithBlock { element in
//            defer { index += 1 }
//            let currentPoint = element.pointee.points.pointee
//
//            if element.pointee.type == .moveToPoint {
//                prevPoint = currentPoint
//                prevPrevPoint = currentPoint
//            } else if element.pointee.type == .addLineToPoint {
//                let distanceSquared = CGPointDistanceSquared(from: prevPoint, to: currentPoint)
//                context.saveGState()
//
//                // Filters part of the path to correct border, fill, gradient, and arrow overlaps
//                if distanceSquared > 2 * fillWidthSquared {
//                    let path = linePath(start: prevPoint, end: currentPoint, width: fillWidth, startArc: false, endArk: true)
//                    drawBorder(path, strokeColor: strokeColor, strokeWidth: strokeWidth, in: context)
//                    // Fill is drawn on top of the previous path to prevent it from being overlapped by next border
//                    drawFill(prevPath, fillColor: fillColor, in: context)
//                    // Gradient is drawn on top of the previous path to prevent it from being overlapped by next border
//                    drawGradient(prevPath, index: prevIndex, point: prevPoint, prevIndex: prevPrevIndex, prevPoint: prevPrevPoint, in: context)
//
//                    prevPrevIndex = prevIndex
//                    prevIndex = index
//                    prevPrevPoint = prevPoint
//                    prevPoint = currentPoint
//                    prevPath = path
//                }
//
//                // Drawing arrows
//                if drawArrows {
//                    // Arrows is drawn on top of the previous path to prevent it from being overlapped by next border and fill
//                    let distanceSquared = CGPointDistanceSquared(from: prevIconPoint, to: prevPoint)
//                    if distanceSquared > arrowDistanceSquared {
//                        defer { prevIconPoint = prevPoint }
//                        if prevIconPoint != .zero {
//                            drawArrow(currentPoint: currentPoint, iconPoint: prevIconPoint, arrowPath: arrowPath, in: context)
//                        }
//                    }
//                }
//
//                context.restoreGState()
//            }
//        }
//
//        // Draw last step of fill and gradient
//        drawFill(prevPath, fillColor: fillColor, in: context)
//        drawGradient(prevPath, index: prevIndex, point: prevPoint, prevIndex: prevPrevIndex, prevPoint: prevPrevPoint, in: context)
//    }

    func drawBorder(_ path: CGPath, borderColor: CGColor?, borderWidth: CGFloat, in context: CGContext) {
        guard let borderColor else { return }
        context.addPath(path)
        context.setFillColor(borderColor)
        context.fillPath()
    }

    func drawFill(_ path: CGPath, fillColor: CGColor, in context: CGContext) {
        context.addPath(path)
        context.setFillColor(fillColor)
        context.fillPath()
    }

    func drawGradient(_ path: PathElement, in context: CGContext) {
        let colors = [path.startColor, path.endColor] as CFArray
        guard let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: [0, 1]) else { return }

        context.addPath(path.fillPath)
        context.clip()
        context.drawLinearGradient(gradient, start: path.start, end: path.end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        context.resetClip()
    }

    func drawArrow(currentPoint: CGPoint, iconPoint: CGPoint, arrowPath: CGPath, in context: CGContext) {
        let angle = atan2(currentPoint.y - iconPoint.y, currentPoint.x - iconPoint.x)
        context.translateBy(x: iconPoint.x, y: iconPoint.y)
        context.rotate(by: angle)
        context.addPath(arrowPath)
        context.setFillColor(.white)
//        if !drawGradient {
//            context.setBlendMode(.difference)
//        }
        context.fillPath()
    }

    func linePath(start: CGPoint, end: CGPoint, width: CGFloat, startArc: Bool, endArk: Bool) -> CGPath {
        let halfWidth = width / 2
        let angle = atan2(start.y - end.y, start.x - end.x)
        let dx = sin(angle) * halfWidth
        let dy = cos(angle) * halfWidth
        let path = CGMutablePath()
        path.move(to: .init(x: start.x - dx, y: start.y + dy))
        path.addLine(to: .init(x: end.x - dx, y: end.y + dy))
        path.addArc(center: end, radius: endArk ? halfWidth : 0, startAngle: angle + 0.5 * .pi, endAngle: angle + 1.5 * .pi, clockwise: false)
        path.addLine(to: .init(x: end.x + dx, y: end.y - dy))
        path.addLine(to: .init(x: start.x + dx, y: start.y - dy))
        path.addArc(center: start, radius: startArc ? halfWidth : 0, startAngle: angle + 1.5 * .pi, endAngle: angle + 0.5 * .pi, clockwise: false)
        path.closeSubpath()
        return path
    }

    func arrowPath(size: CGFloat) -> CGPath {
        let halfSize = size / 2
        let arrowPath = CGMutablePath()
        arrowPath.move(to: .init(x: -halfSize, y: -halfSize))
        arrowPath.addLine(to: .init(x: 0, y: 0))
        arrowPath.addLine(to: .init(x: -halfSize, y: halfSize))

        arrowPath.addLine(to: .init(x: halfSize, y: halfSize))
        arrowPath.addLine(to: .init(x: size, y: 0))
        arrowPath.addLine(to: .init(x: halfSize, y: -halfSize))
        arrowPath.closeSubpath()
        return arrowPath
    }

    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return pow(from.x - to.x, 2) + pow(from.y - to.y, 2)
    }
}

