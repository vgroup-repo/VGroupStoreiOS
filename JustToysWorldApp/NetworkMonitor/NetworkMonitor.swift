//
//  NetworkMonitor.swift
//  JustToysWorldApp
//
//  Created by Satyam on 02/12/25.
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    
    // Published property to notify views about connection status changes.
    @Published var isConnected: Bool = true
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        self.monitor = NWPathMonitor()
        
        // Set the closure to be called whenever the network path changes.
        self.monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            // Dispatch the update to the main thread since @Published updates should be on the main queue.
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.isConnected = true
                    print("NetworkMonitor: Status - Connected")
                } else {
                    self.isConnected = false
                    print("NetworkMonitor: Status - Disconnected")
                }
            }
        }
        
        // Start monitoring network paths.
        self.monitor.start(queue: queue)
        
        // Initialize the status based on the current path status
        self.isConnected = self.monitor.currentPath.status == .satisfied
    }
    
    // Deinitializer to stop monitoring when the object is destroyed.
    deinit {
        monitor.cancel()
    }
}
