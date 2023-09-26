//
//  ItemImageView.swift
//  Wardrobe-iOS
//
//  Created by Mariam Khachatryan on 3/28/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

protocol ItemViewDelegate {
    func setMainColor(_ color: UIColor)
    func setLineColor(_ color: UIColor)
    func setLineWidth(_ width: CGFloat)
    func setLineSpacing(_ spacing: CGFloat)
    func setPattern(_ patternType: PatternType)
}

//MARK:- Enums
enum PatternType: String, CaseIterable {
    case None = "None"
    case VerticalLine = "VerticalLines"
    case HorizontalLine = "HorizontalLines"
    case Cell = "Cells"
}

enum LineDirection {
    case vertical
    case horizontal
}

class ItemImageView: UIImageView {
    //MARK:- Constants
    static let defaultContentMode: ContentMode = .scaleAspectFit

    private static let defaultMainColor: UIColor = .black
    private static let defaultLineColor: UIColor = .white
    private static let defaultLineWidth: CGFloat = 20.0
    private static let defaultLineSpacing: CGFloat = 60.0
    private static let defaultPattern: PatternType = .None

    //MARK:- Properties
    private var mainColor: UIColor = defaultMainColor
    private var lineColor: UIColor = defaultLineColor
    private var lineWidth: CGFloat = defaultLineWidth
    private var lineSpacing: CGFloat = defaultLineSpacing
    private var pattern: PatternType = defaultPattern

    //MARK:- Overided functions
    override init(image: UIImage?) {
        super.init(image: image)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(defaultWith image: String) {
        self.init(image: UIImage(named: image))
        self.set(image: image)
    }
}

//MARK:- Public functions
extension ItemImageView {
    func set(image: String, color: UIColor = defaultMainColor, lineColor: UIColor = defaultLineColor, lineWidth: CGFloat = defaultLineWidth, lineSpacing: CGFloat = defaultLineSpacing, pattern: PatternType = defaultPattern) {
        setupImageView(image)
        setMainColor(color)
    }
}

//MARK:- ItemViewDelegate
extension ItemImageView: ItemViewDelegate {
    func setMainColor(_ color: UIColor)  {
        mainColor = color
        self.tintColor = color
    }
    
    func setLineColor(_ color: UIColor)  {
        lineColor = color
        changeLineColors(color)
    }
    
    func setLineWidth(_ width: CGFloat)  {
        lineWidth = width
        drawPattern()
    }
    
    func setLineSpacing(_ spacing: CGFloat)  {
        lineSpacing = spacing
        drawPattern()
    }
    
    func setPattern(_ patternType: PatternType) {
        pattern = patternType
        drawPattern()
    }
}

//MARK:- Private functions -> Configuration
extension ItemImageView {
    private func setupImageView(_ imageName: String) {
        image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        contentMode = ItemImageView.defaultContentMode
        createMaskImage()
    }

    private func createMaskImage() {
        let maskImageview = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        maskImageview.image = image
        maskImageview.contentMode = contentMode
        mask = maskImageview
    }
}

//MARK:- Private functions -> Drawing
extension ItemImageView {
    private func removeAllSublayers() {
        self.layer.sublayers?.removeAll()
    }

    private func changeLineColors(_ color: UIColor) {
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                if layer.isKind(of: CAShapeLayer.self) {
                    let shapeLayer = layer as! CAShapeLayer
                    shapeLayer.strokeColor = color.cgColor
                }
            }
        }
    }
    
    private func drawPattern() {
        removeAllSublayers()
        
        switch pattern {
        case .None:
            return
        case .VerticalLine:
            drawLines(direction: .vertical)
        case .HorizontalLine:
            drawLines(direction: .horizontal)
        case .Cell:
            drawLines(direction: .vertical)
            drawLines(direction: .horizontal)
        }
    }
    
    private func drawLines(direction: LineDirection) {
        let numberOfLines = (direction == .vertical ? frame.width : frame.height) / (lineWidth + lineSpacing)
        for i in 0...Int(numberOfLines) {
            let index = CGFloat(i)
            var startPoint: CGPoint = .zero
            var endPoint: CGPoint = .zero
            
            switch direction {
            case .vertical:
                let pointX: CGFloat = (index * lineWidth) + (index * lineSpacing)
                startPoint = CGPoint(x: pointX, y: 0)
                endPoint = CGPoint(x: pointX, y: frame.maxY)
            case .horizontal:
                let pointY: CGFloat = (index * lineWidth) + (index * lineSpacing)
                startPoint = CGPoint(x: 0, y: pointY)
                endPoint = CGPoint(x: frame.maxX, y: pointY)
            }
            drawLineFromPoint(start: startPoint, toPoint: endPoint, ofColor: lineColor, lineWidth: lineWidth)
        }
    }

    private func drawLineFromPoint(start: CGPoint, toPoint end: CGPoint, ofColor lineColor: UIColor, lineWidth: CGFloat) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth

        self.layer.addSublayer(shapeLayer)
    }
}

