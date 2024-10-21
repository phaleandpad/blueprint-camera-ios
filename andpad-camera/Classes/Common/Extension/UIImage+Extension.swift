//
//  UIImage+Extension.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/24.
//

import Foundation
import MobileCoreServices

extension UIImage {
    /// 指定された画像を現在のUIImageオブジェクトに合成する
    ///
    /// - Parameters:
    ///   - image: 合成するUIImageオブジェクト。
    ///   - ratio: 合成する画像のスケール比率。1.0で元のサイズ、それ以外でスケール変更される。
    ///   - targetX: 合成する画像のX座標位置。現在のUIImageオブジェクトの左上隅を基準とする。
    ///   - targetY: 合成する画像のY座標位置。現在のUIImageオブジェクトの左上隅を基準とする。
    ///
    /// このメソッドは、現在のUIImageオブジェクトに別の画像を合成した新しいUIImageオブジェクトを返す。
    /// 合成される画像は、指定された`ratio`に従ってスケーリングされ、`targetX`と`targetY`の位置に配置される。
    ///
    /// - Returns: 合成後のUIImageオブジェクト
    func combineImage(image: UIImage, ratio: CGFloat, targetX: CGFloat, targetY: CGFloat) -> UIImage {
        // Note: UIGraphicsBeginImageContextWithOptions(_:_:_:)（iOS4.0-17.0 Deprecated）をUIGraphicsImageRendererに変更したいが、そうすると写真撮影時の処理が遅くなるため、一旦このままにしておく。
        // 指定された画像の大きさのコンテキストを用意.
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        // コンテキストに画像を描画する.
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .high
        draw(in: .init(origin: .zero, size: size))
        image.draw(in: .init(x: targetX, y: targetY, width: image.size.width * ratio, height: image.size.height * ratio))
        // コンテキストからUIImageを作る.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // コンテキストを閉じる.
        UIGraphicsEndImageContext()

        return newImage!
    }

    /** 画像をトリミングする */
    func trim(rect: CGRect) -> UIImage {
        let srcImageRef = self.cgImage!
        let trimmedImageRef = srcImageRef.cropping(to: rect)
        let trimmedImage = UIImage(cgImage: trimmedImageRef!)
        return trimmedImage
    }

    /// 画像を指定された角度で回転させる
    /// - Parameter degrees: 回転する角度 (度単位)
    /// - Returns: 回転後の画像
    func imageRotatedByDegrees(deg degrees: CGFloat) -> UIImage {
        // 回転後のビューが収まるべき矩形のサイズを計算する
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let affineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = affineTransform
        let rotatedSize = rotatedViewBox.frame.size

        let renderer = UIGraphicsImageRenderer(size: rotatedSize)
        return renderer.image { [weak self] context in
            guard let self else { return }
            // 描画コンテキストを回転の中心点まで移動する
            context.cgContext.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            // 指定された角度で描画コンテキストを回転する
            context.cgContext.rotate(by: degrees * CGFloat.pi / 180)
            // 元の画像を回転させた位置に描画する
            draw(at: CGPoint(x: -self.size.width / 2, y: -self.size.height / 2))
        }
    }

    /// UIImageを指定されたサイズにリサイズする
    /// - Parameter originalSize: リサイズ前のサイズ
    /// - Returns: リサイズ後のUIImage
    func resize(size originalSize: CGSize) -> UIImage? {
        let widthRatio = originalSize.width / size.width
        let heightRatio = originalSize.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        // リサイズ後のサイズを計算する
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: resizedSize)
        return renderer.image { [weak self] _ in
            // リサイズ後のサイズでUIImageを描画する
            self?.draw(in: CGRect(origin: .zero, size: resizedSize))
        }
    }

    func toData(exif: NSDictionary) throws -> Data {
        return try autoreleasepool(invoking: { () -> Data in

            guard let cgImage else {
                throw ImageConvertError.cgImageIsNull
            }
            let data = NSMutableData()

            guard let imageDestinationRef =
                    CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeJPEG, 1, nil) else {
                throw ImageConvertError.cgImageDestinationCreateFailed
            }
            CGImageDestinationAddImage(imageDestinationRef, cgImage, exif)
            CGImageDestinationFinalize(imageDestinationRef)
            return data as Data
        })
    }
}

enum ImageConvertError: LocalizedError {
    case cgImageIsNull
    case cgImageDestinationCreateFailed

    var errorDescription: String? {
        switch self {
        case .cgImageIsNull: return "cgImageIsNull"
        case .cgImageDestinationCreateFailed: return "CGImageDestinationCreateFailed"
        }
    }
}
