//
//  ContentView.swift
//  Everyday
//
//  Created by dima on 30.03.2021.
//

import SwiftUI

func timeStringFromDateString (dateStr: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let date = dateFormatter.date(from: dateStr)
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date ?? Date()) as String
}

struct ContentView: View {
    
    @State var curDate = Date()
    @ObservedObject var networkManager = NetworkManager()
    
    
   
    
    var body: some View {
        NavigationView {
            ZStack() {
            Button("getEventsAndSetNotifications"){
                self.networkManager.getEventsAndSetNotifications(curDate: curDate)
            }
            }
            /*
            if (networkManager.isProgressShowing){
                ZStack() {
                    ProgressView("Downloading...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
            } else {
                
                List(networkManager.events) { event in
                    
                HStack{
                    Image(String(event.type))
                        .resizable()
                        .frame(width: 40.0, height: 40.0)
                        .cornerRadius(10)
                    VStack(alignment: .leading) {
                        Text(timeStringFromDateString(dateStr: event.dt)+" "+event.name)
                        Text(event.dscr)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
 */
            
        }.onAppear {
            self.networkManager.fetchData(curDate: curDate)
          
           // self.networkManager.getEventsAndSetNotifications(curDate: curDate)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
