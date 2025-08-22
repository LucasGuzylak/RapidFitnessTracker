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
    
    struct RawExercise: Codable {
        let name: String
        let category: String?
        let primary_muscles: [String]?
        let equipment: [String]?
        let difficulty: String?
        let instructions: [String]?
        let variation_on: [String]?
        let video: String?
        let description: String?
        let license: License?
        let license_author: String?
        let secondary_muscles: [String]?
        let variation_id: Int?
    }
    
    struct License: Codable {
        let full_name: String?
        let short_name: String?
        let url: String?
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
                        type: $0.category ?? "unknown",
                        muscle: $0.primary_muscles?.first ?? "unknown",
                        equipment: $0.equipment ?? [],
                        difficulty: $0.difficulty ?? "unknown"
                    )
                }

            }
        } catch {
            print("Failed to decode exercises.json:", error)
            print("Error details:", error.localizedDescription)
        }
    }
}
