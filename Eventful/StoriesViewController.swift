//
//  Stories.swift
//  Eventful
//
//  Created by Shawn Miller on 8/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import  AVFoundation
import AFDateHelper
import Firebase

class StoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SegmentedProgressBarDelegate {
    
    let cellID = "cellID"
    var eventKey = ""
    var allStories = [Story]()
    let player: AVPlayer? = nil
    
    var playerController: AVPlayerViewController!
    var imageView: UIImageView!
    var currentIndex = 0
    var spb: SegmentedProgressBar!
    var isRewind = false
    var isForwarding = false
    var onRepeat = false
    
    var durations = [TimeInterval]()
    
    var tapInfoView: UITapGestureRecognizer!
    var swipeInfoView: UISwipeGestureRecognizer!
    
    var leftRect: CGRect!
    var rightRect: CGRect!
    
    //The Info View for the username/time/profile image
    var infoView: UIView!
    var infoImageView: UIImageView!
    var infoNameLabel: UILabel!
    var infoTimeLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
       let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allStories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! StoryDisplayCell
        let desiredURL = allStories[indexPath.row].Url
        cell.startPlayingVideo(urlEntered: desiredURL)
        cell.cellStry = allStories[indexPath.row]
        cell.backgroundColor = UIColor.white
    return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.addSubview(collectionView)
        //collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        //Do any additional setup after loading the view
        collectionView.register(StoryDisplayCell.self, forCellWithReuseIdentifier: cellID)
        
        tapInfoView = UITapGestureRecognizer(target: self, action: #selector(self.tapInfoViewPressed(_:)))
        swipeInfoView = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedInfoView(_:)))
        
        tapInfoView.numberOfTapsRequired = 1
        swipeInfoView.direction = .down
        
        let width = self.view.frame.width / 4
        
        leftRect = CGRect(x: 0, y: 0, width: width, height: self.view.frame.height)
        rightRect = CGRect(x: self.view.frame.maxX - width, y: 0, width: width, height: self.view.frame.height)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchStories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        spb.removeFromSuperview()
        playerController.view.removeFromSuperview()
        imageView.removeFromSuperview()
        
        infoView.removeFromSuperview()
        
        infoImageView.image = nil
        infoNameLabel.text = ""
        infoTimeLabel.text = ""
        
        playerController.player = nil
        playerController = nil
        
        imageView = nil
        spb = nil
        
        UserService.setCurrentIndexOfStory(currentIndex: currentIndex, eventId: eventKey) { (user) in
            
            if user != nil {
                print("worked")
            }
        }
        
    }
    
    
    @IBAction func tapInfoViewPressed(_ sender: AnyObject) {
        let p = sender.location(in: self.view)
        handleTap(p: p)
    }

    
    @IBAction func swipedInfoView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func handleTap(p: CGPoint) {
        if rightRect.contains(p) {
            //next pressed
            if currentIndex < allStories.count {
                //you can go to the next
                //playerController.player?.pause()
                playerController.player = nil
                
                infoImageView.image = nil
                infoNameLabel.text = ""
                infoTimeLabel.text = ""
                
                
                self.spb.skip()
                
            } else {
                //done viewing story so leave
                self.dismiss(animated: true, completion: nil)
            }
            
        } else if leftRect.contains(p) {
            //back pressed
            if currentIndex > 0 {
                //you can go back
                isRewind = true
                //playerController.player?.pause()
                playerController.player = nil
                
                infoImageView.image = nil
                infoNameLabel.text = ""
                infoTimeLabel.text = ""
                
                self.spb.rewind()
                
            } else {
                //cant go back so leave the story vc
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    
    fileprivate func fetchStories(){
        
        StoryService.showEvent(for: self.eventKey) { (stories) in
            
            //reset the current index
            self.currentIndex = 0
            self.allStories.removeAll()
            self.durations.removeAll()
            
            self.allStories = stories
            
            if self.allStories.count > 0 {
                
                for s in self.allStories {
                    
                    if s.Url.contains(".mp4") {
                        
                        let videoUrl = URL(string: s.Url)
                        
                        let asset = AVAsset(url: videoUrl!)
                        let secAsset = CMTimeGetSeconds(asset.duration)
                        self.durations.append(secAsset)
                    
                    } else {
                        self.durations.append(5)
                    }
                    
                }
                self.playStories()
            }
            
        }
    }
    
    func setupViews() {
        spb = SegmentedProgressBar(numberOfSegments: allStories.count)
        spb.frame = CGRect(x: 0, y: 4, width: self.view.frame.width, height: 9)
        self.view.addSubview(spb)
        
        spb.delegate = self
        playerController = AVPlayerViewController()
        playerController.showsPlaybackControls = false
        
        self.addChildViewController(playerController)
        
        imageView = UIImageView(frame: self.view.frame)
        
        infoView = UIView(frame: self.view.frame)
        infoView.backgroundColor = UIColor.clear
        
        let infoImageViewFrame = CGRect(x: 10, y: 20, width: 30, height: 30)
        
        infoImageView = UIImageView(frame: infoImageViewFrame)
        infoImageView.layer.cornerRadius = 15
        infoImageView.layer.masksToBounds = true
        
        self.view.addSubview(imageView)
        self.view.addSubview(playerController.view)
        self.view.bringSubview(toFront: spb)
        
        self.view.addSubview(infoView)
        
        self.infoView.addSubview(infoImageView)
        
        let infoNameLabelFrame = CGRect(x: infoImageView.frame.origin.x + infoImageView.frame.width + 5, y: 20, width: 80, height: 30)
        infoNameLabel = UILabel(frame: infoNameLabelFrame)
        infoNameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        infoNameLabel.textColor = UIColor.white
        infoNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        infoNameLabel.adjustsFontSizeToFitWidth = true
        
        self.infoView.addSubview(infoNameLabel)
        
        let infoTimeLabelFrame = CGRect(x: infoNameLabel.frame.origin.x + infoNameLabel.frame.width + 10, y: 20, width: 40, height: 30)
        infoTimeLabel = UILabel(frame: infoTimeLabelFrame)
        infoTimeLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        infoTimeLabel.textColor = UIColor.white

        self.infoView.addSubview(infoTimeLabel)
        
        infoView.isUserInteractionEnabled = true
        infoView.addGestureRecognizer(tapInfoView)
        infoView.addGestureRecognizer(swipeInfoView)
        
        infoTimeLabel.layer.cornerRadius = 10
        infoTimeLabel.layer.masksToBounds = true
        infoTimeLabel.textAlignment = .center
        
        infoNameLabel.layer.cornerRadius = 10
        infoNameLabel.layer.masksToBounds = true
        infoNameLabel.textAlignment = .center
        
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerController.view.frame = view.frame
        
        spb.durations = durations
    }
    
    func playStories() {
    
        self.setupViews()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            UserService.getCurrentIndexOfStory(eventId: eventKey, userId: uid, completion: { (savedIndex) in
                
                if !self.onRepeat {
                    if let savedIndex = savedIndex {
                        
                        self.currentIndex = savedIndex
                        self.spb.savedIndex = savedIndex
                        
                        self.isForwarding = true
                        
                        for i in 0...savedIndex {
                            self.spb.skip()
                            print("skipping")
                        }
                        
                        self.isForwarding = false
                        self.segmentedProgressBarChangedIndex(index: 0)
                        return

                    } else {
                        
                        let savedIndex = 0
                        self.isForwarding = true
                        
                        for i in 0...savedIndex {
                            self.spb.skip()
                            print("skipping")
                        }
                        
                        self.isForwarding = false
                        self.segmentedProgressBarChangedIndex(index: 0)
                        return
                        
                    }
                    
                } else {
                    self.onRepeat = false
                }

                let story = self.allStories[self.currentIndex]
                
                self.getStoryInfo(story: story)
                if story.Url.contains(".mp4") {
                    //video
                    print("the first one bro")
                    self.playerController.view.isHidden = false
                    
                    self.view.bringSubview(toFront: self.playerController.view)
                    self.view.bringSubview(toFront: self.spb)
                    self.view.bringSubview(toFront: self.infoView)
                    
                    let videoUrl = URL(string: story.Url)
                    
                    let asset = AVAsset(url: videoUrl!)
                    let secAsset = CMTimeGetSeconds(asset.duration)
                    print("this is the url time \(secAsset)")
                
                    self.playerController.player = AVPlayer(url: videoUrl!)
                    self.freezeViewsUntilLoaded()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self.unfreeze()
                        
                        self.playerController.player?.play()
                        self.spb.startAnimation()
                    })
                    

                } else {
                    //photo
                    self.view.bringSubview(toFront: self.imageView)
                    self.view.bringSubview(toFront: self.spb)
                    self.view.bringSubview(toFront: self.infoView)
                    
                    let url = URL(string: story.Url)
                    let data = try! Data(contentsOf: url!)
                    let image = UIImage(data: data)
                    
                    self.imageView.image = image
                    
                    self.spb.startAnimation()
                }
            })
        }
        
    }
    
    func freezeViewsUntilLoaded() {
        playerController.view.isUserInteractionEnabled = false
        imageView.isUserInteractionEnabled = false
    }
    
    func unfreeze() {
        playerController.view.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
    }
    
    
    //SEGMENT BAR DELEGATES
    func segmentedProgressBarFinished() {
        print("segment is done")
        
        currentIndex = 0
        onRepeat = true
        playStories()

    }
    
    func segmentedProgressBarChangedIndex(index: Int) {
        print("segment index changed")
        
        //spb.isPaused = true
        
        if playerController.player != nil {
            playerController.player = nil
        }
        
        if isRewind {
            currentIndex = currentIndex - 1
            isRewind = false
            
        } else if isForwarding {
            print("1")
            return
        
        } else {
            currentIndex = currentIndex + 1
            print("2")
        }
        
        spb.isPaused = true
        
        if currentIndex < allStories.count {
            
            let story = allStories[currentIndex]
            
            getStoryInfo(story: story)
            
            if story.Url.contains(".mp4") {
                //video
                print("video")
                self.playerController.view.isHidden = false
                self.view.bringSubview(toFront: playerController.view)
                self.view.bringSubview(toFront: spb)
                self.view.bringSubview(toFront: infoView)
                
                let videoUrl = URL(string: story.Url)
                playerController.player = AVPlayer(url: videoUrl!)

                freezeViewsUntilLoaded()
                
                print("is paused: \(self.spb.isPaused)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.unfreeze()
                    
                    self.spb.currentAnimationIndex = self.currentIndex
                    self.playerController.player?.play()
                    self.spb.isPaused = false
                })

                
            } else {
                //photo
                print("photo")
                self.view.bringSubview(toFront: imageView)
                self.view.bringSubview(toFront: spb)
                self.view.bringSubview(toFront: infoView)
                
                let url = URL(string: story.Url)
                let data = try! Data(contentsOf: url!)
                let image = UIImage(data: data)
                
                self.spb.duration = 3
                self.spb.currentAnimationIndex = self.currentIndex
                
                print("is paused: \(self.spb.isPaused)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.spb.isPaused = false
                    self.imageView.image = image
                })

                
            }
        }
    }
    
    func getStoryInfo(story: Story) {
        
        setupTimeLabel(date: story.date)
        
        UserService.show(forUID: story.uid) { (user) in
            
            if let user = user {
                print("got the user")
                print(user.username)
                self.infoNameLabel.text = user.username
                
                let imageUrl = URL(string: user.profilePic!)
                
                if user.profilePic != ""{
                    print("Tried to load default pic")
                    self.infoImageView.af_setImage(withURL: imageUrl!)
                    
                } else {
                    print("Set image Url")
                    self.infoImageView.image = UIImage(named: "no-profile-pic")
                }
                
            } else {
                //user doesnt exist for some reason
                print("for whatever fucking reason didnt get the user")
            }
            
        }
    }
    
    func setupTimeLabel(date: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let start = dateFormatter.date(from: date)
        let minutes = Int(Date().since(start!, in: .minute))
        
        if minutes < 60 {
            infoTimeLabel.text = "\(minutes)min"
            
        } else {
            
            let hours = minutes / 60
            
            if hours < 24 {
                infoTimeLabel.text = "\(hours)hr"
                
            } else {
                let days = Int(Date().since(start!, in: .day))
                infoTimeLabel.text = "\(days)d"
            }
            
        }
        
        
    }
    
    
    func deleteStory() {
        
        
        
        
    }
    


    
    
}
