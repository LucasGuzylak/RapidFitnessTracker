//
//  ExerciseViewModel.swift
//  FitnessApp
//
//  Created by Lucas Guzylak on 6/29/25.
//

import Foundation
import Combine

class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    
    struct ExercisesResponse: Codable {
        let exercises: [RawExercise]
    }
    
    func fetchExercises() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("exercises.json not found in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(ExercisesResponse.self, from: data)
            DispatchQueue.main.async {
                self.exercises = response.exercises.map {
                    Exercise(
                        name: $0.name,
                        type: $0.type ?? "unknown",
                        muscle: $0.muscle ?? "unknown",
                        equipment: $0.equipment ?? [],
                        difficulty: $0.difficulty ?? "unknown"
                    )
                }
                print("Loaded \(self.exercises.count) exercises")
            }
        } catch {
            print("Failed to decode exercises.json:", error)
        }
    }
}
