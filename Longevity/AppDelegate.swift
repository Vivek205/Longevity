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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
            print("Amplify configured with auth plugin")

        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }

       SentrySDK.start(options: [
                        "dsn": "https://fad7b602a82a42a6928403d810664c6f@o411850.ingest.sentry.io/5287662",
                        "enableAutoSessionTracking": true
        //                "debug": true // Enabled debug when first installing is always helpful
                    ])
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
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
        print("////////////////////////////////////////////////////////background fetch")
        let weatherURL = URL(string: "https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=439d4b804bc8187953eb36d2a8c26a02")

        let urlSession = URLSession.shared.dataTask(with: weatherURL!) { (data, response, error) in
            print("data", data)
            guard let data = data, error == nil else {
                return completionHandler(.failed)
            }
            do{
                if let jsonData: [String:Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                    let main = jsonData["main"] as? [String: Any]
                    let temp = main!["temp"]
                    print("temp", temp!)
                    UserDefaults.standard.set("\(temp!)", forKey: "temparature")
                }
            }catch {}
            completionHandler(.newData)
        }
        urlSession.resume()
    }
    
}
