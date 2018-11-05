//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit
import Utils

protocol CollageSceneViewControllerDelegate: AnyObject {
    func collageSceneViewController(_ controller: CollageSceneViewController, didEndEditingCollage collage: Collage)
}

class CollageSceneViewController: CollageBaseViewController {
    weak var delegate: CollageSceneViewControllerDelegate?

    init(collage: Collage,
         templates: [CollageTemplate] = [],
         context: AppContext) {
        self.context = context
        self.cellsCount = context.remoteSettingsService.cellsCount

        templateBarController = TemplateBarCollectionViewController(context: context)
        templateBarController.templates = templates

        super.init(nibName: nil, bundle: nil)
        collageViewController.collage = collage
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    deinit {
        tokens.removeAll()
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
        makeConstraints()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        makeConstraints(for: UIDevice.current.orientation)
        updateTemplateBarAppearence()
    }

    private func updateTemplateBarAppearence() {
        templateBarController.scrollDirection = UIDevice.current.orientation.isLandscape ? .vertical : .horizontal
    }

    func makeConstraints(for orientation: UIDeviceOrientation) {
        collageViewContainer.snp.remakeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }

            make.left.equalToSuperview()

            if orientation.isLandscape {
                make.bottom.equalTo(toolsBar.snp.top)
                make.width.equalTo(collageViewContainer.snp.height)
            } else {
                make.right.equalToSuperview()
                make.height.equalTo(collageViewContainer.snp.width)
            }
        }

        templateControllerView.snp.remakeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(toolsBar.snp.top)

            if orientation.isLandscape {
                make.top.equalTo(collageViewContainer)
                make.left.equalTo(collageViewContainer.snp.right)
            } else {
                make.left.equalToSuperview()
                make.top.equalTo(collageViewContainer.snp.bottom)
            }
        }
    }

    private func makeConstraints() {
        let toolsBarHeight: CGFloat = 59.0

        toolsBar.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.bottom)
            }

            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(toolsBarHeight)
        }

        makeConstraints(for: UIDevice.current.orientation)
    }

    private func setup() {
        let btn = NavigationBarButtonItem(icon: R.image.share_btn(), target: self, action: #selector(shareCollage))
        btn.button.accessibilityIdentifier = Accessibility.NavigationControl.share.id
        navBarItem.right = btn
        navBarItem.title = "Edit"

        makeConstraints()
        updateTemplateBarAppearence()

        toolsBar.delegate = self
        templateBarController.delegate = self
        collageViewController.delegate = self

        tokens.append(context.remoteSettingsService.subscribe(on: .main) { [weak self] in self?.cellsCount = $0.numberOfCells })
    }

    @objc private func shareCollage() {
        collageViewController.saveCellsVisibleRect()

        if Environment.isTestEnvironment {
            collageNavigationController?.push(ShareScreenViewController(collage: collageViewController.collage, context: context))
        }

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
            self?.collageViewController.undo()
        }

        let cancelAction = UIAlertAction(title: "No", style: .destructive, handler: nil)

        controller.addAction(action)
        controller.addAction(cancelAction)

        present(controller, animated: true, completion: nil)
    }

    private func pickImage() {
        let controller = ImagePickerCollectionViewController(context: context, selectionMode: .single)
        controller.delegate = self

        collageViewController.saveCellsVisibleRect()
        navigationController?.pushViewController(controller, animated: true)
    }

    private let collageViewContainer: UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private var cellsCount: Int
    private var tokens = [Any]()
    private let context: AppContext
    private let toolsBar = CollageToolbar.standart
    let collageViewController = CollageViewController()
    let templateControllerView = TemplatesContainerView()
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
    func collageViewControllerDidRestoreCells(_ controller: CollageViewController) {
        let actualAssets = controller.collage.cells.compactMap { $0.photoAsset }
        let templates = context.templateProvider.templates(for: actualAssets)

        templateBarController.templates = templates
    }

    func collageViewController(_ controller: CollageViewController, didDeleteCellView cellView: CollageCellView) {
        var actualAssets = templateBarController.assets ?? []

        guard let asset = cellView.collageCell.photoAsset, let index = actualAssets.firstIndex(of: asset) else {
            return
        }

        actualAssets.remove(at: index)
        let templates = context.templateProvider.templates(for: actualAssets)

        templateBarController.templates = templates
    }

    func collageViewControllerPlusButtonTapped(_ controller: CollageViewController) {
        pickImage()
    }
}

extension CollageSceneViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        context.templateProvider.collage(from: collageTemplate, size: .large) { [weak self] collage in
            self?.collageViewController.collage = collage
        }
    }
}

extension CollageSceneViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewControllerDidCancel(_ controller: ImagePickerCollectionViewController) {
        collageNavigationController?.popViewController(animated: true)
    }

    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelectAssets assets: [PHAsset]) {
        guard let asset = assets.first else {
            return
        }

        var actualAssets = [asset]
        actualAssets.append(contentsOf: templateBarController.assets ?? [])

        if let selectedCellAsset = collageViewController.selectedCellView.collageCell.photoAsset,
            let index = actualAssets.index(of: selectedCellAsset) {
            actualAssets.remove(at: index)
        }

        let templates = context.templateProvider.templates(for: actualAssets)

        context.templateProvider.photoLibrary.photo(with: asset, deliveryMode: .highQualityFormat, size: CGSize(width: 1000, height: 1000)) { [weak self] in
            let abstractPhoto = AbstractPhoto(photo: $0, asset: asset)
            self?.collageViewController.addAbstractPhotoToSelectedCell(abstractPhoto)
        }

        templateBarController.templates = templates
        navigationController?.popViewController(animated: true)
    }
}

extension CollageSceneViewController: CollageToolbarDelegate {
    func collageToolbar(_ collageToolbar: CollageToolbar, itemTapped: CollageBarButtonItem) {
        switch itemTapped.tag {
        case 0:
            if collageViewController.collage.cells.count < cellsCount {
                EventTracker.shared.track(.split(by: .horizontal))
                collageViewController.splitSelectedCell(by: .horizontal)
            }

        case 1:
            if collageViewController.collage.cells.count < cellsCount {
                EventTracker.shared.track(.split(by: .vertical))
                collageViewController.splitSelectedCell(by: .vertical)
            }

        case 2: pickImage()

        case 3: collageViewController.deleteSelectedCell()
        default: break
        }
    }
}
