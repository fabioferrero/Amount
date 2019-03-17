//
//  Amount.swift
//  App Architecture
//
//  Created by Fabio Ferrero on 13/03/2019.
//  Copyright © 2019 Fabio Ferrero. All rights reserved.
//

import UIKit

public struct Amount {
    
    private let value: Decimal
    private let currencyCode: String
    
    init(value: Decimal, currencyCode: String = .euroCurrencyCode) {
        self.currencyCode = currencyCode
        self.value = value.roundedValue
    }
    
    init(value: NSNumber, currencyCode: String = .euroCurrencyCode) {
        self.init(value: value.decimalValue, currencyCode: currencyCode)
    }
    
    init(value: Double, currencyCode: String = .euroCurrencyCode) {
        self.init(value: Decimal(value), currencyCode: currencyCode)
    }
    
    var absoluteValue: Amount {
        return Amount(value: abs(value), currencyCode: currencyCode)
    }
}

// Mark: - Arithmetics

extension Amount {
    static func +(lhs: Amount, rhs: Amount) -> Amount {
        precondition(lhs.currencyCode == rhs.currencyCode)
        return Amount(value: lhs.value + rhs.value, currencyCode: lhs.currencyCode)
    }
    
    static func -(lhs: Amount, rhs: Amount) -> Amount {
        precondition(lhs.currencyCode == rhs.currencyCode)
        return Amount(value: lhs.value - rhs.value, currencyCode: lhs.currencyCode)
    }
    
    static func *(lhs: Amount, rhs: Amount) -> Amount {
        precondition(lhs.currencyCode == rhs.currencyCode)
        return Amount(value: lhs.value * rhs.value, currencyCode: lhs.currencyCode)
    }
    
    static func /(lhs: Amount, rhs: Amount) -> Amount {
        precondition(lhs.currencyCode == rhs.currencyCode)
        return Amount(value: lhs.value / rhs.value, currencyCode: lhs.currencyCode)
    }
    
    static func +=(lhs: inout Amount, rhs: Amount) -> Amount {
        precondition(lhs.currencyCode == rhs.currencyCode)
        lhs = Amount(value: lhs.value + rhs.value, currencyCode: lhs.currencyCode)
        return lhs
    }
}

extension Amount: Equatable {
    public static func ==(lhs: Amount, rhs: Amount) -> Bool {
        return lhs.value == rhs.value && lhs.currencyCode == rhs.currencyCode
    }
}

extension Amount: Comparable {
    public static func <(lhs: Amount, rhs: Amount) -> Bool {
        precondition(lhs.currencyCode == rhs.currencyCode)
        return lhs.value < rhs.value
    }
}

// Mark: - Expressible by literals

extension Amount: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value: Decimal(integerLiteral: value))
    }
}

extension Amount: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value: Decimal(floatLiteral: value))
    }
}

// Mark: - Descripion

extension Amount: CustomStringConvertible {
    public var description: String {
        Amount.formatter.currencyCode = currencyCode
        return Amount.formatter.string(from: value as NSDecimalNumber) ?? "Importo non valido"
    }
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.roundingMode = .down
        formatter.numberStyle = .currency
        formatter.positiveFormat = "0.00 ¤"
        formatter.negativeFormat = "-0.00 ¤"
        formatter.usesGroupingSeparator = true
        formatter.groupingSize = 3
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()
}

extension Optional: CustomStringConvertible where Wrapped == Amount {
    public var description: String {
        switch self {
        case .some(let value):
            return value.description
        case .none:
            return "Informazione non disponibile"
        }
    }
}

// Mark: - String conversions

extension Amount {
    func attributedText(withIntegerSize integerSize: CGFloat, andCurrencySize currencySize: CGFloat, textColor: UIColor = .black) -> NSAttributedString? {
        let components = description.components(separatedBy: ",")
        
        guard components.count == 2 else { return nil }
        
        let integer = NSAttributedString(string: components[0], attributes: [
            .foregroundColor: textColor,
            .font: UIFont.systemFont(ofSize: integerSize, weight: .bold),
            ])
        let decimalAndCurrency = NSAttributedString(string: "," + components[1], attributes: [
            .foregroundColor: textColor,
            .font: UIFont.systemFont(ofSize: currencySize, weight: .thin),
            ])
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(integer)
        attributedString.append(decimalAndCurrency)
        return attributedString
    }
    
    func attributedText(ofSize size: CGFloat, textColor: UIColor = .black) -> NSAttributedString? {
        return attributedText(withIntegerSize: size, andCurrencySize: size-1, textColor: textColor)
    }
}

extension Optional where Wrapped == Amount {
    
    func attributedText(withIntegerSize integerSize: CGFloat, andCurrencySize currencySize: CGFloat, textColor: UIColor = .black) -> NSAttributedString? {
        switch self {
        case .some(let value):
            return value.attributedText(withIntegerSize: integerSize, andCurrencySize: currencySize, textColor: textColor)
        case .none:
            return NSAttributedString(string: "Informazione non disponibile")
        }
    }
    
    func attributedText(ofSize size: CGFloat, textColor: UIColor = .black) -> NSAttributedString? {
        return attributedText(withIntegerSize: size, andCurrencySize: size-1, textColor: textColor)
    }
}

// Mark: - Codable

extension Amount: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Double.self)
        self.init(value: value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

// Mark: - Uility

extension String {
    static var euroCurrencyCode: String { return "EUR" }
}

extension Decimal {
    var roundedValue: Decimal {
        let decimalHandler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return (self as NSDecimalNumber).rounding(accordingToBehavior: decimalHandler).decimalValue
    }
}

extension UILabel {
    func display(amount: Amount?, withEqualFontDimentions: Bool = false) {
        if withEqualFontDimentions {
            self.attributedText = amount.attributedText(withIntegerSize: self.font.pointSize, andCurrencySize: self.font.pointSize)
        } else {
            self.attributedText = amount.attributedText(ofSize: self.font.pointSize)
        }
    }
}
