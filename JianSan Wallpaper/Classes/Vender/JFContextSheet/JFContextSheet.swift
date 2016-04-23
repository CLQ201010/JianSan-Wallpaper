//
//  JFContextSheet.swift
//  JianSan Wallpaper
//
//  Created by zhoujianfeng on 16/4/22.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFContextSheetDelegate {
    func contextSheet(contextSheet: JFContextSheet, didSelectItemWithItemName itemName: String)
}

class JFContextSheet: UIView {
    
    var delegate: JFContextSheetDelegate?
    
    /// 圆的半径 触摸点到选项的直线距离
    var pathRadius: CGFloat = 100
    
    // 横纵边界区域 可以想象成contentInset
    var insetX: CGFloat = 80
    var insetY: CGFloat = 120
    
    // MARK: - 初始化
    init(items: Array<JFContextItem>) {
        super.init(frame: SCREEN_BOUNDS)
        
        for itemView in items {
            itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedItemWithItemName(_:))))
            addSubview(itemView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     item触摸手势
     */
    func didTappedItemWithItemName(tap: UITapGestureRecognizer) -> Void {
        let itemView = tap.view as! JFContextItem
        
        // 回调触摸itemName
        delegate?.contextSheet(self, didSelectItemWithItemName: itemView.itemLabel.text!)
        
        self.removeFromSuperview()
        centerView.removeFromSuperview()
    }
    
    /**
     根据圆心、角度、半径，计算圆上的点坐标
     
     - parameter center: 圆心
     - parameter angle:  角度
     - parameter radius: 半径
     
     - returns: 返回点坐标
     */
    func getCircleCoordinate(center: CGPoint, angle: CGFloat, radius: CGFloat) -> CGPoint {
        let x = radius * CGFloat(cosf(Float(angle) * Float(M_PI) / 180))
        let y = radius * CGFloat(sinf(Float(angle) * Float(M_PI) / 180))
        return CGPoint(x: center.x + x, y: center.y + y)
    }
    
    /**
     制造弹簧动画
     
     - parameter startAngle:  开始角度
     - parameter endAngle:    结束角度
     - parameter centerPoint: 圆心点
     - parameter index:       角标
     - parameter itemView:    选项
     */
    func makeSpringAnimation(startAngle: CGFloat, endAngle: CGFloat, centerPoint: CGPoint, index: Int, itemView: JFContextItem) -> Void {
        // 每个选项之间的角度间距
        let angleDistance = (endAngle - startAngle) / CGFloat(subviews.count - 1)
        let angle = startAngle + CGFloat(index) * angleDistance
        let destinationPoint = getCircleCoordinate(centerPoint, angle: angle, radius: pathRadius)
        
        UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            let tx = destinationPoint.x - centerPoint.x
            let ty = destinationPoint.y - centerPoint.y
            itemView.transform = CGAffineTransformTranslate(itemView.transform, tx, ty)
            }, completion: { (_) in
                
        })
    }
    
    /**
     开始弹簧动画
     
     - parameter centerPoint: 中心点
     */
    func startSpringAnimation(centerPoint: CGPoint) -> Void {
        // item布局
        let itemWidth: CGFloat = 40
        let itemHeight: CGFloat = 50
        
        // 把所有item都以触摸点为原点
        for (index, item) in subviews.enumerate() {
            let itemView = item as! JFContextItem
            itemView.frame = CGRect(x: centerPoint.x - itemWidth * 0.5, y: centerPoint.y - itemHeight * 0.5, width: itemWidth, height: itemHeight)
            
            // 布局角度范围
            var startAngle: CGFloat = 0
            var endAngle: CGFloat = 0
            
            // 左上
            if centerPoint.x <= insetX && centerPoint.y <= insetY {
                startAngle = 0
                endAngle = 90
            }
            
            // 上
            if centerPoint.x > insetX && centerPoint.x <= SCREEN_WIDTH - insetX && centerPoint.y <= insetY {
                switch subviews.count {
                case 1:
                    startAngle = 90
                    endAngle = 90
                    break
                case 2, 3:
                    startAngle = 135
                    endAngle = 45
                    break
                case 4:
                    startAngle = 150
                    endAngle = 30
                    break
                case 5:
                    startAngle = 180
                    endAngle = 0
                    break
                default:
                    break
                }
            }
            
            // 右上角
            if centerPoint.x > SCREEN_WIDTH - insetX && centerPoint.y <= insetY {
                startAngle = 180
                endAngle = 90
            }
            
            // 左
            if centerPoint.x <= insetX && centerPoint.y > 150 && centerPoint.y <= SCREEN_HEIGHT - insetY {
                switch subviews.count {
                case 1:
                    startAngle = 90
                    endAngle = 90
                    break
                case 2, 3:
                    startAngle = -45
                    endAngle = 45
                    break
                case 4:
                    startAngle = -60
                    endAngle = 60
                    break
                case 5:
                    startAngle = -90
                    endAngle = 90
                    break
                default:
                    break
                }
            }
            
            // 左下
            if centerPoint.x <= insetX && centerPoint.y > SCREEN_HEIGHT - insetY {
                startAngle = -90
                endAngle = 0
            }
            
            // 中间区域/下
            if centerPoint.x > insetX && centerPoint.x < SCREEN_WIDTH - insetX && centerPoint.y > insetY {
                switch subviews.count {
                case 1:
                    startAngle = -90
                    endAngle = -90
                    break
                case 2, 3:
                    startAngle = -135
                    endAngle = -45
                    break
                case 4:
                    startAngle = -150
                    endAngle = -30
                    break
                case 5:
                    startAngle = -180
                    endAngle = 0
                    break
                default:
                    break
                }
            }
            
            // 右
            if centerPoint.x > SCREEN_WIDTH - insetX && centerPoint.y > insetY && centerPoint.y <= SCREEN_HEIGHT - insetY {
                switch subviews.count {
                case 1:
                    startAngle = 180
                    endAngle = 180
                    break
                case 2, 3:
                    startAngle = 225
                    endAngle = 135
                    break
                case 4:
                    startAngle = 130
                    endAngle = 240
                    break
                case 5:
                    startAngle = 270
                    endAngle = 90
                    break
                default:
                    break
                }
            }
            
            // 右下
            if centerPoint.x > SCREEN_WIDTH - insetX && centerPoint.y > SCREEN_HEIGHT - insetY {
                startAngle = 270
                endAngle = 180
            }
            
            // 制造动画
            makeSpringAnimation(startAngle, endAngle: endAngle, centerPoint: centerPoint, index: index, itemView: itemView)
            
        }
    }
    
    /**
     根据手势弹出sheet
     
     - parameter gestureRecognizer: 手势
     - parameter inView:            手势所在视图
     */
    func startWithGestureRecognizer(gestureRecognizer: UIGestureRecognizer, inView: UIView) -> Void {
        
        // 添加弹出视图
        inView.addSubview(self)
        
        // 遮罩用当前view
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        // 触摸圆点
        let centerPoint = gestureRecognizer.locationInView(inView)
        
        // 开始弹簧动画
        startSpringAnimation(centerPoint)
        
        // 圆点视图
        centerView.frame = CGRect(x: centerPoint.x - 20, y: centerPoint.y - 20, width: 40, height: 40)
        inView.addSubview(centerView)
        
    }
    
    // MARK: - 懒加载
    lazy var centerView: UIView = {
        let centerView = UIView()
        centerView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        centerView.layer.cornerRadius = 20
        centerView.layer.masksToBounds = true
        centerView.layer.borderColor = UIColor(red:0.502,  green:0.502,  blue:0.502, alpha:0.5).CGColor
        centerView.layer.borderWidth = 2.0
        return centerView
    }()
    
    
}