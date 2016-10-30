//
//  ViewController.swift
//  Calculator
//
//  Created by John Lu on 10/21/16.
//  Copyright © 2016 John Lu. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
  
  @IBOutlet weak var display: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  /* List of supported unary opeartions */
  private let supportedUnaryOperations = ["√"];
  
  /* Keeps track of whether or not the user is inputing numbers */
  private var userIsModifying = false
  private var decimalPointExists = false;
  
  /* This variable stores the most recently pressed operation for the purposes
   of printing the sequence of operations pressed by the user */
  private var mostRecentlyPressedUnaryOperation = ""
  private var lastButtonPressed = ""
  private var lastNumberPressed = ""
  private var displayValue: Double {
    get {
      return Double(display.text!)!
    }
    set {
      display.text = String(newValue)
    }
  }
  /* All calculations will be done in the Model */
  private var calculatorModel = CalculatorModel()
  
  
  /* This function is called when the user presses a number */
  @IBAction private func numberWasPressed(_ sender: UIButton) {
    let numberPressed = sender.currentTitle!
    
    /* If user is modifying, then we want to append digits pressed
     to whatever is currently in the display. */
    if userIsModifying {
      display.text = display.text! + String(numberPressed)
    }
    else {
      /* If user is not modifying, then set the whole label to digit
       that user pressed */
      display.text = String(numberPressed)
      userIsModifying = true
    }
    lastNumberPressed = sender.currentTitle!
  }
  
  /* This function handles the event that the user touches an operation
   button */
  @IBAction private func mathematicalOperation(_ sender: UIButton) {
    if (userIsModifying) {
      calculatorModel.setOperand(operand: displayValue)
    }
    userIsModifying = false
    if sender.currentTitle != nil {
      lastButtonPressed = sender.currentTitle!
      if (sender.currentTitle! == "π") {
        lastNumberPressed = "π"
      }
      if (supportedUnaryOperations.contains(sender.currentTitle!)) {
        mostRecentlyPressedUnaryOperation = sender.currentTitle!
      }
      calculatorModel.performOperation(symbol: sender.currentTitle!)
      
      /* Modify the description label */
      modifyDescriptionLabel(sender: sender);
    }
    /* Update the display label */
    displayValue = calculatorModel.result
    
    /* Update the description label */
    descriptionLabel.text = calculatorModel.description
    
    /* Allow user to enter another floating point number as the next number */
    decimalPointExists = false
  }
  
  /* ---------- Modify the description of the sequence of commands ---------- */
  private func modifyDescriptionLabel(sender: UIButton) {
    
    /* There are 4 distinct cases to consider:
     #1) A calculation had previous finished and user supplied another number with
     an operation (after he had hit "=").
     
     #2) User is chaining together two separate operations. That is, user had already
     supplied a number and an operation, and has just hit another number or opeartion
     WITHOUT hitting "="
     
     #3) No calculation or chaining has occurred. User has supplied a number and an opeartion
     for the first time.
     
     #4) User hit "=" or a unary operation such as π or sqrt (while not as part of a chain).
     
     #5) Binary operation is in progress but user hit a unary operator.
     
     */
 
    let description = calculatorModel.description
    var stringToAppend = ""
    
    /* Cases 1, 2, and 3 */
    if (calculatorModel.isPartialResult) {
      /* CASE 1: */
      if (description.contains("=")) {
        print("Case 1")
        /* Replace occurence of "=" with the operation pressed */
        stringToAppend = sender.currentTitle! + " " + "..."
        calculatorModel.description =
          description.replacingOccurrences(of: "=", with: stringToAppend)
      }
        /* CASE 2: */
      else if (description.contains("...")) {
        print("Case2")
        /* If there is an occurences of "..." the user is chaining
         together operations. */
        
        /* append the digit pressed and the operation */
        if (lastNumberPressed == "π") {
          print("last button pressed is \(lastButtonPressed)")
          stringToAppend += lastButtonPressed
        }
        else {
          if (lastButtonPressed == "√") {
            stringToAppend += lastButtonPressed + "(" + lastNumberPressed + ")"
          }
          else {  /* this part has an error!! */
            if (mostRecentlyPressedUnaryOperation != "√") {
              stringToAppend += lastNumberPressed + " "
            }
            stringToAppend += lastButtonPressed
            mostRecentlyPressedUnaryOperation = ""
            print("set mostRecentlyPressedUnary to blank")
          }
        }
        stringToAppend += " ..."
        
        calculatorModel.description =
        description.replacingOccurrences(of: "...", with: stringToAppend)
      }
        /* CASE 3 */
      else {
        print("Case 3")
        /* User has not chained any operations yet */
        if (lastNumberPressed == "π") {
          stringToAppend += ""
        }
        else {
          if (mostRecentlyPressedUnaryOperation != "√") {
            print(mostRecentlyPressedUnaryOperation)
            stringToAppend += lastNumberPressed
          }
        }
        stringToAppend += " " + lastButtonPressed + " " + "..."
        calculatorModel.description += stringToAppend
      }
    }
      /* CASE 4 */
    else {
      print("Case 4: Equals was pressed or Unary operator was pressed");
      if (lastButtonPressed == "π") {
        stringToAppend = lastButtonPressed
      }
      else if (lastButtonPressed == "√") {
        /* Take the most recent digit pressed, wrap parentheses () around it,
         and put square root before */
        print("Last button pressed is √")
        if (sender.currentTitle! != "=") {
          stringToAppend = sender.currentTitle! + "(" + String(displayValue) + ")"
        } else {
          /* sender.currentTitle is "=" here. Also displayValue is the last digit
           user pressed */
          stringToAppend = String(displayValue) + " " + sender.currentTitle!
        }
      }
        /* Last button pressed is "=" */
      else {
        print("Equals was pressed")
        print("Value of most recently pressed unary is \(mostRecentlyPressedUnaryOperation)")
        if (lastNumberPressed == "π") {
          stringToAppend = ""
        }
        else {
          if (mostRecentlyPressedUnaryOperation != "√") {
            stringToAppend = lastNumberPressed
          }
        }
        stringToAppend += " ="
        mostRecentlyPressedUnaryOperation = ""
      }
      calculatorModel.description = description.replacingOccurrences(of: "...", with: "")
      calculatorModel.description += stringToAppend
    }
  }
  /* -------------------- End of Description Modification ------------------- */
  
  @IBAction func decimalPointPressed(_ sender: UIButton) {
    if (!decimalPointExists) {
      numberWasPressed(sender)
      decimalPointExists = true
    }
  }
  
  /* This function resets the display and erases all pending calculations */
  @IBAction func clear(_ sender: UIButton) {
    displayValue = 0
    userIsModifying = false
    decimalPointExists = false
    descriptionLabel.text = ""
    mostRecentlyPressedUnaryOperation = ""
    lastNumberPressed = ""
    lastButtonPressed = ""
    calculatorModel.clearModel()
  }
}

