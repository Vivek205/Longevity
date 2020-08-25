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
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        logoutUserIfAppIsUpdated()
        SentrySDK.start(options: [
            "dsn": "https://fad7b602a82a42a6928403d810664c6f@o411850.ingest.sentry.io/5287662",
            "enableAutoSessionTracking": true
            //                "debug": true // Enabled debug when first installing is always helpful
        ])
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func logoutUserIfAppIsUpdated() {
        let previousBuild = UserDefaults.standard.string(forKey: "build")
        let currentBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        if previousBuild == nil {
            //fresh install
            _ = Amplify.Auth.signOut() { (result) in
                switch result {
                case .success:
                    print("Successfully signed out")
                case .failure(let error):
                    print("Sign out failed with error \(error)")
                }
            }
        } else if previousBuild != currentBuild {
            //application updated
        }
        UserDefaults.standard.set(currentBuild, forKey: "build")
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
        Logger.log("device token created")
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

        guard let apsData = userInfo["aps"] as? [String: AnyObject] else {
            Logger.log("did receive wrong background notification")
            completionHandler(.failed)
            return
        }
        Logger.log("did receive background notification")
        let fitbitModel = FitbitModel()
        fitbitModel.refreshTheToken()
        completionHandler(.newData)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        Logger.log("received foreground notification")
        let fitbitModel = FitbitModel()
        fitbitModel.refreshTheToken()
        completionHandler(.sound)
    }
}
