//
//  UN.swift
//  EverydayNew
//  Created by dima on 20.02.2021.
//

//import Foundation
import SwiftUI
import UserNotifications

//MARK:- CLASS UN
class UN : NSObject, ObservableObject, UNUserNotificationCenterDelegate{
    
    @Published var alert=false
    
    public static var notificationCenter=UNUserNotificationCenter.current()
    
    //MARK:- RequestAuthorization
    static func appRequestAuthorization (){
        self.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]){
            (granted,error) in print("permission granted \(granted)")
            guard granted else {return}
            self.notificationCenter.getNotificationSettings { (settings) in
               // print("notification settings \(settings)")
            }
        }
    }
    //MARK:- scheduleNotification
    public static func scheduleNotification(notificationType:String){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("scheduleNotification")
                let content=UNMutableNotificationContent()
                content.title=notificationType
                content.body=getDate()
                content.sound=UNNotificationSound.default
                content.badge=3
                content.userInfo=["data":"testdata"]
                let triger=UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let identifire=UUID().uuidString
                let request=UNNotificationRequest(identifier: identifire, content: content, trigger: triger)
                self.notificationCenter.add(request) { (error) in
                    if let error=error {
                        print("error \(error.localizedDescription)")
                    }
                }
            } else {
                print("error authorizationStatus")
            }
        }
    }
    
    public static func scheduleEventNotification(title:String, hour:String, minute:String, second:String,day:String,month:String,year:String){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("scheduleEventNotification")
                let content=UNMutableNotificationContent()
                content.title=title
                content.body="body"
                content.sound=UNNotificationSound.default
             
                content.userInfo=["data":"testdata"]
                
                var dateComponents = DateComponents()
                    dateComponents.calendar = Calendar.current
                    
                dateComponents.hour = Int(hour)
                dateComponents.minute = Int(minute)
                dateComponents.second = Int(second)
                dateComponents.day=Int(day)
                dateComponents.month=Int(month)
                dateComponents.year=Int(year)

                    // The time/repeat trigger
                    let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                
                let identifire=UUID().uuidString
                let request=UNNotificationRequest(identifier: identifire, content: content, trigger: triger)
                self.notificationCenter.add(request) { (error) in
                    if let error=error {
                        print("error \(error.localizedDescription)")
                    }
                }
            } else {
                print("error authorizationStatus")
            }
        }
    }
    //MARK:- clearBadge
    public static func clearBadge(){
        UIApplication.shared.applicationIconBadgeNumber=0
    }
    //MARK:- willPresent
    func userNotificationCenter(_ center:UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)->Void){
        
        completionHandler([.badge, .banner, .sound])
    }
    //MARK:- didReceive
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo=response.notification.request.content.userInfo
        print(userInfo["data"] as? String ?? "")
            /*
        if response.actionIdentifier=="REPLY"{
            print("reply the content")
            self.alert.toggle()
        } else {
            print("reply the content2")
        }
 */
        completionHandler()
    }
    
    public static func cancelNotifications() -> Void {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    //MARK:- helpers
    public static func getDate()->String{
         let time = Date()
         let timeFormatter = DateFormatter()
         timeFormatter.dateFormat = "yyyy/MM/dd HH:mm"
         let stringDate = timeFormatter.string(from: time)
         return stringDate
        }
}

