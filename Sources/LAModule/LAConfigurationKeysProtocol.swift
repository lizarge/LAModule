//
//  File.swift
//  
//
//  Created by ankudinov aleksandr on 07.08.2023.
//

import Foundation
import UIKit

public protocol LAConfigurationKeysProtocol:UIApplicationDelegate {
    func DontForgetIncludeFBKeysInInfo() -> LAModule.LAConfigurationKeys
}
