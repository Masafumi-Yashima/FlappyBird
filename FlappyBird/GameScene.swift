//
//  GameScene.swift
//  FlappyBird
//
//  Created by YashimaMasafumi on 2021/02/18.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
    
    var scrollNode:SKNode!

    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
    
    }
    
    func setupGround() {
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width/groundTexture.size().width)+2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
        
        //groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width/2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height/2
            )
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needCloudnumber = Int(self.frame.size.width/cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール->元の位置->左にスクロールを無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud,resetCloud]))
        
        //スプライトを配置する
        for i in 0..<needCloudnumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            //一番後ろになるようにする（奥行き方向マイナス）
            sprite.zPosition = -100
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width/2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height/2
            )
            
            //スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
