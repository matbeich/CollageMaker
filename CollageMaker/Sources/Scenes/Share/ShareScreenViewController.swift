//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit
import Utils

enum SharingError: Error {
    case photoLibraryAccessDenied
}

protocol ShareScreenViewControllerDelegate: AnyObject {
    func shareScreenViewControllerDidCancel(_ controller: ShareScreenViewController)
    func shareScreenViewController(_ controller: ShareScreenViewController, didShareCollageImage image: UIImage, withError error: SharingError?)
}

class ShareScreenViewController: CollageBaseViewController {
    weak var delegate: ShareScreenViewControllerDelegate?

    var thumbnailIsSet: Bool {
        return thumbnailImageView.image != nil
    }

    init(collage: Collage, context: AppContext) {
        self.context = context
        self.collage = collage
        self.shareFooter = ShareScreenFooter(destinations: [.photos, .messages, .instagram, .other])

        super.init(nibName: nil, bundle: nil)

        prepareHightResolutionImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(thumbnailImageView)
        view.addSubview(shareFooter)

        setup()
        makeConstraints()
    }

    @objc private func cancel() {
        if Environment.isTestEnvironment { collageNavigationController?.pop() }

        delegate?.shareScreenViewControllerDidCancel(self)
    }

    private func setup() {
        shareFooter.delegate = self

        let btn = NavigationBarButtonItem(icon: R.image.close_btn(), target: self, action: #selector(cancel))
        btn.button.accessibilityIdentifier = Accessibility.NavigationControl.close.id
        navBarItem.left = btn
        navBarItem.title = "Share"

        view.backgroundColor = .white
    }

    private func makeConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }

            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(thumbnailImageView.snp.width)
        }

        shareFooter.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(thumbnailImageView.snp.bottom)
        }
    }

    private func shareToDestination(destination: ShareDestination) {
        guard let image = collageImage else {
            return
        }

        let content = ShareContent()
        content.item = image
        content.userCaption = hashtag

        switch destination {
        case .instagram:
            shareToInstagram(content: content)
        case .messages:
            shareViaMessage(content: content)
        case .other:
            shareToOther(content: content)
        case .photos:
            saveToPhotos(content: content)
        }
    }

    private func saveToPhotos(content: ShareContent) {
        context.shareService.saveToPhotos(content, in: self, with: nil)
    }

    private func shareViaMessage(content: ShareContent) {
        context.shareService.shareToMessages(content, in: self, with: nil)
    }

    private func shareToOther(content: ShareContent) {
        context.shareService.shareToOther(content, in: self, with: nil)
    }

    private func shareToInstagram(content: ShareContent) {
        context.shareService.shareToInstagram(content, in: self, with: nil)
    }

    private func prepareHightResolutionImage() {
        context.collageRenderer.renderAsyncImage(from: collage, with: CGSize(width: 1200, height: 1200), borders: true) { [weak self] image in
            self?.collageImage = image
        }
    }

    private func setThumbnailImage(_ image: UIImage?, animated: Bool) {
        thumbnailImageView.image = image

        if animated {
            thumbnailImageView.alpha = 0.3
            UIView.animate(withDuration: 0.2) { self.thumbnailImageView.alpha = 1.0 }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private var collageImage: UIImage? {
        didSet {
            setThumbnailImage(collageImage, animated: true)
            shareFooter.setEnabled(collageImage != nil)
        }
    }

    private var collage: Collage
    private var hashtag: String?
    private let context: AppContext
    private let shareFooter: ShareScreenFooter
    private let thumbnailImageView = UIImageView()
}

extension ShareScreenViewController: ShareScreenFooterDelegate {
    func shareScreenFooter(_ footer: ShareScreenFooter, shareToolbar: ShareToolbar, didSelectDestination destination: ShareDestination) {
        EventTracker.shared.track(.share(destination: destination))
        shareToDestination(destination: destination)
    }

    func shareScreenFooter(_ footer: ShareScreenFooter, didTappedHashtag hashtag: String) {
        self.hashtag = hashtag
        Alerts.popUpMessageAlert("Hashtag copied to clipboard", duration: 0.75, in: self)
    }
}
