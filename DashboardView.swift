import SwiftUI

// MARK: - Supporting Types

enum NoteDirection {
    case up, down
}

struct Note: Identifiable {
    let id: UUID
    var symbol: String
    var x: CGFloat
    var y: CGFloat
    var direction: NoteDirection
    var speed: Int
}

struct NavigationCard: View {
    let title: String
    let iconName: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.white)
                .padding(10)
                .background(AppColors.tyreRubber)
                .clipShape(Circle())

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.black)

            Spacer()
        }
        .padding()
        .background(AppColors.creamyWhite)
        .cornerRadius(12)
        .shadow(color: AppColors.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

struct DashboardView: View {
    @EnvironmentObject var storageManager: StorageManager

    @State private var showingAddStudentSheet = false
    @State private var selectedLesson: Lesson? = nil

    // New state var for AddLesson sheet
    @State private var showingAddLessonSheet = false

    private let noteSymbols = ["music.note", "music.mic", "music.note.list"]
    @State private var notes: [Note] = []
    @State private var timer: Timer? = nil

    var body: some View {
        NavigationView {
            ZStack {
                AppGradient.background
                    .ignoresSafeArea()

                ZStack {
                    ForEach(notes) { note in
                        Image(systemName: note.symbol)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .position(x: note.x, y: note.y)
                    }
                }
                .allowsHitTesting(false)

                ScrollView {
                    VStack(spacing: 20) {
                        heroSection
                        nextLessonSection
                        primaryActionsSection
                        secondaryActionsSection
                    }
                }
            }
            // EDIT SELECTED LESSON
            .sheet(item: $selectedLesson) { lessonToEdit in
                if let index = storageManager.lessons.firstIndex(where: { $0.id == lessonToEdit.id }) {
                    EditLessonView(lesson: $storageManager.lessons[index])
                        .environmentObject(storageManager)
                } else {
                    Text("Lesson not found.")
                }
            }
            // ADD STUDENT SHEET
            .sheet(isPresented: $showingAddStudentSheet) {
                AddStudentView()
                    .environmentObject(storageManager)
            }
            // ADD LESSON SHEET
            .sheet(isPresented: $showingAddLessonSheet) {
                // Make sure AddLessonView is set up to allow picking existing students if desired
                AddLessonView(lessons: $storageManager.lessons)
                    .environmentObject(storageManager)
            }
            .navigationTitle("Main Menu")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupNotes()
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "music.note")
                .font(.system(size: 50))
                .foregroundColor(AppColors.black)

            Text("Sarah Skeens Assistant")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppColors.black)

            Text("What would you like to do?")
                .font(.headline)
                .foregroundColor(AppColors.black.opacity(0.8))
        }
        .padding(.top, 60)
    }

    // MARK: - Next Upcoming Lesson
    private var nextLessonSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Next Upcoming Lesson")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.black)
                .padding(.horizontal, 20)

            let lesson = nextUpcomingLesson
            if let lesson {
                Button(action: {
                    selectedLesson = lesson
                }) {
                    VStack(alignment: .leading, spacing: 5) {
                        // Display the lesson's stored studentName directly
                        Text(lesson.studentName)
                            .font(.headline)
                            .foregroundColor(AppColors.black)

                        Text("\(formattedDate(lesson.date)) at \(lesson.time)")
                            .font(.subheadline)
                            .foregroundColor(AppColors.black.opacity(0.7))
                    }
                    .padding()
                    .background(AppColors.creamyWhite)
                    .cornerRadius(12)
                    .shadow(color: AppColors.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    .padding(.horizontal, 20)
                }
            } else {
                Text("No upcoming lessons.")
                    .font(.title3)
                    .foregroundColor(AppColors.black)
                    .padding()
                    .background(AppColors.creamyWhite)
                    .cornerRadius(12)
                    .shadow(color: AppColors.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Next Upcoming Lesson Logic
    private var nextUpcomingLesson: Lesson? {
        let now = Date()
        let future = storageManager.lessons.filter { $0.date > now }
        return future.sorted { $0.date < $1.date }.first
    }

    // MARK: - Primary Actions
    private var primaryActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Main Actions")
                .font(.headline)
                .foregroundColor(AppColors.black)
                .padding(.horizontal, 20)

            VStack(spacing: 15) {
                // Example: TodayScheduleView
                NavigationLink(destination: TodayScheduleView()) {
                    NavigationCard(title: "View Today’s Schedule", iconName: "clock.fill")
                }

                // *** Add Lesson ***
                Button(action: {
                    showingAddLessonSheet = true
                }) {
                    NavigationCard(title: "Add Lesson", iconName: "plus.circle")
                }

                // Add Student
                Button(action: {
                    showingAddStudentSheet = true
                }) {
                    NavigationCard(title: "Add Student", iconName: "person.badge.plus")
                }

                // Weekly Planner
                NavigationLink(destination: WeeklyPlannerView()) {
                    NavigationCard(title: "Weekly Planner", iconName: "calendar")
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Secondary Actions
    private var secondaryActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("More Options")
                .font(.headline)
                .foregroundColor(AppColors.black)
                .padding(.horizontal, 20)

            VStack(spacing: 15) {
                // For a list of all students
                NavigationLink(destination: StudentListView()) {
                    NavigationCard(title: "Student Contacts", iconName: "person.3")
                }

                // Term Overview & Management
                NavigationLink(destination: TermOverviewView()) {
                    NavigationCard(title: "Term Overview & Management", iconName: "doc.text.fill")
                }

                // NEW: Help & Tips link
                NavigationLink(destination: HelpView()) {
                    NavigationCard(title: "Help & Tips", iconName: "questionmark.circle.fill")
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Animated Notes
    private func setupNotes() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        notes = (0..<10).map { _ in
            Note(
                id: UUID(),
                symbol: noteSymbols.randomElement() ?? "music.note",
                x: CGFloat.random(in: 50...(screenWidth - 50)),
                y: screenHeight + CGFloat.random(in: 50...300),
                direction: .up,
                speed: 2
            )
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateNotesPosition()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateNotesPosition() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let top: CGFloat = -100
        let bottom: CGFloat = screenHeight + 300

        notes = notes.map { note in
            var n = note
            switch n.direction {
            case .up:
                n.y -= CGFloat(n.speed)
                if n.y < top {
                    n.y = top
                    n.direction = .down
                    n.speed = 10
                }
            case .down:
                n.y += CGFloat(n.speed)
                if n.y > bottom {
                    n.y = bottom
                    n.x = CGFloat.random(in: 50...(screenWidth - 50))
                    n.direction = .up
                    n.speed = 2
                }
            }
            return n
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

