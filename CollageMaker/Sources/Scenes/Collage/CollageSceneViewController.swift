//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Utils

protocol CollageSceneViewControllerDelegate: AnyObject {
    func collageSceneViewController(_ controller: CollageSceneViewController, didEndEditingCollage collage: Collage)
}

class CollageSceneViewController: CollageBaseViewController {
    weak var delegate: CollageSceneViewControllerDelegate?

    init(collage: Collage = Collage(), templates: [CollageTemplate]) {
        templateBarController = TemplateBarCollectionViewController(templateProvider: self.templateProvider)
        templateBarController.templates = templates

        super.init(nibName: nil, bundle: nil)
        collageViewController.collage = collage
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override var prefersStatusBarHidden: Bool {
        return true
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
        navBarItem.right = NavigationBarButtonItem(icon: R.image.share_btn(), target: self, action: #selector(shareCollage))
        navBarItem.title = "Edit"

        makeConstraints()

        toolsBar.delegate = self
        templateBarController.delegate = self
        collageViewController.delegate = self
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

    private func showMotionAlert() {
        let controller = UIAlertController(title: nil, message: "Would you like to restore deleted cell?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.collageViewController.restoreDeletedCell()
        }

        let cancelAction = UIAlertAction(title: "No", style: .destructive, handler: nil)

        controller.addAction(action)
        controller.addAction(cancelAction)

        present(controller, animated: true, completion: nil)
    }

    private func pickImage() {
        let controller = ImagePickerCollectionViewController(selectionMode: .single)

        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    private let collageViewContainer: UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let toolsBar = CollageToolbar.standart
    private let photoLibrary = PhotoLibrary()
    private let templateProvider = CollageTemplateProvider()
    private let templateControllerView = TemplatesContainerView()
    private var collageViewController = CollageViewController()
    private var templateBarController: TemplateBarCollectionViewController
}

extension CollageSceneViewController {
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            EventTracker.shared.track(.shake())
            showMotionAlert()
        }
    }
}

extension CollageSceneViewController: CollageViewControllerDelegate {
    func collageViewController(_ controller: CollageViewController, didRestoreCellView cellView: CollageCellView) {
        var actualAssets = templateBarController.assets ?? []

        guard let asset = cellView.collageCell.photoAsset else {
            return
        }

        actualAssets.append(asset)
        let templates = templateProvider.templates(for: actualAssets)

        templateBarController.templates = templates
    }

    func collageViewController(_ controller: CollageViewController, didDeleteCellView cellView: CollageCellView) {
        var actualAssets = templateBarController.assets ?? []

        guard let asset = cellView.collageCell.photoAsset, let index = actualAssets.firstIndex(of: asset) else {
            return
        }

        actualAssets.remove(at: index)
        let templates = templateProvider.templates(for: actualAssets)

        templateBarController.templates = templates
    }

    func collageViewControllerPlusButtonTapped(_ controller: CollageViewController) {
        pickImage()
    }
}

extension CollageSceneViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        templateProvider.collage(from: collageTemplate, size: .large) { [weak self] collage in
            self?.collageViewController.collage = collage
        }
    }
}

extension CollageSceneViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewControllerDidCancel(_ controller: ImagePickerCollectionViewController) {
        navigationController?.popViewController(animated: true)
    }

    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelectAssets assets: [PHAsset]) {
        guard let asset = assets.first, let currentAssets = templateBarController.assets else {
            return
        }

        var actualAssets = [asset]
        actualAssets.append(contentsOf: currentAssets)

        if let selectedCellAsset = collageViewController.selectedCellView.collageCell.photoAsset, let index = actualAssets.index(of: selectedCellAsset) {
            actualAssets.remove(at: index)
        }

        let templates = templateProvider.templates(for: actualAssets)

        photoLibrary.photo(with: asset, deliveryMode: .highQualityFormat, size: CGSize(width: 1000, height: 1000)) { [weak self] in
            let abstractPhoto = AbstractPhoto(photo: $0, asset: asset)
            self?.collageViewController.addAbstractPhotoToSelectedCell(abstractPhoto)
        }

        templateBarController.templates = templates
        navigationController?.popViewController(animated: true)
    }
}

extension CollageSceneViewController: CollageToolbarDelegate {
    func collageToolbar(_ collageToolbar: CollageToolbar, itemTapped: CollageBarItem) {
        switch itemTapped.title {
        case "HORIZONTAL":
            if collageViewController.collage.cells.count < Collage.maximumAllowedCellsCount {
                EventTracker.shared.track(.split(by: .horizontal))
                collageViewController.splitSelectedCell(by: .horizontal)
            }
        case "VERTICAL":
            if collageViewController.collage.cells.count < Collage.maximumAllowedCellsCount {
                EventTracker.shared.track(.split(by: .vertical))
                collageViewController.splitSelectedCell(by: .vertical)
            }
        case "ADD IMG": pickImage()
        case "DELETE": collageViewController.deleteSelectedCell()
        default: break
        }
    }
}
