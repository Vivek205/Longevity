//
//  OnboardingVC.swift
//  Longevity
//
//  Created by vivek on 28/05/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class OnboardingVC: UIViewController, UIScrollViewDelegate {

    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageHeading: UILabel!
    @IBOutlet weak var pageDescription: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    let images:[UIImage] = [ #imageLiteral(resourceName: "onboardingOne") , #imageLiteral(resourceName: "onboardingTwo"), #imageLiteral(resourceName: "onboardingThree")]
    let pageHeadings:[String] = [
        """
            Discover
            Yourself in new
            ways with AI
        """,
        """
            Connect your
            Health data in
            one place
        """
        ,
        """
            Ready to
            explore
            yourself?
        """]
    let pageDescriptions:[String] = [
        """
        Let us help you to find
        useful aspects of your
        health that supports you
        and health research.
    """,
        """
        Our mission is to connect
        people with the places in
        which they spend their time.
    """
        ,
        """
        Our app offers
        comprehensive guides and
        analysis about you.
    """]
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setInitialContent()
        initScrollViewWithImages()
        styleButtons()
        hideNavigationBar()
        getCurrentUser()
    }

    override func viewDidAppear(_ animated: Bool) {
        hideNavigationBar()
    }

    func setInitialContent(){
        pageHeading.text = pageHeadings[0]
        pageDescription.text = pageDescriptions[0]
        pageControl.numberOfPages = images.count
    }

    func initScrollViewWithImages(){
        let screenRect = UIScreen.main.bounds
        let screenHeight = screenRect.size.height
        let screenWidth = screenRect.size.width

        for index in 0..<images.count {
            frame.origin.x = screenWidth * CGFloat(index)
            frame.size = scrollView.frame.size

            frame.size.height = screenHeight * CGFloat(11) / CGFloat(13)
            frame.size.width = screenWidth
            let imgView = UIImageView(frame: frame)
            imgView.image = images[index]
            imgView.contentMode = .scaleToFill
            imgView.clipsToBounds = true

            scrollView.insertSubview(imgView, at: 0)
        }

        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(images.count), height: scrollView.frame.size.height)
        scrollView.contentSize.height = 1.0
        scrollView.delegate =  self
    }

    func styleButtons(){
        signupButton.layer.cornerRadius = CGFloat(10)
        signupButton.layer.masksToBounds = true

        loginButton.layer.borderColor = #colorLiteral(red: 0, green: 0.7176470588, blue: 0.5019607843, alpha: 1)
        loginButton.layer.cornerRadius = CGFloat(10)
        loginButton.layer.borderWidth = 2
        loginButton.layer.masksToBounds = true
    }

    func hideNavigationBar(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func getCurrentUser(){
        var userSignedIn = false
        let group = DispatchGroup()
        group.enter()

        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                userSignedIn = session.isSignedIn
                group.leave()
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
        group.wait()
        if userSignedIn{
            self.performSegue(withIdentifier: "OnboardingToTOS", sender: self)
        }
    }

    // MARK: ScrolView delegate method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = Int( scrollView.contentOffset.x / scrollView.frame.size.width)
        print("page number", pageNumber)
        pageControl.currentPage = pageNumber
        pageHeading.text = pageHeadings[pageNumber]
        pageDescription.text = pageDescriptions[pageNumber]
    }


}
