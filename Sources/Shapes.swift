import SwiftUI

// MARK: - Общая форма пламени

struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height

        path.move(to: CGPoint(x: w/2, y: 0))
        path.addQuadCurve(to: CGPoint(x: w * 0.98, y: h * 0.62),
                          control: CGPoint(x: w * 1.05, y: h * 0.28))
        path.addQuadCurve(to: CGPoint(x: w/2, y: h),
                          control: CGPoint(x: w * 0.92, y: h))
        path.addQuadCurve(to: CGPoint(x: w * 0.02, y: h * 0.62),
                          control: CGPoint(x: w * 0.08, y: h))
        path.addQuadCurve(to: CGPoint(x: w/2, y: 0),
                          control: CGPoint(x: -w * 0.05, y: h * 0.28))
        path.closeSubpath()
        return path
    }
}

// MARK: - Силуэт спиртовки (склянка с плечиками)

struct LampBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let neckW = w * 0.55
        let neckH = h * 0.22
        let shoulderH = h * 0.12

        p.move(to: CGPoint(x: (w - neckW)/2, y: 0))
        p.addLine(to: CGPoint(x: (w + neckW)/2, y: 0))
        p.addQuadCurve(
            to: CGPoint(x: w, y: neckH + shoulderH),
            control: CGPoint(x: w * 0.95, y: neckH + shoulderH * 0.4)
        )
        p.addLine(to: CGPoint(x: w, y: h - 6))
        p.addQuadCurve(
            to: CGPoint(x: w - 6, y: h),
            control: CGPoint(x: w, y: h)
        )
        p.addLine(to: CGPoint(x: 6, y: h))
        p.addQuadCurve(
            to: CGPoint(x: 0, y: h - 6),
            control: CGPoint(x: 0, y: h)
        )
        p.addLine(to: CGPoint(x: 0, y: neckH + shoulderH))
        p.addQuadCurve(
            to: CGPoint(x: (w - neckW)/2, y: 0),
            control: CGPoint(x: w * 0.05, y: neckH + shoulderH * 0.4)
        )
        p.closeSubpath()
        return p
    }
}
