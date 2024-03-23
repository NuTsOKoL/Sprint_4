import UIKit

final class StatisticServiceImplementation: StatisticServiceProtocol {

//не понятно(требует инициализации)
    var totalAccurace: Double = 0.0

    var gameCount: Int = 0
    
    
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
            guard total != 0 else {
                return 0
            }
        return Double(correct) / Double(total) * 100
        
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord? {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private var date = Date()
    
    private var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    private var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
        
    }
    
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct: Int, total: Int) {
        gamesCount += 1
        self.total = self.total + total
        self.correct = self.correct + correct
        if let best = bestGame, best < GameRecord(correct: correct, total: total, date: date) {
            self.bestGame = GameRecord(correct: correct, total: total, date: date)
        } else {
            self.bestGame = bestGame ?? GameRecord(correct: 0, total: 0, date: Date())
        }
    }
}
