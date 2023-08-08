//
//  File.swift
//  
//
//  Created by ankudinov aleksandr on 07.08.2023.
//

import Foundation

protocol LAConfigurationKeysProtocol {
    func appsFlyerDevKey() -> String
    func appleAppID() -> String
    func oneSignalAppId() -> String
    
    func TTAppId() -> (TTAppId:String,TTAppSecret:String)
    func remoteConfigKeys() -> (remoteTargetKey:String,remoteLKey:String )
    
    func DontForgetIncludeFBKeysInInfo()
}
