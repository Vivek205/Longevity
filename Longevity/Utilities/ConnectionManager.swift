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
//    private var monitor: NWPathMonitor?

    func addConnectionObserver(){
        observeReachability()
//        if #available(iOS 12.0, *) {
//            monitorNetworkPath()
//        } else {
//            observeReachability()
//        }

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
        }else {
            print("not connected")
        }
//        switch reachability.connection {
//        case .cellular:
//            print("Cellular")
//        case .wifi:
//            print("Wifi")
//        case .none:
//            print("none")
//        case .unavailable:
//            print("unavailable")
//        }

//        print("isConnected", reachability)
    }

    @available(iOS 12.0, *)
    func monitorNetworkPath() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {
            path in

            if path.status == .satisfied {
                print("connected")
            }else {
                print("not connected")
            }

//            switch path.status {
//            case .requiresConnection:
//            print("reuire connection")
//            case .unsatisfied:
//            print("unsatisfied")
//            case .satisfied:
//            print("satisifed")
//            @unknown default:
//                print("unknown default")
//            }
            print("is Expensive", path.isExpensive)
        }

        let queue = DispatchQueue(label: "NetworkPathMonitor")
        monitor.start(queue: queue)

//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            print("currentpath status",monitor.currentPath.status, self.reachability.connection.description)
//        }
    }
}
