//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Patrick Murphy on 1/3/17.
//  Copyright © 2017 Patrick Murphy. All rights reserved.
//


// This is the model file. Never import UIKit into a model file as the model is UI indpendent

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()

    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        descriptionAccumulator = String(format: "%g", operand)
    }

    
    func setOperand(variableName: String) {
        accumulator = variableValues[variableName]!
        internalProgram.append(variableName)
        descriptionAccumulator = variableName
    }
    
    var variableValues =  [String:Double]()
    
    
    private var currentPrecedence = Int.max
    
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        
        "±": Operation.UnaryOperation({ -$0 }, { "-(" + $0 + ")"}), // change sign
        "√": Operation.UnaryOperation(sqrt, {"√(" + $0 + ")"}),
        "cos": Operation.UnaryOperation(cos, {"cos(" + $0 + ")"}),
        "sin": Operation.UnaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan": Operation.UnaryOperation(tan, {"tan(" + $0 + ")"}),
        "x²": Operation.UnaryOperation({pow($0, 2)}, {"(" + $0 + ")²"}),
        "x³": Operation.UnaryOperation({pow($0, 3)}, {"(" + $0 + ")³"}),
        "log₁₀": Operation.UnaryOperation({log10($0)}, {"log₁₀(" + $0 + ")"}),
        "ln": Operation.UnaryOperation({log(($0))}, {"ln(" + $0 + ")"}),
        
        "×": Operation.BinaryOperation({ $0 * $1 }, {$0 + "×" + $1}, 1), //closure, basically an inline function. $0 is first argument, $1 second etc.
        "÷": Operation.BinaryOperation({ $0 / $1 }, {$0 + "÷" + $1}, 1),
        "+": Operation.BinaryOperation({ $0 + $1 }, {$0 + "+" + $1}, 0),
        "−": Operation.BinaryOperation({ $0 - $1 }, {$0 + "−" + $1}, 0),
        "=": Operation.Equals
    ]
    
    private enum Operation {
        // associated values. Double associated with Constant
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double,Double) -> Double, (String, String) -> String, Int)
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let  operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation (let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals: executePendingBinaryOperation()
            }
        }
    }
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    // Lets you create a named type that is exatly the same as another type
    typealias PropertyList = AnyObject // PropertyList a type, exact same as AnyObject
    
    var program: PropertyList { // Tells anyone using program that it is AnyObject, but also a PropertyList. Documents program
        get {
            return internalProgram // returns array (a value type), which gets copied when returned. So don't return pointer to internal data structure but a copy of it
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        if(operation == "M"){
                            //print("printing dict \(operation)")
                            //print(variableValues)
                            setOperand(operation)
                        } else {
                            performOperation(operation)
                        }
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        descriptionAccumulator = "0"
        internalProgram.removeAll()
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator: "")
            }
        }
    }
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
}