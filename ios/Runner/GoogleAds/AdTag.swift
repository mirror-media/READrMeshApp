import Foundation
import UIKit

@IBDesignable class AdTagLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 2.0
    @IBInspectable var bottomInset: CGFloat = 2.0
    @IBInspectable var leftInset: CGFloat = 8.0
    @IBInspectable var rightInset: CGFloat = 8.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
    
    /// 外框顏色
    @IBInspectable var labelBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    /// 外框寬度
    @IBInspectable var labelBorderWidth: CGFloat {
        get {
            return 1
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
        var cornerRadius: CGFloat {
            get {
                return layer.cornerRadius
            }
            set {
                layer.cornerRadius = newValue
            }
        }
}

