//
//  GameScene.swift
//  FlappyBird
//
//  Created by YashimaMasafumi on 2021/02/18.
//

import UIKit
import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
//    var item:SKSpriteNode!
    
    //衝突判定カテゴリー
    let birdCategory:UInt32 = 1<<0           //0...0000001
    let groundCategory:UInt32 = 1<<1         //0...0000010
    let wallCategory:UInt32 = 1<<2           //0...0000100
    let scoreCategory:UInt32 = 1<<3          //0...0001000
    let appleCategory:UInt32 = 1<<4
    let greenappleCategory:UInt32 = 1<<5
    let poisonappleCategory:UInt32 = 1<<6
    
    //スコア用
    var score = 0
    var score_item = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard

    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        //重力の設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード,スクロールノードに追加
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        
        setupScoreLabel()
        
        let BGM = SKAction.repeatForever(SKAction.playSoundFileNamed("BGM.mp3", waitForCompletion: true))
        self.run(BGM)
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
            
            //スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
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
    
    func setupWall() {
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //壁の移動に関するアクションの作成
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -2*movingDistance, y: 0, duration: 8)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall,removeWall])
        
        //壁の作成に関するアクションの作成
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_lenght = birdSize.height * 3
        
        //隙間位置の上下の振れ幅を鳥のサイズの2.5倍にする
        let random_y_range = birdSize.height * 2.5
        
        //下の壁のY軸下限位置（中央位置から下方向の最大振れ幅で下の壁を表示する位置）を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height)/2
        let under_wall_lowest_y = center_y - slit_lenght/2 - wallTexture.size().height/2 - random_y_range/2
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.run ({
            //壁関連のノードを載せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width/2, y: 0)
            //雲より手前地面より奥に配置
            wall.zPosition = -50
            
            //0~random_y_rangemまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            //Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            //下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            //衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            wall.addChild(under)
            
            //上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + slit_lenght + wallTexture.size().height)
            //スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            //衝突の時に動かなように設定する
            upper.physicsBody?.isDynamic = false
            wall.addChild(upper)
            
            //スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width/2, y: self.frame.height/2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            wall.addChild(scoreNode)
            
            //アイテムを作成
//            let randomItem_Num = Float.random(in: 0...1)
//            let item_x = CGFloat(upper.size.width + self.bird.size.width*2)
//            let item_y = center_y + self.frame.size.height/2 * CGFloat.random(in: -0.5...0.5)
//            switch randomItem_Num {
//            case (0..<3/10):
//                //appleを出現
//                let itemTexture = SKTexture(imageNamed: "apple")
//                itemTexture.filteringMode = .linear
//                let item = SKSpriteNode(texture: itemTexture)
//                item.physicsBody?.categoryBitMask = self.appleCategory
//                item.position = CGPoint(x: item_x, y: item_y)
//                item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height/2)
//                item.physicsBody?.isDynamic = false
//                item.physicsBody?.contactTestBitMask = self.birdCategory
//                wall.addChild(item)
//            case (3/10..<2/5):
//                //greenappleを出現
//                let itemTexture = SKTexture(imageNamed: "apple_green")
//                itemTexture.filteringMode = .linear
//                let item = SKSpriteNode(texture: itemTexture)
//                item.physicsBody?.categoryBitMask = self.greenappleCategory
//                item.position = CGPoint(x: item_x, y: item_y)
//                item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height/2)
//                item.physicsBody?.isDynamic = false
//                item.physicsBody?.contactTestBitMask = self.birdCategory
//                wall.addChild(item)
//            case (2/5...3/5):
//                //poisonappleを出現
//                let itemTexture = SKTexture(imageNamed: "apple_poison")
//                itemTexture.filteringMode = .linear
//                let item = SKSpriteNode(texture: itemTexture)
//                item.physicsBody?.categoryBitMask = self.poisonappleCategory
//                item.position = CGPoint(x: item_x, y: item_y)
//                item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height/2)
//                item.physicsBody?.isDynamic = false
//                item.physicsBody?.contactTestBitMask = self.birdCategory
//                wall.addChild(item)
//            default:
//                return
//            }
            
            
            
//            if randomItem_Num < 3/10 {
//                //appleを出現
//                let itemTexture = SKTexture(imageNamed: "apple")
//                itemTexture.filteringMode = .linear
//                let item = SKSpriteNode(texture: itemTexture)
//                item.physicsBody?.categoryBitMask = self.appleCategory
//                item.position = CGPoint(x: item_x, y: item_y)
//                item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height/2)
//                item.physicsBody?.isDynamic = false
//                item.physicsBody?.contactTestBitMask = self.birdCategory
//                wall.addChild(item)
//            } else if randomItem_Num >= 3/10 && randomItem_Num < 2/5 {
//                //greenappleを出現
//                let itemTexture = SKTexture(imageNamed: "apple_green")
//                itemTexture.filteringMode = .linear
//                let item = SKSpriteNode(texture: itemTexture)
//                item.physicsBody?.categoryBitMask = self.greenappleCategory
//                item.position = CGPoint(x: item_x, y: item_y)
//                item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height/2)
//                item.physicsBody?.isDynamic = false
//                item.physicsBody?.contactTestBitMask = self.birdCategory
//                wall.addChild(item)
//            } else if randomItem_Num >= 2/5 && randomItem_Num < 1 {
//                //poisonappleを出現
//                let itemTexture = SKTexture(imageNamed: "apple_poison")
//                itemTexture.filteringMode = .linear
//                let item = SKSpriteNode(texture: itemTexture)
//                item.physicsBody?.categoryBitMask = self.poisonappleCategory
//                item.position = CGPoint(x: item_x, y: item_y)
//                item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height/2)
//                item.physicsBody?.isDynamic = false
//                item.physicsBody?.contactTestBitMask = self.birdCategory
//                wall.addChild(item)
//            }
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        //次の壁作成までの待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->待ち時間->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation,waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird() {
        //鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        //2種類のテクスチャを交互に表示するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA,birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        //アニメーションを設定
        bird.run(flap)
        
        //スプライトを追加する
        addChild(bird)
    }
    
    //画面をタップしたときに呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //ゲーム中の時
        if scrollNode.speed > 0 {
            //鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }
        //ゲームが停止した時
        else if bird.speed == 0{
            restart()
        }
    }
    
    //SKPhysicsContactDelegateのメソッドで衝突した時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        //ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        //&はビットアンド、２つのビットを結合する
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            //ベストスコア更新か確認する
            var bestscore = userDefaults.integer(forKey: "BEST")
            if score > bestscore {
                bestscore = score
                bestScoreLabelNode.text = "Best Score:\(bestscore)"
                userDefaults.set(bestscore, forKey: "BEST")
                userDefaults.synchronize()
            }
        }
        //アイテムに衝突した時の処理
        if (contact.bodyA.categoryBitMask & appleCategory) == appleCategory || (contact.bodyB.categoryBitMask & appleCategory) == appleCategory {
            contact.bodyB.node?.removeFromParent()
            print("アイテム獲得")
            score_item += 1
            itemScoreLabelNode.text = "Item Score:\(score_item)"
            scoreLabelNode.text = "Score:\(score)"
            //アイテム獲得音を鳴らす
            let getMusic = SKAction.playSoundFileNamed("get.mp3", waitForCompletion: true)
            self.run(getMusic)
        }
        if (contact.bodyA.categoryBitMask & greenappleCategory) == greenappleCategory || (contact.bodyB.categoryBitMask & greenappleCategory) == greenappleCategory {
            contact.bodyB.node?.removeFromParent()
            print("アイテム獲得")
            score_item += 2
            itemScoreLabelNode.text = "Item Score:\(score_item)"
            scoreLabelNode.text = "Score:\(score)"
            //アイテム獲得音を鳴らす
            let getMusic = SKAction.playSoundFileNamed("get.mp3", waitForCompletion: true)
            self.run(getMusic)
        }
        if (contact.bodyA.categoryBitMask & poisonappleCategory) == poisonappleCategory || (contact.bodyB.categoryBitMask & poisonappleCategory) == poisonappleCategory {
            contact.bodyB.node?.removeFromParent()
            print("アイテム獲得")
            score_item -= 1
            itemScoreLabelNode.text = "Item Score:\(score_item)"
            scoreLabelNode.text = "Score:\(score)"
            //アイテム獲得音を鳴らす
            let getMusic = SKAction.playSoundFileNamed("get.mp3", waitForCompletion: true)
            self.run(getMusic)
        }
        else {
            //壁か地面と衝突した
            print("GameOver")
            
            //スクロールを停止させる
            scrollNode.speed = 0
            
            //一時的に壁と衝突して跳ね返らないようにする
            bird.physicsBody?.collisionBitMask = groundCategory
            
            //衝突表現に回転追加、回転後停止する
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi)*CGFloat(bird.position.y)*0.01, duration: 1)
            bird.run(roll, completion: {
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        score_item = 0
        itemScoreLabelNode.text = "Item Score:\(score_item)"
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        score_item = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item Score:\(score_item)"
        self.addChild(itemScoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
