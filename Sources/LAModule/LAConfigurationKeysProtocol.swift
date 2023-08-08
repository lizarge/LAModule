//
//  File.swift
//  
//
//  Created by ankudinov aleksandr on 07.08.2023.
//

import Foundation

protocol LAConfigurationKeysProtocol {
    static let appsFlyerDevKey:String
    static var appleAppID:String
    static var oneSignalAppId:String

    static var fbAppId:String
    static var fbAppSecret:String

    static var tTAppId:String
    static var tTAppSecret:String

    static var targetUrlKey:String
    static var remoteConfigKey :String
}
