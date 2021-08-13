//
//  BannerView.swift
//  Banner3D
//
//  Created by fuyoufang on 2021/8/13.
//

import UIKit
import SnapKit
import Then
import CoreMotion

class BannerView: UIView {
    
    /// 图片最大偏移量
    var maxOffset: CGFloat = 30
    var lastGravityX: Double = 0, lastGravityY: Double = 0
    
    var deviceMotionUpdateInterval: TimeInterval = 1 / 40.0
    
    lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = deviceMotionUpdateInterval
        return manager
    }()
    
    let frontImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let middleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let backImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    var frontImageViewCenter: CGPoint = .zero
    var backImageViewCenter: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        
        frontImageView.image = UIImage(named: "banner_1")
        middleImageView.image = UIImage(named: "banner_2")
        backImageView.image = UIImage(named: "banner_3")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        backImageViewCenter = center
        frontImageViewCenter = center
    }
    
    private func setupSubviews() {
        addSubview(backImageView)
        addSubview(middleImageView)
        addSubview(frontImageView)

        backImageView.snp.makeConstraints {
            $0.width.equalToSuperview().offset(maxOffset * 2)
            $0.height.equalToSuperview().offset(maxOffset * 2)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        middleImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        frontImageView.snp.makeConstraints {
            $0.width.equalToSuperview().offset(maxOffset * 2)
            $0.height.equalToSuperview().offset(maxOffset * 2)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    func start() {
        startMotion()
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func startMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] deviceMotion, error in
        
            guard let motion = deviceMotion else {
                return
            }
            // motion.gravity 为重力方向
            self?.update(gravityX: motion.gravity.x,
                         gravityY: motion.gravity.y,
                         gravityZ: motion.gravity.z)

        }
    }
    
    func update(gravityX: Double, gravityY: Double, gravityZ: Double) {
        
        let timeInterval = sqrt(pow((gravityX - lastGravityX), 2) + pow((gravityY - lastGravityY), 2)) * deviceMotionUpdateInterval

        let animationKey = "positionAnimation"
        
        let newBackImageViewCenter = self.center.with {
            $0.x += CGFloat(gravityX) * maxOffset
            $0.y += CGFloat(gravityY) * maxOffset
        }
        
        let backImageViewAnimation = CABasicAnimation(keyPath: "position").then {
            $0.fromValue = NSValue(cgPoint: self.backImageViewCenter)
            $0.toValue = NSValue(cgPoint: newBackImageViewCenter)
            $0.duration = timeInterval
            $0.fillMode = .forwards
            $0.isRemovedOnCompletion = false
        }
        
        backImageView.layer.do {
            $0.removeAnimation(forKey: animationKey)
            $0.add(backImageViewAnimation, forKey: animationKey)
        }
        
        let newFrontImageViewCenter = self.center.with {
            $0.x -= CGFloat(gravityX) * maxOffset
            $0.y -= CGFloat(gravityY) * maxOffset
        }
        
        let frontImageViewAnimation = CABasicAnimation(keyPath: "position").then {
            $0.fromValue = NSValue(cgPoint: self.frontImageViewCenter)
            $0.toValue = NSValue(cgPoint: newFrontImageViewCenter)
            $0.duration = timeInterval
            $0.fillMode = .forwards
            $0.isRemovedOnCompletion = false
        }
        
        frontImageView.layer.do {
            $0.removeAnimation(forKey: animationKey)
            $0.add(frontImageViewAnimation, forKey: animationKey)
        }
        
        self.backImageViewCenter = newBackImageViewCenter
        self.frontImageViewCenter = newFrontImageViewCenter
        
    }
}
