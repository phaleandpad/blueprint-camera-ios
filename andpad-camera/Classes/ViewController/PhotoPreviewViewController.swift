//
//  PhotoPreviewViewController.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2020/11/13.
//

import Photos
import RxCocoa
import RxSwift
import UIKit
import rakugaki

protocol ResizeImageFetcher {}

protocol PhotoPreviewViewControllerDelegate: AnyObject {
    func photoPreviewViewControllerDidFinish(photos: [TakeCameraViewController.Photo])
}

final class PhotoPreviewViewController: UIViewController {

    typealias Photo = TakeCameraViewController.Photo
    typealias FetchImageHandler = (_ key: String, _ completion: @escaping (_ image: UIImage?) -> Void) -> Void

    private let deleteButton: UIButton = .init(type: .custom)
    private let toEditButton: UIButton = .init(type: .custom)
    private var closeButton: UIBarButtonItem?

    private let mainImageScrollView: MainImageScrollView
    private let thumbnailScrollView: ThumbnailImageScrollView

    private var photos: [Photo]

    private let maxPhotoCount: Int

    private let imageStore: DiskImageStore
    weak var delegate: PhotoPreviewViewControllerDelegate?
    
    private let allowsEditing: Bool
    private let completion: ([Photo]) -> Void

    private let lock: NSRecursiveLock = .init()
    private let disposeBag = DisposeBag()

    init(
        photos: [Photo],
        imageStore: DiskImageStore,
        allowsEditing: Bool,
        maxPhotoCount: Int,
        completion: @escaping ([Photo]) -> Void
    ) {
        self.photos = photos
        self.imageStore = imageStore
        self.allowsEditing = allowsEditing
        self.maxPhotoCount = maxPhotoCount
        self.completion = completion

        mainImageScrollView = .init(imageStore: imageStore)
        thumbnailScrollView = .init(imageStore: imageStore)

        super.init(nibName: nil, bundle: nil)
        overrideUserInterfaceStyle = .light
        mainImageScrollView.setDelegate(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #unavailable(iOS 15) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up NavigationBar
        updateTitle()

        navigationController?.navigationBar.tintColor = .textColor

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }

        navigationItem.leftBarButtonItem = .init(
            image: UIImage(named: "icon_cancel", in: .andpadCamera, compatibleWith: nil),
            style: .plain,
            target: self,
            action: #selector(didTapCloseButton)
        )

        // set up Views
        view.backgroundColor = .white

        deleteButton.setImage(
            UIImage(named: "icon_delete", in: .andpadCamera, compatibleWith: nil),
            for: .normal
        )
        deleteButton.imageEdgeInsets = .init(top: 0.0, left: 0.0, bottom: 0.0, right: 16.0)
        deleteButton.setTitle(L10n.Common.delete, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 16.0)
        deleteButton.backgroundColor = .black.withAlphaComponent(0.6)
        deleteButton.layer.cornerRadius = 8.0

        [
            mainImageScrollView,
            thumbnailScrollView,
            deleteButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [
            mainImageScrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            mainImageScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mainImageScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mainImageScrollView.heightAnchor.constraint(
                equalTo: mainImageScrollView.widthAnchor,
                multiplier: 4 / 3
            ),
            deleteButton.widthAnchor.constraint(equalToConstant: 92),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.topAnchor.constraint(
                equalTo: mainImageScrollView.topAnchor,
                constant: 16.0
            ),
            deleteButton.rightAnchor.constraint(
                equalTo: mainImageScrollView.rightAnchor,
                constant: -16.0
            ),
            thumbnailScrollView.topAnchor.constraint(
                equalTo: mainImageScrollView.bottomAnchor,
                constant: 16.0
            ),
            thumbnailScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            thumbnailScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            thumbnailScrollView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16.0
            )
        ].forEach { $0.isActive = true }

        if allowsEditing {
            toEditButton.imageEdgeInsets = .init(top: 0.0, left: 0.0, bottom: 0.0, right: 16.0)
            toEditButton.setTitle(L10n.Common.draw, for: .normal)
            toEditButton.setImage(
                UIImage(named: "icon_edit", in: .andpadCamera, compatibleWith: nil)?.withTintColor(.white),
                for: .normal
            )
            toEditButton.titleLabel?.font = .systemFont(ofSize: 16.0)
            toEditButton.backgroundColor = .black.withAlphaComponent(0.6)
            toEditButton.layer.cornerRadius = 8.0

            view.addSubview(toEditButton)

            toEditButton.snp.makeConstraints { make in
                make.width.equalTo(125)
                make.height.equalTo(44)
                make.top.equalTo(mainImageScrollView.snp.top).offset(16)
                make.right.equalTo(deleteButton.snp.left).offset(-16)
            }
        }

        let bottomConstraint = thumbnailScrollView.heightAnchor.constraint(equalToConstant: 88.0)
        bottomConstraint.isActive = true

        thumbnailScrollView.didSelectImage = { [weak self] in
            self?.mainImageScrollView.move(to: $0)
        }

        toEditButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            let index = self.mainImageScrollView.currentPage
            let photo = self.photos[index]
            let url = DiskImageStore.url(for: photo.imageKey, pathExtension: .jpg)
            if self.photos.count < self.maxPhotoCount {
                self.showEditPhoto(image: loadImage(from: url)) { [weak self] image in
                    guard let self else { return }
                    guard let key = imageStore.save(
                        image,
                        cacheSize: MainImageScrollView.maximumImageSize,
                        exif: photo.exif,
                        withTamperProof: false
                    ) else {
                        return
                    }
                    self.photos.insert(photo.updating(imageKey: key), at: index + 1)

                    let keys = self.photos.map({ $0.imageKey })
                    mainImageScrollView.set(imageKeys: keys)
                    thumbnailScrollView.set(imageKeys: keys)
                    thumbnailScrollView.move(to: index)
                    self.updateTitle()
                }
            } else {
                self.showEditDisabledAlert()
            }
        })
        .disposed(by: disposeBag)
        
        deleteButton.addTarget(
            self,
            action: #selector(self.didTapDeleteButton),
            for: .touchUpInside
        )
        
        let keys = photos.map({ $0.imageKey })

        mainImageScrollView.set(imageKeys: keys)
        thumbnailScrollView.set(imageKeys: keys)

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.thumbnailScrollView.move(to: 0)
        }

        setAccessibilityIdentifiers()
    }

    private func loadImage(from url: URL) -> UIImage {
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch {
            print("Error : \(error.localizedDescription)")
        }
        return UIImage()
    }

    private func setAccessibilityIdentifiers() {
        deleteButton.viewAccessibilityIdentifier = .photoDeleteButton
        navigationItem.leftBarButtonItem?.viewAccessibilityIdentifier = .photoPreviewViewCloseButton
        navigationController?.navigationBar.viewAccessibilityIdentifier = .photoPreviewNavigationBar
    }

    private func updateTitle() {
        let currentPage = mainImageScrollView.currentPage + 1
        title = "\(min(currentPage, photos.count))/\(photos.count)"
    }

    private func showEditPhoto(
        image: UIImage,
        completedHandler: @escaping (UIImage) -> Void
    ) {
        let cameraVC = PhotoEditViewController
            .instantiate(
                editTarget: image,
                sendBtnTitle: L10n.Common.save,
                cancelHandler: { vc in
                    vc?.dismiss(animated: true)
                },
                completedHandler: { photoEditVC, image in
                    guard let image else {
                        photoEditVC?.dismiss(animated: true)
                        return
                    }
                    completedHandler(image)
                    photoEditVC?.dismiss(animated: true)
                }
            )
        let nav = UINavigationController(rootViewController: cameraVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }

    @objc private func didTapCloseButton() {
        delegate?.photoPreviewViewControllerDidFinish(photos: photos)
        dismiss(animated: true, completion: nil)
    }

    private func showEditDisabledAlert() {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Camera.drawDisabled,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.Common.ok,
                style: .cancel,
                handler: nil
            )
        )

        present(alert, animated: true)
    }

    @objc private func didTapDeleteButton() {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Photo.isDeletePhoto,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.Common.cancel,
                style: .cancel,
                handler: nil
            )
        )
        let deleteAction =
            UIAlertAction(
                title: L10n.Common.delete,
                style: .destructive,
                handler: { [weak self] _ in
                    guard let self else { return }
                    defer { self.lock.unlock() }
                    self.lock.lock()

                    let index = self.mainImageScrollView.currentPage
                    let photo = self.photos[index]

                    self.mainImageScrollView.removeCurrentImage()
                    self.thumbnailScrollView.remove(at: index)
                    self.photos.remove(at: index)
                    self.imageStore.delete(for: photo.imageKey, pathExtension: .jpg)

                    self.updateTitle()

                    if self.photos.isEmpty {
                        self.didTapCloseButton()
                    }
                }
            )
        deleteAction.viewAccessibilityIdentifier = .photoDeleteAlertDeleteButton
        alert.addAction(deleteAction)

        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoPreviewViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateTitle()
        thumbnailScrollView.move(to: mainImageScrollView.currentPage)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateTitle()
    }
}

extension PhotoPreviewViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        delegate?.photoPreviewViewControllerDidFinish(photos: photos)
    }
}
