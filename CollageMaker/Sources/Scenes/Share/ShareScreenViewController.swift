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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setThumbnail()
    }

    @objc private func cancel() {
        delegate?.shareScreenViewControllerDidCancel(self)
    }

    private func setup() {
        shareFooter.delegate = self

        let left = NavigationBarButtonItem(icon: R.image.close_btn(), target: self, action: #selector(cancel))
        let title = NavigationBarLabelItem(title: "Share", color: .black, font: R.font.sfProDisplaySemibold(size: 19))

        navBarItem = NavigationBarItem(left: left, title: title)
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

    private func saveToPhotos(content: ShareContent, completion: ((Bool, PHAsset?) -> Void)? = nil) {
        guard let image = content.item as? UIImage else {
            return
        }

        photoLibrary.add(image) { [weak self] succes, asset in
            self?.popUpMessageAlert("Saved to photos", duration: 0.75)
            self?.currentImageAsset = asset

            completion?(succes, asset)
        }
    }

    private func shareViaMessage(content: ShareContent) {
        Pigeon.shared.shareToMessages(content, in: self, with: nil)
    }

    private func shareToOther(content: ShareContent) {
        let settings = ActivityShareSettings()
        Pigeon.shared.share(content, in: self, from: view.frame, settings: settings, with: nil)
    }

    private func shareToInstagram(content: ShareContent) {
        let completion: (Bool, PHAsset?) -> Void = { [weak self] succes, asset in
            if succes, let asset = asset {
                self?.openInstagram(withAssetId: asset.localIdentifier)
            } else {
                self?.popUpMessageAlert("Something went wrong", duration: 0.8)
            }
        }

        guard
            let currentImageAsset = currentImageAsset,
            let asset = photoLibrary.assetFor(localIdentifier: currentImageAsset.localIdentifier),
            currentImageAsset == asset
        else {
            saveToPhotos(content: content, completion: completion)
            return
        }

        openInstagram(withAssetId: currentImageAsset.localIdentifier)
    }

    private func popUpMessageAlert(_ message: String, duration: TimeInterval) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let completion = { alertController.dismiss(animated: true, completion: nil) }

        present(alertController, animated: true) { DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: completion) }
    }

    private func openInstagram(withAssetId assetId: String) {
        guard let shareURL = URL(string: "instagram://library?LocalIdentifier=\(assetId)") else {
            return
        }

        Utils.Application.redirect(to: shareURL)
    }

    private func setThumbnail() {
        if imageIsPrepared {
            thumbnailImageView.image = collageImage

            return
        }

//        collageRenderer.renderImage(from: collage, with: thumbnailImageView.bounds.size, in: .global()) { [weak self] image in
//            self?.thumbnailImageView.image = image
//        }
    }

    private func prepareHightResolutionImage() {
//        collageRenderer.renderImage(from: collage, with: CGSize(width: 1200, height: 1200), in: .global()) { [weak self] image in
//            self?.collageImage = image
//        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private var collage: Collage
    private var collageImage: UIImage?
    private var hashtag: String?
    private var currentImageAsset: PHAsset?
    private let thumbnailImageView = UIImageView()
    private let shareFooter: ShareScreenFooter
    private let authService = PhotoAuthService()
    private let photoLibrary = PhotoLibrary()
    private let collageRenderer = CollageRenderer()
}

extension ShareScreenViewController: ShareScreenFooterDelegate {
    func shareScreenFooter(_ footer: ShareScreenFooter, shareToolbar: ShareToolbar, didSelectDestination destination: ShareDestination) {
        shareToDestination(destination: destination)
    }

    func shareScreenFooter(_ footer: ShareScreenFooter, didTappedHashtag hashtag: String) {
        self.hashtag = hashtag
        popUpMessageAlert("Hashtag copied to clipboard", duration: 0.75)
    }
}
