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

#if DEBUG
let SNSPlatformApplicationARN = "arn:aws:sns:us-west-2:533793137436:app/APNS_SANDBOX/RejuveDevelopment"
#else
let SNSPlatformApplicationARN = "arn:aws:sns:us-west-2:533793137436:app/APNS/RejuveProduction"
#endif

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
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            if let path = Bundle.main.path(forResource: Strings.configFile, ofType: "json"),
               let fileURL = URL(fileURLWithPath: path) as? URL {
                try Amplify.configure(AmplifyConfiguration(configurationFile: fileURL))
            } else {
                try Amplify.configure()
            }
            configureCognito()
            print("Amplify configured with auth plugin")
            ConnectionManager.instance.addConnectionObserver()
            print("arn value", AppSyncManager.instance.userNotification.value?.endpointArn)
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        
        //        SentrySDK.start(options: [
        //            "dsn": "https://fad7b602a82a42a6928403d810664c6f@o411850.ingest.sentry.io/5287662",
        //            "enableAutoSessionTracking": true
        //        ])
        
        UNUserNotificationCenter.current().delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // To remove support for dark mode
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
        
        presentLoaderAnimationViewController()
        
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "io.rejuve.Longevity.bgFetch",
                                            using: nil) { [weak self] (task) in
                guard let task = task as? BGProcessingTask else { return }
                self?.appHandleRefreshTask(task: task)
            }
        } else {
            if UIApplication.shared.backgroundRefreshStatus == .available {
                UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
            } else {
                print("Background fetch is not available")
            }
        }
        
        if HKHealthStore.isHealthDataAvailable() {
            _ = HealthStore.shared.getHealthStore()
            HealthStore.shared.startObserving(device: .applehealth)
            HealthStore.shared.startObserving(device: .applewatch)
        }
        
        return true
    }
    
    func presentLoaderAnimationViewController() {
        let loaderVC = LoaderAnimationViewController()
        loaderVC.modalPresentationStyle = .fullScreen
        self.window?.rootViewController = loaderVC
        self.window?.makeKeyAndVisible()
    }
    
    func setRootViewController() {
        UserAuthAPI.shared.checkUserSignedIn(completion: { [weak self] (signedIn) in
            if signedIn {
                UserAuthAPI.shared.getUserAttributes { [weak self] (tocStatus) in
                    DispatchQueue.main.async {
                        if tocStatus == .accepted {
                            let tabbarViewController = LNTabBarViewController()
                            self?.window?.rootViewController = tabbarViewController
                            self?.window?.makeKeyAndVisible()
                        } else if tocStatus == .notaccepted || tocStatus == .unknown {
                            let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
                            guard let tosViewController = storyboard.instantiateViewController(withIdentifier: "TermsOfServiceVC") as? TermsOfServiceVC else { return }
                            let navigationController = UINavigationController(rootViewController: tosViewController)
                            self?.window?.rootViewController = navigationController
                            self?.window?.makeKeyAndVisible()
                        } else {
                            
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.gotoLogin()
                }
            }
        })
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            if AppSyncManager.instance.healthProfile.value?.devices?[ExternalDevices.fitbit]?["connected"] == 1 {
                self.scheduleBackgroundFetch()
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if AppSyncManager.instance.pollingTimer != nil {
            AppSyncManager.instance.pollingTimer?.cancel()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.getPendingTaskRequests { (pendingTasks) in
                pendingTasks.forEach { BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: $0.identifier) }
            }
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //        Implement this method if your app supports the fetch background mode. When an opportunity arises to download data, the system calls this method to give your app a chance to download any data it needs. Your implementation of this method should download the data, prepare that data for use, and call the block in the completionHandler parameter.
        //        When this method is called, your app has up to 30 seconds of wall-clock time to perform the download operation and call the specified completion handler block
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperations(FitbitModel.getOperationsToRefreshFitbitToken(), waitUntilFinished: false)
        
        queue.operations.last?.completionBlock = {
            if !(queue.operations.last?.isCancelled ?? false) {
                completionHandler(.newData)
            } else {
                completionHandler(.failed)
            }
        }
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if identifier == FitbitFetchBackground.identifier {
            FitbitFetchBackground.shared.savedCompletionHandler = completionHandler
        } else if identifier == FitbitPublishBackground.identifier {
            FitbitPublishBackground.shared.publishedCompletionHandler = completionHandler
        }
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
                    //                    if let tabBarController = self.window!.rootViewController as? LNTabBarViewController {
                    //                        tabBarController.selectedIndex = 1
                    //                    }
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
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter,
    //                                willPresent notification: UNNotification,
    //                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
    //        Logger.log("received foreground notification - will present")
    //        if let apsData = notification.request.content.userInfo["aps"] as? [String: Any]  {
    //            if let type =  apsData["type"] as? String {
    //                if let notificationType = PushNotificationType(rawValue: type) {
    //                    completionHandler(.alert)
    //                }
    //            }
    //            if let alert = apsData["alert"] as? [String: Any] {
    //                if let alertBody = alert["body"] as? String {
    //                    if alertBody == "Synchronize fitbit data." {
    //                        let fitbitModel = FitbitModel()
    //                        fitbitModel.refreshTheToken()
    //                        completionHandler(.alert)
    //                        return
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
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
                        guard let data = apsData["notification_data"] as? [String: Any],
                              let submissionID = data["submission_id"] as? String else {
                            completionHandler()
                            return
                        }
                        SurveyTaskUtility.shared.openResultView = false
                        SurveyTaskUtility.shared.doOpenResult(submissionID: submissionID)
                        completionHandler()
                        return
                    default:
                        completionHandler()
                        return
                    }
                }
                
            }
        }
    }
    
    fileprivate func gotoLogin() {
        let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
        let onBoardingViewController = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = onBoardingViewController
        self.window?.makeKeyAndVisible()
    }
    
    @available(iOS 13.0, *)
    func appHandleRefreshTask(task: BGProcessingTask) {
        scheduleBackgroundFetch()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let operations = FitbitModel.getOperationsToRefreshFitbitToken()
        
        task.expirationHandler = {
            operations.forEach { $0.cancel() }
            task.setTaskCompleted(success: false)
        }
        
        operations.last?.completionBlock = {
            task.setTaskCompleted(success: !(operations.last?.isCancelled ?? false))
        }
        queue.addOperations(operations, waitUntilFinished: true)
    }
    
    @available(iOS 13.0, *)
    func scheduleBackgroundFetch() {
        let rejuveFetchTask = BGProcessingTaskRequest(identifier: "io.rejuve.Longevity.bgFetch")
        rejuveFetchTask.requiresNetworkConnectivity = true
        rejuveFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: 3 * 60 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(rejuveFetchTask)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func checkARNStatus() {
        guard let endpointARN = AppSyncManager.instance.userNotification.value?.endpointArn else {
            self.createARNEndPoint()
            return
        }
        
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        guard let _ = defaults.string(forKey: keys.deviceTokenForSNS) else {
            return
        }
        
        guard let request = AWSSNSGetEndpointAttributesInput() else { return }
        request.endpointArn = endpointARN
        AWSSNS.default().getEndpointAttributes(request) { [weak self] (response, error) in
            if error != nil {
                self?.createARNEndPoint()
            } else {
                print("arn", endpointARN)
                guard let response = response,
                      let attributes = response.attributes,
                      let isEnabledSNS = attributes["Enabled"],
                      isEnabledSNS != "true" else {
                    return
                }
                
                self?.setSNSEndpointAttributes(endpointArn: endpointARN)
            }
        }
    }
    
    func setSNSEndpointAttributes(endpointArn: String) {
        guard let request = AWSSNSSetEndpointAttributesInput() else {
            return
        }
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        guard let token = defaults.string(forKey: keys.deviceTokenForSNS) else {
            return
        }
        
        request.attributes = ["Enabled":"true", "Token":token]
        request.endpointArn = endpointArn
        AWSSNS.default().setEndpointAttributes(request) { (error) in
            if error != nil {
                NotificationAPI.instance.registerARN(platform: .iphone, arnEndpoint: endpointArn)
            }
        }
    }
    
    func createARNEndPoint() {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        
        guard let token = defaults.string(forKey: keys.deviceTokenForSNS) else {
            return
        }
        
        guard let request = AWSSNSCreatePlatformEndpointInput() else { return }
        request.token = token
        request.platformApplicationArn = SNSPlatformApplicationARN
        
        AWSSNS.default().createPlatformEndpoint(request).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                guard let createEndpointResponse = task.result,
                      let endpointArnForSNS = createEndpointResponse.endpointArn else {
                    return nil
                }
                print("endpointArn: \(endpointArnForSNS)")
                
                AppSyncManager.instance.userNotification.value?.endpointArn = endpointArnForSNS
                NotificationAPI.instance.registerARN(platform: .iphone, arnEndpoint: endpointArnForSNS)
            }
            return nil
        })
    }
    
    func deleteARNEndpoint(endpointArn: String ,completion: ((Error?) -> Void)?) {
        guard let request = AWSSNSDeleteEndpointInput() else { return }
        request.endpointArn = endpointArn
        AWSSNS.default().deleteEndpoint(request, completionHandler: completion)
    }
}

enum PushNotificationType: String {
    case syncFitbit = "SYNC_FITBIT"
    case covidReportProcessed = "COVID_REPORT_PROCESSED"
}
