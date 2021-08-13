//
//  ViewController.swift
//  Banner3D
//
//  Created by fuyoufang on 2021/8/13.
//

import UIKit

import SnapKit

class ViewController: UIViewController {

   
    let banner = BannerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(banner)
        banner.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        banner.start()
    }
    
    
}

