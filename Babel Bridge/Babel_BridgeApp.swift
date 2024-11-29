//
//  Babel_BridgeApp.swift
//  Babel Bridge
//
//  Created by 邱鑫 on 10/31/24.
//

import SwiftData
import SwiftUI

@main
struct Babel_BridgeApp: App {
    init () {
        loadRocketSimConnect()
    }
    private func loadRocketSimConnect() {
        #if DEBUG
        guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
            print("Failed to load linker framework")
            return
        }
        print("RocketSim Connect successfully linked")
        #endif
    }
    var body: some Scene {
        
        WindowGroup { ContentView() }
    }
}
