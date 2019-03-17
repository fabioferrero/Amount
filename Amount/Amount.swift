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
    private let currency: Currency
    
    init(value: Decimal, currency: Currency = .default) {
        self.currency = currency
        self.value = value.roundedValue
    }
    
    init(value: NSNumber, currency: Currency = .default) {
        self.init(value: value.decimalValue, currency: currency)
    }
    
    init(value: Double, currency: Currency = .default) {
        self.init(value: Decimal(value), currency: currency)
    }
    
    var absoluteValue: Amount {
        return Amount(value: abs(value), currency: currency)
    }
}

// Mark: - Arithmetics

extension Amount {
    static func +(lhs: Amount, rhs: Amount) -> Amount {
        precondition(lhs.currency == rhs.currency)
        return Amount(value: lhs.value + rhs.value, currency: lhs.currency)
    }
    
    static func -(lhs: Amount, rhs: Amount) -> Amount {
        precondition(lhs.currency == rhs.currency)
        return Amount(value: lhs.value - rhs.value, currency: lhs.currency)
    }
    
    static func *(lhs: Amount, rhs: Amount) -> Amount {
        precondition(lhs.currency == rhs.currency)
        return Amount(value: lhs.value * rhs.value, currency: lhs.currency)
    }
    
    static func /(lhs: Amount, rhs: Amount) -> Amount {
        precondition(lhs.currency == rhs.currency)
        return Amount(value: lhs.value / rhs.value, currency: lhs.currency)
    }
    
    static func +=(lhs: inout Amount, rhs: Amount) -> Amount {
        precondition(lhs.currency == rhs.currency)
        lhs = Amount(value: lhs.value + rhs.value, currency: lhs.currency)
        return lhs
    }
}

extension Amount: Equatable {
    public static func ==(lhs: Amount, rhs: Amount) -> Bool {
        return lhs.value == rhs.value && lhs.currency == rhs.currency
    }
}

extension Amount: Comparable {
    public static func <(lhs: Amount, rhs: Amount) -> Bool {
        precondition(lhs.currency == rhs.currency)
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
        Amount.formatter.currencyCode = currency.rawValue
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
        formatter.locale = Locale.current
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
