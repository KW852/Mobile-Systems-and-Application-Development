//
//  CalculatorViewModel.swift
//  Calculator2025
//
//  Created by KitYin Wong on 20/2/2025.
//

import Foundation

enum CalculatorMode: String, CaseIterable {
    case dec = "DEC"
    case bin = "BIN"
    case hex = "HEX"
}

class CalculatorViewModel: ObservableObject {
    
    @Published var value = "0"
    @Published var expression = ""
    @Published var isLandscape: Bool = false
    @Published var selectedMode: CalculatorMode = .dec {
        didSet {
            convertValue(from: previousMode, to: selectedMode)
            previousMode = selectedMode
        }
    }
    
    private var shouldClearExpression = false
    private var didJustPressEquals = false
    private var previousMode: CalculatorMode = .dec
    private var isUserEnteringNumber = false
    private var pendingOperationType: CalcuButton?
    private var pendingHighPriorityOperation: PendingBinaryOperation?
    private var pendingLowPriorityOperation: PendingBinaryOperation?

    private func convertValue(from oldMode: CalculatorMode, to newMode: CalculatorMode) {
        if oldMode == .dec {
            guard let doubleValue = Double(value) else {
                value = "0"
                return
            }
            if (newMode == .bin || newMode == .hex) &&
                doubleValue.truncatingRemainder(dividingBy: 1) != 0 {
                value = "Error"
                return
            }
            let intValue = Int(doubleValue)
            switch newMode {
            case .dec:
                value = String(intValue)
            case .bin:
                value = String(intValue, radix: 2)
            case .hex:
                value = String(intValue, radix: 16).uppercased()
            }
        } else {
            let oldRadix = (oldMode == .bin) ? 2 : 16
            guard let currentValue = Int(value, radix: oldRadix) else {
                value = "0"
                return
            }
            switch newMode {
            case .dec:
                value = String(currentValue)
            case .bin:
                value = String(currentValue, radix: 2)
            case .hex:
                value = String(currentValue, radix: 16).uppercased()
            }
        }
    } // convertValue

    var buttons: [[CalcuButton]] {
        switch selectedMode {
        case .dec:
            if isLandscape {
                return [
                    [.seven, .eight, .nine, .divide, .clear, .pi],
                    [.four, .five, .six, .multiply, .cos, .e],
                    [.one, .two, .three, .subtract, .sin, .negative],
                    [.zero, .decimal, .add, .equal, .percent],
                ]
            } else {
                return [
                    [.pi, .e, .sin, .cos],
                    [.clear, .negative, .percent, .divide],
                    [.seven, .eight, .nine, .multiply],
                    [.four, .five, .six, .subtract],
                    [.one, .two, .three, .add],
                    [.zero, .decimal, .equal],
                ]
            }
        case .bin:
            return [
                [.add, .subtract, .multiply, .divide],
                [.zero, .one, .equal, .clear]
            ]
        case .hex:
            if isLandscape {
                return [
                    [.seven, .eight, .nine, .F, .clear],
                    [.four, .five, .six, .E, .multiply, .divide],
                    [.one, .two, .three, .D, .add, .subtract],
                    [.zero, .A, .B, .C, .equal],
                ]
            } else {
                return [
                    [.clear, .equal],
                    [.add, .subtract, .multiply, .divide],
                    [.seven, .eight, .nine, .F],
                    [.four, .five, .six, .E],
                    [.one, .two, .three, .D],
                    [.zero, .A, .B, .C]
                ]
            }
        }
    } // buttons

    var displayValue: String {
        if value == "Error" {
            return "Error"
        }
        if selectedMode == .dec, value.hasSuffix(".") {
            return value
        }
        if selectedMode == .dec {
            return formatDouble(accumulator)
        } else {
            guard let intValue = Int(value, radix: currentRadix) else {
                return "0"
            }
            switch selectedMode {
            case .dec:
                return String(intValue)
            case .bin:
                return String(intValue, radix: 2)
            case .hex:
                return String(intValue, radix: 16).uppercased()
            }
        }
    } // displayValue
    
    private var currentRadix: Int {
        switch selectedMode {
        case .dec: return 10
        case .bin: return 2
        case .hex: return 16
        }
    }

    private var operations: [String: Operation] = [
        CalcuButton.pi.rawValue:       .constant(Double.pi),
        CalcuButton.e.rawValue:        .constant(M_E),
        CalcuButton.add.rawValue:      .binaryOperation({ $0 + $1 }),
        CalcuButton.subtract.rawValue: .binaryOperation({ $0 - $1 }),
        CalcuButton.multiply.rawValue: .binaryOperation({ $0 * $1 }),
        CalcuButton.divide.rawValue:   .binaryOperation({ $0 / $1 }),
        CalcuButton.sin.rawValue:      .unaryOperation(sin),
        CalcuButton.cos.rawValue:      .unaryOperation(cos),
        CalcuButton.negative.rawValue: .unaryOperation({ -$0 }),
        CalcuButton.percent.rawValue:  .unaryOperation({ $0 / 100 }),
        CalcuButton.equal.rawValue:    .equals
    ]

    private enum Operation {
        case constant(Double)
        case binaryOperation((Double, Double) -> Double)
        case unaryOperation((Double) -> Double)
        case equals
    } // Operation

    private var accumulator: Double {
        get {
            if selectedMode == .dec {
                return Double(value) ?? 0
            } else {
                guard let intValue = Int(value, radix: currentRadix) else { return 0 }
                return Double(intValue)
            }
        }
        set {
            if selectedMode == .dec {
                if newValue.truncatingRemainder(dividingBy: 1) == 0 {
                    value = String(Int(newValue))
                } else {
                    value = String(newValue)
                }
            } else {
                let intValue = Int(newValue)
                switch selectedMode {
                case .dec:
                    value = String(intValue)
                case .bin:
                    value = String(intValue, radix: 2)
                case .hex:
                    value = String(intValue, radix: 16).uppercased()
                }
            }
        }
    } // accumulator

    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    } // PendingBinaryOperation

    func didTap(button: CalcuButton) {
        if button == .equal {
            operationPressed(button: button)
            updateExpression(with: button)
        } else {
            updateExpression(with: button)
            if button.isDigit {
                digitPressed(button: button)
            } else {
                operationPressed(button: button)
            }
        }
    } // didTap
    
    private func updateExpression(with button: CalcuButton) {
        switch button {
        case .equal:
            expression += " = \(displayValue)"
            didJustPressEquals = true

        case .clear:
            expression = ""
            didJustPressEquals = false
            
        default:
            if didJustPressEquals {
                expression = "\(displayValue)"
                didJustPressEquals = false
            }
            
            if button.isDigit {
                expression += button.rawValue
            } else {
                expression += " \(button.rawValue) "
            }
        }
    }

    func digitPressed(button: CalcuButton) {
        let number = button.rawValue
        
        if value == "Error" {
            value = number
            isUserEnteringNumber = true
            return
        }
        if selectedMode == .bin, !["0","1"].contains(number) {
            return
        }
        if selectedMode == .hex, !"0123456789ABCDEF".contains(number) {
            return
        }
        
        if selectedMode == .dec, button == .decimal {
            if !isUserEnteringNumber {
                value = "0."
                isUserEnteringNumber = true
                return
            }
            if !value.contains(".") {
                value += "."
            }
            return
        }
        
        if !isUserEnteringNumber {
            value = number
            isUserEnteringNumber = true
        } else {
            value += number
        }
    } // digitPressed
    
    func operationPressed(button: CalcuButton) {
        if button == .clear {
            value = "0"
            expression = ""
            isUserEnteringNumber = false
            pendingHighPriorityOperation = nil
            pendingLowPriorityOperation = nil
            return
        }
        
        isUserEnteringNumber = false
        let currentVal = accumulator
        
        guard let op = operations[button.rawValue] else { return }
        switch op {
        case .constant(let resultValue):
            accumulator = resultValue
            
        case .unaryOperation(let function):
            accumulator = function(currentVal)
            
        case .binaryOperation(let function):
            if button == .multiply || button == .divide {
                if let highOp = pendingHighPriorityOperation {
                    accumulator = highOp.perform(with: currentVal)
                    pendingHighPriorityOperation = nil
                }
                pendingHighPriorityOperation = PendingBinaryOperation(function: function, firstOperand: accumulator)
            } else {
                if let highOp = pendingHighPriorityOperation {
                    accumulator = highOp.perform(with: currentVal)
                    pendingHighPriorityOperation = nil
                }
                if let lowOp = pendingLowPriorityOperation {
                    accumulator = lowOp.perform(with: accumulator)
                    pendingLowPriorityOperation = nil
                }
                pendingLowPriorityOperation = PendingBinaryOperation(function: function, firstOperand: accumulator)
            }
            
        case .equals:
            if let highOp = pendingHighPriorityOperation {
                accumulator = highOp.perform(with: accumulator)
                pendingHighPriorityOperation = nil
            }
            if let lowOp = pendingLowPriorityOperation {
                accumulator = lowOp.perform(with: accumulator)
                pendingLowPriorityOperation = nil
            }
        }
    } // operationPressed

    private func formatDouble(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

//private struct PendingBinaryOperation {
//    let function: (Double, Double) -> Double
//    let firstOperand: Double
//    
//    func perform(with secondOperand: Double) -> Double {
//        return function(firstOperand, secondOperand)
//    }
//}

