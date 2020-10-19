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
            ConnectionManager.instance.addConnectionObserver()
            print("arn value", AppSyncManager.instance.userNotification.value?.endpointArn)
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        
        SentrySDK.start(options: [
            "dsn": "https://fad7b602a82a42a6928403d810664c6f@o411850.ingest.sentry.io/5287662",
            "enableAutoSessionTracking": true
        ])
        
        UNUserNotificationCenter.current().delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        
        /// To remove support for dark mode
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }

        presentLoaderAnimationViewController()
        window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "io.rejuve.Longevity.bgFetch", using: nil) { (task) in
                self.appHandleRefreshTask(task: task as! BGAppRefreshTask)
            }
        } else {
            if UIApplication.shared.backgroundRefreshStatus == .available {
                UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
            } else {
                print("Background fetch is not available")
            }
        }
        
//        let fitbitModel = FitbitModel()
//        fitbitModel.refreshTheToken()
        
//        checkARNStatus()
        
        if HKHealthStore.isHealthDataAvailable() {
            HealthStore.shared.getHealthStore()
            HealthStore.shared.startObserving(device: .applehealth)
            HealthStore.shared.startObserving(device: .applewatch)
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
            self.window?.rootViewController = tabbarViewController
        } else {
            gotoLogin()
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        if HKHealthStore.isHealthDataAvailable() {
//            if !(AppSyncManager.instance.healthProfile.value?.devices?.isEmpty ?? true) {
//                HealthStore.shared.getHealthStore()
//                if AppSyncManager.instance.healthProfile.value?.devices?[ExternalDevices.healthkit]?["connected"] == 1 {
//                    HealthStore.shared.startObserving(device: .applehealth)
//                }
//                if AppSyncManager.instance.healthProfile.value?.devices?[ExternalDevices.watch]?["connected"] == 1 {
//                    HealthStore.shared.startObserving(device: .applewatch)
//                }
//            }
//        }
        
        if #available(iOS 13.0, *) {
            if AppSyncManager.instance.healthProfile.value?.devices?[ExternalDevices.fitbit]?["connected"] == 1 {
                self.scheduleBackgroundFetch()
            }
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //        Implement this method if your app supports the fetch background mode. When an opportunity arises to download data, the system calls this method to give your app a chance to download any data it needs. Your implementation of this method should download the data, prepare that data for use, and call the block in the completionHandler parameter.
        //        When this method is called, your app has up to 30 seconds of wall-clock time to perform the download operation and call the specified completion handler block
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
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
        checkARNStatus()
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
            if let notificationType = PushNotificationType(rawValue: type) {
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
                if let notificationType = PushNotificationType(rawValue: type) {
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
                if let notificationType = PushNotificationType(rawValue: type) {
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
        scheduleBackgroundFetch()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        let queue = OperationQueue()
        queue.addOperations(FitbitModel.getOperationsToRefreshFitbitToken(), waitUntilFinished: false)
        
        queue.operations.last?.completionBlock = {
            task.setTaskCompleted(success: !(queue.operations.last?.isCancelled ?? false))
        }
    }
    
    @available(iOS 13.0, *)
    func scheduleBackgroundFetch() {
        let rejuveFetchTask = BGAppRefreshTaskRequest(identifier: "io.rejuve.Longevity.bgFetch")
        rejuveFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(rejuveFetchTask)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func updateARNToken() {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        let notificationAPI = NotificationAPI()
        // Check if ARN is created already
        guard AppSyncManager.instance.userNotification.value?.endpointArn == nil else {
            return
        }
        
        guard let token = defaults.string(forKey: keys.deviceTokenForSNS) else {
            return
        }

        let deviceIdForVendor = notificationAPI.getDeviceIdForVendor()
        if deviceIdForVendor == nil {
            _ = notificationAPI.createDeviceIdForVendor()
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
//                    defaults.set(endpointArnForSNS, forKey: keys.snsARN)
                    AppSyncManager.instance.userNotification.value?.endpointArn = endpointArnForSNS

                    notificationAPI.registerARN(platform: .iphone, arnEndpoint: endpointArnForSNS)
                    
                }
            }
            return nil
        })
    }
    
    func checkARNStatus() {
        guard let endpointARN = AppSyncManager.instance.userNotification.value?.endpointArn else {
            self.createARNEndPoint()
            return
        }
        
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        guard let token = defaults.string(forKey: keys.deviceTokenForSNS) else {
            return
        }
        
        let awsSNS = AWSSNS.default()
        let request = AWSSNSGetEndpointAttributesInput()
        request?.endpointArn = endpointARN
        awsSNS.getEndpointAttributes(request!) { [weak self] (response, error) in
            if error != nil {
                self?.createARNEndPoint()
            } else {
                print("arn", endpointARN)
                if let response = response as? AWSSNSGetEndpointAttributesResponse {
                    let isEnabledSNS = response.attributes!["Enabled"]
                    print("isEnabledSNS", isEnabledSNS)
                    if isEnabledSNS != "true" {
                        self?.setSNSEndpointAttributes(endpointArn: endpointARN)
                    }
                }

//                let notificationAPI = NotificationAPI()
//                notificationAPI.registerARN(platform: .iphone, arnEndpoint: endpointARN)

//                if let endpointARN = AppSyncManager.instance.userNotification.value?.endpointArn {

//                }
            }
        }
    }

    func setSNSEndpointAttributes(endpointArn: String) {
        let awsSNS = AWSSNS.default()
        guard let request = AWSSNSSetEndpointAttributesInput() else {
            print("request unavailable")
            return
        }
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        guard let token = defaults.string(forKey: keys.deviceTokenForSNS) else {
            return
        }

        request.attributes = ["Enabled":"true", "Token":token]
        request.endpointArn = endpointArn
        awsSNS.setEndpointAttributes(request) { (error) in
            if error != nil {
                let notificationAPI = NotificationAPI()
                notificationAPI.registerARN(platform: .iphone, arnEndpoint: endpointArn)
            }
            print("setEndpointAttributes error", error)
        }
    }
    
    func createARNEndPoint() {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        
        guard let token = defaults.string(forKey: keys.deviceTokenForSNS) else {
            return
        }
        
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = token
        request?.platformApplicationArn = SNSPlatformApplicationARN
        let awsSNS = AWSSNS.default()
        awsSNS.createPlatformEndpoint(request!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                if let endpointArnForSNS = createEndpointResponse.endpointArn {
                    print("endpointArn: \(endpointArnForSNS)")
                    Logger.log("ARN endpoint created")
//                    defaults.set(endpointArnForSNS, forKey: keys.snsARN)
                    AppSyncManager.instance.userNotification.value?.endpointArn = endpointArnForSNS
                    let notificationAPI = NotificationAPI()
                    notificationAPI.registerARN(platform: .iphone, arnEndpoint: endpointArnForSNS)
                    
                }
            }
            return nil
        })
    }

    func deleteARNEndpoint(endpointArn: String ,completion: ((Error?) -> Void)?) {
        let awsSNS = AWSSNS.default()
        guard let request = AWSSNSDeleteEndpointInput() else {return}
        request.endpointArn = endpointArn
        awsSNS.deleteEndpoint(request, completionHandler: completion)
    }
}

enum PushNotificationType: String {
    case syncFitbit = "SYNC_FITBIT"
    case covidReportProcessed = "COVID_REPORT_PROCESSED"
}
