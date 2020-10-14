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
                           titleText: "Digital Twin of your body", infoText: "Create your personalized health profile, and connect your favorite health tracking devices to detail insights."),
    OnboardingCarouselData(bgImageName: "onboardingBgYellow", carouselImageName: "onboardingThree",
    titleText: "Powerful and safe AI-insights", infoText: "We use AI that protects your data to generate your personalized health insights and recommendations.")
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
        return collectionView
    }()

    lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.pageIndicatorTintColor = .pageIndicatorTintColor
        control.currentPageIndicatorTintColor = .themeColor
        control.numberOfPages = carouselData.count
        control.transform = CGAffineTransform(scaleX: 2, y: 2)
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

    lazy var loginButtonLocal: CustomButtonOutlined = {
        let button = CustomButtonOutlined()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Got account? Login here.", for: .normal)
        button.layer.borderColor = UIColor.clear.cgColor
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 20)
        button.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
        return button
    }()

    let onboardingContent = OnboardingContent()

    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(carouselCollection)
        self.view.addSubview(pageControl)
        self.view.addSubview(getStartedButton)
        self.view.addSubview(loginButtonLocal)

        let loginButtonBottomMargin = UIDevice.hasNotch ? 83.0 : 30.0
        let pageControlBottomMargin = UIDevice.hasNotch ? 32.0 : 5.0

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
            loginButtonLocal.heightAnchor.constraint(equalToConstant: 30)
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
            self.showAlert(title: "Login Failed" , message: error.errorDescription)
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


// MARK: Alert
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handleUIAlertAction(_:) ))
        self.present(alert, animated: true)
    }

    @objc func handleUIAlertAction(_ action: UIAlertAction) {

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
