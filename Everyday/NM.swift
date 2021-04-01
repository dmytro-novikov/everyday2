//
//  NetworkManager.swift
//  EverydayNew
//
//  Created by dima on 20.11.2020.
//

import Foundation

struct Events: Codable { var events: [Event] }
struct Event: Identifiable, Codable {
    var id: Int
    var dt: String
  
    var name: String
    var dscr: String
    var type:Int
    
}

class NM: ObservableObject {

    @Published var events = [Event]()
    @Published var isProgressShowing: Bool=true
    
    func fetchData(curDate:Date) {
        DispatchQueue.main.async {
            self.isProgressShowing=true
        
        }
        let dtFormatter = DateFormatter()
      
       
        dtFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
       
     
        
        let dateInISO=dtFormatter.string(from: curDate)
        //    https://my.everyday.ua/api/eventsSwift?date=2020-11-25T00:00:00\(searchText)
        let urlString = "https://my.everyday.ua/api/eventsSwift?date=\(dateInISO)"
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil{
                    let decoder = JSONDecoder()
                    if let safeData = data{
                        do{
                            let results = try decoder.decode(Events.self, from: safeData)
                            DispatchQueue.main.async {
                                self.events = results.events
                              //  print(self.events)
                            }
                        } catch{
                            print(error)
                        }
                        DispatchQueue.main.async{
                        self.isProgressShowing=false
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func getEventsAndSetNotifications(curDate:Date) {
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateInISO=dtFormatter.string(from: curDate)
        //    let urlString = "https://my.everyday.ua/api/eventsSwift?date=2020-11-25T00:00:00\(searchText)"
        let urlString = "https://my.everyday.ua/api/eventsSwift?date=\(dateInISO)"
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil{
                    let decoder = JSONDecoder()
                    if let safeData = data{
                        do{
                            let results = try decoder.decode(Events.self, from: safeData)
                           
                            
                            UN.cancelNotifications()
                                                        
                            UN.scheduleNotification(notificationType: "events count: "+String(results.events.count))
                            
                            for event in results.events {
                                print(event.dt+" "+event.name)
                                
                                let t=self.timeStringFromDateTimeString(dateStr: event.dt)
                                UN.scheduleEventNotification(title:event.name, hour:t.hour, minute:t.minute, second:t.second,day:t.day,month:t.month,year:t.year)
                            }
                        } catch{
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func timeStringFromDateTimeString (dateStr: String) -> (hour:String, minute:String, second:String,day:String,month:String,year:String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: dateStr)
      
        dateFormatter.dateFormat = "yyyy"
        let year=dateFormatter.string(from: date ?? Date()) as String
        dateFormatter.dateFormat = "MM"
        let month=dateFormatter.string(from: date ?? Date()) as String
        dateFormatter.dateFormat = "dd"
        let day=dateFormatter.string(from: date ?? Date()) as String
        dateFormatter.dateFormat = "HH"
        let hour=dateFormatter.string(from: date ?? Date()) as String
        dateFormatter.dateFormat = "mm"
        let minute=dateFormatter.string(from: date ?? Date()) as String
        dateFormatter.dateFormat = "ss"
        let second=dateFormatter.string(from: date ?? Date()) as String
       
        return (hour, minute, second,day,month,year)
    }
    
}
