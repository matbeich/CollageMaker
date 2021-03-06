//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

protocol ShareScreenFooterDelegate: AnyObject {
    func shareScreenFooter(_ footer: ShareScreenFooter, didTappedHashtag hashtag: String)
    func shareScreenFooter(_ footer: ShareScreenFooter, shareToolbar: ShareToolbar, didSelectDestination destination: ShareDestination)
}

class ShareScreenFooter: UIView {
    weak var delegate: ShareScreenFooterDelegate?

    init(frame: CGRect = .zero, destinations: [ShareDestination]) {
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

    func setEnabled(_ enabled: Bool) {
        shareToolbar.isEnabled = enabled
    }

    private func setup() {
        accessibilityIdentifier = Accessibility.View.shareFooter.id
        messageLabel.delegate = self
        shareToolbar.delegate = self
    }

    private func makeConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.4)
        }

        shareToolbar.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private(set) lazy var messageLabel: AttributedTextLabel = {
        let label = AttributedTextLabel(text: "Tap #MadeWithCollagist to use this hashtag in your message")
        label.font = R.font.sfCompactDisplayMedium(size: 16)
        label.isUserInteractionEnabled = true

        if let hashtagsWords = label.hashtags {
            hashtagsWords.forEach {
                label.addAttributes(attrs: [
                    .foregroundColor: UIColor.brightLavender,
                    .font: R.font.sfProTextBold(size: 16) as Any
            ], to: $0) }
        }

        label.textAlignment = .center

        return label
    }()

    private let shareToolbar: ShareToolbar
    private let destinations: [ShareDestination]
}

extension ShareScreenFooter: AttributedTextLabelDelegate {
    func attributedTextLabelWasTapped(_ label: AttributedTextLabel) {
        guard let hashtags = label.hashtags?.joined(separator: ", ") else {
            return
        }

        delegate?.shareScreenFooter(self, didTappedHashtag: hashtags)
    }
}

extension ShareScreenFooter: ShareToolbarDelegate {
    func shareToolbar(_ shareToolbar: ShareToolbar, didSelectDestination destination: ShareDestination) {
        delegate?.shareScreenFooter(self, shareToolbar: shareToolbar, didSelectDestination: destination)
    }
}
