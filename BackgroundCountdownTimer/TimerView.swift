//
//  TimerView.swift
//  BackgroundCountdownTimer
//
//  Created by 仲純平 on 2023/02/28.
//

import SwiftUI

struct TimerView: View {
    let session: CountdownSession
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var progressIndicator: String = "00:00"
    @State private var progressPercent: Double = 0
    
    let tick = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            if session.finished() {
                Text("終了しました")
                Button("リセット") {
                    cancel()
                }
            } else {
                Text(progressIndicator)
                    .font(.system(size: 20.0, weight: .regular, design: .monospaced))
                HStack(spacing: 20) {
                    Button("キャンセル") {
                        cancel()
                    }
                    if session.isRunning() {
                        Button("一時停止") {
                            pause()
                        }
                    } else {
                        Button("再開") {
                            resume()
                        }
                    }
                }
                
            }
            
        }
        .onAppear {
            progressIndicator = formatTimeMillis(session: session)
            /*withAnimation {
                if (focusSession.isRunning()) {
                    applyRunningEffect()
                } else {
                    applyPausedEffect()
                }
            }*/
        }
        .onReceive(tick) { _ in
            progressIndicator = formatTimeMillis(session: session)
            withAnimation {
                progressPercent = session.progressPercent()
            }
            
            // 終了状態へ移行
            if session.remainingMillis() <= 0 {
                finish()
            }
        }
        .onChange(of: session) { session in
            print(session.status)
            withAnimation {
                if (session.isRunning()) {
                    //applyRunningEffect()
                } else {
                    //applyPausedEffect()
                }
            }
        }
    }
    
    func pause() {
        session.progressMillisAtResumed = Int64(session.currentProgressMillis())
        session.status = Int16(CountdownSession.Status.paused.rawValue)
        
        try? viewContext.save()
    }
    
    func resume() {
        session.resumedAt = Date.now
        session.status = Int16(CountdownSession.Status.running.rawValue)
        
        try? viewContext.save()
    }
    
    func cancel() {
        viewContext.delete(session)
        
        try? viewContext.save()
    }
    
    func finish() {
        session.status = Int16(CountdownSession.Status.finished.rawValue)
        
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

/*struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        //TimerView(session: )
    }
}*/
