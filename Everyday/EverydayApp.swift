
import SwiftUI
import BackgroundTasks
import NotificationCenter


@main
struct EverydayApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { (phase) in
                    switch phase {
                    case .active:
                        NSLog("ScenePhase: active")
                        
                    case .background:
                        NSLog("ScenePhase: background")
                        
                        
                    case .inactive: NSLog("ScenePhase: inactive")
                    @unknown default: NSLog("ScenePhase: unexpected state")
                        
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    NSLog("To the background!")
                    appDelegate.cancelAllPandingBGTask()
                    appDelegate.scheduleAppProcessing()
                    
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
        
        
        return true
    }
    
    
    private func registerBackgroundTaks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "ua.novikov.BGProcessingTask", using: nil) { task in
            self.handleAppProcessing(task: task as! BGProcessingTask)
        }
        
    }
    
    func cancelAllPandingBGTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    
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
        let networkManager = NM()
        networkManager.getEventsAndSetNotifications(curDate: curDate)
    }
    
    
}
