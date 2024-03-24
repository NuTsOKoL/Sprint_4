import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private let questionAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol?
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    //MARK: - yes/no button
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = true
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else {return}
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = false
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else {return}
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            showResult()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showResult() {
        statisticService?.store(correct: correctAnswers, total: questionAmount)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: resultMessage(),
            buttonText: "Сыграть еще раз") { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func resultMessage() -> String {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            return ""
        }
        let totalPlayCount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResult = "Ваш результат: \(correctAnswers)/\(questionAmount) "
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let bestGameInfo = "Рекорд:  \(bestGame.correct)/10" + "(\(bestGame.date.dateTimeString)"
        let resultMessage = [currentGameResult, totalPlayCount, bestGameInfo,
                             averageAccuracy].joined(separator: "\n")
        return resultMessage
    }
}
