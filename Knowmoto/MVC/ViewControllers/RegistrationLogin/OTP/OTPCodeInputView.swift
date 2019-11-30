import UIKit

//MARK:- ======== Protocol ========
public protocol CodeInputViewDelegate {
    func codeInputView(_ codeInputView: OTPCodeInputView, didFinishWithCode code: String,completion:Bool)
}

//MARK:- ======== Class ========
open class OTPCodeInputView: UIView, UIKeyInput {
    
    private var nextTag = 1
    private let digitCount = 5
    private let numberPlaceHolder = ""
    private let lineColor = UIColor.BorderColor

    open var delegate: CodeInputViewDelegate?
    
    open var otpCode:String {
        var code = ""
        for index in 1..<digitCount+1 {
            guard let lbl = viewWithTag(index) as? UILabel else { return "" }
            code += lbl.text ?? ""
        }
        code = code.replacingOccurrences(of: numberPlaceHolder, with: "")
        return code
    }
    
    // MARK: - UIView
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.OtpBecomeFirstResponder))
        self.addGestureRecognizer(tapGesture)
        // calculate dims
        let spaceV = CGFloat(10)
        let spaceH = CGFloat(20)
        let height = frame.size.height
        
        let width = (frame.size.width - (spaceH * CGFloat(digitCount - 1)))/CGFloat(digitCount)
  
        // Add six digitLabels
        var lframe = CGRect(x: 0, y: 0, width: width, height: height)
        for index in 1...digitCount {
            let digitLabel = UILabel(frame: lframe)
            digitLabel.font = ENUM_APP_FONT.bold.size(14)
            digitLabel.tag = index
            digitLabel.text = numberPlaceHolder
            digitLabel.textColor = UIColor.white
            digitLabel.textAlignment = .center
            addSubview(digitLabel)
            lframe.origin.x += width + spaceH
            
//            let lineFrame = CGRect(x: digitLabel.frame.minX, y: digitLabel.frame.maxY, width: width, height: 2)
            
//            let digitLine = UILabel(frame: lineFrame)
//            digitLine.backgroundColor = lineColor
//            addSubview(digitLine)

            digitLabel.layer.cornerRadius = 4
            digitLabel.layer.borderWidth = 0.3
            digitLabel.layer.borderColor = lineColor?.cgColor
//            digitLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
//            digitLabel.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
//            digitLabel.layer.shadowOpacity = 1
//            digitLabel.layer.shadowRadius = 4
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    } // NSCoding
    
    @objc func OtpBecomeFirstResponder(){
        
        self.becomeFirstResponder()
        
    }
//}
//
//// MARK: - UIKeyInput
//extension OTPCodeInputView: UIKeyInput
//{
    public var hasText : Bool {
        return nextTag > 1 ? true : false
    }
 
    // MARK: - UIResponder
    open override var canBecomeFirstResponder : Bool {
        return true
    }
    
    // MARK: - UITextInputTraits
    open var keyboardType: UIKeyboardType { get { return .asciiCapableNumberPad } set {
        } }
    
    public var keyboardAppearance: UIKeyboardAppearance{ get { return .dark } set {
        } }

    
    open func insertText(_ text: String) {
        if nextTag < digitCount+1 {
            guard let lbl = viewWithTag(nextTag) as? UILabel else { return }
            lbl.text = text
            nextTag += 1
            
            if nextTag == digitCount+1 {
                var code = ""
                for index in 1..<nextTag {
                    guard let lbl = viewWithTag(index) as? UILabel else { return }
                    code += lbl.text ?? ""
                }
                
                delegate?.codeInputView(self, didFinishWithCode: code, completion: true)
                
            }else{
                
                delegate?.codeInputView(self, didFinishWithCode: "", completion: false)

            }
            
        }
    }
    
    open func deleteBackward() {
        
        if nextTag > 1 {
            nextTag -= 1
            guard let lbl = viewWithTag(nextTag) as? UILabel else { return }
            lbl.text = numberPlaceHolder
            delegate?.codeInputView(self, didFinishWithCode: "", completion: false)
        }
        
    }
    
    open func clear() {
        while nextTag > 1 {
            deleteBackward()
        }
    }
}


