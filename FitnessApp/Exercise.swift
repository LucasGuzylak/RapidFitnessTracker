//
//  Exercise.swift
//  FitnessApp
//
//  Created by Lucas Guzylak on 6/29/25.
//

import Foundation

struct Exercise: Identifiable {
    let id: UUID
    let name: String
    let type: String
    let muscle: String
    let equipment: [String]
    let difficulty: String

    init(
        id: UUID = UUID(),
        name: String,
        type: String = "unknown",
        muscle: String = "unknown",
        equipment: [String] = [],
        difficulty: String = "unknown"
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.muscle = muscle
        self.equipment = equipment
        self.difficulty = difficulty
    }
}

struct RawExercise: Codable {
    let name: String
    let type: String?
    let muscle: String?
    let equipment: [String]?
    let difficulty: String?
}

