//
//  HomeViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/27/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import EZSwipeController


class HomeViewController: EZSwipeController {
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // setupView()
//    }
    
    override func setupView() {
        datasource = self
        navigationBarShouldNotExist = true
    }

    
    
    // Things that I need to appear everytime will be in viewWillAppear
//    func setupView( ) {
//        let layout = UICollectionViewFlowLayout()
//        let homeFeedController = HomeFeedController(collectionViewLayout: layout)
//        
//        // let viewController = HomeFeedController()
//        let navController = UINavigationController(rootViewController: homeFeedController)
//        navController.navigationBar.isTranslucent = false
//        navController.tabBarItem.image = UIImage(named: "icons8-Home-50")
//        navController.tabBarItem.selectedImage = UIImage(named: "icons8-Home Filled-50")
//
//        navController.tabBarItem.title = "Home"
//        //ProfileeViewController being setup and added to array of view controllers
//        
//        let profileView = ProfileeViewController(collectionViewLayout: layout)
//        
//        let profileViewNavController = UINavigationController(rootViewController: profileView)
//        profileViewNavController.navigationBar.isTranslucent = false
//        profileViewNavController.tabBarItem.image = UIImage(named: "icons8-User-50")
//        profileViewNavController.tabBarItem.selectedImage = UIImage(named: "icons8-User Filled-50")
//        
//        profileViewNavController.tabBarItem.title = "Search"
//
//        let searchController = EventSearchController(collectionViewLayout: UICollectionViewFlowLayout())
//        let searchNavController = UINavigationController(rootViewController: searchController)
//        searchNavController.tabBarItem.image = UIImage(named: "icons8-Search-48")
// 
//        searchNavController.tabBarItem.title = "Search"
//
//        
//        // array of view controllers
//        viewControllers = [navController,searchNavController, profileViewNavController]
//      
//        
//    
//        
//    }
//    
//    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}






extension HomeViewController: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        
        
        let layout = UICollectionViewFlowLayout()
        let homeFeedController = HomeFeedController(collectionViewLayout: layout)
//        let navController = UINavigationController(rootViewController: homeFeedController)
//        navController.navigationBar.isTranslucent = false
//        navController.tabBarItem.image = UIImage(named: "icons8-Home-50")
//        navController.tabBarItem.selectedImage = UIImage(named: "icons8-Home Filled-50")
        
//        navController.tabBarItem.title = "Home"
        //ProfileeViewController being setup and added to array of view controllers
        
        let profileView = ProfileeViewController(collectionViewLayout: layout)
        
//        let profileViewNavController = UINavigationController(rootViewController: profileView)
//        profileViewNavController.navigationBar.isTranslucent = false
//        profileViewNavController.tabBarItem.image = UIImage(named: "icons8-User-50")
//        profileViewNavController.tabBarItem.selectedImage = UIImage(named: "icons8-User Filled-50")
        
//        profileViewNavController.tabBarItem.title = "Search"
        
        let searchController = EventSearchController(collectionViewLayout: UICollectionViewFlowLayout())
//        let searchNavController = UINavigationController(rootViewController: searchController)
//        searchNavController.navigationBar.isTranslucent = false

//        searchNavController.tabBarItem.image = UIImage(named: "icons8-Search-48")
        
//        searchNavController.tabBarItem.title = "Search"
       
        return [searchController, homeFeedController, profileView]
    }
    
    func titlesForPages() -> [String] {
        return ["Search", "Home", "Profile"]
    }
    
    func indexOfStartingPage() -> Int {
        return 1 // EZSwipeController starts from 2nd, green page
    }
    
}



