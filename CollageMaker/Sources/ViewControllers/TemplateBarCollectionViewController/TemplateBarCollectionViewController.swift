//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

protocol TemplateBarCollectionViewControllerDelegate: AnyObject {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collage: CollageTemplate)
}

class TemplateBarCollectionViewController: UICollectionViewController {
    weak var delegate: TemplateBarCollectionViewControllerDelegate?

    var templates: [CollageTemplate] {
        didSet {
            collectionView?.reloadData()
        }
    }

    init(templates: [CollageTemplate] = []) {
        self.templates = templates

        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(TemplateBarCollectionViewCell.self, forCellWithReuseIdentifier: TemplateBarCollectionViewCell.identifier)
        collectionView?.backgroundColor = .clear
        collectionView?.alwaysBounceHorizontal = true

        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateBarCollectionViewCell.identifier, for: indexPath)

        guard let templateBarCell = cell as? TemplateBarCollectionViewCell else {
            return cell
        }

        templateBarCell.collageTemplate = templates[indexPath.row]

        return templateBarCell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.templateBarCollectionViewController(self, didSelect: templates[indexPath.row])
    }
}

extension TemplateBarCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height - 40, height: collectionView.frame.height - 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
