//
//  ContentView.swift
//  BackgroundCountdownTimer
//
//  Created by 仲純平 on 2023/02/28.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @FetchRequest(entity: CountdownSession.entity(), sortDescriptors: [])
    private var sessions:  FetchedResults<CountdownSession>
    private var session: CountdownSession? { sessions.first }
    
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    private var sessionDurationSeconds: Int {
        minutes * 60 + seconds
    }
    
    private var canStart: Bool {
        sessionDurationSeconds > 0
    }
    
    

    var body: some View {
        NavigationView {
            VStack {
                if let session = session {
                    TimerView(session: session)
                } else {
                    List {
                        Section("時間") {
                            Picker("分", selection: $minutes) {
                                ForEach(0...99, id: \.self) { value in
                                    Text("\(value)分").tag(value)
                                }
                            }
                            
                            Picker("秒", selection: $seconds) {
                                ForEach(0...59, id: \.self) { value in
                                    Text("\(value)秒").tag(value)
                                }
                            }
                        }
                        Button {
                            start()
                        } label: {
                            Label("スタート", systemImage: "play")
                                .opacity(canStart ? 1 : 0.5)
                        }
                        .disabled(!canStart)
                    }

                    
                }
            }

            
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func start() {
        CountdownSession.insert(in: viewContext, durationSeconds: sessionDurationSeconds)
        try? viewContext.save()
    }
    
    func formatTimeMillis(session: CountdownSession) -> String {
        let waitingMillis = max(session.durationMillis() - session.currentProgressMillis(), 0)
        var remainder: Int = waitingMillis % 1000
        let waitingSec: Double = Double(waitingMillis - remainder) / 1000 + ((remainder > 0) ? 1 : 0)
        let hours = Int(waitingSec / 3600)
        remainder = Int(waitingSec) % 3600
        let minutes = Int(Double(remainder) / 60)
        let seconds = remainder % 60
        if (hours > 0) {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
