//
//  ModernBlackboardItemTextView.swift
//  andpad-camera
//
//  Created by msano on 2021/08/20.
//

// MARK: - ModernBlackboardItemTextView
final class ModernBlackboardItemTextView: UITextView {
    func configureBlackboardMemoItemStyle(
        by arguments: ModernBlackboardMemoStyleArguments,
        displayStyle: ModernBlackboardCaseViewDisplayStyle = .normal(shouldSetCornerRounder: true),
        likePlaceholderTextColor: UIColor
    ) {
        func setPlaceHolder() {
            self.textColor = likePlaceholderTextColor
            self.text = L10n.Blackboard.DefaultName.memo
        }
        
        isScrollEnabled = false
        self.textColor = arguments.textColor
        font = .systemFont(ofSize: arguments.adjustableMaxFontSize.value, weight: .semibold)
        textContainerInset = .zero
        
        adjustFontSizeIfNeeded(with: arguments.adjustableMaxFontSize)
        shrinkTopMarginIfNeeded()
        adjust(verticalAlignment: arguments.verticalAlignment)
        textAlignment = arguments.horizontalAlignment
        
        guard displayStyle.shouldShowPlaceHolder else { return }
        guard let text else {
            setPlaceHolder()
            return
        }
        guard text.isEmpty else { return }
        setPlaceHolder()
    }
}

// MARK: - private
extension ModernBlackboardItemTextView {
    // NOTE: テキスト全文が画面内に収まるまでフォントサイズを縮小させる
    private func adjustFontSizeIfNeeded(with adjustableMaxFontSize: ModernMemoStyleType.AdjustableMaxFontSize) {
        assert(
            font != nil,
            "本メソッドを実行する際には、fontは非nilである必要があります。必ずconfigureBlackboardMemoItemStyleを先に呼び出しfontを初期化してください。"
        )
        func decreaseFontSize() {
            font = font!.withSize(font!.pointSize - 1)
        }

        var newSize = sizeThatFits(.init(width: frame.size.width, height: .greatestFiniteMagnitude))

        // フォントサイズを徐々に小さくしながら TextView に収まるサイズになるまで縮小する。
        // NOTE: 文字数が多い場合や行数が多い場合、フォントサイズが1ptに達しても TextView のサイズに収まらないケースがある。
        // そのため、フォントサイズが1に達した場合についてもループから抜けるようにする(フォントサイズが1ptに達しても収まらないケースでも、 TextView から文字がはみ出ないことは確認済み)。
        while (newSize.height > frame.height) && (font!.pointSize > 1) {
            decreaseFontSize() // 1pt縮小したフォントサイズに更新
            newSize = sizeThatFits(.init(width: frame.size.width, height: .greatestFiniteMagnitude))
        }

        guard font!.pointSize > adjustableMaxFontSize.value else { return }
        font = font!.withSize(adjustableMaxFontSize.value)
    }

    // NOTE: （line height / フォントサイズから計算し）必要があればテキスト上部のマージンを詰める
    private func shrinkTopMarginIfNeeded() {
        guard let font else { return }
        let shrinkTopMargin = (font.lineHeight - font.pointSize) / 2
        guard shrinkTopMargin > 0 else { return }
        contentInset = .init(top: -shrinkTopMargin, left: 0, bottom: 0, right: 0)
    }
    
    // NOTE: 垂直方向の文字揃え調整
    // ref: https://stackoverflow.com/questions/41387549/how-to-align-text-inside-textview-vertically/41387780
    private func adjust(verticalAlignment: ModernMemoStyleType.VerticalAlignment) {
        func calcPositiveTopOffset(with size: CGSize) -> CGFloat {
            var topOffset: CGFloat
            
            switch verticalAlignment {
            case .top:
                return .zero
            case .middle:
                topOffset = (bounds.size.height - size.height * zoomScale) / 2
            case .bottom:
                topOffset = (bounds.size.height - size.height * zoomScale)
            }
            return max(1, topOffset)
        }
        
        // 上揃えに限り、処理不要のため早期returnする
        if case .top = verticalAlignment { return }
        
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        contentOffset.y = -calcPositiveTopOffset(with: size)
    }
}

// MARK: - ModernBlackboardMemoStyleArguments
public struct ModernBlackboardMemoStyleArguments: Equatable {
    public let textColor: UIColor
    public let adjustableMaxFontSize: ModernMemoStyleType.AdjustableMaxFontSize
    public let verticalAlignment: ModernMemoStyleType.VerticalAlignment
    public let horizontalAlignment: NSTextAlignment
    
    public init(
        textColor: UIColor,
        adjustableMaxFontSize: ModernMemoStyleType.AdjustableMaxFontSize,
        verticalAlignment: ModernMemoStyleType.VerticalAlignment,
        horizontalAlignment: NSTextAlignment
    ) {
        self.textColor = textColor
        self.adjustableMaxFontSize = adjustableMaxFontSize
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
    }
    
    public static func defaultSetting(with theme: ModernBlackboardAppearance.Theme) -> Self {
        return .init(textColor: theme.textColor)
    }
    
    static func defaultSetting(with textColor: UIColor) -> Self {
        return .init(textColor: textColor)
    }
    
    func updating(textColor: UIColor) -> Self {
        return Self(
            textColor: textColor,
            adjustableMaxFontSize: self.adjustableMaxFontSize,
            verticalAlignment: self.verticalAlignment,
            horizontalAlignment: self.horizontalAlignment
        )
    }
}

// MARK: - private
extension ModernBlackboardMemoStyleArguments {
    private init(textColor: UIColor) {
        self.init(
            textColor: textColor,
            adjustableMaxFontSize: .small,
            verticalAlignment: .top,
            horizontalAlignment: .left
        )
    }
}
