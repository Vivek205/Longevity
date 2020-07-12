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
        styleNavigationBar()
        hideNavigationBar()
        self.removeBackButtonNavigation()
        getCurrentUser()
      
    }

    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        hideNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        showNavigationBar()
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

    func styleNavigationBar(){
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
        navigationBar?.tintColor = #colorLiteral(red: 0.4175422788, green: 0.7088702321, blue: 0.7134250998, alpha: 1)
    }

    func hideNavigationBar(){
        navigationController?.setNavigationBarHidden(true, animated: true)
//        navigationItem.hid
    }

    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func getCurrentUser() {
        print("started getCurrent user")
        func onSuccess(userSignedIn: Bool, idToken: String) {
            if userSignedIn {
                getProfile()
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "OnboardingToProfileSetup", sender: self)
//                    let viewController = TermsOfServiceVC.init()
//                    self.navigationController?.pushViewController(viewController, animated: true)

//                                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                                        var nextViewController: UIViewController = UIViewController()
//                                        let defaults = UserDefaults.standard
//                                        let keys = UserDefaultsKeys()
//
//                                        let isTermsAccepted = defaults.bool(forKey: keys.isTermsAccepted)
//                                        print("isTermsAccepted", isTermsAccepted)
//
//                                        if isTermsAccepted == true {
//                                            nextViewController = storyBoard.instantiateInitialViewController() as! SetupProfileDisclaimerVC
//                                            self.present(nextViewController, animated: true, completion: nil)
//                                        }

                    
                }
            }
        }

        func onFailure(error: AuthError) {
            print(error)
            showAlert(title: "Login Failed" , message: error.errorDescription)
        }

        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
//                print(session)
                onSuccess(userSignedIn: session.isSignedIn, idToken: "")
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


// MARK: Alert
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
