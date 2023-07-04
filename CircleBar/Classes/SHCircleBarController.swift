//
//  SHCircleBarController.swift
//  SHCircleBar
//
//  Created by Adrian Perțe on 19/02/2019.
//  Copyright © 2019 softhaus. All rights reserved.
//

import UIKit

open class SHCircleBarController: UITabBarController {

    @IBInspectable var color: UIColor?
    
    fileprivate var shouldSelectOnTabBar = true
    private var circleView : UIView!
    private var circleImageView: UIImageView!
    private var isFirst: Bool =  true
    open override var selectedViewController: UIViewController? {
        willSet {
            guard shouldSelectOnTabBar, let newValue = newValue else {
                shouldSelectOnTabBar = true
                return
            }
            guard let index = viewControllers?.index(of: newValue) else {return}
            selectedIndex = index
        }
    }
    
    open override var selectedIndex: Int {
        willSet {
            guard shouldSelectOnTabBar else {
                shouldSelectOnTabBar = true
                return
            }
            guard let tabBar = tabBar as? SHCircleBar else {
                return
            }
            tabBar.select(itemAt: newValue, animated: true)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open func setStarerGraphic(backgrounColor: UIColor, tintColor: UIColor, circleColor: UIColor){
        viewDidLoad()
        let tabBar = SHCircleBar()
        tabBar.backgroundTintColor = backgrounColor
        tabBar.customInit(backgrounColor, tintColor)
        self.setValue(tabBar, forKey: "tabBar")
        self.circleView = UIView(frame: .zero)
        circleView.layer.cornerRadius = 25
        circleView.backgroundColor = circleColor
        circleView.isUserInteractionEnabled = false
        self.circleImageView = UIImageView(frame: .zero)
        circleImageView.layer.cornerRadius = 25
        circleImageView.isUserInteractionEnabled = false
        circleView.addSubview(circleImageView)
        self.view.addSubview(circleView)
        let tabWidth = UIScreen.main.bounds.width /// CGFloat(self.tabBar.items?.count ?? 5)
        let y = UIScreen.main.bounds.height - self.tabBar.frame.height - 45
        circleView.frame = CGRect(x: tabWidth / 2 - 25, y: y, width: 50, height: 50)
        circleImageView.frame = self.circleView.bounds
        circleImageView.contentMode = .scaleToFill
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        circleImageView.image = self.tabBar.selectedItem?.selectedImage ?? self.tabBar.items?.first?.selectedImage
    }
    
    private var _barHeight: CGFloat = 74
    open var barHeight: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return _barHeight + view.safeAreaInsets.bottom
            } else {
                return _barHeight
            }
        }
        set {
            _barHeight = newValue
            updateTabBarFrame()
        }
    }
    
    private func updateTabBarFrame() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = barHeight
        tabFrame.origin.y = self.view.frame.size.height - barHeight
        self.tabBar.frame = tabFrame
        tabBar.setNeedsLayout()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateTabBarFrame()
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        updateTabBarFrame()
    }
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {        guard let idx = tabBar.items?.index(of: item) else { return }
        
        if  idx != selectedIndex || isFirst {
            if  let controller = viewControllers?[idx] {
                isFirst = false
                shouldSelectOnTabBar = false
                selectedIndex = idx
                let tabWidth = self.view.bounds.width / CGFloat(self.tabBar.items!.count)
                UIView.animate(withDuration: 0.3) {
                    self.circleView.frame = CGRect(x: (tabWidth * CGFloat(idx) + tabWidth / 2 - 25), y: self.tabBar.frame.origin.y - 10, width: 50, height: 50)
                }
                UIView.animate(withDuration: 0.15, animations: {
                    self.circleImageView.alpha = 0
                }) { (_) in
                    self.circleImageView.image = item.selectedImage// self.image(with: item.selectedImage, scaledTo: CGSize(width: 30, height: 30))
                    UIView.animate(withDuration: 0.15, animations: {
                        self.circleImageView.alpha = 1
                    })
                }
                delegate?.tabBarController?(self, didSelect: controller)
            }
        }
    }
    private func image(with image: UIImage?, scaledTo newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, _: false, _: 0.0)
        image?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
