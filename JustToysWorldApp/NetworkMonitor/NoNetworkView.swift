//
//  NoNetworkView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 02/12/25.
//

import Foundation
import Network
import Combine
import SwiftUI
struct NoNetworkView: View {
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @EnvironmentObject var dataFetcher: DataFetcher
    
    @State private var isRefreshing = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding(.bottom, 8)
            
            Text("No Internet Connection")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Please check your Wi-Fi or cellular data and try again.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: handleRefresh) {
                HStack {
                    if isRefreshing {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                }
                .frame(maxWidth: 200)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isRefreshing)
            
        }
        .padding(40)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
      
        .onChange(of: networkMonitor.isConnected) { newValue in
            if newValue && isRefreshing {
                print("Network reconnected! Executing stored refresh action.")
                dataFetcher.refreshAction?()
                isRefreshing = false
            }
        }
    }
    
    func handleRefresh() {
        // 1. First, check current connection status
        if networkMonitor.isConnected {
            // If connected, execute the action immediately
            print("Refresh tapped: Network is already connected. Calling API immediately.")
            dataFetcher.refreshAction?()
        } else {
            // If disconnected, show a loading/refresh state and wait for the monitor to detect connection
            print("Refresh tapped: Waiting for network to reconnect...")
            isRefreshing = true
        }
    }
}

