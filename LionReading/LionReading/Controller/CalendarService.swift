//
//  CalendarService.swift
//  LionReading
//
//  Created by TanJianing.
//  Make sure the project is linked to the EventKit framework

import Foundation
import EventKit

class CalendarService {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    private var hasCalendarAccess = false
    
    private init() {}
    
    // Request calendar access
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        
        // Check the new permission request method in iOS 17+
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    self.hasCalendarAccess = granted
                    completion(granted)
                }
            }
        } else {
            // Request method before iOS 17
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    self.hasCalendarAccess = granted
                    completion(granted)
                }
            }
        }
    }
    
    func addBookFinishToCalendar(bookName: String, author: String, date: Date, completion: @escaping (Bool, String?) -> Void) {
        if !hasCalendarAccess {
            requestCalendarAccess { [weak self] granted in
                if granted {
                    self?.createBookEvent(bookName: bookName, author: author, date: date, completion: completion)
                } else {
                    completion(false, "If you do not have calendar access, allow your app to access the calendar in your Settings")
                }
            }
        } else {
            createBookEvent(bookName: bookName, author: author, date: date, completion: completion)
        }
    }
    
    // Book reading completes the event
    private func createBookEvent(bookName: String, author: String, date: Date, completion: @escaping (Bool, String?) -> Void) {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Finish reading《\(bookName)》"
        event.notes = "You have finished reading 《\(bookName)》 \n author: \(author)"
        
        // Set this parameter to all-day event
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let startDate = calendar.date(from: dateComponents)!
        
        event.startDate = startDate
        event.endDate = startDate
        event.isAllDay = true
        
        // use default calendar
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // save event
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(true, nil)
        } catch {
            completion(false, "Failed to add to calendar: \(error.localizedDescription)")
        }
    }
    
    func checkCalendarAuthorizationStatus() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        return status == .authorized || status == .fullAccess
    }
}
