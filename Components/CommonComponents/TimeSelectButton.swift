import SwiftUI
import CoreData

struct TimeSelectButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var recordService: DailyRecordService
    @State private var selectedHour = 12
    @State private var selectedMinute = 30
    @State private var showPicker = false
    @Binding var confirmedTime: Bool

    // 時間変更時の通知用コールバック
    var onTimeChanged: (() -> Void)? = nil

    var body: some View {
        VStack {
            if !confirmedTime && !recordService.hasScheduledTime() {
                BasicButton(label: "時間を設定",colorOpacity: 0.5, width: 104, height: 56) {
                    showPicker = true
                }
                .padding(.leading, -16)
            } else {
                Button(action: {
                    showPicker = true
                }) {
                    Text(recordService.getFormattedTime())
                        .font(.system(size: 16))
                        .foregroundColor(.gray0)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showPicker) {
            TimeSelectPicker(
                recordService: recordService,
                confirmedTime: $confirmedTime,
                selectedHour: $selectedHour,
                selectedMinute: $selectedMinute,
                showPicker: $showPicker,
                onTimeChanged: onTimeChanged
            )
        }
        .onAppear {
            let (hour, minute) = recordService.getScheduledTime()
            selectedHour = Int(hour)
            selectedMinute = Int(minute)
            confirmedTime = recordService.hasScheduledTime()
        }
    }
}

struct TimeSelectPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var recordService: DailyRecordService
    @Binding var confirmedTime: Bool
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var showPicker: Bool

    // 時間変更時の通知用コールバック
    var onTimeChanged: (() -> Void)? = nil

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

                    // 時間変更通知
                    onTimeChanged?()

                    showPicker = false
                    confirmedTime = true
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

