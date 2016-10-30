//
//  CalculatorModel.swift
//  Calculator
//
//  Created by John Lu on 10/21/16.
//  Copyright © 2016 John Lu. All rights reserved.
//

import Foundation

struct BinaryOperationInfo {
  var firstOperand : Double
  var function : (Double, Double) -> Double  // Function for operation
}

class CalculatorModel {
  /* This enum lists the possible "operations" */
  enum Operation {
    case Constant(Double)
    case UnaryOperation((Double) -> Double)
    case BinaryOperation((Double, Double) -> Double)
    case Equals
  }
  
  /* ------------------- Private variables -------------------- */
  private var total = 0.0  // For storing total (so far)
  /* Read-only variable */
  var result : Double {
    get {
      return total
    }
  }
  private var binOpInProgress : BinaryOperationInfo?
  /* Dictionary to map operation string to Operation enum */
  private var operations : Dictionary<String, Operation> = [
    // Constant Operations
    "π" : Operation.Constant(M_PI),
    // Unary Operations
    "√" : Operation.UnaryOperation(sqrt),
    "cos": Operation.UnaryOperation(cos),
    "sin": Operation.UnaryOperation(sin),
    // Binary Operations
    "×" : Operation.BinaryOperation({ $0 * $1 }),
    "+" : Operation.BinaryOperation({ $0 + $1 }),
    "÷" : Operation.BinaryOperation({ $0 / $1 }),
    "−" : Operation.BinaryOperation({ $0 - $1 }),
    // Equals
    "=" : Operation.Equals
  ]
  
  var description = ""
  
  var sequenceOfOperations: String {
    get {
      return description
    }
    set {
      description = newValue;
    }
  }
  
  var isPartialResult: Bool {
    get {
      return binOpInProgress != nil
    }
  }
  
  /* --------------- calculation functions ------------------- */
  /* This function saves the users operand */
  func setOperand(operand : Double) {
    total = operand
  }
  
  func performOperation(symbol : String) {
    if let operation = operations[symbol] {
      switch(operation) {
      case .Constant(let constValue): total = constValue
      case .UnaryOperation(let function): total = function(total)
      case .BinaryOperation(let function):
        executePendingBinaryOperation()
        /* Note: This call to executePendingBinaryOperation() is
         to implement a "running total" to allow for a chaining of
         operations. For example, if user enters 5 * 3 * 4 + 3, after
         each operation, the "total-so-far" will be calculated */
        binOpInProgress = BinaryOperationInfo(firstOperand: total, function: function)
      case .Equals:
        executePendingBinaryOperation()
      }
    }
  }
  
  func clearModel() {
    total = 0
    binOpInProgress = nil
    description = ""
  }
  
  private func executePendingBinaryOperation() {
    if (binOpInProgress != nil) {
      total = binOpInProgress!.function(binOpInProgress!.firstOperand,
                                        total)
      binOpInProgress = nil
    }
  }
}
