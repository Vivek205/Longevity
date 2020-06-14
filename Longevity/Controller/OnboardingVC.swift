//
//  OnboardingVC.swift
//  Longevity
//
//  Created by vivek on 28/05/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import SwiftGRPC

class OnboardingVC: UIViewController, UIScrollViewDelegate {

    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageHeading: UILabel!
    @IBOutlet weak var pageDescription: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    let onboardingContent = OnboardingContent()

    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
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
        pageHeading.text = onboardingContent.pageHeadings[0]
        pageDescription.text = onboardingContent.pageDescriptions[0]
        pageControl.numberOfPages = onboardingContent.imageCount
    }

    func initScrollViewWithImages(){
        let screenRect = UIScreen.main.bounds
        let screenHeight = screenRect.size.height
        let screenWidth = screenRect.size.width

        for index in 0..<onboardingContent.imageCount {
            frame.origin.x = screenWidth * CGFloat(index)
            frame.size = scrollView.frame.size
            frame.size.height = screenHeight * CGFloat(11) / CGFloat(13)
            frame.size.width = screenWidth
            let imgView = UIImageView(frame: frame)
            imgView.image = onboardingContent.images[index]
            imgView.contentMode = .scaleToFill
            imgView.clipsToBounds = true
            scrollView.insertSubview(imgView, at: 0)
        }

        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(onboardingContent.imageCount), height: scrollView.frame.size.height)
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
                group.leave()
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
        pageControl.currentPage = pageNumber
        pageHeading.text = onboardingContent.pageHeadings[pageNumber]
        pageDescription.text = onboardingContent.pageDescriptions[pageNumber]
    }

    // MARK: Actions
    @IBAction func unwindToOnboarding(_ sender: UIStoryboardSegue){
        print("un wound")
    }

    @IBAction func handleGRPC(_ sender: Any) {

        self.add()

    }

    func add(){
        let address = "example-service-a.singularitynet.io:8092"
        print("version", gRPC.version)
        let channel = Channel(address: address, secure: false)
        let service = Escrow_ExampleServiceServiceClient(channel: channel)

        let messageData = "hello, I'm Vivek!".data(using: .utf8)

        let method = "/escrow.ExampleService/Ping"

        let metadata = Metadata()

        do {
            let call = try channel.makeCall(method)
            try call.start(.unary, metadata: metadata, message: messageData) { (callResult) in
                print("result   ",callResult.statusCode, callResult.statusMessage, callResult.resultData)
            }
        } catch  {
            print("make call error", error)
        }

    }

}
