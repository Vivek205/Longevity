//
//  ConnectionManager.swift
//  Longevity
//
//  Created by vivek on 15/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Reachability
import Network

final class ConnectionManager: NSObject {
    static let instance = ConnectionManager()
    private var reachability : Reachability!
    private let offlineNotificationView: OfflineNotificationView = OfflineNotificationView()
    private var timer: Timer?

    func startTimer() {
//        guard timer == nil else {return}
//        DispatchQueue.main.async {
//            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [weak self](_) in
                self.addConnectionObserver()
//            }
//    }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func addConnectionObserver(){
        if #available(iOS 12.0, *) {
            self.monitorNetworkPath()
        } else {
            self.observeReachability()
        }
    }

    func observeReachability() {
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.reachabilityChanged),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
        do {
            self.reachability = try Reachability()
            try self.reachability.startNotifier()
        } catch {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        guard  let reachability = note.object as? Reachability else { return }
        if reachability.connection != .unavailable {
            print("connected")
            AppSyncManager.instance.internetConnectionAvailable.value = .connected
            self.showNotification(false)
//            self.stopTimer()
        } else {
            print("not connected")
            AppSyncManager.instance.internetConnectionAvailable.value = .notconnected
            self.showNotification(true)
//            self.startTimer()
        }
    }

    @available(iOS 12.0, *)
    func monitorNetworkPath() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("connected")
                AppSyncManager.instance.internetConnectionAvailable.value = .connected
                self.showNotification(false)
//                self.stopTimer()
            } else {
                print("not connected")
                AppSyncManager.instance.internetConnectionAvailable.value = .notconnected
                self.showNotification(true)
//                self.startTimer()
            }
            print("is Expensive", path.isExpensive)
        }

        let queue = DispatchQueue(label: "NetworkPathMonitor")
        monitor.start(queue: queue)
    }

    private func showNotification(_ show: Bool) {
        if show {
            DispatchQueue.main.async {
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.view.addSubview(self.offlineNotificationView)
                    self.offlineNotificationView.fillSuperview()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.offlineNotificationView.removeFromSuperview()
            }
        }
    }
}
