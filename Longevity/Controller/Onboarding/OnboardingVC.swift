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

struct OnboardingCarouselData {
    var bgImageName:String
    var carouselImageName:String
    var titleText:String
    var infoText:String
}

fileprivate var carouselData = [
    OnboardingCarouselData(bgImageName: "onboardingBgYellow", carouselImageName: "onboardingOne",
                           titleText: "COVID-19 Risk Management", infoText: "Track COVID-19 symptoms and infection risks.  Gain personalized insights report with health goals."),
    OnboardingCarouselData(bgImageName: "onboardingBgGreen", carouselImageName: "onboardingTwo",
                           titleText: "Digital Body Twin", infoText: "Create your personalized health profile, and connect your favorite health tracking devices to detail insights."),
    OnboardingCarouselData(bgImageName: "onboardingBgYellow", carouselImageName: "onboardingThree",
    titleText: "Powerful & Secure AI-insights", infoText: "We use AI that protects your data to generate your personalized health insights and reports.")
]

class OnboardingVC: UIViewController {
    lazy var carouselCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        return collectionView
    }()

    lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.pageIndicatorTintColor = .pageIndicatorTintColor
        control.currentPageIndicatorTintColor = .themeColor
        control.numberOfPages = carouselData.count
        control.transform = CGAffineTransform(scaleX: 1, y: 1)
        control.currentPage = 0
        return control
    }()

    lazy var getStartedButton: CustomButtonFill = {
        let button = CustomButtonFill()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get Started", for: .normal)
        button.addTarget(self, action: #selector(handleGetStarted(_:)), for: .touchUpInside)
        return button
    }()

    lazy var loginButtonLocal: UIButton = {
        let button = UIButton()
        button.setTitleColor(.themeColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Got account? Login here.", for: .normal)
        button.layer.borderColor = UIColor.clear.cgColor
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 20)
        button.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var backgroundImage1: UIImageView = {
        let bgImageView1 = UIImageView()
        bgImageView1.contentMode = .scaleAspectFill
        bgImageView1.translatesAutoresizingMaskIntoConstraints = false
        return bgImageView1
    }()
    
    lazy var backgroundImage2: UIImageView = {
        let bgImageView2 = UIImageView()
        bgImageView2.contentMode = .scaleAspectFill
        bgImageView2.translatesAutoresizingMaskIntoConstraints = false
        return bgImageView2
    }()

    let onboardingContent = OnboardingContent()

    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var currentPhotoIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .appBackgroundColor
        
        self.view.addSubview(backgroundImage1)
        self.view.addSubview(backgroundImage2)
        self.view.addSubview(carouselCollection)
        self.view.addSubview(pageControl)
        self.view.addSubview(getStartedButton)
        self.view.addSubview(loginButtonLocal)

        let loginButtonBottomMargin = UIDevice.hasNotch ? 83.0 : 30.0
        let pageControlBottomMargin = UIDevice.hasNotch ? 32.0 : 10.0

        NSLayoutConstraint.activate([
            carouselCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carouselCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carouselCollection.topAnchor.constraint(equalTo: view.topAnchor),
            carouselCollection.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -5),

            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: getStartedButton.topAnchor,
                                                constant: -CGFloat(pageControlBottomMargin)),
            pageControl.heightAnchor.constraint(equalToConstant: 20),

            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            getStartedButton.bottomAnchor.constraint(equalTo: loginButtonLocal.topAnchor,constant: -20),
            getStartedButton.heightAnchor.constraint(equalToConstant: 48),

            loginButtonLocal.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginButtonLocal.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginButtonLocal.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                     constant: -CGFloat(loginButtonBottomMargin)),
            loginButtonLocal.heightAnchor.constraint(equalToConstant: 30),
            
            self.backgroundImage2.leadingAnchor.constraint(equalTo: self.carouselCollection.leadingAnchor),
            self.backgroundImage2.trailingAnchor.constraint(equalTo: self.carouselCollection.trailingAnchor),
            self.backgroundImage2.topAnchor.constraint(equalTo: self.carouselCollection.topAnchor),
            self.backgroundImage2.bottomAnchor.constraint(equalTo: self.carouselCollection.bottomAnchor),
            self.backgroundImage1.leadingAnchor.constraint(equalTo: self.carouselCollection.leadingAnchor),
            self.backgroundImage1.trailingAnchor.constraint(equalTo: self.carouselCollection.trailingAnchor),
            self.backgroundImage1.topAnchor.constraint(equalTo: self.carouselCollection.topAnchor),
            self.backgroundImage1.bottomAnchor.constraint(equalTo: self.carouselCollection.bottomAnchor)
        ])

        //        self.carouselCollection.contentInset.top = -UIApplication.shared.statusBarFrame.height

        guard let layout = carouselCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal

        styleNavigationBar()
        hideNavigationBar()
        self.removeBackButtonNavigation()
        getCurrentUser()

        if let token = UserDefaults.standard.value(forKey: "deviceTokenForSNS") {
            print("device token ====   \(token)")
        }
        
        self.initView(offsetX: 0.0)
    }
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNavigationBar()

    }

    override func viewWillDisappear(_ animated: Bool) {
        showNavigationBar()
    }

    @objc func handleGetStarted(_ sender: UIButton?) {
        let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
        let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupVC")
        self.navigationController?.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(signupVC, animated: true)
    }

    @objc func handleLogin(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "PersonalLoginVC")
        self.navigationController?.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(loginVC, animated: true)
    }

    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func getCurrentUser() {
        func onSuccess(userSignedIn: Bool, idToken: String) {
            if userSignedIn {
                DispatchQueue.main.async {
                    //                    self.navigateToTheNextScreen()
//                    retrieveARN()
                }
            }
        }

        func onFailure(error: AuthError) {
            print(error)
            Alert(title: "Login Failed" , message: error.errorDescription)
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
    
    fileprivate func initView(offsetX: CGFloat) {
        let scrollImageNum = max(0, min(self.pageControl.numberOfPages - 1, Int(offsetX / self.view.bounds.width)))
        
        if scrollImageNum != currentPhotoIndex {
            self.currentPhotoIndex = scrollImageNum
            if let bgImageName1 = self.currentPhotoIndex != 0 ? carouselData[self.currentPhotoIndex - 1].bgImageName : nil {
                self.backgroundImage1.image = UIImage(named: bgImageName1)
            } else {
                self.backgroundImage1.image = nil
            }
            self.backgroundImage1.image = UIImage(named: carouselData[self.currentPhotoIndex].bgImageName)

            if let bgImageName2 = self.currentPhotoIndex != (self.pageControl.numberOfPages - 1) ? carouselData[self.currentPhotoIndex + 1].bgImageName : nil {
                self.backgroundImage2.image = UIImage(named: bgImageName2)
            } else {
                self.backgroundImage2.image = nil
            }
        }

        var offset = offsetX - (CGFloat(self.currentPhotoIndex) * self.view.bounds.width)

        if offset < 0 {
            offset = self.view.bounds.width - min(-offset, self.view.bounds.width)
            backgroundImage2.alpha = 0
            backgroundImage1.alpha = (offset / self.view.bounds.width)
        } else if offset != 0 {
            if self.currentPhotoIndex == self.pageControl.numberOfPages - 1 {
                backgroundImage1.alpha = 1.0 - (offset / self.view.bounds.width)
            } else {
                backgroundImage2.alpha = offset / self.view.bounds.width
                backgroundImage1.alpha = 1 - backgroundImage2.alpha
            }
        } else {
            backgroundImage1.alpha = 1
            backgroundImage2.alpha = 0
        }
    }

}

// MARK: Spinner
fileprivate var spinnerView: UIView?
extension UIViewController{
    func showSpinner() {
        spinnerView = UIView(frame: UIScreen.main.bounds)
        spinnerView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.center = spinnerView?.center as! CGPoint
        spinner.startAnimating()
        spinnerView?.addSubview(spinner)
        let window = UIApplication.shared.keyWindow!
        window.addSubview(spinnerView!)
        window.bringSubviewToFront(spinnerView!)
    }

    func removeSpinner() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
}

enum UIAlertType {
    case offlineNotification
}

extension UIAlertType {
    var title: String {
        switch self {
        case .offlineNotification:
            return "No Internet Connection.."
        }
    }
    var message: String {
        switch self {
        case .offlineNotification:
            return "Please reconnect your Internet to continue this app action."
        }
    }
    var color: UIColor {
        switch self {
        case .offlineNotification:
            return UIColor(red: (242/255.0), green: (242/255.0), blue: (242/255.0), alpha: 0.8)
        }
    }
}

extension OnboardingVC:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: CarouselCollectionCell.self, at: indexPath) as? CarouselCollectionCell else {
            preconditionFailure("invalid cell")
        }
        let data = carouselData[indexPath.item]
        cell.carouselDetails = data
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.item
    }
}

extension OnboardingVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.initView(offsetX: scrollView.contentOffset.x)
    }
}
