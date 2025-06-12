import SwiftUI
import CoreData

struct TimeSelectButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var recordService: DailyRecordService
    @State private var selectedHour = 12
    @State private var selectedMinute = 30
    @State private var showPicker = false

    var body: some View {
        VStack {
            Button(action: {
                showPicker = true
            }) {
                Text(recordService.getFormattedTime())
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showPicker) {
                TimeSelectPicker(
                    recordService: recordService,
                    selectedHour: $selectedHour,
                    selectedMinute: $selectedMinute,
                    showPicker: $showPicker
                )
            }
        }
        .padding()
        .onAppear {
            let (hour, minute) = recordService.getScheduledTime()
            selectedHour = Int(hour)
            selectedMinute = Int(minute)
        }
    }
}

struct TimeSelectPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var recordService: DailyRecordService
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var showPicker: Bool

    let hours = Array(0...23)
    let minutes = Array(0...59)

    var body: some View {
        VStack {
            HStack {
                Button("キャンセル") {
                    showPicker = false
                }
                .foregroundColor(.red)

                Spacer()

                Button("確定") {
                    recordService.updateScheduledHour(Int16(selectedHour), context: viewContext)
                    recordService.updateScheduledMinute(Int16(selectedMinute), context: viewContext)
                    showPicker = false
                }
                .font(.headline)
            }
            .padding()

            HStack {
                Picker("時", selection: $selectedHour) {
                    ForEach(hours, id: \.self) { hour in
                        Text("\(hour) 時").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 150)

                Text(":")
                    .font(.largeTitle)

                Picker("分", selection: $selectedMinute) {
                    ForEach(minutes, id: \.self) { minute in
                        Text("\(minute) 分").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 150)
            }

            Spacer()
        }
        .presentationDetents([.fraction(0.4)])
    }
}
