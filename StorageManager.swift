import Foundation
import Combine
import SwiftUI

// MARK: - Student
struct Student: Identifiable, Codable {
    var id = UUID()
    var studentFirstName: String
    var studentLastName: String
    var parentFirstName: String?
    var parentLastName: String?
    var mobile: String?
    var email: String?
}

// MARK: - Terms
struct AcademicTermData: Codable, Identifiable {
    var id = UUID()
    var term: AcademicTerm
    var patternCycles: [PatternCycle] = []
}

class StorageManager: ObservableObject {
    @Published var students: [Student] {
        didSet { saveStudents() }
    }
    @Published var lessons: [Lesson] {
        didSet { saveLessons() }
    }
    @Published var enquiries: [Enquiry] {
        didSet { saveEnquiries() }
    }
    @Published var studentNotes: [String: String] {
        didSet { saveStudentNotes() }
    }
    @Published var dailyAvailability: [String: Bool] {
        didSet { saveDailyAvailability() }
    }
    @Published var recurringPatterns: [RecurringLessonPattern] {
        didSet { saveRecurringPatterns() }
    }
    @Published var terms: [AcademicTermData] {
        didSet { saveTerms() }
    }

    // UserDefaults Keys
    private static let studentsKey = "studentsKey"
    private static let lessonsKey = "lessonsKey"
    private static let enquiriesKey = "enquiriesKey"
    private static let studentNotesKey = "studentNotesKey"
    private static let dailyAvailabilityKey = "dailyAvailabilityKey"
    private static let recurringPatternsKey = "recurringPatternsKey"
    private static let termsKey = "termsKey"

    init() {
        self.students           = Self.loadStudents()
        self.lessons            = Self.loadLessons()
        self.enquiries          = Self.loadEnquiries()
        self.studentNotes       = Self.loadStudentNotes()
        self.dailyAvailability  = Self.loadDailyAvailability()
        self.recurringPatterns  = Self.loadRecurringPatterns()
        self.terms              = Self.loadTerms()

        generateLessonsFromPatterns()
        generateLessonsFromTermPatterns()
    }

    // MARK: - Students
    static func loadStudents() -> [Student] {
        guard let data = UserDefaults.standard.data(forKey: studentsKey) else { return [] }
        do {
            return try JSONDecoder().decode([Student].self, from: data)
        } catch {
            print("Error decoding students: \(error)")
            return []
        }
    }
    private func saveStudents() {
        do {
            let data = try JSONEncoder().encode(students)
            UserDefaults.standard.set(data, forKey: Self.studentsKey)
        } catch {
            print("Error encoding students: \(error)")
        }
    }

    // MARK: - Lessons
    static func loadLessons() -> [Lesson] {
        guard let data = UserDefaults.standard.data(forKey: lessonsKey) else { return [] }
        do {
            return try JSONDecoder().decode([Lesson].self, from: data)
        } catch {
            print("Error decoding lessons: \(error)")
            return []
        }
    }
    private func saveLessons() {
        do {
            let data = try JSONEncoder().encode(lessons)
            UserDefaults.standard.set(data, forKey: Self.lessonsKey)
        } catch {
            print("Error encoding lessons: \(error)")
        }
    }
    func updateLesson(_ updated: Lesson) {
        if let i = lessons.firstIndex(where: { $0.id == updated.id }) {
            lessons[i] = updated
        }
    }

    // MARK: - Enquiries
    static func loadEnquiries() -> [Enquiry] {
        guard let data = UserDefaults.standard.data(forKey: enquiriesKey) else { return [] }
        do {
            return try JSONDecoder().decode([Enquiry].self, from: data)
        } catch {
            print("Error decoding enquiries: \(error)")
            return []
        }
    }
    private func saveEnquiries() {
        do {
            let data = try JSONEncoder().encode(enquiries)
            UserDefaults.standard.set(data, forKey: Self.enquiriesKey)
        } catch {
            print("Error encoding enquiries: \(error)")
        }
    }

    // MARK: - Student Notes
    static func loadStudentNotes() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: studentNotesKey) else { return [:] }
        do {
            return try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("Error decoding student notes: \(error)")
            return [:]
        }
    }
    private func saveStudentNotes() {
        do {
            let data = try JSONEncoder().encode(studentNotes)
            UserDefaults.standard.set(data, forKey: Self.studentNotesKey)
        } catch {
            print("Error encoding student notes: \(error)")
        }
    }

    /// Add this function to update a student's notes in the dictionary.
    func updateStudentNotes(for studentName: String, notes: String) {
        studentNotes[studentName] = notes
    }

    // MARK: - Daily Availability
    static func loadDailyAvailability() -> [String: Bool] {
        guard let data = UserDefaults.standard.data(forKey: dailyAvailabilityKey) else {
            return defaultAvailability()
        }
        do {
            return try JSONDecoder().decode([String: Bool].self, from: data)
        } catch {
            print("Error decoding daily availability: \(error)")
            return defaultAvailability()
        }
    }
    private func saveDailyAvailability() {
        do {
            let data = try JSONEncoder().encode(dailyAvailability)
            UserDefaults.standard.set(data, forKey: Self.dailyAvailabilityKey)
        } catch {
            print("Error encoding daily availability: \(error)")
        }
    }
    static func defaultAvailability() -> [String: Bool] {
        var dict = [String: Bool]()
        let slots = halfHourTimeSlots()
        for slot in slots { dict[slot] = true }
        return dict
    }

    // MARK: - Recurring Patterns
    static func loadRecurringPatterns() -> [RecurringLessonPattern] {
        guard let data = UserDefaults.standard.data(forKey: recurringPatternsKey) else { return [] }
        do {
            return try JSONDecoder().decode([RecurringLessonPattern].self, from: data)
        } catch {
            print("Error decoding recurring patterns: \(error)")
            return []
        }
    }
    private func saveRecurringPatterns() {
        do {
            let data = try JSONEncoder().encode(recurringPatterns)
            UserDefaults.standard.set(data, forKey: Self.recurringPatternsKey)
        } catch {
            print("Error encoding recurring patterns: \(error)")
        }
    }
    func addRecurringPattern(_ pattern: RecurringLessonPattern) {
        recurringPatterns.append(pattern)
        generateLessonsFromPatterns()
    }

    // MARK: - Terms
    static func loadTerms() -> [AcademicTermData] {
        guard let data = UserDefaults.standard.data(forKey: termsKey) else { return [] }
        do {
            return try JSONDecoder().decode([AcademicTermData].self, from: data)
        } catch {
            print("Error decoding terms: \(error)")
            return []
        }
    }
    private func saveTerms() {
        do {
            let data = try JSONEncoder().encode(terms)
            UserDefaults.standard.set(data, forKey: Self.termsKey)
        } catch {
            print("Error encoding terms: \(error)")
        }
    }
    func addTerm(_ termData: AcademicTermData) {
        terms.append(termData)
    }
    func updateTerm(_ updated: AcademicTermData) {
        if let i = terms.firstIndex(where: { $0.id == updated.id }) {
            terms[i] = updated
        }
    }
    func deleteTerm(by id: UUID) {
        if let i = terms.firstIndex(where: { $0.id == id }) {
            terms.remove(at: i)
        }
    }

    // MARK: - Patterns
    func generateLessonsFromPatterns() { }
    func generateLessonsFromTermPatterns() { }

    // MARK: - halfHourTimeSlots
    static func halfHourTimeSlots() -> [String] {
        var slots: [String] = []
        let startHour = 9
        let endHour = 17
        for hour in startHour..<endHour {
            slots.append(String(format: "%02d:00", hour))
            slots.append(String(format: "%02d:30", hour))
        }
        slots.append("17:00")
        return slots
    }

    // MARK: - isTimeSlotAvailable
    func isTimeSlotAvailable(date: Date, time: String, excludingLessonID: UUID? = nil) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            return true
        }
        let dayLessons = lessons.filter { $0.date >= startOfDay && $0.date < endOfDay }
        return !dayLessons.contains { lesson in
            if let excludeID = excludingLessonID, lesson.id == excludeID {
                return false
            }
            return lesson.time == time
        }
    }

    // MARK: - Reset
    func resetAllData() {
        students = []
        lessons = []
        enquiries = []
        studentNotes = [:]
        dailyAvailability = Self.defaultAvailability()
        recurringPatterns = []
        terms = []
    }
}

