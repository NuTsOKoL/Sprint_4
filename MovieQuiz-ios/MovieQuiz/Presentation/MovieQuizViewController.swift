import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
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
    
    
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private let questionAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    
    // MARK: - QuestionFactoryDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
//        if let firstQuestion = questionFactory.requestNextQuestion() {
//            currentQuestion = firstQuestion
//            let viewModel = convert(model: firstQuestion)
//            show(quiz: viewModel)
//        }
//    меняем на:
        questionFactory.requestNextQuestion()
        
        //        let _: () = show(quiz: QuizStepViewModel(
        //            image: .theGodfather,
        //            question: "Рейтинг этого фильма больше чем 6?",
        //            questionNumber: "1/10"))
        //    }
    }
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        //        была переменная questionStep =
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/ \(questionAmount)")
        //        return questionStep
    }
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            //            guard let question = question else {
            //                return
            //            }
            
            //            currentQuestion = question
            //            let viewModel = convert(model: question)
            //            DispatchQueue.main.async { [weak self] in
            //                self?.show(quiz: viewModel)
            //            }
//        }
        //        у меня было, но по заданию убрали (и сверху та же функция)
//            if let firstQuestion = self.questionFactory.requestNextQuestion() {
//                            self.currentQuestion = firstQuestion
//                            let viewModel = self.convert(model: firstQuestion)
//                            self.show(quiz: viewModel)
//            }
            questionFactory?.requestNextQuestion()
    }
}
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            let text = correctAnswers == questionAmount ?
            "Поздравялем вы ответили на 10 из 10!" :
            "Вы ответили на  \(correctAnswers) из 10, попробуйте еще раз!"
            //выше по текучке задания
            //            let text = "Ваш реузльтат:  \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
            noButton.isEnabled = true
            yesButton.isEnabled = true
        } else {
            currentQuestionIndex += 1
            
            imageView.layer.borderColor = UIColor.clear.cgColor
            noButton.isEnabled = true
            yesButton.isEnabled = true
//            if let nextQuestion = questionFactory.requestNextQuestion() {
//                currentQuestion = nextQuestion
//                let viewModel = convert(model: nextQuestion)
//                
//                
//                show(quiz: viewModel)
//            }
            questionFactory?.requestNextQuestion()

        }
    }
    
    
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            
//            if  let firstQustion = self.questionFactory.requestNextQuestion() {
//                self.currentQuestion = firstQustion
//                let viewModel = self.convert(model: firstQustion)
//                
//                self.show(quiz: viewModel)
//            }
            self.questionFactory?.requestNextQuestion()

            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
