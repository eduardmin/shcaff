//
//  DateSelectionView.swift
//   Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/26/15.
//

import UIKit

protocol DatePickerViewDelegate: class {
    func setDate(date: Date)
}

class DatePickerView: UIView {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    let pickerViewBottomConstraint: CGFloat = -176
    var delegate: DatePickerViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        cancelButton.setTitle("Cancel".localize(), for: .normal)
        doneButton.setTitle("Done".localize(), for: .normal)
        if #available(iOS 14, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.cancelsTouchesInView = true
        addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture() {
        delegate?.setDate(date: datePickerView.date)
        disappear()
    }

    class func instanceFromNib() -> DatePickerView {
        return UINib(nibName: "DatePickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DatePickerView
    }
    
    public func appearOnView(_ view: UIView) {
        bottomConstraint?.constant = pickerViewBottomConstraint
        view.layoutIfNeeded()
        bottomConstraint?.constant = 0
    }
    
    public func disappear() {
        bottomConstraint?.constant = 0
        superview?.layoutIfNeeded()
        bottomConstraint?.constant = pickerViewBottomConstraint
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.superview?.layoutIfNeeded()
        },  completion: { (done) -> Void in  self.removeFromSuperview()})
    }
}

//MARK:- Button action
extension DatePickerView {
    @IBAction func cancelClick(_ sender: Any) {
        disappear()
    }
    
    @IBAction func doneClick(_ sender: Any) {
        delegate?.setDate(date: datePickerView.date)
        disappear()
    }
}
