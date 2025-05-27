import SwiftUI
import CoreData

struct TimeSelectButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dailyRecord: DailyRecord
    @State private var selectedHour = 12
    @State private var selectedMinute = 30
    @State private var showPicker = false
    @State private var confirmedHour: Int? = nil
    @State private var confirmedMinute: Int? = nil

    let hours = Array(0...23)
    let minutes = Array(0...59)

    var formattedTime: String {
        if let hour = confirmedHour, let minute = confirmedMinute {
            return String(format: "%02d:%02d", hour, minute)
        } else {
            return "時間を選択"
        }
    }

    var body: some View {
        VStack {
            Button(action: {
                showPicker = true
            }) {
                Text(formattedTime)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }

            .sheet(isPresented: $showPicker) {
                TimeSelectPicker(
                    dailyRecord: dailyRecord, selectedHour: $selectedHour,
                    selectedMinute: $selectedMinute,
                    showPicker: $showPicker,
                    confirmedHour: $confirmedHour,
                    confirmedMinute: $confirmedMinute
                )
            }
        }
        .padding()
        .onAppear {
            confirmedHour = Int(dailyRecord.scheduledHour)
            confirmedMinute = Int(dailyRecord.scheduledMinute)
        }
    }
}

struct TimeSelectPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dailyRecord: DailyRecord
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var showPicker: Bool
    @Binding var confirmedHour: Int?
    @Binding var confirmedMinute: Int?

    let hours = Array(0...23)
    let minutes = Array(0...59)

    var body: some View {
        VStack {
            // 上部の「キャンセル」＆「確定」ボタン
            HStack {
                Button("キャンセル") {
                    showPicker = false
                }
                .foregroundColor(.red)

                Spacer()

                Button("確定") {
                    confirmedHour = selectedHour
                    confirmedMinute = selectedMinute
                    showPicker = false
                    
                    if let hour = confirmedHour, let minute = confirmedMinute {
                        DailyRecordManager.shared.updateScheduledHour(Int16(hour), for: dailyRecord, context: viewContext)
                        DailyRecordManager.shared.updateScheduledMinute(Int16(minute), for: dailyRecord, context: viewContext)
                    }
                }
                .font(.headline)
            }
            .padding()

            // ピッカー本体
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
        .presentationDetents([.fraction(0.4)]) // iOS16以降：シートの高さを調整
    }
}

//struct CustomTimePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeSelectButton(dailyRecord: $dailyRecord)
//    }
//}

