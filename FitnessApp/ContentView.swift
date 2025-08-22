//
//  ContentView.swift
//  FitnessApp
//
//  Created by Lucas Guzylak on 6/6/25.
//

import SwiftUI

// MARK: - Theme System
enum AppTheme: String, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    
    var backgroundColor: Color {
        switch self {
        case .dark:
            return .black
        case .light:
            return .white
        }
    }
    
    var textColor: Color {
        switch self {
        case .dark:
            return .white
        case .light:
            return .black
        }
    }
    
    var secondaryTextColor: Color {
        switch self {
        case .dark:
            return .gray
        case .light:
            return .gray
        }
    }
    
    var accentColor: Color {
        return .red
    }
    
    var cardBackgroundColor: Color {
        switch self {
        case .dark:
            return .black.opacity(0.6)
        case .light:
            return .white
        }
    }
    
    var cardBorderColor: Color {
        switch self {
        case .dark:
            return .red.opacity(0.3)
        case .light:
            return .black.opacity(0.3)
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.dark.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .dark
    }
}

enum Route : Hashable, Equatable {
    case LogWorkout
    case PastWorkouts
    case searchWorkout
    case FinishedWorkout(entries: [WorkoutEntry], elapsedMinutes: Int)
    case favorites
    
}

struct WorkoutEntry: Codable, Equatable, Hashable {
    var name: String
    var weight: String
    var reps: String
}

struct LogButton: View {
    var name: String
    var reps: String
    var weight: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.red)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text("\(weight) x \(reps) reps")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(width: 380, height: 80, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black)
        .cornerRadius(5)
        .overlay(RoundedRectangle(cornerRadius: 5)
            .stroke(Color.red, lineWidth: 4))
        .padding(.bottom, 10)
    }
}

struct WeightInputView: View {
    @Binding var weightInput: String
    @Binding var unit: String
    @Binding var wasPressed: Bool
    var repsInput: String
    var onAdd: () -> Void
    
    var body: some View {
        HStack {
            TextField(wasPressed && weightInput.isEmpty ? "Please enter a weight" : "Enter", text: $weightInput)
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(5)
                .keyboardType(.numberPad)
                .onChange(of: weightInput) {
                    weightInput = String(weightInput.filter { $0.isNumber }.prefix(5))
                }
            Menu(unit) {
                Button("lbs") { unit = "lbs" }
                Button("kgs") { unit = "kgs" }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.3))
            .cornerRadius(6)
        }
    }
}

struct WorkoutButton: View {
    var title: String
    var icon: String
    var onAdd: (String, String) -> Void
    var isExpanded: Bool
    var onToggle: () -> Void
    var isFavorite: Bool
    var onToggleFavorite: () -> Void
    @ObservedObject var themeManager: ThemeManager
    @State private var textInput = ""
    @State private var repsInput = ""
    @State private var weightInput = ""
    @State private var wasPressed = false
    @State private var unit = "lbs"
    
    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                withAnimation(.spring()) {
                    onToggle()
                }
            }) {
                HStack {
                    HStack {
                        Image(systemName: icon)
                            .font(.title)
                        Text(title)
                            .font(.headline)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                        Spacer()
                    
                        Button(action: onToggleFavorite) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                        }
                        .buttonStyle(PlainButtonStyle())
                    .foregroundColor(isFavorite ? .yellow : themeManager.currentTheme.accentColor)
                    .font(.title2)
                }
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding()
                .frame(width: 380, height: 100)
                .background(themeManager.currentTheme.cardBackgroundColor)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(themeManager.currentTheme == .light ? .black : themeManager.currentTheme.accentColor, lineWidth: 2))
            }
            
            if isExpanded {
                VStack(spacing: 16) {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack(alignment: .leading) {
                                if repsInput.isEmpty {
                                    Text(wasPressed ? "Please Enter Reps" : "Enter Reps")
                                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.4))
                                        .padding(.leading, 14)
                                }
                                TextField("", text: $repsInput)
                                    .padding(10)
                                    .background(themeManager.currentTheme.secondaryTextColor.opacity(0.2))
                                    .foregroundColor(themeManager.currentTheme.textColor)
                                    .cornerRadius(8)
                                    .keyboardType(.numberPad)
                                    .onChange(of: repsInput) {
                                        repsInput = String(repsInput.filter { $0.isNumber }.prefix(5))
                                    }
                            }
                        }
                        
                        HStack(spacing: 12) {
                            ZStack(alignment: .leading) {
                                if weightInput.isEmpty {
                                    Text(wasPressed ? "Please Enter Weight" : "Enter Weight")
                                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.4))
                                        .padding(.leading, 14)
                                }
                                TextField("", text: $weightInput)
                                    .padding(10)
                                    .background(themeManager.currentTheme.secondaryTextColor.opacity(0.2))
                                    .foregroundColor(themeManager.currentTheme.textColor)
                                    .cornerRadius(8)
                                    .keyboardType(.numberPad)
                                    .onChange(of: weightInput) {
                                        weightInput = String(weightInput.filter { $0.isNumber }.prefix(5))
                                    }
                            }
                            
                            Menu(unit) {
                                Button("lbs") { unit = "lbs" }
                                Button("kgs") { unit = "kgs" }
                            }
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(themeManager.currentTheme.accentColor.opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                    
                    Button(action: {
                        wasPressed = true
                        if !repsInput.isEmpty && !weightInput.isEmpty {
                            onAdd(repsInput, "\(weightInput) \(unit)")
                            repsInput = ""
                            weightInput = ""
                            withAnimation(.spring()) {
                                onToggle()
                            }
                            wasPressed = false
                        } // else: warning state is triggered by wasPressed
                    }) {
                        HStack {
                            Image(systemName: wasPressed && (repsInput.isEmpty || weightInput.isEmpty) ? "exclamationmark.triangle" : "plus.circle")
                                .font(.system(size: 20))
                            Text(wasPressed && (repsInput.isEmpty || weightInput.isEmpty) ? "Please Fill Both Fields" : "Add Workout")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(wasPressed && (repsInput.isEmpty || weightInput.isEmpty) ? Color.orange : themeManager.currentTheme.accentColor)
                        .cornerRadius(8)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.top, 12)
                .frame(height: 180)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .animation(.bouncy, value: repsInput.isEmpty || weightInput.isEmpty)
        .padding(.horizontal, 10)
        .frame(width: 380)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .cornerRadius(5)
        .transition(.scale.combined(with: .opacity))
        .overlay(RoundedRectangle(cornerRadius: 5)
            .stroke(themeManager.currentTheme == .light ? .black : themeManager.currentTheme.accentColor, lineWidth: 2))
        
    }
}

// MARK: - PastWorkout Model and Store
struct PastWorkout: Codable, Equatable, Hashable, Identifiable {
    let id: UUID
    let startTime: Date
    let entries: [WorkoutEntry]
    let elapsedMinutes: Int
    
    var endTime: Date {
        return startTime.addingTimeInterval(TimeInterval(elapsedMinutes * 60))
    }
    
    init(startTime: Date, entries: [WorkoutEntry], elapsedMinutes: Int) {
        self.id = UUID()
        self.startTime = startTime
        self.entries = entries
        self.elapsedMinutes = elapsedMinutes
    }
}

class PastWorkoutStore: ObservableObject {
    @Published var pastWorkouts: [PastWorkout] = []
    private let key = "pastWorkouts"
    
    init() {
        load()
    }
    
    func add(_ workout: PastWorkout) {
        pastWorkouts.insert(workout, at: 0)
        save()
    }
    
    func delete(_ workout: PastWorkout) {
        pastWorkouts.removeAll { $0.id == workout.id }
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(pastWorkouts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([PastWorkout].self, from: data) {
            pastWorkouts = decoded
        }
    }
}

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var entries: [WorkoutEntry] = []
    @StateObject private var pastWorkoutStore = PastWorkoutStore()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                (themeManager.currentTheme == .dark ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    // Theme Toggle Button
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.currentTheme = themeManager.currentTheme == .dark ? .light : .dark
                            }
                        }) {
                            Image(systemName: themeManager.currentTheme == .dark ? "moon.fill" : "sun.max.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.currentTheme.accentColor)
                                .padding(12)
                                .background(themeManager.currentTheme.cardBackgroundColor)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(themeManager.currentTheme == .light ? .black : themeManager.currentTheme.accentColor, lineWidth: 2)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    
                    ZStack {
                        // Glow effect
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 50))
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .blur(radius: 8)
                            .opacity(0.6)
                        
                        // Main bolt
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .shadow(color: themeManager.currentTheme.accentColor, radius: 10, x: 0, y: 0)
                    }
                    .padding(.bottom, 20)
                    Text("Welcome to Rapid")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .padding(.bottom, 50)
                    NavigationLink(value: Route.LogWorkout) {
                        HStack{
                            Text("Log a workout")
                            Image(systemName: "plus")
                        }
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .padding()
                            .frame(width: 300, height: 80)
                            .background(themeManager.currentTheme.cardBackgroundColor)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(themeManager.currentTheme == .light ? .black : themeManager.currentTheme.accentColor, lineWidth: 2)
                            )
                            .padding(.bottom, 30)
                    }
                    NavigationLink(value: Route.PastWorkouts) {
                        HStack {
                            Text("Past workouts")
                            Image(systemName: "clock")
                        }
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .padding()
                            .frame(width: 300, height: 80)
                            .background(themeManager.currentTheme.cardBackgroundColor)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(themeManager.currentTheme == .light ? .black : themeManager.currentTheme.accentColor, lineWidth: 2)
                            )
                            .padding(.bottom, 30)
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Progression")
                            Image(systemName: "chart.line.uptrend.xyaxis")
                        }
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .padding()
                            .frame(width: 300, height: 80)
                            .background(themeManager.currentTheme.cardBackgroundColor)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(themeManager.currentTheme == .light ? .black : themeManager.currentTheme.accentColor, lineWidth: 2)
                            )
                    }
                }
                .padding()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .LogWorkout:
                    LogWorkout(path: $path, entries: $entries, pastWorkoutStore: pastWorkoutStore, themeManager: themeManager)
                case .PastWorkouts:
                    PastWorkouts(path: $path, entries: $entries, pastWorkoutStore: pastWorkoutStore, themeManager: themeManager)
                case .searchWorkout:
                    SearchWorkout(entries: $entries, themeManager: themeManager)
                case .FinishedWorkout(let entries, let elapsedMinutes):
                    FinishedWorkout(path: $path, entries: entries, elapsedMinutes: elapsedMinutes, pastWorkoutStore: pastWorkoutStore, themeManager: themeManager)
                        .onAppear {
                            self.entries = []
                        }
                case .favorites:
                    SearchWorkout(entries: $entries, themeManager: themeManager)
                }
            }
        }
    }
}

struct LogWorkout: View {
    @Binding var path: NavigationPath
    @State private var showAlert = false
    @Binding var entries: [WorkoutEntry]
    @State private var showingDeleteAlert = false
    @State private var indexToDelete: Int?
    @State private var workoutStartTime = Date()
    let pastWorkoutStore: PastWorkoutStore
    @ObservedObject var themeManager: ThemeManager
    
    var count: Int {
        entries.count
    }
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor
                .ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    HStack {
                        Text("WORKOUT LOG")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .tracking(2)
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(themeManager.currentTheme.accentColor)
                                .frame(width: 40, height: 40)
                            Text("\(count)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.currentTheme.textColor)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                if entries.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 80))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .opacity(0.5)
                        Text("No exercises yet")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        Text("Tap the + button to add your first exercise")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                ScrollView {
                        LazyVStack(spacing: 12) {
                    ForEach(entries.indices, id: \.self) { i in
                        let entry = entries[i]
                                ModernLogButton(
                                    name: entry.name,
                                    reps: entry.reps,
                                    weight: entry.weight,
                                    index: i,
                                    onDelete: {
                                        indexToDelete = i
                                        showingDeleteAlert = true
                                    },
                                    themeManager: themeManager
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                HStack(spacing: 30) {
                    Button(action: {
                        if !entries.isEmpty {
                        showAlert = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text("FINISH")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tracking(1)
                        }
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .frame(width: 140, height: 50)
                        .background(
                            entries.isEmpty ? themeManager.currentTheme.secondaryTextColor.opacity(0.3) : Color.green
                        )
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(themeManager.currentTheme == .light ? .black.opacity(0.3) : themeManager.currentTheme.textColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(entries.isEmpty)
                    Button(action: {
                        path.append(Route.searchWorkout)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("ADD")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tracking(1)
                        }
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .frame(width: 140, height: 50)
                        .background(themeManager.currentTheme.accentColor)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(themeManager.currentTheme == .light ? .black.opacity(0.3) : themeManager.currentTheme.textColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
                }
                .alert("Finish your workout?", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Finish", role: .destructive) {
                let elapsedTime = Date().timeIntervalSince(workoutStartTime)
                let elapsedMinutes = Int(elapsedTime / 60)
                
                // Save workout to past workouts
                let pastWorkout = PastWorkout(startTime: workoutStartTime, entries: entries, elapsedMinutes: elapsedMinutes)
                pastWorkoutStore.add(pastWorkout)
                
                path.append(Route.FinishedWorkout(entries: entries, elapsedMinutes: elapsedMinutes))
            }
        } message: {
            Text("Are you sure you want to finish this workout?")
        }
        .alert("Remove Exercise", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let index = indexToDelete {
                    entries.remove(at: index)
                }
            }
        } message: {
            Text("Are you sure you want to remove this exercise from your workout?")
        }
    }
}

// Modern log button component
struct ModernLogButton: View {
    let name: String
    let reps: String
    let weight: String
    let index: Int
    let onDelete: () -> Void
    @ObservedObject var themeManager: ThemeManager
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(themeManager.currentTheme.accentColor)
                    .frame(width: 35, height: 35)
                
                Text("\(index + 1)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.currentTheme.textColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .lineLimit(2)
                
                Text("\(weight) × \(reps) reps")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.currentTheme.accentColor.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(themeManager.currentTheme.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(themeManager.currentTheme == .light ? .black.opacity(0.3) : themeManager.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct FinishedWorkout: View {
    @Binding var path: NavigationPath
    let entries: [WorkoutEntry]
    let elapsedMinutes: Int
    let pastWorkoutStore: PastWorkoutStore
    @ObservedObject var themeManager: ThemeManager
    @State private var isShowingView = true
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.orange, Color.red, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 80))
                    .symbolEffect(.bounce)
                    .shadow(color: .yellow, radius: 10)
                Text("Great Job!")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 3)
                Text("Workout Complete!")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black, radius: 2)
                
                // Stats section
                VStack(spacing: 15) {
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(entries.count)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Exercises")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        VStack {
                            Text("\(elapsedMinutes)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Minutes")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                path = NavigationPath()
            }
        }
    }
}

struct SearchWorkout: View {
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var searchTerm = ""
    @State private var expandedExerciseId: UUID? = nil
    @State private var selectedTab = 0
    @State private var favoriteExercises: Set<String> = []
    @Binding var entries: [WorkoutEntry]
    @ObservedObject var themeManager: ThemeManager
    
    init(entries: Binding<[WorkoutEntry]>, themeManager: ThemeManager) {
        self._entries = entries
        self.themeManager = themeManager
        let savedFavorites = UserDefaults.standard.stringArray(forKey: "favoriteExercises") ?? []
        self._favoriteExercises = State(initialValue: Set(savedFavorites))
    }
    
    private let popularExercises = [
        "Barbell Bench Press",
        "Barbell Squat",
        "Deadlift",
        "Pull-Up",
        "Push-Up",
        "Dumbbell Bicep Curl",
        "Barbell Deadlift",
        "Barbell Curl",
        "Overhead Press",
        "Dumbbell Shoulder Press",
        "Dumbbell Bench Press",
        "Dumbbell Fly",
        "Lat Pulldown",
        "Cable Triceps Pushdown",
        "Barbell Row",
        "Dumbbell Row",
        "Seated Cable Row",
        "Leg Press",
        "Tricep Dips",
        "Plank",
        "Barbell Incline Bench Press",
        "Cable Crossover",
        "Dumbbell Lateral Raise",
        "Incline Dumbbell Press",
        "Leg Curl",
        "Leg Extension",
        "Hammer Curl",
        "Concentration Curl",
        "Cable Lat Pulldown",
        "Barbell Shrug",
        "Dumbbell Shrug",
        "Bulgarian Split Squat",
        "Dumbbell Incline Fly",
        "Calf Raise",
        "Cable Rope Face Pull",
        "Bent-Over Row",
        "Dumbbell Triceps Kickback",
        "Reverse Fly",
        "Lying Leg Curl",
        "Dumbbell Chest Press",
        "Arnold Press",
        "Chest Dip",
        "Front Squat",
        "Machine Chest Press",
        "Incline Barbell Bench Press",
        "Machine Shoulder Press",
        "Dumbbell Front Raise",
        "Close-Grip Bench Press",
        "Lateral Raise Machine",
        "Smith Machine Squat"
    ]
    
    var filteredExercises: [Exercise] {
        let filtered = searchTerm.isEmpty
            ? viewModel.exercises
            : viewModel.exercises.filter {
                $0.name.localizedCaseInsensitiveContains(searchTerm)
            }
        let filteredByLength = filtered.filter { exercise in
            exercise.name.count <= 35
        }
        
        return filteredByLength.sorted { exercise1, exercise2 in
            let exercise1IsPopular = popularExercises.contains(exercise1.name)
            let exercise2IsPopular = popularExercises.contains(exercise2.name)
            
            if exercise1IsPopular && !exercise2IsPopular {
                return true
            }
            if !exercise1IsPopular && exercise2IsPopular {
                return false
            }
            return exercise1.name < exercise2.name
        }
    }
    var favoriteExercisesList: [Exercise] {
        return viewModel.exercises.filter { favoriteExercises.contains($0.name) }
    }
    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .foregroundColor(selectedTab == 0 ? themeManager.currentTheme.textColor : themeManager.currentTheme.secondaryTextColor)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedTab == 0 ? themeManager.currentTheme.accentColor : Color.clear)
                }
                
                Button(action: { selectedTab = 1 }) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Favorites")
                    }
                    .foregroundColor(selectedTab == 1 ? themeManager.currentTheme.textColor : themeManager.currentTheme.secondaryTextColor)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedTab == 1 ? themeManager.currentTheme.accentColor : Color.clear)
                }
            }
            .background(themeManager.currentTheme.backgroundColor)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 10)
            
            if selectedTab == 0 {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeManager.currentTheme.textColor)
                    ZStack(alignment: .leading) {
                        if searchTerm.isEmpty {
                            Text("Search for a workout")
                                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                        }
                        TextField("", text: $searchTerm)
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                }
                .padding()
                .background(themeManager.currentTheme.backgroundColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(themeManager.currentTheme == .light ? .black : themeManager.currentTheme.accentColor, lineWidth: 2)
                )
                .padding(.horizontal)
                .padding(.top, 10)
            }
            
            if selectedTab == 0 {
                if filteredExercises.isEmpty {
                    Text("No matching workouts found")
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredExercises) { exercise in
                                WorkoutButton(
                                    title: exercise.name, 
                                    icon: "dumbbell",
                                    onAdd: { reps, weight in
                                        entries.append(WorkoutEntry(name: exercise.name, weight: weight, reps: reps))
                                    },
                                    isExpanded: expandedExerciseId == exercise.id,
                                    onToggle: {
                                        if expandedExerciseId == exercise.id {
                                            expandedExerciseId = nil
                                        } else {
                                            expandedExerciseId = exercise.id
                                        }
                                    },
                                    isFavorite: favoriteExercises.contains(exercise.name),
                                    onToggleFavorite: {
                                        if favoriteExercises.contains(exercise.name) {
                                            favoriteExercises.remove(exercise.name)
                                        } else {
                                            favoriteExercises.insert(exercise.name)
                                        }
                                        // Save to UserDefaults
                                        UserDefaults.standard.set(Array(favoriteExercises), forKey: "favoriteExercises")
                                    },
                                    themeManager: themeManager
                                )
                                .background(themeManager.currentTheme.backgroundColor)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            } else {
                if favoriteExercisesList.isEmpty {
                    VStack {
                        Image(systemName: "star")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .padding(.bottom, 20)
                        Text("No favorites yet")
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .font(.title2)
                        Text("Tap the star on any exercise to add it to favorites")
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor.opacity(0.7))
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(favoriteExercisesList) { exercise in
                                WorkoutButton(
                                    title: exercise.name, 
                                    icon: "dumbbell",
                                    onAdd: { reps, weight in
                                        entries.append(WorkoutEntry(name: exercise.name, weight: weight, reps: reps))
                                    },
                                    isExpanded: expandedExerciseId == exercise.id,
                                    onToggle: {
                                        if expandedExerciseId == exercise.id {
                                            expandedExerciseId = nil
                                        } else {
                                            expandedExerciseId = exercise.id
                                        }
                                    },
                                    isFavorite: favoriteExercises.contains(exercise.name),
                                    onToggleFavorite: {
                                        if favoriteExercises.contains(exercise.name) {
                                            favoriteExercises.remove(exercise.name)
                                        } else {
                                            favoriteExercises.insert(exercise.name)
                                        }
                                        // Save to UserDefaults
                                        UserDefaults.standard.set(Array(favoriteExercises), forKey: "favoriteExercises")
                                    },
                                    themeManager: themeManager
                                )
                                .background(themeManager.currentTheme.backgroundColor)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .onAppear() {
            viewModel.fetchExercises()
        }
        .navigationTitle("Search Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.red, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct PastWorkouts: View {
    @Binding var path: NavigationPath
    @Binding var entries: [WorkoutEntry]
    @ObservedObject var pastWorkoutStore: PastWorkoutStore
    @ObservedObject var themeManager: ThemeManager
    @State private var expandedWorkoutId: UUID? = nil
    @State private var showingDeleteAlert = false
    @State private var workoutToDelete: PastWorkout? = nil
    
    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    VStack(spacing: 8) {
                        Text("WORKOUT HISTORY")
                            .font(.system(size: 25, weight: .black, design: .rounded))
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .tracking(2)
                        
                        Rectangle()
                            .fill(themeManager.currentTheme.accentColor)
                            .frame(width: 300, height: 4)
                            .cornerRadius(2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    if !pastWorkoutStore.pastWorkouts.isEmpty {
                        Text("Tap any workout to see details")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .padding(.bottom, 10)
                    }
                }
            
                if pastWorkoutStore.pastWorkouts.isEmpty {
                    // Empty state
                    VStack(spacing: 30) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(themeManager.currentTheme.accentColor.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 50))
                                .foregroundColor(themeManager.currentTheme.accentColor)
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Workouts Yet")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.currentTheme.textColor)
                            
                            Text("Complete your first workout to see it here")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                    // Workout list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(pastWorkoutStore.pastWorkouts) { workout in
                                VStack(alignment: .leading, spacing: 0) {
                                    // Main workout card
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            if expandedWorkoutId == workout.id {
                                                expandedWorkoutId = nil
                                            } else {
                                                expandedWorkoutId = workout.id
                                            }
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            // Date and time row
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(workout.startTime, style: .date)
                                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                                        .foregroundColor(themeManager.currentTheme.textColor)
                                                    
                                                    Text("\(workout.startTime, style: .time) - \(workout.endTime, style: .time)")
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                                }
                                                
                                                Spacer()
                                                
                                                // Stats badges
                                                HStack(spacing: 12) {
                                                    VStack(spacing: 2) {
                                                        Text("\(workout.entries.count)")
                                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                                            .foregroundColor(themeManager.currentTheme.accentColor)
                                                        Text("EXERCISES")
                                                            .font(.system(size: 8, weight: .bold, design: .rounded))
                                                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                                            .tracking(1)
                                                    }
                                                    
                                                    VStack(spacing: 2) {
                                                        Text("\(workout.elapsedMinutes)")
                                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                                            .foregroundColor(themeManager.currentTheme.accentColor)
                                                        Text("MINUTES")
                                                            .font(.system(size: 8, weight: .bold, design: .rounded))
                                                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                                            .tracking(1)
                                                    }
                                                }
                                            }
                                            
                                            // Expand indicator
                                            HStack {
                                                Spacer()
                                                                                            Image(systemName: expandedWorkoutId == workout.id ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                            }
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    // Expanded details
                                    if expandedWorkoutId == workout.id {
                                        VStack(alignment: .leading, spacing: 12) {
                                            // Divider
                                            Divider()
                                                .background(themeManager.currentTheme.secondaryTextColor.opacity(0.3))
                                            
                                            // Exercise details
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Exercises:")
                                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                    .foregroundColor(themeManager.currentTheme.textColor)
                                                
                                                ForEach(workout.entries, id: \.name) { entry in
                                                    HStack {
                                                        Text("• \(entry.name)")
                                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.9))
                                                        Spacer()
                                                        Text("\(entry.weight) × \(entry.reps) reps")
                                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                                            .foregroundColor(themeManager.currentTheme.accentColor)
                                                    }
                                                    .padding(.leading, 8)
                                                }
                                            }
                                            
                                            // Delete button
                                            Button(action: {
                                                workoutToDelete = workout
                                                showingDeleteAlert = true
                                            }) {
                                                HStack {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 14))
                                                    Text("Delete Workout")
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                }
                                                .foregroundColor(themeManager.currentTheme.accentColor)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(themeManager.currentTheme.accentColor.opacity(0.1))
                                                .cornerRadius(8)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 16)
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .top)),
                                            removal: .opacity.combined(with: .move(edge: .top))
                                        ))
                                    }
                                }
                                .background(themeManager.currentTheme.accentColor.opacity(0.15))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeManager.currentTheme == .light ? .black.opacity(0.3) : themeManager.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .alert("Delete Workout", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let workout = workoutToDelete {
                    pastWorkoutStore.delete(workout)
                }
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
    }
}


#Preview {
    ContentView()
}
