//
//  AppDelegate.swift
//  Longevity
//
//  Created by vivek on 28/05/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import AmplifyPlugins
import ResearchKit
import Sentry
import UserNotifications
import BackgroundTasks
import AWSSNS

let SNSPlatformApplicationARN = "arn:aws:sns:us-west-2:533793137436:app/APNS_SANDBOX/RejuveDevelopment"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window : UIWindow?
    
    override init() {
        super.init()
        UIFont.overrideInitialize()
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
            configureCognito()
            print("Amplify configured with auth plugin")
            Logger.log("App Launched")

            print("arn value", UserDefaults.standard.value(forKey: UserDefaultsKeys().endpointArnForSNS))
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        
        SentrySDK.start(options: [
            "dsn": "https://fad7b602a82a42a6928403d810664c6f@o411850.ingest.sentry.io/5287662",
            "enableAutoSessionTracking": true
            //                "debug": true // Enabled debug when first installing is always helpful
        ])
        
        if HKHealthStore.isHealthDataAvailable() {
            AppSyncManager.instance.healthProfile.addAndNotify(observer: self, completionHandler: {
                if let devices = AppSyncManager.instance.healthProfile.value?.devices {
                    HealthStore.shared.getHealthStore()
                    HealthStore.shared.startQueryingHealthData()
                }
            })
        }
        
        
        UNUserNotificationCenter.current().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        /// To remove support for dark mode
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }

        presentLoaderAnimationViewController()
        window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "", using: nil) { (task) in
                
            }
        } else {
            if UIApplication.shared.backgroundRefreshStatus == .available {
                UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
            } else {
                print("Background fetch is not available")
            }
        }
        
        return true
    }

    func presentLoaderAnimationViewController() {
        let loaderVC = LoaderAnimationViewController()
        loaderVC.modalPresentationStyle = .fullScreen
        self.window?.rootViewController = loaderVC
    }
    
    func setRootViewController() {
        if UserAuthAPI.shared.checkUserSignedIn() {
            let tabbarViewController = LNTabBarViewController()
            tabbarViewController.modalPresentationStyle = .fullScreen
            self.window?.rootViewController = tabbarViewController
        } else {
            gotoLogin()
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if let devices = AppSyncManager.instance.healthProfile.value?.devices {
            HealthStore.shared.getHealthStore()
            HealthStore.shared.startObservingHealthData()
        }
        
        if #available(iOS 13.0, *) {
            (UIApplication.shared.delegate as! AppDelegate).scheduleBackgroundFetch()
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //        Implement this method if your app supports the fetch background mode. When an opportunity arises to download data, the system calls this method to give your app a chance to download any data it needs. Your implementation of this method should download the data, prepare that data for use, and call the block in the completionHandler parameter.
        //        When this method is called, your app has up to 30 seconds of wall-clock time to perform the download operation and call the specified completion handler block
    }

    func configureCognito() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest2,
                                                                identityPoolId:"us-west-2:71e6c80c-3543-4a1c-b149-1dbfa77f0d40")

        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        var token = ""
        for index in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [deviceToken[index]])
        }
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        defaults.set(token, forKey: keys.deviceTokenForSNS)
        Logger.log("device token created \(token)")
        // Check if ARN is created already
        guard defaults.object(forKey: keys.endpointArnForSNS) == nil else {
            return
        }

        let awsSNS = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = token
        request?.platformApplicationArn = SNSPlatformApplicationARN



        awsSNS.createPlatformEndpoint(request!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                if let endpointArnForSNS = createEndpointResponse.endpointArn {
                    print("endpointArn: \(endpointArnForSNS)")
                    Logger.log("ARN endpoint created")
                    defaults.set(endpointArnForSNS, forKey: keys.endpointArnForSNS)
                    registerARN(platform: "IOS", arnEndpoint: endpointArnForSNS)
                    AppSyncManager.instance.updateUserNotification(enabled: true)
                }
            }
            return nil
        })
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.log("failed to register notification \(error.localizedDescription)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("user info", userInfo)
        guard let apsData = userInfo["aps"] as? [String: AnyObject] else {
            
            Logger.log("did receive wrong background notification")
            completionHandler(.failed)
            return
        }
        Logger.log("did receive background notification \(apsData)")
        if let type = apsData["type"] as? String {
            if let notificationType = NotificationType(rawValue: type) {
                switch notificationType {
                case .syncFitbit:
                    let fitbitModel = FitbitModel()
                    fitbitModel.refreshTheToken()
                    completionHandler(.newData)
                    return
                case .covidReportProcessed:
                    // TODO: redirect to mydata page
                    if let tabBarController = self.window!.rootViewController as? LNTabBarViewController {
                        tabBarController.selectedIndex = 1
                    }
                    completionHandler(.newData)
                    return
                default:
                    completionHandler(.noData)
                    return
                }
            }

        }
        if let alert = apsData["alert"] as? [String: Any] {

            if let alertBody = alert["body"] as? String {
                if alertBody == "Synchronize fitbit data." {
                    let fitbitModel = FitbitModel()
                    fitbitModel.refreshTheToken()
                    completionHandler(.newData)
                    return
                }
            }
        }
        completionHandler(.noData)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        Logger.log("received foreground notification - will present")
        if let apsData = notification.request.content.userInfo["aps"] as? [String: Any]  {
            if let type =  apsData["type"] as? String {
                if let notificationType = NotificationType(rawValue: type) {
                    completionHandler(.alert)
//                    switch notificationType {
//                    case .syncFitbit:
//                        let fitbitModel = FitbitModel()
//                        fitbitModel.refreshTheToken()
//                        completionHandler(.alert)
//                        return
//                    case .covidReportProcessed:
//                          let checkInResultViewController = CheckInResultViewController()
//                                              NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController, style: .overCurrentContext)
//                        completionHandler(.alert)
//                        return
//                    default:
//                        return
//                    }
                }

            }
            if let alert = apsData["alert"] as? [String: Any] {
                if let alertBody = alert["body"] as? String {
                    if alertBody == "Synchronize fitbit data." {
                        let fitbitModel = FitbitModel()
                        fitbitModel.refreshTheToken()
                        completionHandler(.alert)
                        return
                    }
                }
            }
        }

        let fitbitModel = FitbitModel()
        fitbitModel.refreshTheToken()
        completionHandler(.alert)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.log("received foreground notification - did receive")
        if let apsData = response.notification.request.content.userInfo["aps"] as? [String: Any] {
            if let type = apsData["type"] as? String {
                if let notificationType = NotificationType(rawValue: type) {
                    switch notificationType {
                    case .syncFitbit:
                        let fitbitModel = FitbitModel()
                        fitbitModel.refreshTheToken()
                        completionHandler()
                        return
                    case .covidReportProcessed:
                        let checkInResultViewController = CheckInResultViewController()
                        NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController, style: .overCurrentContext)
                        completionHandler()
                        return
                    default:
                        completionHandler()
                        return
                    }
                }

            }
        }
        let fitbitModel = FitbitModel()
        fitbitModel.refreshTheToken()
        completionHandler()
    }
    
    fileprivate func gotoLogin() {
        let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
        let onBoardingViewController = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = onBoardingViewController
    }
    
    fileprivate func checkIfAppUpdated() {

        let previousBuild = UserDefaults.standard.string(forKey: "build")
        let currentBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        UserDefaults.standard.set(currentBuild, forKey: "build")
        if previousBuild == nil {
            //fresh install
            _ = Amplify.Auth.signOut() { [weak self] (result) in
                switch result {
                case .success:
                    print("Successfully signed out")
                    DispatchQueue.main.async {
                        self?.gotoLogin()
                    }
                case .failure(let error):
                    print("Sign out failed with error \(error)")
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    func appHandleRefreshTask(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        scheduleBackgroundFetch()
    }
    
    @available(iOS 13.0, *)
    func scheduleBackgroundFetch() {
        let rejuveFetchTask = BGAppRefreshTaskRequest(identifier: "")
        rejuveFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(rejuveFetchTask)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

enum NotificationType: String {
    case syncFitbit = "SYNC_FITBIT"
    case covidReportProcessed = "COVID_REPORT_PROCESSED"
}
