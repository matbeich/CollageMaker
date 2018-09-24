//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class PlusView: UIView {
    init(frame: CGRect, color: UIColor) {
        self.color = color
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        let lineWidth: CGFloat = 2.0

        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(lineWidth)

        let horizontalPathStartPoint = CGPoint(x: lineWidth / 2, y: bounds.midY)
        let horizontalPathEndPoint = CGPoint(x: bounds.width - lineWidth / 2, y: bounds.midY)
        let horizontalPath = pathForDraw(start: horizontalPathStartPoint, end: horizontalPathEndPoint)

        let verticalPathStartPoint = CGPoint(x: bounds.midX, y: lineWidth / 2)
        let verticalPathEndPoint = CGPoint(x: bounds.midX, y: bounds.height - lineWidth / 2)
        let verticalPath = pathForDraw(start: verticalPathStartPoint, end: verticalPathEndPoint)

        context?.addPath(horizontalPath)
        context?.addPath(verticalPath)
        context?.setLineCap(.round)
        context?.strokePath()
    }

    private func setup() {
        backgroundColor = .clear
    }

    private func pathForDraw(start: CGPoint, end: CGPoint) -> CGPath {
        let path = UIBezierPath()

        path.move(to: start)
        path.addLine(to: end)
        return path.cgPath
    }

    private let color: UIColor
}
