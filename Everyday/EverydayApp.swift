
import SwiftUI
import BackgroundTasks
import NotificationCenter


@main
struct EverydayApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //@ObservedObject var networkManager = NetworkManager()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { (phase) in
                    switch phase {
                    case .active:
                        NSLog("ScenePhase: active")
                      //  networkManager.isProgressShowing=false
                    case .background:
                        NSLog("ScenePhase: background")
                    //  UN.scheduleNotification(notificationType: "ScenePhase: background")
                        
                    case .inactive: NSLog("ScenePhase: inactive")
                    @unknown default: NSLog("ScenePhase: unexpected state")
                    //  UN.scheduleNotification(notificationType: "SScenePhase: unexpected state")
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    NSLog("To the background!")
                    appDelegate.cancelAllPandingBGTask()
                    appDelegate.scheduleAppProcessing()
                   // appDelegate.scheduleAppRefresh()
                }
        }
    }
    
}


class AppDelegate: NSObject, UIApplicationDelegate {
        
    @ObservedObject var unDelegate = UN()
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NSLog("didFinishLaunchingWithOptions")
      //  print("didFinishLaunchingWithOptions")
        
        registerBackgroundTaks()
        
        // register local notification
        UN.appRequestAuthorization()
        UNUserNotificationCenter.current().delegate = unDelegate
        
       // UN.scheduleNotification(notificationType: "initFinished")
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        //NSLog("applicationDidEnterBackground")
    
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("applicationWillResignActive")
    }

    
    private func registerBackgroundTaks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "ua.novikov.BGProcessingTask", using: nil) { task in
            self.handleAppProcessing(task: task as! BGProcessingTask)
        }
        /*
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "test3.bgtasks.AppRefreshTask", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        */
    }
    
    func cancelAllPandingBGTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    
    /*
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "test3.bgtasks.AppRefreshTask")
        // Fetch no earlier than 15 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            NSLog("Could not schedule app refresh: \(error)")
        }
    }
    */
    func scheduleAppProcessing() {
        // Command for simulation task
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"ua.novikov.BGProcessingTask"]
        let request = BGProcessingTaskRequest(identifier: "ua.novikov.BGProcessingTask")
        request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
        request.requiresExternalPower = false
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // Featch Image Count after 1 minute.
        //Note :: EarliestBeginDate should not be set to too far into the future.
        do {
            try BGTaskScheduler.shared.submit(request)
            
        } catch {
            print("Could not schedule image featch: \(error)")
        }
    }
    
    
    
    func handleAppProcessing(task: BGProcessingTask) {
        scheduleAppProcessing() // Recall
        
        //Todo Work
        task.expirationHandler = {
            //This Block call by System
            //Canle your all tak's & queues
        }
        
        scheduleEventNotifications()
        //Get & Set New Data
        
        task.setTaskCompleted(success: true)
        
    }
    
    func scheduleEventNotifications()
    {
        let curDate = Date()
        let networkManager = NetworkManager()
        networkManager.getEventsAndSetNotifications(curDate: curDate)
    }
    
    
    /*
    func handleAppRefresh(task: BGAppRefreshTask) {
        //Todo Work
       
        task.expirationHandler = {
            //This Block call by System
            //Canle your all tak's & queues
        }
        UN.scheduleNotification(notificationType: "handleAppRefresh")
        //
        task.setTaskCompleted(success: true)
    }
 */
}
