//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import AVKit
import Photos
import SnapKit
import UIKit
import Utils

protocol CollageSceneViewControllerDelegate: AnyObject {
    func collageSceneViewController(_ controller: CollageSceneViewController, didEndEditingCollage collage: Collage)
}

class CollageSceneViewController: CollageBaseViewController {
    weak var delegate: CollageSceneViewControllerDelegate?

    init(collage: Collage = Collage(), templates: [CollageTemplate]) {
        templateBarController.templates = templates

        super.init(nibName: nil, bundle: nil)
        collageViewController.collage = collage
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(collageViewContainer)
        view.addSubview(templateControllerView)
        view.addSubview(toolsBar)

        addChild(collageViewController, to: collageViewContainer)
        addChild(templateBarController, to: templateControllerView)

        setup()
    }

    private func makeConstraints() {
        collageViewContainer.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }

            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(collageViewContainer.snp.width)
        }

        toolsBar.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(collageViewContainer).dividedBy(6)
        }

        templateControllerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(toolsBar.snp.top)
            make.top.equalTo(collageViewContainer.snp.bottom)
        }
    }

    private func setup() {
        let right = NavigationBarButtonItem(icon: R.image.share_btn(), target: self, action: #selector(shareCollage))
        let left = NavigationBarButtonItem(icon: R.image.back_btn(), target: self, action: #selector(dismissController))
        let title = NavigationBarLabelItem(title: "Edit", color: .black, font: R.font.sfProDisplaySemibold(size: 19))

        navBarItem = NavigationBarItem(left: left, right: right, title: title)
        makeConstraints()

        toolsBar.delegate = self
        templateBarController.delegate = self
        collageViewController.delegate = self
    }

    @objc private func resetCollage() {
        collageViewController.resetCollage()
    }

    @objc private func shareCollage() {
        collageViewController.saveCellsVisibleRect()
        delegate?.collageSceneViewController(self, didEndEditingCollage: collageViewController.collage)
    }

    @objc private func dismissController() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func pickImage() {
        let assets = PhotoLibraryService.getImagesAssets()
        let controller = ImagePickerCollectionViewController(assets: assets)

        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    private let collageViewContainer: UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private var collageViewController = CollageViewController()
    private let toolsBar = CollageToolbar.standart
    private let templateControllerView = TemplateControllerView()
    private let templateBarController = TemplateBarCollectionViewController()
}

extension CollageSceneViewController: CollageViewControllerDelegate {
    func collageViewControllerPlusButtonTapped(_ controller: CollageViewController) {
        pickImage()
    }
}

extension CollageSceneViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        CollageTemplateProvider.collage(from: collageTemplate, size: .large) { [weak self] collage in
            self?.collageViewController.collage = collage
        }
    }
}

extension CollageSceneViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CollageSceneViewController: CollageToolbarDelegate {
    func collageToolbar(_ collageToolbar: CollageToolbar, itemTapped: CollageBarItem) {
        switch itemTapped.title {
        case "HORIZONTAL": collageViewController.splitSelectedCell(by: .horizontal)
        case "VERTICAL": collageViewController.splitSelectedCell(by: .vertical)
        case "ADD IMG": pickImage()
        case "DELETE": collageViewController.deleteSelectedCell()
        default: break
        }
    }
}

extension CollageSceneViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewControllerDidCancel(_ controller: ImagePickerCollectionViewController) {
        navigationController?.popViewController(animated: true)
    }

    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelectAssets assets: [PHAsset]) {
        guard let asset = assets.first else {
            return
        }

        PhotoLibraryService.photo(from: asset, deliveryMode: .highQualityFormat, size: CGSize(width: 1000, height: 1000)) { [weak self] in
            self?.collageViewController.addImageToSelectedCell($0)
        }

        navigationController?.popViewController(animated: true)
    }
}
