//
//  ProgressBar.swift
//  student
//
//  Created by oyoung on 15/12/22.
//  Copyright © 2015年 singlu. All rights reserved.
//

import UIKit

enum LineDirection : Int
{
    case Up
    case Down
    case Left
    case Right
    func isHorizontal() -> Bool {
        return self == .Left || self == .Right
    }
    
    func isVertical() -> Bool {
        return self == .Up || self == .Down
    }
}

enum ProgressBarStyle
{
    case Line(LineDirection)
    case CircleClock
    case CircleUnclock
}

extension UIView
{
    func CGRectGetCenter(rect r: CGRect) -> CGPoint
    {
        return CGPoint(x: r.origin.x + r.width / 2, y: r.origin.y + r.height / 2)
    }
}

class SectorView: UIView {
    
    var maxValue: CGFloat = 1.0 //最大值
    var midValue: CGFloat = 1.0 //中间值
    var value: CGFloat = 0.0 //当前值
    
    
    var startAngle: CGFloat = CGFloat(M_PI_2 * 3) //
    
    var clockwise: Int32 = 1 //是否顺时针 1：逆时针， 0：顺时针
    
    var lineWidth: CGFloat = 10.0 //线宽
    

    
    var backColor: UIColor = UIColor.grayColor()
    var midColor: UIColor = UIColor.brownColor()
    var color: UIColor = UIColor.greenColor()
    
    
    
    init(frame: CGRect, clockwise: Int32) {
        var f = frame
        self.clockwise = clockwise
        guard f.height == f.width else {
            f.size.width = f.height > f.width ? f.height : f.width
            f.size.height = f.width
            super.init(frame: f)
            return
        }
        super.init(frame: f)
    }
    
 
    
    override func drawRect(rect: CGRect) {
        let center = CGRectGetCenter(rect: rect)
        let r = rect.width / 2
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        var endAngle: CGFloat = 0.0
        
        
        CGContextSetLineWidth(context, 0)
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextClearRect(context, rect)
        //画背景圆
        CGContextSetFillColorWithColor(context, backColor.CGColor)
        CGContextSetStrokeColorWithColor(context, backColor.CGColor)
        CGContextMoveToPoint(context, center.x, center.y)
        CGContextAddArc(context, center.x, center.y, r, 0, CGFloat(M_PI * 2), 0)
        CGContextFillPath(context)
        //画中间层
        CGContextSetFillColorWithColor(context, midColor.CGColor)
        CGContextSetStrokeColorWithColor(context, midColor.CGColor)
        CGContextMoveToPoint(context, center.x, center.y)
        endAngle = angle(start: startAngle, change: CGFloat(M_PI * 2) * midValue / maxValue, clockwise: clockwise)
        if fabs(midValue - maxValue) > 0.00001
        {
            CGContextAddArc(context, center.x, center.y, r, startAngle, endAngle, clockwise)
        }
        else
        {
            CGContextAddArc(context, center.x, center.y, r, 0 , CGFloat(M_PI * 2), 0)
            
        }
        CGContextFillPath(context)
        //画显示层
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextMoveToPoint(context, center.x, center.y)
        endAngle = angle(start: startAngle, change: CGFloat(M_PI * 2) * value / maxValue , clockwise: clockwise)
        if fabs(value - maxValue) > 0.00001
        {
            CGContextAddArc(context, center.x, center.y, r, startAngle, endAngle, clockwise)
        }
        else
        {
            CGContextAddArc(context, center.x, center.y, r, 0 , CGFloat(M_PI * 2), 0)
       
        }
        CGContextFillPath(context)
        //画遮盖层
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, center.x, center.y)
        CGContextAddArc(context, center.x, center.y, r - lineWidth, 0,CGFloat(M_PI * 2), 0)
        CGContextFillPath(context)
        super.drawRect(rect)
    }
    
    func angle(start s: CGFloat, change: CGFloat, clockwise: Int32) -> CGFloat
    {
        var angle: CGFloat
        if clockwise == 0
        {
            angle = s + change
            angle = angle > CGFloat(M_PI * 2) ? angle - CGFloat(M_PI * 2) : angle
        }
        else
        {
            angle = s - change
            angle = angle < 0 ? angle + CGFloat(M_PI * 2) : angle
        }
        return angle
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProgressBar: UIView {

    //通用属性
    var maxValue: CGFloat = 1.0 {
        didSet {
            sectorView?.maxValue = maxValue
        }
    }
    var value: CGFloat = 0.0{
        didSet{
            valueChanged(value: value)
        }
    }
    var style: ProgressBarStyle
    
  
    var lineWidth: CGFloat = 20.0 {
        didSet {
            lineWidthChanged(width: lineWidth)
        }
    }
    var midValue: CGFloat = 1.0 {
        didSet {
            midValueChanged(value: midValue)
        }
    }
    
    var bgColor: UIColor = UIColor.grayColor()  {//背景色
        didSet {
            sectorView?.backColor = bgColor
            backgroundView?.backgroundColor = bgColor
        }
    }
    var midColor: UIColor = UIColor.brownColor()  {//中间层颜色，通常用于缓冲
        didSet {
            sectorView?.midColor = midColor
            midView?.backgroundColor = midColor
        }
    }
    var fgColor: UIColor = UIColor.greenColor() { //前景色，显示当前值
        didSet {
            sectorView?.color = fgColor
            foregroundView?.backgroundColor = fgColor
        }
    }
    //----------通用属性边界结束----------
   
    
    
    
    
    init(frame: CGRect, style: ProgressBarStyle = .CircleClock)
    {
        self.style = style
        super.init(frame: frame)
        setup(style: style)
    }
    
    override func layoutSubviews() {
        switch style
        {
        case .Line(_):break
        default:
            sectorView?.frame = self.bounds
            sectorView?.layer.cornerRadius = self.bounds.width / 2
            break
        }
    }
    
    //---------------------通用代码边界开始----------------------------
    func setup(style s: ProgressBarStyle)
    {
        backgroundColor = UIColor.clearColor()
        switch style
        {
        case .Line(_):
            setupWithLineStyle()
        case .CircleClock:
            setupWithCircleStyle()
        case .CircleUnclock:
            setupWithCircleStyle()
        }
    }
    private func lineWidthChanged(width w: CGFloat)
    {
        if case let .Line(d) = style
        {
            if d.isHorizontal()
            {
                let y = (bounds.height - w ) / 2
                let length = bounds.width
                let midWidth = length * midValue / maxValue
                let width = length * value / maxValue
                backgroundView?.frame = CGRect(x: 0, y: y, width: length, height: w)
                switch d
                {
                case .Left:
                    midView?.frame = CGRect(x: 0, y: y, width: midWidth, height: w)
                    foregroundView?.frame = CGRect(x: 0, y: y, width: width, height: w)
                case .Right:
                    midView?.frame = CGRect(x: length - midWidth, y: y, width: midWidth, height: w)
                    foregroundView?.frame = CGRect(x: length - width, y: y, width: width, height: lineWidth)
                default:
                    break
                }
            }
            else if d.isVertical()
            {
                let x = (bounds.width - w ) / 2
                let length = bounds.height
                let height = length * value / maxValue
                let midHeight = length * midValue / maxValue
                backgroundView?.frame = CGRect(x: x, y: 0, width: w, height: length)
                switch d
                {
                case .Up:
                    midView?.frame = CGRect(x: x, y: 0, width: w, height: midHeight)
                    foregroundView?.frame = CGRect(x: x, y: 0, width: w, height: height)
                case .Down:
                    midView?.frame = CGRect(x: x, y: length - midHeight, width: w, height: midHeight)
                    foregroundView?.frame = CGRect(x: x, y: length - height, width: w, height: height)
                default:
                    break
                }
            }
        }
        else
        {
            sectorView?.lineWidth = w
        }
    }
    private func valueChanged(value v: CGFloat)
    {
        switch style
        {
        case .Line(_):
            valueChangedOnLineStyle(value: v)
        case .CircleClock:
            valueChangedOnCircleStyle(value: v)
        case .CircleUnclock:
            valueChangedOnCircleStyle(value: v)
        }
    }
    private func midValueChanged(value v: CGFloat)
    {
        if case let .Line(d) = style
        {
            if var frame = midView?.frame
            {
                switch d
                {
                case .Up:
                    frame.size.height = self.bounds.height * v / maxValue
                case .Down:
                    
                    frame.size.height = self.bounds.height * v / maxValue
                    frame.origin.y = self.bounds.height - frame.height
                case .Left:
                    frame.size.width = self.bounds.width * v / maxValue
                case .Right:
                    frame.size.width = self.bounds.width * v / maxValue
                    frame.origin.x = self.bounds.width - frame.width
                }
                midView?.frame = frame
            }
        }
        else
        {
            sectorView?.midValue = v
        }
    }
    
    //----------------通用代码边界结束------------------------
    
    

    
    //------------------线型进度条相关代码边界结束--------------
    //线型进度条
    var backgroundView: UIView?
    var midView: UIView?
    var foregroundView: UIView?
    
    //线型进度条值变化
    func valueChangedOnLineStyle(value v: CGFloat)
    {
        if case let .Line(d) = style
        {
            var frame = (foregroundView?.frame)!
            switch d
            {
            case .Up:
                frame.size.height = self.bounds.height * v / maxValue
            case .Down:
                
                frame.size.height = self.bounds.height * v / maxValue
                frame.origin.y = self.bounds.height - frame.height
            case .Left:
                frame.size.width = self.bounds.width * v / maxValue
            case .Right:
                frame.size.width = self.bounds.width * v / maxValue
                frame.origin.x = self.bounds.width - frame.width
            }
            foregroundView?.frame = frame
        }
        
    }

    func setupWithLineStyle()
    {
        if case .Line(_) = style {
            backgroundView = UIView()
            midView = UIView()
            foregroundView = UIView()
            backgroundView?.backgroundColor = bgColor
            midView?.backgroundColor = midColor
            foregroundView?.backgroundColor = fgColor
            addSubViewsOnLineStyle()
        }
    }
    

    
    func addSubViewsOnLineStyle()
    {
        addSubview(backgroundView!)
        addSubview(midView!)
        addSubview(foregroundView!)
    }
    //------------------线型进度条相关代码边界结束--------------
    //------------------圆形进度条相关代码边界开始--------------
    var sectorView: SectorView?
    
    func setupWithCircleStyle()
    {
        makeStantardFrame()
        setupSecotor()
    }
    
    func setupSecotor()
    {
        let clockwise: Int32 = {
            switch style
            {
            case .CircleClock:return 0
            case .CircleUnclock:return 1
            default:return 0
            }
        }()
        sectorView = SectorView(frame: self.frame, clockwise: clockwise)
        sectorView?.backColor = bgColor
        sectorView?.midColor = midColor
        sectorView?.color = fgColor
        sectorView?.maxValue = maxValue
        sectorView?.midValue = midValue
        sectorView?.value = value
        sectorView?.layer.cornerRadius = self.frame.width / 2
        sectorView?.backgroundColor = UIColor.clearColor()
        
        addSubview(sectorView!)
    }
    
    func makeStantardFrame()
    {
        var frm = frame
        if frm.height > frm.width  //要求只能是正方形，如果不是，则按短边自动构造正方形
        {
            frm.size.height = frm.width
        }
        else
        {
            frm.size.width = frm.height
        }
        frame = frm
    }
    
    func valueChangedOnCircleStyle(value v: CGFloat) {
        sectorView?.value = v
    }
 
    
    //---------------------圆形进度条代码区边界结束---------------------
    
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
