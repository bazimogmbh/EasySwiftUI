//
//  RechabilityService.swift
//
//
//  Created by Yevhenii Korsun on 30.01.2024.
//

import Foundation
import Network
import SystemConfiguration

public final class RechabilityService: ObservableObject {
    public static let shared = RechabilityService()
    
    @Published public private(set) var isNetworkConnected: Bool = false
    @Published public private(set) var isCellularConnection: Bool = false
    
    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "monitorInternet")
    
    private init() {
        monitor = NWPathMonitor()
        isNetworkConnected = Self.isConnectedToNetwork
        enableMonitoring()
    }
    
    private func enableMonitoring() {
        monitor.start(queue: monitorQueue)
        
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handleNetworkUpdate(path)
        }
    }
    
    private func handleNetworkUpdate(_ path: NWPath) {
        DispatchQueue.main.async {
            self.isNetworkConnected = path.status == .satisfied
            self.isCellularConnection = path.usesInterfaceType(.cellular)
        }
    }
    
    private static var isConnectedToNetwork: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
