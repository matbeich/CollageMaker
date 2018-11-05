//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit

protocol TemplateBarCollectionViewControllerDelegate: AnyObject {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collage: CollageTemplate)
}

class TemplateBarCollectionViewController: UICollectionViewController {
    weak var delegate: TemplateBarCollectionViewControllerDelegate?

    var assets: [PHAsset]? {
        return templates.first?.assets
    }

    var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet {
            setScrollDirection()
        }
    }

    var templates: [CollageTemplate] {
        didSet {
            collectionView?.reloadData()
        }
    }

    init(context: AppContext, templates: [CollageTemplate] = []) {
        self.context = context
        self.templates = templates
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        collectionView?.register(TemplateBarCollectionViewCell.self, forCellWithReuseIdentifier: TemplateBarCollectionViewCell.identifier)
        collectionView?.backgroundColor = .clear
        collectionView?.accessibilityIdentifier = Accessibility.View.templateCollectionView.id
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false

        setScrollDirection()
    }

    private func setScrollDirection() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.scrollDirection = scrollDirection

        switch scrollDirection {
        case .horizontal:
            collectionView?.alwaysBounceHorizontal = true
            collectionView?.alwaysBounceVertical = false

        case .vertical:
            collectionView?.alwaysBounceHorizontal = false
            collectionView?.alwaysBounceVertical = true
        }
    }

    private func getImageForTemplate(_ template: CollageTemplate, callback: @escaping (UIImage?) -> Void) {
        context.templateProvider.collage(from: template, size: .medium) { [weak self] collage in

            let collageView = CollageView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 150)))
            collageView.collage = collage
            collageView.saveCellsVisibleFrames()

            self?.context.collageRenderer.renderAsyncImage(from: collageView.collage, with: collageView.bounds.size, borders: true) { image in
                callback(image)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateBarCollectionViewCell.identifier, for: indexPath)

        guard let templateBarCell = cell as? TemplateBarCollectionViewCell else {
            return cell
        }

        templateBarCell.setupIdentifier(with: indexPath.row)
        getImageForTemplate(templates[indexPath.row]) { templateBarCell.collageImage = $0 }

        return templateBarCell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.templateBarCollectionViewController(self, didSelect: templates[indexPath.row])
    }

    private let context: AppContext
}

extension TemplateBarCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let value = min(collectionView.frame.height, collectionView.frame.width) * 0.8

        return CGSize(width: value, height: value)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
