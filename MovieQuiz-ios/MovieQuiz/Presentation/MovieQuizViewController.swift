import UIKit

final class MovieQuizViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theGodfather: () = show(quiz: QuizStepViewModel(
            image: .theGodfather,
            question: "Рейтинг этого фильма больше чем 6?",
            questNumber: "1/10"))
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
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
    
//    счетчик правильных ответов
    private var correctAnswers = 0
    
//    let currentQuestion = questions[currentQuestionIndex]

    
    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questNumber: String
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questNumber: "\(currentQuestionIndex + 1)/ \(questions.count)")
        return questionStep
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questNumber
    }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionResults()
        }
    }
    private func showNextQuestionResults() {
        if currentQuestionIndex == questions.count - 1 {
        let text = "Ваш реузльтат  \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
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
            self.correctAnswer = 0
            
            let firstQustion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQustion)
            self.show(quiz: viewModel)
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
