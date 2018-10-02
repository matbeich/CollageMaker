//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class ShareScreenFooter: UIView {
    init(frame: CGRect, with destinations: [ShareDestination]) {
        self.destinations = destinations
        self.shareToolbar = ShareToolbar(destinations: destinations)

        super.init(frame: frame)

        addSubview(messageLabel)
        addSubview(shareToolbar)

        makeConstraints()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func setMessage(_ message: String) {
        messageLabel.text = message
    }

    private func setup() {
        messageLabel.delegate = self
    }

    private func makeConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.2)
        }

        shareToolbar.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.3)
            make.centerX.equalToSuperview()
        }
    }

    private lazy var messageLabel: AttributedTextLabel = {
        let label = AttributedTextLabel(text: "Tap #MadeWithCollagist to use this hashtag in your message")
        label.font = R.font.sfProDisplaySemibold(size: 19)
        label.isUserInteractionEnabled = true

        if let hashtagsWords = label.hashtags {
            hashtagsWords.forEach {
                label.addAttributes(attrs: [
                    .foregroundColor: UIColor.brightLavender,
                    .font: R.font.sfProTextBold(size: 19) as Any
            ], to: $0) }
        }

        label.textAlignment = .center

        return label
    }()

    var hashtagTapped: Bool = false
    private let destinations: [ShareDestination]
    private let shareToolbar: ShareToolbar
}

extension ShareScreenFooter: AttributedTextLabelDelegate {
    func attributedTextLabelWasTapped(_ label: AttributedTextLabel) {
        hashtagTapped = true
        guard let hashtags = label.hashtags else {
            return
        }

        let hashtagMessage = hashtags.joined(separator: ", ")
        print(hashtagMessage)
    }
}
