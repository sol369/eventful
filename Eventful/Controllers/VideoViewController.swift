
import UIKit
import AVFoundation
import AVKit
import Firebase


class VideoViewController: UIViewController {
    
   public var eventKey = ""
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //URL of video to save to Firebase storage. URL is being passed from CameraViewController
    private var videoURL: URL
    
    // Allows you to play the actual mp4 or video
    var player: AVPlayer?
    // Allows you to display the video content of a AVPlayer
    var playerController : AVPlayerViewController?
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nextButton: UIButton = {
        //let nextButton = UIButton(frame: CGRect(x: 320, y: 600, width: 30, height: 30))
        let nextButton = UIButton(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 30, height: 30))
        nextButton.backgroundColor = UIColor.clear
        nextButton.setImage(#imageLiteral(resourceName: "next"), for: UIControlState())
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        return nextButton
    }()
    
    
    func swipeAction(_ swipe: UIGestureRecognizer){
        if let swipeGesture = swipe as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                break
            case UISwipeGestureRecognizerDirection.down:
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                break
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                break
            default:
                break
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)

        
        //Setting the video url of the AVPlayer
        player = AVPlayer(url: videoURL)
        playerController = AVPlayerViewController()
        
        guard player != nil && playerController != nil else {
            return
        }
        playerController!.showsPlaybackControls = false
        // Setting AVPlayer to the player property of AVPlayerViewController
        playerController!.player = player!
        self.addChildViewController(playerController!)
        self.view.addSubview(playerController!.view)
        playerController!.view.frame = view.frame
        // Added an observer for when the video stops playing so it can be on a continuous loop
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
        // Adding buttons programatically
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 20.0, height: 20.0))
        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        //TODO: Need to fix frame of x and y
      
        view.addSubview(nextButton)
        
        //Constraints
        //        let margins = self.view.layoutMarginsGuide
        //        nextButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true
        //        nextButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    
    func cancel() {
               dismiss(animated: true, completion: nil)
//    _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Takes you to AddPostViewController
    func nextPressed()
    {
        print("Next Button pressed")
        
        // Setting nil to the player so video will stop playing
        let alertController = UIAlertController(title: "Add To The Hype??", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let addAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.handleAddToStory()
        }
        alertController.addAction(addAction)
        let cancelAction = UIAlertAction(title: "No", style: .default) { (_) in
            self.handleDontAddToStory()
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated:true, completion: nil)

    }
    
    func handleAddToStory(){
        print("Attempting to add to story")
        print(self.eventKey)
        
        let data = NSData(contentsOf: self.videoURL as URL)!
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        
        let tempVideoPath = NSTemporaryDirectory() + NSUUID().uuidString + ".mp4"
        
        let compressedURL = NSURL.fileURL(withPath: tempVideoPath)
        
        compressVideo(inputURL: videoURL, outputURL: compressedURL) { (exportSession) in
            
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                //worked now add to storage and post to database
                self.addToStorageAndPost(url: compressedURL)
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    
        //svprogresshud insert here
        _ = self.navigationController?.popViewController(animated: true)
        player!.replaceCurrentItem(with: nil)

    }
    
    func handleDontAddToStory(){
      _ = self.navigationController?.popViewController(animated: true)
        player!.replaceCurrentItem(with: nil)

    }

    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func addToStorageAndPost(url: URL) {
        
        let dateFormatter = ISO8601DateFormatter()
        let timeStamp = dateFormatter.string(from: Date())
        let uid = User.current.uid
        
        let storageRef = Storage.storage().reference().child("event_stories").child(self.eventKey).child(uid).child(timeStamp + ".mp4")
        
        StorageService.uploadVideo(url, at: storageRef) { (downloadUrl) in
            guard let downloadUrl = downloadUrl else {
                return
            }
            
            let videoUrlString = downloadUrl.absoluteString
            print(videoUrlString)
            
            //now that the video is saved clear temp file so storage doesnt get full
            do {
                try FileManager.default.removeItem(at: url)
                print("succesful deletion")
            } catch let deleteError as NSError {
                
                print(deleteError.localizedDescription)
            }
            
            //post to the database
            PostService.create(for: self.eventKey, for: videoUrlString)
            
        }
        
    }
    
    
    // Allows the video to keep playing on a loop
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            self.player!.play()
        }
    }
}
