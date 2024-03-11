import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private struct QuizQuestion {
        let image: String
        let text: String = "Рейтинг этого фильма больше чем 6?"
        let correctAnswer: Bool
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",
                     correctAnswer: true),
        QuizQuestion(image: "The Dark Knight",
                     correctAnswer: true),
        QuizQuestion(image: "Kill Bill",
                     correctAnswer: true),
        QuizQuestion(image: "The Avengers",
                     correctAnswer: true),
        QuizQuestion(image: "Deadpool",
                     correctAnswer: true),
        QuizQuestion(image: "The Green Knight",
                     correctAnswer: true),
        QuizQuestion(image: "Old",
                     correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                     correctAnswer: false),
        QuizQuestion(image: "Tesla",
                     correctAnswer: false),
        QuizQuestion(image: "Vivarium",
                     correctAnswer: false)
    ]
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _: () = show(quiz: QuizStepViewModel(
            image: .theGodfather,
            question: "Рейтинг этого фильма больше чем 6?",
            questionNumber: "1/10"))
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/ \(questions.count)")
        return questionStep
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш реузльтат:  \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            imageView.layer.borderColor = UIColor.clear.cgColor
            noButton.isEnabled = true
            yesButton.isEnabled = true
            
            show(quiz: viewModel)
        }
    }
    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            
            let firstQustion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQustion)
            self.show(quiz: viewModel)
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
