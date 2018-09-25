//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit
import Utils

protocol ImagePickerCollectionViewControllerDelegate: AnyObject {
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelectAssets assets: [PHAsset])
    func imagePickerCollectionViewControllerDidCancel(_ controller: ImagePickerCollectionViewController)
}

class ImagePickerCollectionViewController: CollageBaseViewController {
    weak var delegate: ImagePickerCollectionViewControllerDelegate?

    var photoAssets: [PHAsset] {
        willSet {
            PhotoLibraryService.stopCaching()
        }
        didSet {
            PhotoLibraryService.cacheImages(for: photoAssets)
            collectionView.reloadData()
        }
    }

    var selectedAssets: [PHAsset] {
        return selectedCellsIndexPaths.compactMap { asset(for: $0) }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    init(assets: [PHAsset]) {
        self.photoAssets = assets

        let layout = CustomInsetsGridLayout(insets: UIEdgeInsets(top: 2, left: 2, bottom: 50, right: 2))
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        view.addSubview(collectionView)
    }

    func changeLayout(to: UICollectionViewFlowLayout) {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(to, animated: false)
    }

    @objc private func cancel() {
        delegate?.imagePickerCollectionViewControllerDidCancel(self)
    }

    private func setup() {
        let title = NavigationBarLabelItem(title: "All Photos", color: .black, font: R.font.sfProDisplaySemibold(size: 19))
        let left = NavigationBarButtonItem(title: "Cancel", font: R.font.sfProDisplaySemibold(size: 19), target: self, action: #selector(cancel))

        navBarItem = NavigationBarItem(left: left, title: title)

        collectionView.backgroundColor = .white
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true

        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
    }

    private func asset(for indexPath: IndexPath) -> PHAsset? {
        return photoAssets[indexPath.row]
    }

    private(set) var collectionView: UICollectionView
    private var selectedCellsIndexPaths: [IndexPath] = []
}

extension ImagePickerCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.identifier, for: indexPath)

        guard let pickerCell = cell as? ImagePickerCollectionViewCell else {
            return cell
        }

        pickerCell.photoAsset = photoAssets[indexPath.row]
        if selectedCellsIndexPaths.contains(indexPath) {
            DispatchQueue.main.async {
                pickerCell.cellSelected = true
            }
        }

        return pickerCell
    }
}

extension ImagePickerCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell else {
            return
        }

        if selectedCellsIndexPaths.contains(indexPath) {
            selectedCellsIndexPaths = selectedCellsIndexPaths.filter { $0 != indexPath }
        } else if selectedCellsIndexPaths.count < 8 {
            selectedCellsIndexPaths.append(indexPath)
        } else {
            return
        }

        cell.toogleSelection()
        delegate?.imagePickerCollectionViewController(self, didSelectAssets: selectedAssets)
    }
}
