//
//  DiskImageStore.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2020/11/24.
//

import Foundation
import TamperProof

final class DiskImageStore {

    typealias Key = String

    let saveImageProgress = Progress()

    private let cache: NSCache<NSString, UIImage> = .init()
    private let queue: DispatchQueue = .init(
        label: Bundle.andpadCamera.bundleIdentifier(appending: "ImageStore"),
        qos: .userInitiated
    )

    init() {
        cache.countLimit = 10
    }

    deinit {
        cache.removeAllObjects()
    }

    func save(_ image: UIImage, cacheSize: CGSize, exif: NSDictionary, withTamperProof: Bool) -> Key? {
        let key = UUID().uuidString
        saveImageProgress.incrementUnitCount()

        queue.async { [weak self] in
            guard let self else { return }
            defer { saveImageProgress.incrementCompletedUnitCount() }

            do {
                if withTamperProof {
                    let suffix = "_src"
                    let sourceUrl = DiskImageStore.url(for: key, suffix: suffix, pathExtension: .jpg)
                    let destinationUrl = DiskImageStore.url(for: key, pathExtension: .jpg)

                    try image
                        .toData(exif: exif)
                        .write(to: sourceUrl, options: .init())
                    try TamperUtil.writeHashValue(
                        src: sourceUrl.path,
                        dest: destinationUrl.path
                    )
                    self.delete(for: key, suffix: suffix, pathExtension: .jpg)
                } else {
                    try image
                        .toData(exif: exif)
                        .write(to: DiskImageStore.url(for: key, pathExtension: .jpg), options: .init())
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }

            if let resizedImage = image.resize(size: cacheSize) {
                self.cache.setObject(resizedImage, forKey: .init(string: key))
            }
        }
        return key
    }

    func saveSVG(
        captureImage: UIImage,
        blackboardImage: UIImage,
        blackboardImageOrigin: CGPoint,
        exif: NSDictionary
    ) -> Key? {
        let svgKey = UUID().uuidString
        saveImageProgress.incrementUnitCount()

        queue.async { [weak self] in
            guard let self else { return }
            defer { saveImageProgress.incrementCompletedUnitCount() }

            do {
                let sourceFileSuffix = "_src"

                func saveSourceImage(
                    _ image: UIImage,
                    with exif: NSDictionary
                ) throws -> (key: Key, sourceURL: URL) {
                    let key = UUID().uuidString
                    let sourceURL = DiskImageStore.url(
                        for: key,
                        suffix: sourceFileSuffix,
                        pathExtension: .jpg
                    )

                    try image
                        .toData(exif: exif)
                        .write(to: sourceURL, options: .init())

                    return (key, sourceURL)
                }

                let captureImageSource = try saveSourceImage(captureImage, with: exif)
                let blackboardImageSource = try saveSourceImage(blackboardImage, with: exif)

                let proofedSVGImageResult = try TamperUtil.svgCalculateHashValue(
                    src: captureImageSource.sourceURL.path,
                    blackboard: blackboardImageSource.sourceURL.path
                )

                let svg = BlackboardSVGPhotoBuilder(
                    proofHashCode: proofedSVGImageResult.hashCode,
                    captureImageData: proofedSVGImageResult.embeddedSrcImageData,
                    captureImageSize: captureImage.size,
                    blackboardImageData: proofedSVGImageResult.embeddedBlackboardImageData,
                    blackboardImageRect: .init(origin: blackboardImageOrigin, size: blackboardImage.size)
                ).buildSVG()

                try svg.write(
                    to: DiskImageStore.url(for: svgKey, pathExtension: .svg),
                    atomically: true,
                    encoding: .utf8
                )

                [captureImageSource, blackboardImageSource].forEach {
                    self.delete(for: $0.key, suffix: sourceFileSuffix, pathExtension: .jpg)
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }

        return svgKey
    }

    func delete(for key: Key, suffix: String = "", pathExtension: PathExtensionType) {

        queue.async { [weak self] in
            try? FileManager.default.removeItem(at: DiskImageStore.url(for: key + suffix, pathExtension: pathExtension))
            self?.cache.removeObject(forKey: .init(string: key + suffix))
        }
    }

    func resizedImage(for key: String, targetSize: CGSize, result: @escaping (_ image: UIImage?) -> Void) {

        func resizeIfNeeded(image: UIImage) -> UIImage? {
            let shouldResize: Bool = {
                image.size.width > targetSize.width || image.size.height > targetSize.height
            }()

            return shouldResize ? image.resize(size: targetSize) : image
        }

        queue.async { [weak self] in

            if let image = self?.cache.object(forKey: .init(string: key)) {
                result(resizeIfNeeded(image: image))
                return
            }

            guard let data = try? Data(contentsOf: DiskImageStore.url(for: key, pathExtension: .jpg)),
                  let loadedImage = UIImage(data: data)
            else {
                result(nil)
                return
            }

            result(resizeIfNeeded(image: loadedImage))
        }
    }

    static func url(for key: Key, suffix: String = "", pathExtension: PathExtensionType) -> URL {

        let directory = workDirectory()

        return directory
            .appendingPathComponent(key + suffix)
            .appendingPathExtension(pathExtension.rawValue)
    }

    static func clear() {
        let directory = workDirectory()
        try? FileManager.default.removeItem(atPath: directory.path)
    }

    private static func workDirectory() -> URL {
        let directory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("andpad-camera-temp")
        
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(
                    atPath: directory.path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }

        return directory
    }
}

extension DiskImageStore {
    enum PathExtensionType: String {
        case jpg
        case svg
    }
}

private struct BlackboardSVGPhotoBuilder {
    let proofHashCode: String
    let captureImageData: Data
    let captureImageSize: CGSize
    let blackboardImageData: Data
    let blackboardImageRect: CGRect

    // swiftlint:disable line_length
    func buildSVG() -> String {
        """
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.2" baseProfile="tiny" width="\(captureImageSize.width)" height="\(captureImageSize.height)" viewBox="0 0 \(captureImageSize.width) \(captureImageSize.height)" style="transform: rotate(0deg); transform-origin: 50% 50%;">
          <x:xmpmeta xmlns:x="adobe:ns:meta/">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
              <rdf:Description rdf:about="" xmlns:dcpm="http://dcpadv.org/schema/3.1/metadata">
                <dcpm:vender>\(MetaData.vender)</dcpm:vender>
                <dcpm:software>\(MetaData.software)</dcpm:software>
                <dcpm:metaVersion>\(MetaData.metaVersion)</dcpm:metaVersion>
                <dcpm:stdVersion>\(MetaData.stdVersion)</dcpm:stdVersion>
                <dcpm:hashCode>\(proofHashCode)</dcpm:hashCode>
              </rdf:Description>
            </rdf:RDF>
          </x:xmpmeta>
          <g id="dcp_org_img">
            <image x="0" y="0" width="\(captureImageSize.width)" height="\(captureImageSize.height)" xlink:href="data:image/jpeg;base64,\(base64CaptureImageData())" />
          </g>
          <g id="dcp_chalkboard_img">
            <image x="\(blackboardImageRect.origin.x)" y="\(blackboardImageRect.origin.y)" width="\(blackboardImageRect.width)" height="\(blackboardImageRect.height)" xlink:href="data:image/jpeg;base64,\(base64BlackboardImageData())" />
          </g>
        </svg>

        """
    }
    // swiftlint:enable line_length
}

private extension BlackboardSVGPhotoBuilder {
    enum MetaData {
        static let vender = "株式会社アンドパッド"
        static let software = "ANDPAD"
        static let metaVersion = "3.1"
        static let stdVersion = "1.5"
    }

    func base64CaptureImageData() -> String {
        captureImageData.base64EncodedString()
    }

    func base64BlackboardImageData() -> String {
        blackboardImageData.base64EncodedString()
    }
}

private extension Progress {
    func incrementUnitCount() {
        totalUnitCount += 1
    }

    func incrementCompletedUnitCount() {
        completedUnitCount += 1
    }
}
