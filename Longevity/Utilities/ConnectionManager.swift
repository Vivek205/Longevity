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

    func addConnectionObserver(){
        if #available(iOS 12.0, *) {
            monitorNetworkPath()
        } else {
            observeReachability()
        }

    }

    func observeReachability() {
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            self.reachability = try Reachability()
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        guard  let reachability = note.object as? Reachability else { return }
        if reachability.connection != .unavailable {
            print("connected")
            AppSyncManager.instance.internetConnectionAvailable.value = true
        }else {
            print("not connected")
            AppSyncManager.instance.internetConnectionAvailable.value = false
        }
    }

    @available(iOS 12.0, *)
    func monitorNetworkPath() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {
            path in

            if path.status == .satisfied {
                print("connected")
                AppSyncManager.instance.internetConnectionAvailable.value = true
            }else {
                print("not connected")
                AppSyncManager.instance.internetConnectionAvailable.value = false
            }
            print("is Expensive", path.isExpensive)
        }

        let queue = DispatchQueue(label: "NetworkPathMonitor")
        monitor.start(queue: queue)
    }
}
