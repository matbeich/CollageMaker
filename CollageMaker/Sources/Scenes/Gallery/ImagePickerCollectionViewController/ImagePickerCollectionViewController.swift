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

    var maxSelectedCellsAllowed: Int {
        return mode.maxSelectedCells
    }

    enum SelectionMode {
        case single
        case multiply(Int)

        var maxSelectedCells: Int {
            switch self {
            case let .multiply(number): return number
            default: return 1
            }
        }
    }

    var photoAssets: [PHAsset] = [] {
        willSet {
            library.stopCaching()
        }
        didSet {
            library.cacheImages(with: photoAssets)
            updateSelection()
            collectionView.reloadData()
        }
    }

    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            collectionView.contentInset = contentInsets
        }
    }

    init(library: PhotoLibraryType = PhotoLibrary(), selectionMode: SelectionMode) {
        self.library = library
        self.mode = selectionMode
        self.photoAssets = library.assets.reversed()

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.accessibilityIdentifier = Accessibility.View.imageCollectionView.id

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc private func cancel() {
        delegate?.imagePickerCollectionViewControllerDidCancel(self)
    }

    private func select(_ indexPath: IndexPath) {
        if !isSelected(indexPath) {
            selectedCellsIndexPaths.append(indexPath)
        }
    }

    private func unselsect(_ indexPath: IndexPath) {
        if let index = selectedCellsIndexPaths.firstIndex(of: indexPath) {
            selectedCellsIndexPaths.remove(at: index)
        }
    }

    private func isSelected(_ indexPath: IndexPath) -> Bool {
        return selectedCellsIndexPaths.contains(indexPath)
    }

    private func select(cell: ImagePickerCollectionViewCell, at indexPath: IndexPath) {
        switch mode {
        case .single:
            selectedCellsIndexPaths = [indexPath]

        case let .multiply(maxSelectedCount) where selectedCellsIndexPaths.count < maxSelectedCount:
            cell.toggleSelection()

            isSelected(indexPath) ? unselsect(indexPath) : select(indexPath)
        case let .multiply(maxSelectedCount) where selectedCellsIndexPaths.count == maxSelectedCount:
            if isSelected(indexPath) {
                unselsect(indexPath)
                cell.toggleSelection()
            }

        default: break
        }
    }

    private func setup() {
        view.backgroundColor = .white
        library.delegate = self

        navBarItem.left = NavigationBarButtonItem(title: "Cancel", font: R.font.sfProDisplaySemibold(size: 19), target: self, action: #selector(cancel))
        navBarItem.title = "All Photos"

        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
    }

    private func updateSelection() {
        selectedCellsIndexPaths = selectedAssets.compactMap { indexPath(for: $0) }
        selectedAssets = selectedCellsIndexPaths.compactMap { asset(for: $0) }
    }

    private func indexPath(for asset: PHAsset) -> IndexPath? {
        guard let assetIndex = photoAssets.index(of: asset) else {
            return nil
        }

        return IndexPath(row: assetIndex, section: 0)
    }

    private func asset(for indexPath: IndexPath) -> PHAsset? {
        return photoAssets[indexPath.row]
    }

    private(set) var selectedAssets: [PHAsset] = [] {
        didSet {
            guard selectedAssets != oldValue else {
                return
            }

            delegate?.imagePickerCollectionViewController(self, didSelectAssets: selectedAssets)
        }
    }

    private var selectedCellsIndexPaths: [IndexPath] = [] {
        didSet {
            selectedAssets = selectedCellsIndexPaths.compactMap { asset(for: $0) }
        }
    }

    private(set) var library: PhotoLibraryType
    private(set) var mode: SelectionMode
    private(set) var collectionView: UICollectionView
}

extension ImagePickerCollectionViewController: PhotoLibraryDelegate {
    func photoLibrary(_ library: PhotoLibrary, didUpdateAssets assets: [PHAsset]) {
        photoAssets = assets.reversed()
    }

    func photoLibrary(_ library: PhotoLibrary, didRemoveAssets assets: [PHAsset]) {
        assets.compactMap { photoAssets.index(of: $0) }.forEach { photoAssets.remove(at: $0) }
    }

    func photoLibrary(_ library: PhotoLibrary, didInsertAssets assets: [PHAsset]) {
        assets.forEach { photoAssets.insert($0, at: 0) }
    }
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

        let assetForCell = photoAssets[indexPath.row]
        pickerCell.setupIdentifier(with: indexPath.row)

        library.photo(with: assetForCell, deliveryMode: .opportunistic, size: pickerCell.bounds.size.scaled(by: 3)) { image in
            pickerCell.image = image
        }

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

        select(cell: cell, at: indexPath)
    }
}

extension ImagePickerCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 2 * 3) / 4

        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
