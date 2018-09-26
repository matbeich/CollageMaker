//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class AttributedTextLabel: UILabel {
    init(text: String? = nil) {
        super.init(frame: .zero)

        numberOfLines = 0
        font = R.font.sfProTextBold(size: 20)
        textAlignment = .left

        set(text: text)
    }

    override var text: String? {
        didSet {
            set(text: text)
        }
    }

    var lastWord: String? {
        return String(attributedText?.string.split(separator: " ").last ?? " ")
    }

    var letterSpacing: CGFloat = 0 {
        didSet {
            addAttributes(attrs: [NSAttributedStringKey.kern: letterSpacing], to: attributedText?.string ?? "")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addAttributes(attrs: [NSAttributedStringKey: Any], to word: String) {
        guard let range = findRangeOf(word: word, in: attributedText?.string ?? "") else {
            return
        }

        attributedString.addAttributes(attrs, range: range)
        attributedText = attributedString
    }

    private func findRangeOf(word: String, in string: String) -> NSRange? {
        guard let range = string.range(of: word) else {
            return nil
        }

        return NSRange(location: range.lowerBound.encodedOffset, length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
    }

    private func set(text: String?) {
        if let text = text {
            setup(with: text)
        }
    }

    private func setup(with text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.8

        let attributes = [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.kern: CGFloat(0.01)
        ] as [NSAttributedStringKey: Any]

        attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        attributedText = attributedString
    }

    private var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
}
