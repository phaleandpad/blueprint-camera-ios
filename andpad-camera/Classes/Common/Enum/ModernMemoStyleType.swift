//
//  ModernMemoStyleType.swift
//  andpad-camera
//
//  Created by msano on 2021/09/01.
//

public enum ModernMemoStyleType {
    public enum SelectLevel {
        case level1
        case level2
        case level3
        
        public init(with adjustableMaxFontSize: AdjustableMaxFontSize) {
            switch adjustableMaxFontSize {
            case .small:
                self = .level1
            case .medium:
                self = .level2
            case .large:
                self = .level3
            }
        }
        
        public init(with adjustableMaxFontSize: VerticalAlignment) {
            switch adjustableMaxFontSize {
            case .top:
                self = .level1
            case .middle:
                self = .level2
            case .bottom:
                self = .level3
            }
        }
        
        public init(with horizontalAlignment: NSTextAlignment) {
            switch horizontalAlignment {
            case .left:
                self = .level1
            case .center:
                self = .level2
            case .right:
                self = .level3
            default:
                fatalError()
            }
        }
    }
    
    public enum AdjustableMaxFontSize {
        case large
        case medium
        case small

        var value: CGFloat {
            switch self {
            case .large:
                return 72
            case .medium:
                return 36
            case .small:
                return 18
            }
        }
        
        public init(with level: SelectLevel) {
            switch level {
            case .level1:
                self = .small
            case .level2:
                self = .medium
            case .level3:
                self = .large
            }
        }
    }
    
    public enum VerticalAlignment {
        case top
        case middle
        case bottom
        
        public init(with level: SelectLevel) {
            switch level {
            case .level1:
                self = .top
            case .level2:
                self = .middle
            case .level3:
                self = .bottom
            }
        }
    }
    
    public static func horizontalAlignment(with level: SelectLevel) -> NSTextAlignment {
        switch level {
        case .level1:
            return .left
        case .level2:
            return .center
        case .level3:
            return .right
        }
    }
}
