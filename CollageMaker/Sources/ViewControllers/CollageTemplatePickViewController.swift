//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import SnapKit
import UIKit
import Utils

protocol CollageTemplatePickViewControllerDelegate: AnyObject {
    func collageImagePickSceneViewController(_ controller: CollageTemplatePickViewController, templateController: TemplateBarCollectionViewController, didSelectTemplate: Collage)
}

class CollageTemplatePickViewController: CollageBaseViewController {
    weak var delegate: CollageTemplatePickViewControllerDelegate?

    init(imagePickerController: ImagePickerCollectionViewController) {
        self.imagePickerController = imagePickerController
        super.init(nibName: nil, bundle: nil)

        imagePickerController.delegate = self
        templateController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        view.addSubview(mainControllerContainer)
        view.addSubview(templateControllerContainer)

        makeConstraints()

        addChild(imagePickerController, to: mainControllerContainer)
        addChild(templateController, to: templateControllerContainer.templateContainerView)
    }

    private func setup() {
        let left = NavigationBarButtonItem(icon: R.image.camera_btn(), target: self, action: #selector(openCamera))
        let title = NavigationBarLabelItem(title: "All Photos", color: .black, font: R.font.sfProDisplaySemibold(size: 19))
        let right = NavigationBarViewItem(view: gradientButton)

        gradientButton.addTarget(self, action: #selector(selectTemplate), for: .touchUpInside)

        navBarItem = NavigationBarItem(left: left, right: right, title: title)
    }

    @objc private func selectTemplate() {
        guard let template = templateController.templates.first else {
            return
        }

        select(template: template)
    }

    @objc private func openCamera() {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self

        present(controller, animated: true)
    }

    private func showTemplateController() {
        templateControllerContainer.center.y = view.bounds.height - templateControllerContainer.bounds.size.height / 2
    }

    private func select(template: CollageTemplate) {
        CollageTemplateProvider.collage(from: template, size: .large) { [weak self] collage in
            guard let sself = self else {
                return
            }

            sself.delegate?.collageImagePickSceneViewController(sself, templateController: sself.templateController, didSelectTemplate: collage)
        }
    }

    private func makeConstraints() {
        templateControllerContainer.bounds.size = CGSize(width: view.bounds.width, height: view.bounds.height / 3.5)
        templateControllerContainer.center = CGPoint(x: view.center.x, y: view.frame.maxY + templateControllerContainer.bounds.size.height / 2 - 50)

        mainControllerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private var selectedAssets: [PHAsset] = [] {
        willSet {
            PhotoLibraryService.stopCaching()
        } didSet {
            PhotoLibraryService.cacheImages(for: self.selectedAssets)
            gradientButton.setTitle(String(selectedAssets.count), for: .normal)
        }
    }

    private let gradientButton: GradientButton = {
        let button = GradientButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 25)))
        button.setTitle("0", for: .normal)
        button.setImage(R.image.confirm_btn(), for: .normal)
        button.showShadow = false
        button.titleLabel?.font = R.font.sfProTextBold(size: 19)

        return button
    }()

    private let mainControllerContainer = UIView(frame: .zero)
    private let templateControllerContainer = TemplateControllerView(frame: .zero, headerText: "Choose template")
    private var imagePickerController: ImagePickerCollectionViewController
    private var templateController = TemplateBarCollectionViewController(templates: [])
}

extension CollageTemplatePickViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelect assets: [PHAsset]) {
        selectedAssets = assets

        let templates = CollageTemplateProvider.templates(for: selectedAssets.count, assets: selectedAssets)

        if !templates.isEmpty {
            UIView.animate(withDuration: 0.2,
                           animations: { self.showTemplateController() },
                           completion: { _ in self.templateController.templates = templates })
        } else {
            UIView.animate(withDuration: 0.2,
                           animations: { self.makeConstraints() },
                           completion: { _ in self.templateController.templates = [] })
        }
    }
}

extension CollageTemplatePickViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        CollageTemplateProvider.collage(from: collageTemplate, size: .large) { [weak self] collage in
            guard let sself = self else {
                return
            }

            sself.delegate?.collageImagePickSceneViewController(sself, templateController: controller, didSelectTemplate: collage)
        }
    }
}

extension CollageTemplatePickViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)

        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }

        PhotoLibraryService.add(image) { [weak self] success in
            assert(success, "Unable to write asset to photo library")

            self?.imagePickerController.photoAssets = PhotoLibraryService.getImagesAssets()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
