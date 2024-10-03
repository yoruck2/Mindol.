//
//  RockStackScene.swift
//  Mindol
//
//  Created by dopamint on 9/30/24.
//

import SpriteKit
import CoreMotion
// TODO: ObjectId.stringValue로 저장하는것을 고려해보기
import RealmSwift

struct RockStackSceneConfig {
    static let rockSize: CGFloat = 60
    static let maxRockSpeed: CGFloat = 1000.0
    static let minRockSpeed: CGFloat = 0.1
    static let forceMagnitude: CGFloat = 5.0
    static let backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
}

class RockStackScene: SKScene {
    private let motionManager = CMMotionManager()
    private var rockNodes: [ObjectId: SKNode] = [:]
    var currentMonth: Date?
    var onRockTapped: ((ObjectId) -> Void)?
    
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBackground()
        setupFloor()
        startMotionUpdates()
    }
    
    private func setupBackground() {
        backgroundColor = RockStackSceneConfig.backgroundColor
    }
    
    func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                guard let data = data else { return }
                self?.updateGravity(with: data)
            }
        }
    }
    // draggable??
    //    override func update(_ currentTime: TimeInterval) {
    //        enumerateChildNodes(withName: "draggable") { (node, _) in
    //            guard let ball = node as? SKSpriteNode,
    //                  let physicsBody = ball.physicsBody else { return }
    //
    //            self.constrainBallPosition(ball)
    //            self.limitBallSpeed(physicsBody)
    //        }
    //    }
    
    func setupRocksFromDiaries(_ diaries: [DiaryTable], for month: Date) {
        self.currentMonth = month
        // 기존의 모든 Rock 노드를 제거
        for node in rockNodes.values {
            node.removeFromParent()
        }
        rockNodes.removeAll()
        
        for diary in diaries {
            addRock(for: diary)
        }
    }
    func addRock(for diary: DiaryTable) {
        guard let rock = Rock(rawValue: diary.feeling) else { return }
        let randomPosition = CGPoint(
            x: CGFloat.random(in: 50...300),
            y: CGFloat.random(in: 100...450)
        )
        let rockNode = createBall(at: randomPosition, rockType: rock, diaryId: diary.id)
        rockNodes[diary.id] = rockNode
        addChild(rockNode)
    }
    // addRock with animation
    func addNewRock(_ diary: DiaryTable) {
        guard let rock = Rock(rawValue: diary.feeling) else { return }
        let position = CGPoint(
            x: CGFloat.random(in: 50...300),
            y: size.height - 50
        )
        let rockNode = createBall(at: position, rockType: rock, diaryId: diary.id)
        
        rockNode.alpha = 0
        rockNode.physicsBody?.isDynamic = false
        
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        let enableGravity = SKAction.run { [weak rockNode] in
            rockNode?.physicsBody?.isDynamic = true
        }
        let sequence = SKAction.sequence([fadeIn, enableGravity])
        rockNode.run(sequence)
        rockNodes.updateValue(rockNode, forKey: diary.id)
        addChild(rockNode)
        
    }
    private func createBall(at position: CGPoint, rockType: Rock, diaryId: ObjectId) -> SKNode {
        let ball = SKSpriteNode(imageNamed: rockType.rawValue)
        ball.position = position
        ball.size = CGSize(width: 60, height: 60)
        ball.name = diaryId.stringValue
        
        let physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody = physicsBody
        setupBallPhysics(for: ball)
        return ball
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let name = node.name, let diaryId = try? ObjectId(string: name) {
                onRockTapped?(diaryId)
                break
            }
        }
    }
    
}

// MARK: physics settings
extension RockStackScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        handleCollision(contact)
    }
    private func setupPhysicsWorld() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.speed = 1.0
        physicsWorld.contactDelegate = self
    }
    
    private func setupFloor() {
        let floorNode = SKNode()
        floorNode.position = CGPoint(x: size.width / 2, y: 0)
        floorNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        floorNode.physicsBody?.isDynamic = false
        floorNode.physicsBody?.friction = 0.4
        floorNode.physicsBody?.restitution = 0.2
        addChild(floorNode)
    }
    func updateGravity(with accelerometerData: CMAccelerometerData) {
        let acceleration = accelerometerData.acceleration
        let gravityX = acceleration.x * 9.8
        let gravityY = acceleration.y * 9.8
        physicsWorld.gravity = CGVector(dx: gravityX, dy: gravityY)
    }
    
    private func setupBallPhysics(for ball: SKSpriteNode) {
        let physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody = physicsBody
        ball.physicsBody?.restitution = 0.2
        ball.physicsBody?.friction = 0.2
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.mass = 1.0
        ball.physicsBody?.linearDamping = 0.1
        ball.physicsBody?.angularDamping = 0.1
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = 0x1 << 0
        ball.physicsBody?.collisionBitMask = 0x1 << 0
        ball.physicsBody?.contactTestBitMask = 0x1 << 0
    }
    
    func constrainPosition(_ position: CGPoint, for node: SKNode) -> CGPoint {
        guard let nodeSize = (node as? SKSpriteNode)?.size else { return position }
        
        let minX = nodeSize.width / 2
        let maxX = size.width - nodeSize.width / 2
        let minY = nodeSize.height / 2
        let maxY = size.height - nodeSize.height / 2
        
        let x = min(max(position.x, minX), maxX)
        let y = min(max(position.y, minY), maxY)
        
        return CGPoint(x: x, y: y)
    }
    
    private func constrainBallPosition(_ ball: SKSpriteNode) {
        let constrainedPosition = self.constrainPosition(ball.position, for: ball)
        if constrainedPosition != ball.position {
            ball.position = constrainedPosition
            
            if constrainedPosition.x != ball.position.x {
                ball.physicsBody?.velocity.dx = -ball.physicsBody!.velocity.dx * 0.8
            }
            if constrainedPosition.y != ball.position.y {
                ball.physicsBody?.velocity.dy = -ball.physicsBody!.velocity.dy * 0.8
            }
        }
    }
    
    private func limitBallSpeed(_ physicsBody: SKPhysicsBody) {
        let velocity = physicsBody.velocity
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        
        if speed > RockStackSceneConfig.maxRockSpeed {
            let scale = RockStackSceneConfig.maxRockSpeed / speed
            physicsBody.velocity = CGVector(dx: velocity.dx * scale, dy: velocity.dy * scale)
        }
        
        if speed < RockStackSceneConfig.minRockSpeed {
            physicsBody.velocity = .zero
            physicsBody.angularVelocity = 0
        }
    }
    
    private func handleCollision(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node as? SKSpriteNode,
              let bodyB = contact.bodyB.node as? SKSpriteNode else {
            return
        }
        
        // 충돌 방향 계산
        let collisionVector = CGVector(
            dx: bodyB.position.x - bodyA.position.x,
            dy: bodyB.position.y - bodyA.position.y
        )
        // 충돌 힘 계산 (거리에 반비례)
        let distance = sqrt(collisionVector.dx * collisionVector.dx + collisionVector.dy * collisionVector.dy)
        let forceMagnitude = RockStackSceneConfig.forceMagnitude / max(distance, 1)
        
        let forceVector = CGVector(
            dx: collisionVector.dx / distance * forceMagnitude,
            dy: collisionVector.dy / distance * forceMagnitude
        )
        // 힘 적용
        bodyA.physicsBody?.applyForce(CGVector(dx: -forceVector.dx, dy: -forceVector.dy))
        bodyB.physicsBody?.applyForce(forceVector)
        // 위치 제한
        bodyA.position = constrainPosition(bodyA.position, for: bodyA)
        bodyB.position = constrainPosition(bodyB.position, for: bodyB)
    }
}
