//
//  HomeFeedController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/28/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftLocation
import CoreLocation

class HomeFeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate {
    var isFinishedPaging = false
    let detailView = EventDetailViewController()
    let refreshControl = UIRefreshControl()
    var emptyLabel: UILabel?
    var allEvents = [Event]()
    //will containt array of event keys
    var eventKeys = [String]()
    
    var grideLayout = GridLayout(numberOfColumns: 2)
    
    let paginationHelper = PaginationHelper<Event>(serviceMethod: PostService.showEvent)

    override func viewDidLoad() {
        super.viewDidLoad()
        // we had to do this way because View Controller only has a view now Uicollection view does as well because it is a subclass of UI viewcontroller and because this controller also contains a collection view that is a child of the view controllers view we have to change the collection views background color because that's whats being presented to the screen
        collectionView?.backgroundColor = UIColor.white
        // may need to take this out
        //collectionView?.delegate = self
        //collectionView?.dataSource = self
        collectionView?.collectionViewLayout = grideLayout
        collectionView?.reloadData()
        self.collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        navigationItem.title = "Home Page"
        collectionView?.register(CustomCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        
//        PostService.showEvent(location: User.current.location!) { (event) in
//            self.allEvents = event
//            print(self.allEvents)
//            
//            DispatchQueue.main.async {
//                self.collectionView?.reloadData()
//            }
//        }
        configureCollectionView()
        reloadHomeFeed()
    }
    
    
    func reloadHomeFeed() {
        self.paginationHelper.reloadData(completion: { [unowned self] (events) in
            self.allEvents = events
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        })
    }

    
    func configureCollectionView() {
        // add pull to refresh
        refreshControl.addTarget(self, action: #selector(reloadHomeFeed), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
    }
    
    // need to tell it how many cells to have
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return allEvents.count
    }
    
    let customCellIdentifier = "customCellIdentifier"
    // need to tell the collection view controller what type of cell we want to return
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCell
        let imageURL = URL(string: allEvents[indexPath.item].currentEventImage)
        print(imageURL ?? "")
        customCell.sampleImage.af_setImage(withURL: imageURL!)
        return customCell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let selectedEvent = self.imageArray[indexPath.row]
        //let eventDetailVC
        if let cell = collectionView.cellForItem(at: indexPath){
            detailView.eventImage = allEvents[indexPath.row].currentEventImage
            detailView.eventName = allEvents[indexPath.row].currentEventName
          //  print("Look here for event name")
           // print(detailView.eventName)
            detailView.eventDescription = allEvents[indexPath.row].currentEventDescription
            detailView.eventStreet = allEvents[indexPath.row].currentEventStreetAddress
            detailView.eventCity = allEvents[indexPath.row].currentEventCity
            detailView.eventState = allEvents[indexPath.row].currentEventState
            detailView.eventZip = allEvents[indexPath.row].currentEventZip
            detailView.eventKey = allEvents[indexPath.row].key!
            detailView.eventPromo = allEvents[indexPath.row].currentEventPromo!
            detailView.eventDate = allEvents[indexPath.row].currentEventDate!
            detailView.eventTime = allEvents[indexPath.row].currentEventTime!
            detailView.currentEvent = allEvents[indexPath.row]
            present(detailView, animated: true, completion: nil)
            //self.navigationController?.pushViewController(detailView, animated: true)
            
        }
         print("Cell \(indexPath.row) selected")
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item >= allEvents.count - 1 {
            print("paginating for post")
            paginationHelper.paginate(completion: { [unowned self] (events) in
                self.allEvents.append(contentsOf: events)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            })
        }else{
            print("Not paginating")
        }
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    //will make surepictures keep same orientation even if you flip screen
    // will most likely look into portrait mode but still good to have
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        grideLayout.invalidateLayout()
    }
    //Will allow the first two cells that are displayed to be of varying widths
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == 1 {
            return CGSize(width: view.frame.width, height: grideLayout.itemSize.height)
        }else{
            return grideLayout.itemSize
        }
    }
    
    
}


//responsible for populating each cell with content

class CustomCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    let sampleImage: UIImageView = {
        let firstImage = UIImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleToFill
        firstImage.layer.masksToBounds = true
        return firstImage
    }()
    let nameLabel: UILabel = {
        let name = UILabel()
        name.text = "Custom Text"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    func setupViews() {
        addSubview(sampleImage)
        backgroundColor = UIColor.white
        //addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sampleImage]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sampleImage]))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// responsible for creating the grid layout that you see in the home view feed

class GridLayout: UICollectionViewFlowLayout {
    
    var numberOfColumns:Int = 2
    
    init(numberOfColumns: Int) {
        super.init()
        // controlls spacing inbetween them as well as spacing below them to next item
        self.numberOfColumns = numberOfColumns
        self.minimumInteritemSpacing = 3
        self.minimumLineSpacing = 5
    }
    // just needs to be here because swift tells us to
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var itemSize: CGSize{
        get{
            if collectionView != nil {
                let collectionVieweWidth = collectionView?.frame.width
                let itemWidth = (collectionVieweWidth!/CGFloat(self.numberOfColumns)) - self.minimumInteritemSpacing
                let itemHeight: CGFloat = 200
                return CGSize(width: itemWidth, height: itemHeight)
            }
            return CGSize(width: 100, height: 100)
        }set{
            super.itemSize = newValue
        }
    }
    
    
}
