//
//  OnboardingVC.swift
//  Longevity
//
//  Created by vivek on 28/05/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import GRPC
import NIO


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
            imgView.contentMode = .scaleAspectFit
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

        loginButton.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        loginButton.layer.cornerRadius = CGFloat(10)
        loginButton.layer.borderWidth = 2
        loginButton.layer.masksToBounds = true
    }

    func hideNavigationBar(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func getCurrentUser() {
        func onSuccess(userSignedIn: Bool) {
            print("usersigned in", userSignedIn)
            if userSignedIn {
                DispatchQueue.main.async {
                    print("is main thread",Thread.isMainThread)
                    self.performSegue(withIdentifier: "OnboardingToTOS", sender: self)
                }
            }
        }

        func onFailure(error: AuthError) {
            print("Fetch session failed with error \(error)")
            print(error)
        }

        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
                onSuccess(userSignedIn: session.isSignedIn)
            case .failure(let error):
                onFailure(error: error)
            }
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
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let channel = ClientConnection.insecure(group: group).connect(host: "example-service-a.singularitynet.io", port: 8092)

        let service = Escrow_ExampleServiceClient(channel: channel)

        var input = Escrow_Input()
        input.message = "Hello Vivek here"

        let request = service.ping(input)

        do {
            let response = try request.response.wait()
            print("response" , response)
        } catch  {
            print("error", error)
        }

    }

}

// MARK: Spinner
fileprivate var spinnerView: UIView?
extension UIViewController{
    func showSpinner() {
        spinnerView = UIView(frame: self.view.bounds)
        spinnerView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.center = spinnerView?.center as! CGPoint
        spinner.startAnimating()
        spinnerView?.addSubview(spinner)
        self.view.addSubview(spinnerView!)
    }

    func removeSpinner() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
}

