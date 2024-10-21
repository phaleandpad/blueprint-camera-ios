//
//  MoveBaseView.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/20.
//

import UIKit

public class BlackboardBaseView: UIView, Movable {
    /// サイズ調整ハンドルのサイズ
    private let handleSize: CGFloat = 40.0

    /// ドラッグ操作の種類を表す列挙子
    private enum DragOperation {
        /// 移動
        case move
        /// サイズ変更
        ///
        /// - Parameter grabbingCorner: 掴んでいる黒板の角
        case resize(grabbingCorner: Corner)
        /// なし
        case none
    }

    /// 黒板の角の種類を表す列挙子
    enum Corner {
        /// 左上隅
        case topLeft
        /// 右上隅
        case topRight
        /// 左下隅
        case bottomLeft
        /// 右下隅
        case bottomRight
    }

    /// 実行中のドラッグ操作の種類
    private var currentDragOperation: DragOperation = .none

    // MARK: Movable

    var moveEndPoint: CGPoint?
    var updateDrawingItem: CGPoint?
    var moveCompletedHandler: ((Movable) -> Void)?
    var tapHandler: (() -> Void)?
    var moveEnabled = false
    var moveGesture: UIPanGestureRecognizer?

    // MARK: リサイズ関連

    var resizeEnabled = false {
        didSet {
            resizeEnabledDidChange()
        }
    }

    var resizeCompletedHandler: (() -> Void)?

    /// 禁止エリア
    ///
    /// 黒板がはみ出してはいけないエリアのこと
    var prohibitArea: CGRect?

    var orientation: UIDeviceOrientation!

    /// 黒板のアスペクト比
    ///
    /// 要件: 長辺:短辺＝30:23に設定する
    private var aspectRatio: CGSize {
        frame.width >= frame.height ?
            .init(width: 30, height: 23) :
            .init(width: 23, height: 30)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTapGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTapGestureRecognizer()
    }

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard resizeEnabled else {
            // サイズ変更が無効の場合は、デフォルトのhitTestを実行
            return super.hitTest(point, with: event)
        }
        // サイズ変更が有効な場合
        // ボタンのタップ可能な範囲はは44pt以上が適切
        let inset: CGFloat = 44 / 2
        if bounds.insetBy(dx: -inset, dy: -inset).contains(point) {
            // タッチポイントが黒板からはみ出した領域にあっても、黒板のリサイズを可能にする
            return self
        } else {
            return super.hitTest(point, with: event)
        }
    }

    func enableMove() {
        isUserInteractionEnabled = true
        moveEnabled = true
        moveGesture = UIPanGestureRecognizer(target: self, action: #selector(dragEvent(_:)))
        addGestureRecognizer(moveGesture!)
    }

    func disableMove() {
        moveEnabled = false
        backgroundColor = nil
        if let moveGesture {
            removeGestureRecognizer(moveGesture)
        }
        moveGesture = nil
    }

    private func endDrag(point: CGPoint) {
        moveEndPoint = point
        moveCompletedHandler?(self)
    }

    @objc private func dragEvent(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // ドラッグ開始の場合
            let location = recognizer.location(in: self)
            if resizeEnabled, let grabbingCorner = grabbingCorner(at: location) {
                // タッチポイントがドラッグハンドル上かその周辺にある場合、黒板のリサイズを可能とする
                currentDragOperation = .resize(grabbingCorner: grabbingCorner)
            } else {
                // Note: リサイズのドラッグ操作のためにhitTestを上書きしタップ判定範囲をboundsより広げている
                if bounds.contains(location) {
                    // タッチポイントが黒板の内側にある場合のみ移動可能とする
                    currentDragOperation = .move
                }
            }
        case .changed:
            // ドラッグ中の場合
            switch currentDragOperation {
            case .move:
                moveView(recognizer)
            case .resize(let grabbingCorner):
                resizeView(recognizer, grabbingCorner: grabbingCorner)
            case .none:
                break
            }
        case .ended:
            // ドラッグ終了の場合（ユーザーが指を離した場合）
            switch currentDragOperation {
            case .move:
                if let targetView = recognizer.view {
                    endDrag(point: targetView.frame.origin)
                }
            case .resize:
                resizeCompletedHandler?()
            case .none:
                break
            }

            currentDragOperation = .none
        default:
            // その他の場合、念のため `.none` に戻す
            currentDragOperation = .none
        }
    }

    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEvent))
        self.addGestureRecognizer(tapGesture)
    }

    @objc func tapEvent(_ recognizer: UITapGestureRecognizer) {
        // Note: リサイズのドラッグ操作のためにhitTestを上書きしタップ判定範囲をboundsより広げている
        let tapLocation = recognizer.location(in: self)
        if bounds.contains(tapLocation) {
            // タッチポイントが黒板の内側にある場合のみタップ可能とする
            tapHandler?()
        }
    }

    /// ユーザー操作によるサイズ変更の有効・無効を変更したときのイベント
    func resizeEnabledDidChange() {}
}

// MARK: - リサイズ

extension BlackboardBaseView {
    /// ユーザーの指の位置が黒板のどの角に近いかを判定し、対応する角を返す
    ///
    /// - Parameter location: ユーザーの指の位置
    /// - Returns: 掴んでいる黒板の角（角でなければ `nil` ）
    private func grabbingCorner(at location: CGPoint) -> Corner? {
        let isNearTop = location.y < handleSize
        let isNearLeft = location.x < handleSize
        let isNearBottom = bounds.height - location.y < handleSize
        let isNearRight = bounds.width - location.x < handleSize

        if isNearTop, isNearLeft {
            return .topLeft
        } else if isNearTop, isNearRight {
            return .topRight
        } else if isNearBottom, isNearLeft {
            return .bottomLeft
        } else if isNearBottom, isNearRight {
            return .bottomRight
        } else {
            return nil
        }
    }

    /// ビューのサイズを変更する
    ///
    /// 黒板のアスペクト比を保った状態で行われる。
    /// 黒板が禁止エリアに入らないように調整される。
    /// 黒板のサイズが最小サイズの要件を満たしていない場合、サイズ変更を行わない。
    ///
    /// - Parameters:
    ///   - recognizer: ドラッグ操作を認識する `UIPanGestureRecognizer`
    ///   - grabbingCorner: 掴んでいる黒板の角
    private func resizeView(_ recognizer: UIPanGestureRecognizer, grabbingCorner: Corner) {
        let translation = recognizer.translation(in: self)
        guard let targetView = recognizer.view else {
            return
        }

        // アスペクト比に応じて調整した、X軸、Y軸の移動量
        let adjustedTranslation = getAdjustedTranslation(
            translation: translation,
            grabbingCorner: grabbingCorner,
            aspectRatio: aspectRatio
        )

        var newFrame = updatedFrameForResize(
            targetFrame: targetView.frame,
            grabbingCorner: grabbingCorner,
            translation: adjustedTranslation
        )

        // バリデーションチェック
        guard isAboveMinimumSize(targetSize: newFrame.size) else {
            return
        }

        if
            let prohibitArea,
            !isFrameWithinProhibitArea(targetFrame: newFrame, prohibitArea: prohibitArea) {
            // 新しいフレームがカメラのキャプチャエリアの境界を超えている場合
            // 端にピッタリになるように移動量を調整する
            newFrame = adjustedFrameToFitWithinProhibitArea(
                targetFrame: newFrame,
                prohibitArea: prohibitArea,
                grabbingCorner: grabbingCorner,
                aspectRatio: aspectRatio
            )
        }

        targetView.frame = newFrame
        recognizer.setTranslation(.zero, in: self)
    }

    /// 指定された移動量、掴んでいる角、およびアスペクト比に基づいて調整された移動量を計算する
    ///
    /// - Parameters:
    ///    - translation: 元の移動量
    ///    - grabbingCorner: 現在掴んでいる角
    ///    - aspectRatio: アスペクト比
    /// - Returns: 調整された移動量
    private func getAdjustedTranslation(translation: CGPoint, grabbingCorner: Corner, aspectRatio: CGSize) -> CGPoint {
        var updatedTranslation: CGPoint

        if abs(translation.x * aspectRatio.height) >= abs(translation.y * aspectRatio.width) {
            // X軸の移動量がY軸の移動量よりも大きい場合
            updatedTranslation = .init(
                x: translation.x,
                y: translation.x * (aspectRatio.height / aspectRatio.width)
                    // 右上、左下の場合はX軸の移動量の符号を反転する
                    * (grabbingCorner == .topRight || grabbingCorner == .bottomLeft ? -1 : 1)
            )
        } else {
            // Y軸の移動量がX軸の移動量よりも大きい場合
            updatedTranslation = .init(
                x: translation.y * (aspectRatio.width / aspectRatio.height)
                    // 右上、左下の場合はY軸の移動量の符号を反転する
                    * (grabbingCorner == .topRight || grabbingCorner == .bottomLeft ? -1 : 1),
                y: translation.y
            )
        }
        return updatedTranslation
    }

    /// リサイズのために更新したフレームを返す
    /// - Parameters:
    ///   - targetFrame: 与えられたフレーム
    ///   - grabbingCorner: 掴んでいる黒板の角
    ///   - translation: 移動量
    /// - Returns: 更新されたフレーム
    private func updatedFrameForResize(
        targetFrame: CGRect,
        grabbingCorner: BlackboardBaseView.Corner,
        translation: CGPoint
    ) -> CGRect {
        var newFrame = targetFrame
        switch grabbingCorner {
        case .topLeft:
            newFrame.origin.x += translation.x
            newFrame.origin.y += translation.y
            newFrame.size.width -= translation.x
            newFrame.size.height -= translation.y
        case .topRight:
            newFrame.origin.y += translation.y
            newFrame.size.width += translation.x
            newFrame.size.height -= translation.y
        case .bottomLeft:
            newFrame.origin.x += translation.x
            newFrame.size.width -= translation.x
            newFrame.size.height += translation.y
        case .bottomRight:
            newFrame.size.width += translation.x
            newFrame.size.height += translation.y
        }
        return newFrame
    }

    /// 与えられたフレームをカメラのキャプチャエリアの境界内に収まるよう調整して、フレームを返す
    /// - Parameters:
    ///   - targetFrame: 与えられたフレーム
    ///   - prohibitArea: キャプチャエリアの境界
    ///   - grabbingCorner: 掴んでいる黒板の角
    ///   - aspectRatio: アスペクト比
    /// - Returns: 調整されたフレーム
    func adjustedFrameToFitWithinProhibitArea(
        targetFrame: CGRect,
        prohibitArea: CGRect,
        grabbingCorner: Corner,
        aspectRatio: CGSize
    ) -> CGRect {
        var newFrame = targetFrame

        // フレームが境界を超えないように調整
        switch grabbingCorner {
        case .topLeft:
            if newFrame.minX < prohibitArea.minX {
                newFrame.size = sizePreservingAspectRatio(forWidth: targetFrame.maxX - prohibitArea.minX)
                newFrame.origin.x = prohibitArea.minX
                newFrame.origin.y = targetFrame.maxY - newFrame.height
            }
            if newFrame.minY < prohibitArea.minY {
                newFrame.size = sizePreservingAspectRatio(forHeight: targetFrame.maxY - prohibitArea.minY)
                newFrame.origin.x = targetFrame.maxX - newFrame.width
                newFrame.origin.y = prohibitArea.minY
            }
        case .topRight:
            if newFrame.maxX > prohibitArea.maxX {
                newFrame.size = sizePreservingAspectRatio(forWidth: prohibitArea.maxX - targetFrame.minX)
                newFrame.origin.y = targetFrame.maxY - newFrame.size.height
            }
            if newFrame.minY < prohibitArea.minY {
                newFrame.size = sizePreservingAspectRatio(forHeight: targetFrame.maxY - prohibitArea.minY)
                newFrame.origin.y = prohibitArea.minY
            }
        case .bottomLeft:
            if newFrame.minX < prohibitArea.minX {
                newFrame.size = sizePreservingAspectRatio(forWidth: targetFrame.maxX - prohibitArea.minX)
                newFrame.origin.x = prohibitArea.minX
            }
            if newFrame.maxY > prohibitArea.maxY {
                newFrame.size = sizePreservingAspectRatio(forHeight: prohibitArea.maxY - targetFrame.minY)
                newFrame.origin.x = targetFrame.maxX - newFrame.width
                newFrame.origin.y = prohibitArea.maxY - newFrame.height
            }
        case .bottomRight:
            if newFrame.maxX > prohibitArea.maxX {
                newFrame.size = sizePreservingAspectRatio(forWidth: prohibitArea.maxX - targetFrame.minX)
            }
            if newFrame.maxY > prohibitArea.maxY {
                newFrame.size = sizePreservingAspectRatio(forHeight: prohibitArea.maxY - targetFrame.minY)
            }
        }

        return newFrame
    }

    /// 幅を元にアスペクト比を保持したサイズを返す
    /// - Parameter width: 幅
    /// - Returns: アスペクト比を保持したサイズ
    private func sizePreservingAspectRatio(forWidth width: CGFloat) -> CGSize {
        .init(
            width: width,
            height: width * (aspectRatio.height / aspectRatio.width)
        )
    }

    /// 高さを元にアスペクト比を保持したサイズを返す
    /// - Parameter height: 高さ
    /// - Returns: アスペクト比を保持したサイズ
    private func sizePreservingAspectRatio(forHeight height: CGFloat) -> CGSize {
        .init(
            width: height * (aspectRatio.width / aspectRatio.height),
            height: height
        )
    }

    /// 与えられたフレームがカメラのキャプチャエリアの境界内に収まっているかどうかを判定する
    ///
    /// - Parameters:
    ///   - targetFrame: チェックするフレーム
    ///   - prohibitArea: キャプチャエリアの境界
    /// - Returns: 境界内に収まっている場合は `true` 、境界を超えている場合は `false`
    private func isFrameWithinProhibitArea(targetFrame: CGRect, prohibitArea: CGRect) -> Bool {
        return targetFrame.minY >= prohibitArea.minY &&
            targetFrame.minX >= prohibitArea.minX &&
            targetFrame.maxY <= prohibitArea.maxY &&
            targetFrame.maxX <= prohibitArea.maxX
    }
}

// MARK: - 移動

extension BlackboardBaseView {
    /// ドラッグジェスチャーに応じて黒板の位置を移動する
    ///
    /// 位置の更新は、禁止エリアに入らないように調整される。
    ///
    /// - Parameter recognizer: ドラッグ操作を認識する `UIPanGestureRecognizer`
    private func moveView(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        guard let targetView = recognizer.view else {
            return
        }

        targetView.center = updatedCenter(for: targetView.frame, withPreferredOffset: translation)
        recognizer.setTranslation(.zero, in: self)
    }

    /// ビューの移動位置を更新し、禁止エリアに侵入しないように調整した黒板の中心座標を返す
    ///
    /// 禁止エリアとビューの位置に基づき、ビューが移動するべき新しい位置を計算する。
    /// 移動するビューと禁止エリアが衝突した場合、その衝突を避けるように新しい中心座標を計算する。
    ///
    /// - Parameters:
    ///   - frame: 移動させるビューのフレーム
    ///   - preferredOffset: 提案された移動量
    /// - Returns: 禁止エリアを考慮した新しい中心座標
    private func updatedCenter(for frame: CGRect, withPreferredOffset preferredOffset: CGPoint) -> CGPoint {
        let centerXCoordinate = frame.midX + preferredOffset.x
        let centerYCoordinate = frame.midY + preferredOffset.y

        guard let prohibitArea else {
            return CGPoint(x: centerXCoordinate, y: centerYCoordinate)
        }

        let blackboardWidth = frame.size.width
        let blackboardHeight = frame.size.height

        // 禁止エリアを考慮する
        let updatedCenterXCoordinate: CGFloat = {
            if frame.minX + preferredOffset.x < prohibitArea.minX {
                // 左端を超える場合
                return prohibitArea.minX + blackboardWidth / 2.0
            } else if frame.maxX + preferredOffset.x > prohibitArea.maxX {
                // 右端を超える場合
                return prohibitArea.maxX - blackboardWidth / 2.0
            } else {
                // 左端も右端も超えない場合
                return centerXCoordinate
            }
        }()

        let updatedCenterYCoordinate: CGFloat = {
            if frame.minY + preferredOffset.y < prohibitArea.minY {
                // 上端を超える場合
                return prohibitArea.minY + blackboardHeight / 2.0
            } else if frame.maxY + preferredOffset.y > prohibitArea.maxY {
                // 下端を超える場合
                return prohibitArea.maxY - blackboardHeight / 2.0
            } else {
                // 上端も下端も超えない場合
                return centerYCoordinate
            }
        }()

        return CGPoint(x: updatedCenterXCoordinate, y: updatedCenterYCoordinate)
    }
}

// MARK: - 黒板のサイズチェック

extension BlackboardBaseView {
    /// 与えられた黒板のサイズが最小サイズの要件を満たしているかを確認する
    ///
    /// - Parameter targetSize: チェックする黒板のサイズ
    /// - Returns: 黒板のサイズが要件を満たす場合は `true` 、それ以外は `false`
    private func isAboveMinimumSize(targetSize: CGSize) -> Bool {
        let shorterSide = min(targetSize.width, targetSize.height)
        let longerSide = max(targetSize.width, targetSize.height)

        return shorterSide >= ModernBlackboardConfiguration.minimumShortEdgeLength &&
            longerSide >= ModernBlackboardConfiguration.minimumLongEdgeLength
    }
}

extension BlackboardBaseView {
    /// 黒板のフレームを、指定された長辺の長さとスケールで更新する
    /// - Parameters:
    ///   - longSide: 更新する際の基準となる黒板の長辺の長さ
    ///   - scaleFactor: 適用するスケールファクター
    /// - Returns: 新しい黒板のフレーム
    @MainActor
    func updateFrame(withDefaultLongSide longSide: CGFloat, scaleFactor: CGFloat) async {
        frame = CGRect(
            origin: frame.origin,
            size: defaultBlackboardSize(withDefaultLongSide: longSide)
                .applying(
                    CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                )
        )
        // 禁止エリアに侵入しないように調整
        center = updatedCenter(for: frame, withPreferredOffset: .zero)
    }

    /// 黒板の向きを考慮した、黒板のデフォルトサイズを取得する
    /// - Parameter longSide: 黒板のデフォルトサイズの長辺
    /// - Returns: 黒板の向きを考慮した、黒板のデフォルトサイズ
    private func defaultBlackboardSize(withDefaultLongSide longSide: CGFloat) -> CGSize {
        /// 黒板のアスペクト比
        ///
        /// 要件: 長辺:短辺＝30:23に設定する
        let aspectRatio: CGSize = .init(width: 30, height: 23)
        /// 黒板のデフォルトサイズの短辺
        let shortSide = longSide * (aspectRatio.height / aspectRatio.width)

        if let orientation, orientation.isLandscape {
            // 横向きの場合、縦長のサイズを返す
            return CGSize(width: shortSide, height: longSide)
        } else {
            // それ以外の場合、横長のサイズを返す
            return CGSize(width: longSide, height: shortSide)
        }
    }
}
