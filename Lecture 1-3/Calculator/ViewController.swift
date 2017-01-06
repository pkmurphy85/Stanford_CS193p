//
//  ViewController.swift
//  Calculator
//
//  Created by Patrick Murphy on 1/3/17.
//  Copyright © 2017 Patrick Murphy. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var history: UILabel!
    
    private var userIsInTheMiddleOfTyping = false {
        // propertey observer, sets floating point to false when typing goes false
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfFloatingPointNumber = false
            }
        }
    }
    
    private var userIsInTheMiddleOfFloatingPointNumber = false
    
    @IBAction private func touchDigit(sender: UIButton) {
        var digit = sender.currentTitle!
        
        if digit == "." {
            if userIsInTheMiddleOfFloatingPointNumber {
                return
            }
            if !userIsInTheMiddleOfTyping {
                digit = "0."
            }
            userIsInTheMiddleOfFloatingPointNumber = true
        }
            
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    // computed property, tracks display
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
            history.text = brain.description + (brain.isPartialResult ? "...":"=")
        }
    }
    
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        displayValue = brain.result
        display.text = "0"
        history.text = " "
    }
    
    @IBAction func setVariable(sender: UIButton) {
        let variableName = sender.currentTitle
        brain.setOperand(variableName)
    }
    
    @IBAction func setOperand(sender: UIButton) {
        let variable = sender.currentTitle
        brain.variableValues[variable] = Double(displayValue)
    }
    
    // every new class has one free initializer which is an initializer that takes no arguments. That is used here
    private var brain = CalculatorBrain()
    
    private var previousOp =  AnyObject?()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
    
}


