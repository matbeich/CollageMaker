//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import AVKit
import Photos
import SnapKit
import UIKit
import Utils

protocol CollageSceneViewControllerDelegate: AnyObject {
    func collageSceneViewController(_ controller: CollageSceneViewController, wantsToShare collage: Collage)
    func collageSceneViewControllerWantsToPickImage(_ controller: CollageSceneViewController)
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

        let right = NavigationBarButtonItem(icon: R.image.share_btn(), target: self, action: #selector(shareCollage))
        let left = NavigationBarButtonItem(icon: R.image.camera_btn(), target: self, action: #selector(tryToTakePhoto))
        let title = NavigationBarLabelItem(title: "Edit", color: .black, font: R.font.sfProDisplaySemibold(size: 19))

        navBarItem = NavigationBarItem(left: left, right: right, title: title)

        makeConstraints()

        toolsBar.delegate = self
        templateBarController.delegate = self

        collageViewController.delegate = self

        addChild(collageViewController, to: collageViewContainer)
        addChild(templateBarController, to: templateControllerView)
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

    @objc private func resetCollage() {
        collageViewController.resetCollage()
    }

    @objc private func shareCollage() {
        collageViewController.saveCellsVisibleRect()
        delegate?.collageSceneViewController(self, wantsToShare: collageViewController.collage)
    }

    func pickImage(camera: Bool = false) {
        if camera {
            let controller = UIImagePickerController()
            controller.sourceType = .camera
            controller.delegate = self

            present(controller, animated: true)
        } else {
            let assets = PhotoLibraryService.getImagesAssets()
            let controller = ImagePickerCollectionViewController(assets: assets)

            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    @objc private func tryToTakePhoto() {
        handle(cameraAuthService.status)
    }

    private func handle(_ avAuthorizationStatus: AVAuthorizationStatus) {
        if cameraAuthService.isAuthorized {
            pickImage(camera: true)
            return
        }

        switch avAuthorizationStatus {
        case .notDetermined: cameraAuthService.reqestAuthorization { self.handle($0) }
        case .denied: present(Alerts.cameraAccessDenied(), animated: true, completion: nil)
        case .restricted: present(Alerts.cameraAccessRestricted(), animated: true, completion: nil)
        default: break
        }
    }

    private let collageViewContainer: UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private var collageViewController = CollageViewController()
    private let toolsBar = CollageToolbar.standart
    private let cameraAuthService = CameraAuthService()
    private let templateControllerView = TemplateControllerView()
    private let templateBarController = TemplateBarCollectionViewController()
}

extension CollageSceneViewController: CollageViewControllerDelegate {
    func collageViewController(_ controller: CollageViewController, changed cellsCount: Int) {
        // FIXME: add templates for selected assets
//        if let assets = templateBarController.templates.first?.assets {
//            templateBarController.templates = CollageTemplateProvider.templates(for: cellsCount, assets: assets)
//        }
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
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelect assets: [PHAsset]) {
        guard let asset = assets.first else {
            return
        }

        PhotoLibraryService.photo(from: asset, deliveryMode: .opportunistic) { [weak self] in
            self?.collageViewController.addImageToSelectedCell($0)
        }

        navigationController?.popViewController(animated: true)
    }
}

extension CollageSceneViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)

        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }

        PhotoLibraryService.add(image) { [weak self] success in
            assert(success, "Unable to write asset to photo library")
            self?.collageViewController.addImageToSelectedCell(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
