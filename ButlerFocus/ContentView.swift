import SwiftUI

class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = 1800 {
        didSet {
            self.sliderValue = Double(self.timeRemaining)
            calculateEndTime()
        }
    }
    @Published var sliderValue: Double = 1800  // Initial value set to 30 minutes (30 * 60 seconds)
    @Published var endTime: String = ""
    @Published var isTimerRunning: Bool = false
    var timer: Timer?
    
    func startTimer() {
        self.isTimerRunning = true
        self.timer?.invalidate()  // Ensure the previous timer is invalidated before starting a new one
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.isTimerRunning = false
            }
        }
        calculateEndTime()
    }
    
    func resetTimer() {
        self.isTimerRunning = false
        self.timer?.invalidate()
        self.timer = nil
        self.timeRemaining = 1800  // Reset to initial value
        calculateEndTime()
    }
    
    func calculateEndTime() {
        let now = Date()
        let endTimeDate = now.addingTimeInterval(TimeInterval(self.timeRemaining))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.endTime = formatter.string(from: endTimeDate)
    }
}

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        HStack {
            VStack {
                
                if timerManager.isTimerRunning {
                    ProgressView(value: timerManager.sliderValue, total: 3600)
                } else {
                    Slider(value: $timerManager.sliderValue, in: 300...3600, step: 300)
                        .onChange(of: timerManager.sliderValue) { newValue in
                            timerManager.timeRemaining = Int(newValue)
                        }
                }
                Text(timeString(from: timerManager.timeRemaining))
                Text("Ends at: \(timerManager.endTime)")
                if !timerManager.isTimerRunning {
                    Button(action: timerManager.startTimer) {
                        Text("Start Timer")
                    }
                }
                if timerManager.isTimerRunning {  // Only show the Reset Timer button if the timer is running
                    Button(action: timerManager.resetTimer) {
                        Text("Reset Timer")
                    }
                }
            }
            .padding()
            .onAppear {
                self.timerManager.calculateEndTime()  // Calculate end time when the view appears
            }
        }
    }
    
    func timeString(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
