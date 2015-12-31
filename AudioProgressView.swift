//
//  AudioProgressView.swift
//  student
//
//  Created by oyoung on 15/12/29.
//  Copyright © 2015年 singlu. All rights reserved.
//

import UIKit

protocol AudioProgressViewDelegate: class
{
    func audioProgressView(progressView: AudioProgressView, progressDidChanged: CGFloat)
}

class AudioProgressView: UIView {

    private var progress: CGFloat = 0.0 {
        didSet {
            progressChanged(progress: progress)
        }
    }
    
    var updateProgress: CGFloat {
        get {
            return progress
        }
        set {
            let d = delegate
            delegate = nil
            progress = newValue
            delegate = d
        }
    }
    
    var delegate: AudioProgressViewDelegate?
    var tintWidth: CGFloat = 5.0
    private var trackView: UIPileView
    private var progressView: UIPileView
    
    var customView: UIView? {
        didSet {
            addSubview(customView!)
        }
    }
    
    var interativeEnabled: Bool  = true
    
    var trackTintColor: UIColor {
        get {
            return trackView.backgroundColor!
        }
        set {
            trackView.backgroundColor = newValue
        }
    }
    var progressTintColor: UIColor {
        get {
            return progressView.backgroundColor!
        }
        set {
            progressView.backgroundColor = newValue
        }
    }
    
    var trackImage: UIImage? {
        didSet {
            trackImageDidSet()
        }
    }
    
    var progressImage: UIImage? {
        didSet {
            progressImageDidSet()
        }
    }
    
    func trackImageDidSet()
    {
        if let t = trackImage
        {
            let view = UIImageView(image: t)
            view.frame = trackView.bounds
            for v in trackView.subviews
            {
                v.removeFromSuperview()
            }
            trackView.addSubview(view)
        }
    }
    
    func progressImageDidSet()
    {
        if let p = progressImage
        {
            let view = UIImageView(image: p)
            view.frame = progressView.bounds
            for v in progressView.subviews
            {
                v.removeFromSuperview()
            }
            progressView.addSubview(view)
        }
    }
    
    func progressChanged(progress p: CGFloat)
    {
        if let d = delegate
        {
            d.audioProgressView(self, progressDidChanged: p)
        }
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        var frame = bounds
        frame.origin.y = (frame.height - tintWidth) / 2
        frame.size.height = tintWidth
        trackView.frame = frame
        frame.size.width *= progress
        progressView.frame = frame
        
        if let cv = customView
        {
            frame = cv.frame
            var center = self.center
            frame.size.height = min(bounds.height, frame.height)
            frame.size.width = frame.height
            cv.frame = frame
            center.x = bounds.width * progress
            cv.center = center
            cv.layer.cornerRadius = frame.width / 2
        }
        
    }
    
    
    
    override init(frame: CGRect) {
        trackView = UIPileView(frame: frame)
        progressView = UIPileView(frame: frame)
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        addSubview(trackView)
        addSubview(progressView)
        
    }
    
    var touchedPoint: CGPoint?
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if interativeEnabled
        {
            var pt = touches.first?.locationInView(customView)
            if let p = pt
            {
                touchedPoint = p
                if !(customView?.pointInside(p, withEvent: event))!
                {
                    pt = touches.first?.locationInView(trackView)
                    if let p = pt
                    {
                        progress = max(min(p.x / trackView.frame.width, CGFloat(1.0)), CGFloat(0.0))
                    }
                }
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if interativeEnabled
        {
            let pt = touches.first?.locationInView(customView)
            if let p = pt
            {
                let dx = p.x  - (touchedPoint?.x)!
                var dp = dx / bounds.width
                let ndp = 1.0 - progress
                dp = dp < -progress ? -progress :
                    dp > ndp ? ndp : dp
                progress += dp
            }
        }
        super.touchesMoved(touches, withEvent: event)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
