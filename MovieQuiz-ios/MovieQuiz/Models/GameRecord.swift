import UIKit

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ anotheer: GameRecord) -> Bool {
        correct > anotheer.correct
    }
}
