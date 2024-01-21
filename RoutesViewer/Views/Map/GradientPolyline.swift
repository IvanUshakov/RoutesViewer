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

    public func getHue(from index: Int) -> CGColor {
        return NSColor(hue: hues[index], saturation: 0.9, brightness: 0.9, alpha: 1).cgColor
    }
}

extension GradientPolyline {
    convenience init(points: [Point], maxVelocity: Double, minVelocity: Double = 0) {
        let coordinates = points.map(\.coordinates)
        self.init(coordinates: coordinates, count: coordinates.count)

        let hueDiaposon = (Self.maxHue - Self.minHue)
        let velocityDiaposon = (maxVelocity - minVelocity)
        hues = points.map { CGFloat(Self.minHue + (($0.velocity - minVelocity) * hueDiaposon) / velocityDiaposon) }
    }
}

extension GradientPolyline {
    struct Point {
        let coordinates: CLLocationCoordinate2D
        let velocity: Double
    }
}

class GradidentPolylineRenderer: MKPolylineRenderer {
    var showBorder: Bool = false
    var borderColor: NSColor = .black
    var borderWidth: CGFloat = 1

    var arrowIcon: NSImage?
    var arrowIconDistance: CGFloat = 70

    let gradientPolyline: GradientPolyline

    init(gradientPolyline: GradientPolyline) {
        self.gradientPolyline = gradientPolyline
        super.init(overlay: gradientPolyline)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard rect(for: mapRect).intersects(self.path.boundingBox) else { return }

        drawBorder(in: context, zoomScale: zoomScale)
//        drawFill(in: context, zoomScale: zoomScale)
        drawGradient(in: context, zoomScale: zoomScale)
        drawIcons(in: context, zoomScale: zoomScale, mapRect: mapRect)
    }

    func drawBorder(in context: CGContext, zoomScale: MKZoomScale) {
        guard showBorder else { return }
        let borderWidth: CGFloat = self.lineWidth / zoomScale
        
        context.saveGState()
        context.setLineWidth(borderWidth)
        context.setLineJoin(self.lineJoin)
        context.setLineCap(self.lineCap)
        if let lineDashPattern {
            let phase = self.lineDashPhase / zoomScale
            let lineDashPattern = lineDashPattern.map { CGFloat($0.doubleValue / zoomScale) }
            context.setLineDash(phase: phase, lengths: lineDashPattern)
        }
        context.setStrokeColor(borderColor.cgColor)
        context.addPath(self.path)
        context.strokePath()
        context.restoreGState()
    }

    func drawFill(in context: CGContext, zoomScale: MKZoomScale) {
        let fillWidth: CGFloat = abs(self.lineWidth - self.borderWidth) / zoomScale
       
        context.saveGState()
        context.setLineWidth(fillWidth)
        context.setLineJoin(self.lineJoin)
        context.setLineCap(self.lineCap)
        context.setStrokeColor(NSColor.red.cgColor)
        context.addPath(self.path)
        context.strokePath()
        context.restoreGState()
    }

    func drawGradient(in context: CGContext, zoomScale: MKZoomScale) {
        let fillWidth: CGFloat = abs(self.lineWidth - self.borderWidth) / zoomScale
        
        let mapPoints = self.gradientPolyline.points()
        var prevMapPoint: MKMapPoint?
        var prevColor: CGColor?
        for index in 0..<self.gradientPolyline.pointCount - 1 {
            let currentMapPoint = mapPoints[index]
            let currentColor = gradientPolyline.getHue(from: index)
            guard let unwrapedPrevMapPoint = prevMapPoint, let unwrapedPrevColor = prevColor else {
                prevMapPoint = currentMapPoint
                prevColor = currentColor
                continue
            }

            defer {
                prevMapPoint = currentMapPoint
                prevColor = currentColor
            }

            let startPoint = self.point(for: unwrapedPrevMapPoint)
            let endPoint = self.point(for: currentMapPoint)

            context.saveGState()
            let path = CGMutablePath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            context.setLineWidth(fillWidth)
            context.setLineJoin(self.lineJoin)
            context.setLineCap(self.lineCap)
            context.addPath(path)


            let colors = [unwrapedPrevColor, currentColor] as CFArray
            let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: [0, 1])
            context.replacePathWithStrokedPath()
            context.clip()
            context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
            context.restoreGState()
        }
    }

    func drawIcons(in context: CGContext, zoomScale: MKZoomScale, mapRect: MKMapRect) {
        guard self.gradientPolyline.pointCount > 2 else { return }
        guard let arrowIcon else { return }

        let fillWidth: CGFloat = abs(self.lineWidth - self.borderWidth) / zoomScale
        let distance: CGFloat = self.arrowIconDistance / zoomScale
        var drawRect = NSRect(origin: .zero, size: CGSize(width: fillWidth, height: fillWidth))
        guard let cgImage = arrowIcon.cgImage(forProposedRect: &drawRect, context: .current, hints: nil) else { return }

        let mapPoints = self.gradientPolyline.points()
        var prevMapPoint: MKMapPoint?
        for index in 0..<self.gradientPolyline.pointCount - 1 {
            let currentMapPoint = mapPoints[index]
            guard let unwrapedPrevMapPoint = prevMapPoint else {
                prevMapPoint = currentMapPoint
                continue
            }

            let startPoint = self.point(for: unwrapedPrevMapPoint)
            let endPoint = self.point(for: currentMapPoint)
            let distanceSquared = CGPointDistanceSquared(from: startPoint, to: endPoint)

            if distanceSquared > distance * distance {
                let bearing = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
                let scaleTransform = CGAffineTransform(scaleX: 1, y: -1)
                let rotateTransform = scaleTransform.rotated(by: -bearing)
                let transformed = startPoint.applying(rotateTransform)
                let newPoint = CGPoint(x: transformed.x - drawRect.midX, y: transformed.y - drawRect.midY)
                context.saveGState()
                context.scaleBy(x: 1, y: -1)
                context.rotate(by: -bearing)
                context.setBlendMode(.luminosity)
                context.setAlpha(0.9)
                context.draw(cgImage, in: NSRect(origin: newPoint, size: drawRect.size))
                context.restoreGState()
                prevMapPoint = currentMapPoint
            }
        }
    }

    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
}
