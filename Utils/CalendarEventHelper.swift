//
//  CalendarEventHelper.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/07/18.
//

import EventKit
import Foundation

final class CalendarEventHelper {
    static let shared = CalendarEventHelper()
    private let eventStore = EKEventStore()

    private init() {}

    func requestAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func createOrUpdateEvent(for date: Date, hour: Int, minute: Int, title: String?, existingIdentifier: String?) -> String? {
        let event: EKEvent
        if let id = existingIdentifier, let existing = eventStore.event(withIdentifier: id) {
            event = existing
        } else {
            event = EKEvent(eventStore: eventStore)
            event.calendar = eventStore.defaultCalendarForNewEvents
        }
        

        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        guard let start = Calendar.current.date(from: components) else { return nil }
        event.startDate = start
        event.endDate = start.addingTimeInterval(60 * 60) // 1 hour
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            return event.eventIdentifier
        } catch {
            print("Failed to save event: \(error)")
            return nil
        }
    }

    func fetchEvent(identifier: String) -> EKEvent? {
        return eventStore.event(withIdentifier: identifier)
    }
    /// 指定した日付に存在するイベントを検索
    func findEvent(on date: Date, title: String? = nil) -> EKEvent? {
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return nil }
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = eventStore.events(matching: predicate)
        if let title = title {
            return events.first { $0.title == title }
        }
        return events.first
    }
}
