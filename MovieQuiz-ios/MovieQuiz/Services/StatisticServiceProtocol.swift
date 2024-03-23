import UIKit

protocol StatisticServiceProtocol {
    var totalAccurace: Double { get }
    var gameCount: Int { get }
    var bestGame: GameRecord? { get }
    
    func store(correct count: Int, total: Int)
}
