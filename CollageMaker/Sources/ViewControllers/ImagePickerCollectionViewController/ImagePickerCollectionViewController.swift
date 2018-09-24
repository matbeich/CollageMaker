//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit
import Utils

protocol ImagePickerCollectionViewControllerDelegate: AnyObject {
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelect assets: [PHAsset])
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
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

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

    @objc private func dismissController() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func setup() {
        let title = NavigationBarLabelItem(title: "All Photos", color: .black, font: R.font.sfProDisplaySemibold(size: 19))
        let left = NavigationBarButtonItem(icon: R.image.back_btn(), target: self, action: #selector(dismissController))

        navBarItem = NavigationBarItem(left: left, title: title)

        collectionView.backgroundColor = .white
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true

        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
    }

    private func asset(for indexPath: IndexPath) -> PHAsset? {
        return photoAssets[indexPath.row]
    }

    @objc private func updateAssets() {
        photoAssets = PhotoLibraryService.getImagesAssets()
    }

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateAssets), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh photos")

        return refreshControl
    }()

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
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }

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
        delegate?.imagePickerCollectionViewController(self, didSelect: selectedAssets)
    }
}

extension ImagePickerCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 2 * 5) / 4

        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(repeated: 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
