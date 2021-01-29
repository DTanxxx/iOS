//
//  ViewController.swift
//  Card flip
//
//  Created by David Tan on 6/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import AVFoundation
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {

    @IBOutlet var gradientView: GradientView!
    @IBOutlet var cardContainer: UIView!
    
    var allCards = [CardViewController]()
    var music: AVAudioPlayer!
    var lastMessage: CFAbsoluteTime = 0  // used to track when the last message was sent to the watch, so that we can limit the message sending rate (ie prevent receiving 100 messages per second when our finger is on the star card)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playMusic()
        createParticles()
        loadCards()
        
        // animate the background gradient color
        view.backgroundColor = UIColor.red
        
        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {
            self.view.backgroundColor = UIColor.blue
        })
        // .allowUserInteraction = so the user can tap cards during the animation
        // .autoreverse = so the view can go back to its original color (ie the view can turn back to red after being changed to blue in the closure)
        // .repeat = so the animation loop back and forward forever
        
        // connect to apple watch
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - customise apple watch settings so the hoax does not get spoiled
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // set an alert controller showning instructions on how to customise the watch
        let instructions = "Please ensure your Apple Watch is configured correctly. On your iPhone, launch Apple's 'Watch' configuration app then choose General > Wake Screen. On that screen, please disable Wake Screen On Wrist Raise, then select Wake For 70 Seconds. On your Apple Watch, please swipe up on your watch face and enable Silent Mode. You're done!"
        let ac = UIAlertController(title: "Adjust your settings", message: instructions, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "I'm Ready", style: .default))
        present(ac, animated: true)
        // NOTE: You need to put this alert controller code inside viewDidAppear() rather than viewDidLoad() because it presents an alert view controller. If you put it in viewDidLoad() then it won't work because at the time not everything would have finished loading and presenting an alert controller would cause problems.
    }
    
    // MARK: - load cards
    
    @objc func loadCards() {
        // re-enable user interaction
        view.isUserInteractionEnabled = true
        
        // remove any existing cards
        for card in allCards {
            card.view.removeFromSuperview()  // remove the view
            card.removeFromParent()  // remove the vc
        }
        
        allCards.removeAll(keepingCapacity: true)  // clear the array
        
        // create an array of card positions
        let positions = [
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235)
        ]
        
        // load and unwrap our Zener card images
        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!
        
        // create an array of the images, one for each card, then shuffle it
        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images.shuffle()
        
        // loop over each card position and create a new card view controller
        for (index, position) in positions.enumerated() {
            let card = CardViewController()
            card.delegate = self  // set the delegate property of CardViewController to this ViewController
            
            // use view controller containment and also add the card's view to our cardContainer view
            addChild(card)  // vc containment method 1
            cardContainer.addSubview(card.view)
            card.didMove(toParent: self)  // vc containment method 2
            
            // position the card appropriately, then give it an image from our array
            card.view.center = position
            card.front.image = images[index]
            
            // if we just gave the new card the star image, mark this as the correct answer
            if card.front.image == star {
                card.isCorrect = true
            }
            
            // add the new card view controller to our array for easier tracking
            allCards.append(card)
        }
    }
    
    // MARK: - tap cards
    
    func cardTapped(_ tapped: CardViewController) {
        // ensure that only one card can be tapped at any time - we will be doing that by disabling user interaction for our main view as soon as the user taps any card, and checking the isUserInteractionEnabled property at the start of this method
        guard view.isUserInteractionEnabled == true else { return }
        view.isUserInteractionEnabled = false
        
        // loop through all the cards in the allCards array
        for card in allCards {
            if card == tapped {
                // when it finds the card that was tapped, animate it to flip over then fade away
                card.wasTapped()
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1)  // the perform() method allows us to call a method after a delay or in the background
            } else {
                // for all other cards, animate them fading away
                card.wasntTapped()
            }
        }
        
        // reset the game after two seconds so that more cards appear
        perform(#selector(loadCards), with: nil, afterDelay: 2)
    }
    
    // MARK: - create particles
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()  // CAEmitterLayer() is similar to SKEmitterNode; each CAEmitterLayer() defines the position, shape, size and rendering mode of a particle system, but doesn't actually define any particles - that is handled by CAEmitterCell (which defines the velocity, birthRate etc). You can create as many CAEmitterCell as you want.
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2, y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        particleEmitter.renderMode = .additive  // overlapping particles get brighter
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = .pi
        cell.spinRange = 5
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.1).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "particle")?.cgImage
        particleEmitter.emitterCells = [cell]  // we emit only one cell at a time, so that each individual cell has slightly different properties eg speed
        
        gradientView.layer.addSublayer(particleEmitter)  // we are adding the particle emitter as a sublayer of the gradientView view. This is important as it ensures the stars always go behind the cards.
    }
    
    // MARK: - make music
    
    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                music = audioPlayer
                music.numberOfLoops = -1  // we want the music to loop infinitely
                music.play()
            }
        }
    }
    
    // MARK: - pressure tapping hoax
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)  // need to call this
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: cardContainer)  // note: location(in:) should be passed cardContainer, not the main view
        
        for card in allCards {
            // check if the card view controller's view contains the touch location
            if card.view.frame.contains(location) {
                // check if force touch is supported on the device
                if view.traitCollection.forceTouchCapability == .available {
                    // check if the touch's force is equal to the maximum force the screen can recognise (ie if pressed hard)
                    if touch.force == touch.maximumPossibleForce {
                        // change the card's front image to the star and set that card's isCorrect property to true
                        card.front.image = UIImage(named: "cardStar")
                        card.isCorrect = true
                    }
                }
                
                // the second cheat: if the card which our touch is currently on is correct, send message to apple watch
                if card.isCorrect {
                    sendWatchMessage()
                }
            }
        }
    }
    
    // MARK: - WCSession protocol methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // MARK: - sending messages to watch
    
    func sendWatchMessage() {
        // get the current time
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        // if less than half a second has passed, bail out
        if lastMessage + 0.5 > currentTime {
            return
        }
        
        // send a message to the watch if it's reachable
        if (WCSession.default.isReachable) {
            let message = ["Message": "Hello"]  // message needs to be a dictionary
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
        
        // update our rate limiting property
        lastMessage = CFAbsoluteTimeGetCurrent()
    }
    

}

