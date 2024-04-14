//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Дмитрий Калько on 29.09.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult()
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func noImageBorder()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func enebleButtons()
    func disableButtons()
    
    func showNetworkError(message: String)
}
