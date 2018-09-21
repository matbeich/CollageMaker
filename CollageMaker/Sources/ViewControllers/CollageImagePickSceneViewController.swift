//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import SnapKit
import UIKit
import Utils

protocol CollageImagePickSceneViewControllerDelegate: AnyObject {
    func collageImagePickSceneViewController(_ controller: CollageImagePickSceneViewController, templateBar: TemplateBarCollectionViewController, didSelectTemplate: Collage)
}

class CollageImagePickSceneViewController: CollageBaseViewController {
    weak var delegate: CollageImagePickSceneViewControllerDelegate?

    init(main: ImagePickerCollectionViewController) {
        mainController = main

        super.init(nibName: nil, bundle: nil)
        mainController.delegate = self
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

        addChild(mainController, to: mainControllerContainer)
        addChild(templateController, to: templateControllerContainer.templateContainerView)

        templateController.delegate = self
    }

    private func setup() {
        let left = NavigationBarButtonItem(icon: R.image.camera_btn(), target: self, action: nil)
        let title = NavigationBarLabelItem(title: "All Photos", color: .black, font: R.font.sfProDisplaySemibold(size: 19))
        let right = NavigationBarViewItem(view: gradientButton)

        navBarItem = NavigationBarItem(left: left, right: right, title: title)
    }

    // FIXME: add logic
    @objc private func openCamera() {
    }

    private func showTemplateController() {
        templateControllerContainer.center.y = view.bounds.height - templateControllerContainer.bounds.size.height / 2
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
    private var mainController: ImagePickerCollectionViewController
    private var templateController = TemplateBarCollectionViewController(templates: [])
}

extension CollageImagePickSceneViewController: ImagePickerCollectionViewControllerDelegate {
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

extension CollageImagePickSceneViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        CollageTemplateProvider.collage(from: collageTemplate, size: .large) { [weak self] collage in
            if let sself = self {
                sself.delegate?.collageImagePickSceneViewController(sself, templateBar: controller, didSelectTemplate: collage)
            }
        }
    }
}
