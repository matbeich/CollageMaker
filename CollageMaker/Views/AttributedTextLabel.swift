//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAttributes(attrs: [NSAttributedStringKey: Any], range: NSRange) {
        attributedString.addAttributes(attrs, range: range)
        attributedText = attributedString
    }
    
    private func set(text: String?) {
        if let text = text {
            setup(with: text)
        }
    }
    
    private func setup(with text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.8
        
        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle,
                          NSAttributedStringKey.kern: CGFloat(-1.0),
                          ] as [NSAttributedStringKey : Any]
        
        attributedString = NSMutableAttributedString(string: text , attributes: attributes)
        attributedText = attributedString
    }
    
    private var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
}
