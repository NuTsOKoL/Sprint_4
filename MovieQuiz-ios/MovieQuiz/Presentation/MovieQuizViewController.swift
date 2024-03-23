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
    private var alertPresenter: AlertProtocol?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol?
    
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        alertPresenter = AlertPresenter()
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
    //MARK: - yes/no button action
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
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/ \(questionAmount)")
    }
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypRed.cgColor : UIColor.ypGreen.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
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
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз") { [weak self] in
                    guard self != nil else {return}
                }
            //            show(alertModel: alertModel)
            noButton.isEnabled = true
            yesButton.isEnabled = true
        } else {
            currentQuestionIndex += 1
            
            imageView.layer.borderColor = UIColor.clear.cgColor
            noButton.isEnabled = true
            yesButton.isEnabled = true
            questionFactory?.requestNextQuestion()
        }
       
    }
    
    
    //    func show(quiz result: AlertModel) {
    //        let alert = UIAlertController(
    //            title: result.title,
    //            message: result.buttonText,
    //            preferredStyle: .alert)
    //
    //
    //        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
    //            guard let self = self else { return }
    //
    //            self.currentQuestionIndex = 0
    //            self.correctAnswers = 0
    //            self.imageView.layer.borderColor = UIColor.clear.cgColor
    //            self.questionFactory?.requestNextQuestion()
    //
    //            alert.addAction(action)
    //            self.present(alert, animated: true, completion: nil)
    //        }
    //    }
}
