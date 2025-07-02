//
//  ContentView.swift
//  FitnessApp
//
//  Created by Lucas Guzylak on 6/6/25.
//

import SwiftUI

enum Route : Hashable {
    case LogWorkout
    case searchWorkout
}

struct WorkoutButton: View {
    var title: String
    var icon: String
    @State private var isExpanded = false
    @State private var textInput = ""
    @State private var repsInput = ""
    @State private var weightInput = ""
    @State private var wasPressed = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .font(.title)
                    Text(title)
                        .font(.headline)
                }
                .foregroundColor(.red)
                .padding()
                .frame(width: 380, height: 100)
                .background(Color.black)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 2))
            }
            
            if isExpanded {
                HStack {
                    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 15) {
                        GridRow {
                            Text("Reps:")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .gridColumnAlignment(.leading)
                            if (wasPressed && (repsInput.isEmpty)) {
                                TextField("Please enter number of reps", text: $repsInput)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                    .keyboardType(.numberPad)
                                    .onChange(of: repsInput) {
                                        repsInput = repsInput.filter { $0.isNumber }
                                    }
                            }
                            else {
                                TextField("Enter", text: $repsInput)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                    .keyboardType(.numberPad)
                                    .onChange(of: repsInput) {
                                        repsInput = repsInput.filter { $0.isNumber }
                                    }
                            }
                        }
                        
                        
                        GridRow {
                            Text("Weight:")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .gridColumnAlignment(.leading)
                            if (wasPressed && (weightInput.isEmpty)) {
                                TextField("Please enter a weight", text: $weightInput)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                    .keyboardType(.numberPad)
                                    .onChange(of: weightInput) {
                                        weightInput = weightInput.filter { $0.isNumber }
                                    }
                            }
                            else {
                                TextField("Enter", text: $weightInput)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                    .keyboardType(.numberPad)
                                    .onChange(of: weightInput) {
                                        weightInput = weightInput.filter { $0.isNumber }
                                    }
                            }
                        }
                    }

                    
                    Spacer()
                    
                    Button(action: { withAnimation(.bouncy) {
                        wasPressed = true
                    }
                    }) {
                        Image(systemName: wasPressed && (repsInput.isEmpty || weightInput.isEmpty) ? "x.circle" : "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .id((wasPressed && (repsInput.isEmpty || weightInput.isEmpty)) ? "x" : "plus")
                    }
                }
                .animation(.bouncy, value: repsInput.isEmpty || weightInput.isEmpty)
                .padding(.horizontal, 10)
                .frame(width: 380, height: 150)
                .background(Color.black)
                .cornerRadius(5)
                .transition(.scale.combined(with: .opacity))
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(.red), lineWidth: 2))

            }
        }
    }
}

struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(.darkGray).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Hello,")
                        .font(.largeTitle)
                    
                    Text("Welcome to Rapid")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    NavigationLink(value: Route.LogWorkout) {
                        Text("Log a workout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {}) {
                        Text("Past workouts")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                }
                .padding()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .LogWorkout:
                    LogWorkout(path: $path)
                case .searchWorkout:
                    SearchWorkout()
                }
            }
        }
    }
}

struct LogWorkout: View {
    @State private var count = 0
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Color(.black).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Current Workouts: \(count)")
                    .font(.system(size: 25, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
                
                
                Spacer()
                
                Button(action: {
                    count += 1
                    path.append(Route.searchWorkout)
                }) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 80))
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.red)
                .tint(.black)
                
                }
            .padding()
        }
    }
}

struct SearchWorkout: View {
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var searchTerm = ""
    
    var filteredExercises: [Exercise] {
        let filtered = searchTerm.isEmpty
            ? viewModel.exercises
            : viewModel.exercises.filter {
                $0.name.localizedCaseInsensitiveContains(searchTerm)
            }
        return filtered.sorted { $0.name.count < $1.name.count }
    }
    
    var body: some View {
        VStack {
            if filteredExercises.isEmpty {
                Text("No matching workouts found")
                    .foregroundColor(.gray)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .background(Color.black.ignoresSafeArea())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredExercises) { exercise in
                            WorkoutButton(title: exercise.name, icon: "dumbbell")
                                .background(Color.black)
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
        .searchable(text: $searchTerm, prompt: "Search for a workout")
        .background(Color.black.ignoresSafeArea())
        .onAppear() {
            viewModel.fetchExercises()
        }
        .navigationTitle("Search Workout")
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.red, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}


#Preview {
//    ContentView()
    LogWorkout(path: .constant(NavigationPath()))
//    NavigationStack {
//        SearchWorkout()
//    }
}
