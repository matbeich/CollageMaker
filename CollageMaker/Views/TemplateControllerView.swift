//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import SnapKit

class TemplateControllerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dimmingView)
        addSubview(headerLabel)
        addSubview(templateContainerView)
        
        makeConstraints()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeConstraints() {
        let offset = 20
        
        dimmingView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
        
        headerLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(offset)
            make.right.equalToSuperview().offset(-offset)
            make.top.equalToSuperview()
            make.height.equalTo(50)
        }
        
        templateContainerView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setup() {
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0.8
        
        headerLabel.text = "Choose template"
    }
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = R.font.sfProTextBold(size: 20)
        label.textColor = .white
        label.textAlignment = .left
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.8
        
        
        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle,
                          NSAttributedStringKey.kern: CGFloat(-1.85),
                          ] as [NSAttributedStringKey : Any]
        
        let attributedString = NSMutableAttributedString(string: "Choose template", attributes: attributes)
        
        label.attributedText = attributedString
        label.sizeToFit()
        
        return label
    }()
    
    private let dimmingView = UIView()
    
    private(set) var templateContainerView = UIView()
}
