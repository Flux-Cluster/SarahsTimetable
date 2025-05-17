import SwiftUI

struct HelpView: View {
    var body: some View {
        ZStack {
            AppGradient.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Help & Tips")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.black)
                        .padding(.top, 20)
                        .padding(.horizontal)

                    // Introduction
                    Section {
                        Text("Welcome to Sarah’s Timetable App!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
This app helps you manage your teaching schedule, student details, lessons, and recurring patterns with ease. Use the guidance below to explore each feature and get the most out of it.
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    // Viewing Today’s Schedule
                    Section {
                        Text("Viewing Today’s Schedule")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
From the Main Menu, tap 'View Today’s Schedule' to see all lessons booked for the selected date. You can change the date if you need to view future or past lessons. You’ll see a list of lessons, and you can tap “Add Lesson” if no lessons exist for that date.
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    // Adding a Lesson
                    Section {
                        Text("Adding a Lesson")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
1. Tap “Add Lesson” (found in “Today’s Schedule,” or wherever you see it available).
2. Enter the student’s details, including parent/guardian info and contact details (if needed).
3. Choose a date/time slot. If a slot is already taken or unavailable, the app will inform you.
4. Select the instrument, location, and optional notes.
5. Press “Save Lesson” when you’re done. If you want this lesson to recur weekly, toggle “Repeat this lesson every week?” before saving.
6. Alternatively, if you prefer the “Weekly Planner,” you can add lessons there or from “Manage Terms” if you use advanced scheduling (multiple patterns, etc.).
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    // Managing Lessons & Students
                    Section {
                        Text("Managing Lessons & Students")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
- Tap “Student Contacts” or “Student & Lesson Management” from the Main Menu to view all students and/or lessons.
- Select a lesson to view details, edit it, or mark attendance (e.g., no-show).
- When editing a lesson, you can update its date, time, location, notes, or even rename the student if necessary.
- If you want to move a lesson to a different time slot entirely, you can use “Reschedule” (from Today’s Schedule or the Weekly Planner).
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    // Weekly Planner
                    Section {
                        Text("Weekly Planner")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
The Weekly Planner offers an overview of your lessons across the week. You can see time slots, quickly identify free or occupied slots, and tap on a slot to view or edit a lesson. If you want to add a lesson in an empty slot, you can enable a button or gesture for that, or rely on “Add Lesson” in Today’s Schedule. 
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    // Term Overview & Recurring Lessons
                    Section {
                        Text("Term Overview & Advanced Patterns")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
- The Term Overview lets you define start and end dates for each academic term (e.g., “Highsted, Term 1,” etc.). You can filter by school and see how many lessons/students are in each term.
- If you need more advanced scheduling — for example, different day/time each week of the month — you can set up multi-week cycles using Advanced Patterns. This creates recurring lessons that change each week (rather than the simple “repeat weekly” toggle).
- Recurring lessons automatically generate future lessons based on the pattern you define. This is especially helpful if you rotate days/times each month for a specific school.
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    // Reports & Statistics
                    Section {
                        Text("Reports & Statistics")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
View “Reports & Statistics” to get insights into your teaching schedule. For example:
- Total lessons taught in the last X days.
- Unique students, no-shows, cancellations.
- More advanced metrics can be added in future updates.
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    // General Tips
                    Section {
                        Text("General Tips")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
- Always check your available time slots before adding a lesson to avoid conflicts.
- Update your Daily Availability if your schedule changes.
- Use notes to track each student’s progress, goals, and upcoming exams.
- Use “Add Student” first to create student records, then schedule lessons referencing those records.
- Set up Terms (start/end dates) so the app knows how far to generate new lessons.
- For advanced monthly rotations at Highsted or Borden, define multi-week cycles in Advanced Patterns. This saves time if each month’s schedule changes weekly.
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    // Detailed Usage Flow
                    Section {
                        Text("How to Use the App (Step-by-Step)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)

                        Text("""
1. **Add Student**: Go to the dashboard, tap “Add Student,” enter their name, plus optional parent/guardian details and contact info.
2. **Create Lessons**: 
   - Option A: “Today’s Schedule” → pick a date → “Add Lesson” for that date/time.
   - Option B: “Weekly Planner” → (if available) tap an empty slot or press an “Add Lesson” button. 
   - Option C: Use advanced patterns in “Term Overview” or “AdvancedPatterns” if you want an automatically rotating schedule.
3. **Edit & Reschedule**: Tap any lesson in the Weekly Planner or Today’s Schedule to edit, reschedule, or mark it as a no-show/cancellation.
4. **Manage Terms**: Under “Term Overview,” set start/end dates for each school (Highsted, Borden, etc.) and see how many lessons fall in each term.
5. **View Reports**: In “Reports & Statistics,” get an overview of how many lessons you’ve taught in a given period, plus no-shows and cancellations.
6. **Advanced Patterns**: For monthly rotations or more complex scheduling (e.g., each week a different day/time), set up multi-week cycles that auto-generate lessons. 
""")
                            .font(.body)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }

                    Spacer().frame(height: 50)
                }
                .padding(.bottom, 20)
            }
        }
        .environment(\.colorScheme, .light)
        .navigationTitle("Help & Tips")
        .navigationBarTitleDisplayMode(.inline)
    }
}

