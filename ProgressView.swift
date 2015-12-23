//
//  ProgressView.swift
//  SwiftDemo
//
//  Created by oyoung on 15/12/22.
//  Copyright © 2015年 oyoung. All rights reserved.
//

import UIKit
enum EtaskStatus: Int
{
    case New
    case Unfinished
    case Uncorreted
    case Finished
}
enum EtaskLevel : Int
{
    case Unknown
    case Bad
    case Good
    case Great
}



class StatusHelper {
    var borderWidth: CGFloat
    var borderColor1: UIColor
    var borderColor2: UIColor
    var font1: UIFont
    var font2: UIFont
    var fontColor: UIColor
    var image: String
    
    init(borderWidth w: CGFloat, borderColor1 bC1: UIColor, borderColor2 bC2:UIColor, font1: UIFont, font2: UIFont, fontColor: UIColor, image: String)
    {
        self.borderWidth = w
        self.borderColor1 = bC1
        self.borderColor2 = bC2
        self.font1 = font1
        self.font2 = font2
        self.fontColor = fontColor
        self.image = image
    }
}

class StatusManager{
    var helpers: [StatusHelper]
    init()
    {
        helpers = [StatusHelper]()
        let h0 = StatusHelper(borderWidth: 3,
            borderColor1: UIColor(red: 190.0/255, green: 230.0/255, blue: 1.0, alpha: 1.0),
            borderColor2: UIColor(red: 190.0/255, green: 230.0/255, blue: 1.0, alpha: 1.0),
            font1: UIFont.systemFontOfSize(12),
            font2: UIFont.systemFontOfSize(8),
            fontColor: UIColor(red: 102.0/255, green: 102.0/255, blue: 102.0/255, alpha: 1.0),
            image: "未批改")
        let h1 = StatusHelper(borderWidth: 3,
            borderColor1: UIColor(red: 230.0/255, green: 90.0/255, blue: 0, alpha: 1.0),
            borderColor2: UIColor(red: 1.0, green: 230.0/255, blue: 170.0/255, alpha: 1.0),
            font1: UIFont.systemFontOfSize(12),
            font2: UIFont.systemFontOfSize(8),
            fontColor: UIColor(red: 230.0/255, green: 90.0/255, blue: 0, alpha: 1.0),
            image:"jiaocha1")
        let h2 = StatusHelper(borderWidth: 3,
            borderColor1: UIColor(red: 245.0/255, green: 150.0/255, blue: 0, alpha: 1.0),
            borderColor2: UIColor(red: 1.0, green: 1.0, blue: 170.0/255, alpha: 1.0),
            font1: UIFont.systemFontOfSize(12),
            font2: UIFont.systemFontOfSize(8),
            fontColor: UIColor(red: 245.0/255, green: 150.0/255, blue: 0, alpha: 1.0),
            image: "lianghao1")
        let h3 = StatusHelper(borderWidth: 3,
            borderColor1: UIColor(red: 90.0/255, green: 200.0/255, blue: 0, alpha: 1.0),
            borderColor2: UIColor(red: 170.0/255, green: 1.0, blue: 100.0/255, alpha: 1.0),
            font1: UIFont.systemFontOfSize(12),
            font2: UIFont.systemFontOfSize(8),
            fontColor: UIColor(red: 90.0/255, green: 200.0/255, blue: 0, alpha: 1.0),
            image: "youxiu1")
        helpers.append(h0)
        helpers.append(h1)
        helpers.append(h2)
        helpers.append(h3)
    }
    
    func help(level l: EtaskLevel) -> StatusHelper
    {
        switch l
        {
        case .Unknown:
            return helpers[0]
        case .Bad:
            return helpers[1]
        case .Good:
            return helpers[2]
        case .Great:
            return helpers[3]
        }
    }
}


class ProgressView: UIView {
    
    private var progressBar: ProgressBar?
    private var percentLabel: UILabel?
    private var numberLabel: UILabel?
    private var imageView: UIImageView?
    private var statusLabel: UILabel?
    
    let totalCount: Int
    var correctCount: Int {
        didSet {
            correctCount = min(totalCount, correctCount)
            updateContent()
        }
    }
    var statusManager: StatusManager?
    var status: EtaskStatus

    init(status: EtaskStatus, totalCount: Int, correctCount: Int = 0) {
        self.totalCount = totalCount
        self.status = status
        self.correctCount = correctCount
        super.init(frame: CGRectMake(0, 0, 66, 58))
        setupProgressBar()
        setupContentViews()
        updateContent()
    }
    
    func setupProgressBar()
    {
        progressBar = ProgressBar(
            frame: CGRect(x: 0, y: 0, width: self.bounds.width / 2, height: self.bounds.height / 2),
            style: ProgressBarStyle.CircleClock)
        progressBar?.maxValue = 1.0
        progressBar?.midValue = 1.0
        progressBar?.clipsToBounds = true
        progressBar?.backgroundColor = UIColor.clearColor()
        addSubview(progressBar!)
    }
    
    func setupContentViews()
    {
        statusManager = StatusManager()
        percentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 10))
        numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 10))
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 66, height: 18))
        statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 66, height: 18))
        
        percentLabel?.textAlignment = .Center
        numberLabel?.textAlignment = .Center
        statusLabel?.textAlignment = .Center
        
        //调试用
 
        percentLabel?.backgroundColor = UIColor.clearColor()
        numberLabel?.backgroundColor = UIColor.clearColor()
        
        addSubview(percentLabel!)
        addSubview(numberLabel!)
        addSubview(imageView!)
        addSubview(statusLabel!)
    }
    
    var newFrame: CGRect? {
        didSet {
            self.frame = newFrame!
            layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var center = CGRectGetCenter(rect: self.bounds)
        var frame = self.bounds
        
        
        percentLabel?.center = center
        numberLabel?.center = center
        imageView?.center = center
        statusLabel?.center = center
        
        frame.size.height = frame.width * 0.27
        frame.origin.y = self.frame.height - frame.height - 4
        imageView?.frame = frame
        frame.size.height -= 5
        frame.origin.y += 5
        statusLabel?.frame = frame
        
        
        center.x = (imageView?.frame.width)! / 2
        frame.size.width = self.frame.width * 44 / 66
        frame.size.height = frame.width
        center.y =  frame.height / 2
        progressBar?.frame = frame
        progressBar?.center = center
        
        center.y -= (percentLabel?.frame.height)! / 2
        percentLabel?.center = center
        center = (progressBar?.center)!
        center.y += (numberLabel?.frame.height)! / 2 + 4
        numberLabel?.center = center
        
        
        
    }
    
    func updateImageHiddenWithLevel(level: EtaskLevel)
    {
        switch level
        {
        case .Unknown:
            imageView?.hidden = true
            statusLabel?.hidden = false
        default:
            imageView?.hidden = false
            statusLabel?.hidden = true
        }
    }
    
 

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    //更新显示内容
    func updateContent()
    {
        
        let percent = totalCount > 0 ? CGFloat(correctCount) / CGFloat(totalCount) : 0.0
        let etaskLevel = getLevelByPercent(percent: percent, status: status)
        let helper = statusManager!.help(level: etaskLevel)
        updateProgressBar(percent, helper: helper)
        updateImageViewOrStatusLabel(etaskLevel: etaskLevel, helper: helper)
        updateImageHiddenWithLevel(etaskLevel)

    }
    //更新进度
    func updateProgressBar(percent: CGFloat, helper : StatusHelper?)
    {
        if let h = helper {
            progressBar?.lineWidth = h.borderWidth
            progressBar?.midColor = h.borderColor2
            progressBar?.fgColor = h.borderColor1
            progressBar?.value = percent
            numberLabel?.text = "\(correctCount)/\(totalCount)"
            numberLabel?.textColor = h.fontColor
            numberLabel?.font = h.font2
            percentLabel?.text = "\(Int(percent * 100))%"
            percentLabel?.textColor = h.fontColor
            percentLabel?.font = h.font1
        }
    }
    //更新评分等级
    func updateImageViewOrStatusLabel(etaskLevel e: EtaskLevel, helper: StatusHelper?)
    {
        if let h = helper
        {
            switch e
            {
            case .Unknown:
                imageView?.hidden = true
                statusLabel?.hidden = false
                statusLabel?.text = "未批改"
                statusLabel?.textAlignment = .Center
                statusLabel?.font = UIFont.systemFontOfSize(10)
                statusLabel?.textColor = UIColor(red: 102.0/255, green: 102.0/255, blue: 102.0/255, alpha: 1.0)
            default:
                imageView?.hidden = false
                statusLabel?.hidden = true
                imageView?.image = UIImage(named: h.image)
            }
        }
    }
    //根据百分比和状态获取评分等级 .Unknown代表未评分
    func getLevelByPercent(percent p:CGFloat, status: EtaskStatus) -> EtaskLevel
    {
        switch status
        {
        case .Finished:
            if p > 0.8
            {
                return EtaskLevel.Great
            }
            else if p > 0.6
            {
                return EtaskLevel.Good
            }
            else
            {
                return EtaskLevel.Bad
            }
        default:
            return EtaskLevel.Unknown
        }
        
    }
}
