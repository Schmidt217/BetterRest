//
//  ContentView.swift
//  BetterRest
//
//  Created by Michael Schmidt on 1/3/23.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var bedtime = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a wake up time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp) { _ in
                            calculateBedtime()
                        }
                }
               
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) { _ in
                            calculateBedtime()
                        }
                }
                
                Section("Daily Coffee intake") {
                    Picker("Coffee", selection: $coffeeAmount) {
                        ForEach(1..<15) { int in
                            Text("\(int)")
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: coffeeAmount) { _ in
                        calculateBedtime()
                    }
                }
                Text("Your ideal bedtime is:")
                Text("\(bedtime)")
                    .font(.largeTitle)
            }
            .navigationTitle("BetterRest")
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
        
            bedtime = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            bedtime = "Something went wrong!"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
