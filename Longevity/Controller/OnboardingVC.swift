//
//  OnboardingVC.swift
//  Longevity
//
//  Created by vivek on 28/05/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

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
    }

    func setInitialContent(){
        pageHeading.text = pageHeadings[0]
        pageDescription.text = pageDescriptions[0]
        pageControl.numberOfPages = images.count
    }

    func initScrollViewWithImages(){
        for index in 0..<images.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            let imgView = UIImageView(frame: frame)
            imgView.image = images[index]
            // MARK: Adding gradient to the selected Image
//            let gradientLayer = CAGradientLayer.init()
//            gradientLayer.frame = imgView.bounds
//            gradientLayer.colors = [UIColor.init(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
//                                    UIColor.init(red: 0, green: 0, blue: 0, alpha: 1).cgColor]
//            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
//            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
//            imgView.layer.mask = gradientLayer
            scrollView.addSubview(imgView)
        }

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width *
            CGFloat(images.count), height: scrollView.frame.size.height)
        scrollView.contentSize.height = 1.0
        scrollView.delegate =  self
    }

    func styleButtons(){
        signupButton.layer.cornerRadius = CGFloat(4)
        signupButton.layer.masksToBounds = true

        loginButton.layer.borderColor = UIColor.blue.cgColor
        loginButton.layer.cornerRadius = CGFloat(4)
        loginButton.layer.borderWidth = 2
        loginButton.layer.masksToBounds = true
    }

    // MARK: ScrolView delegate method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = Int( scrollView.contentOffset.x / scrollView.frame.size.width)
        print("page number", pageNumber)
        pageControl.currentPage = pageNumber
        pageHeading.text = pageHeadings[pageNumber]
        pageDescription.text = pageDescriptions[pageNumber]
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if(!scrollView.subviews.isEmpty){
            return scrollView.subviews[0]
        }
        return nil
    }
}
