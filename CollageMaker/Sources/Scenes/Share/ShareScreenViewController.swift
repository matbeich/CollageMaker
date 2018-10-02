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

    var imageIsPrepared: Bool {
        return collageImage != nil
    }

    init(collage: Collage) {
        self.collage = collage
        self.shareFooter = ShareScreenFooter(destinations: [.photos, .messages, .instagram, .other])

        super.init(nibName: nil, bundle: nil)
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
        prepareHightResolutionImage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setThumbnail()
    }

    private func setThumbnail() {
        if imageIsPrepared {
            thumbnailImageView.image = collageImage

            return
        }

        CollageRenderer.renderImage(from: collage, with: thumbnailImageView.bounds.size) { [weak self] image in
            self?.thumbnailImageView.image = image
        }
    }

    private func prepareHightResolutionImage() {
        CollageRenderer.renderImage(from: collage, with: CGSize(width: 1200, height: 1200)) { [weak self] image in
            self?.collageImage = image
        }
    }

    private func setup() {
        shareFooter.delegate = self

        let left = NavigationBarButtonItem(icon: R.image.close_btn(), target: self, action: #selector(cancel))
        let title = NavigationBarLabelItem(title: "Share", color: .black, font: R.font.sfProDisplaySemibold(size: 19))

        navBarItem = NavigationBarItem(left: left, title: title)
        view.backgroundColor = .white
    }

    @objc private func cancel() {
        delegate?.shareScreenViewControllerDidCancel(self)
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

    func saveToPhotos(content: ShareContent) {
        Pigeon.shared.shareToPhotos(content, with: nil)
    }

    func shareViaMessage(content: ShareContent) {
        Pigeon.shared.shareToMessages(content, in: self, with: nil)
    }

    func shareToInstagram(content: ShareContent) {
        //        Pigeon.shared.shareToInstagram(content, in: self, from: view.frame, with: nil)

        guard authService.status != .denied else {
            shareToInstagramViaModalController(content: content, sourceRect: view.frame)
            return
        }

        shareToInstagramViaRedirect(content: content)
    }

    private func shareToInstagramViaModalController(content: ShareContent, sourceRect: CGRect) {
        Pigeon.shared.shareToInstagram(
            content,
            in: self,
            from: view.frame,
            with: nil
        )
    }

    private func shareToInstagramViaRedirect(content: ShareContent) {
        guard let image = content.item as? UIImage else {
            return
        }

        photoLibrary.add(image) { [weak self] succes, asset in
            print(asset)
            self?.openInstagram(withAssetId: asset?.localIdentifier ?? "")
        }
    }

    private func openInstagram(withAssetId assetId: String) {
        guard let shareURL = URL(string: "instagram://library?LocalIdentifier=\(assetId)") else {
            return
        }

        Utils.Application.redirect(to: shareURL)
    }

    func shareToOther(content: ShareContent) {
        let settings = ActivityShareSettings()
        Pigeon.shared.share(content, in: self, from: view.frame, settings: settings, with: nil)
    }

    @objc private func close() {
        delegate?.shareScreenViewControllerDidCancel(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private var collage: Collage
    private var collageImage: UIImage?
    private var hashtag: String?
    private let thumbnailImageView = UIImageView()
    private let shareFooter: ShareScreenFooter
    private let authService = PhotoAuthService()
    private let photoLibrary = PhotoLibrary()
}

extension ShareScreenViewController: ShareScreenFooterDelegate {
    func shareScreenFooter(_ footer: ShareScreenFooter, shareToolbar: ShareToolbar, didSelectDestination destination: ShareDestination) {
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

    func shareScreenFooter(_ footer: ShareScreenFooter, didTappedHashtag hashtag: String) {
        let alertController = UIAlertController(title: nil, message: "Hashtag copied to clipboard", preferredStyle: .alert)
        let completion = { alertController.dismiss(animated: true, completion: nil) }
        self.hashtag = hashtag

        present(alertController, animated: true) { DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: completion) }
    }
}
