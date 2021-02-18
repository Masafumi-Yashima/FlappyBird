//
//  GameScene.swift
//  FlappyBird
//
//  Created by YashimaMasafumi on 2021/02/18.
//

import UIKit
import SpriteKit

class GameScene: SKScene {

    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
