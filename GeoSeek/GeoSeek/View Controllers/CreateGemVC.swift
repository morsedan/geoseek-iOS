//
//  SecondViewController.swift
//  GeoSeek
//
//  Created by Jerry haaser on 2/28/20.
//  Copyright © 2020 Brandi Bailey. All rights reserved.
//

import UIKit
import CoreLocation

protocol CreateGemDelegate {
    func getGemLocation()
    func createGem(_ gem: GemRepresentation)
    
}

class CreateGemVC: UIViewController, Storyboarded, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var addGemView: UIView!
    //    @IBOutlet weak var headerLabel: UILabel!
    //    @IBOutlet weak var giveGemTitleLabel: UILabel!
    
    @IBOutlet weak var gemTitleTextField: UITextField!
    
    //    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var addDescriptionLabel: UILabel!
    @IBOutlet weak var gemDescriptionTextView: UITextView!
    //    @IBOutlet weak var difficultyLabel: UILabel!
    //    @IBOutlet weak var difficultyLevelTextField: UITextField!
    //    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    //Note: Do we want a "tab bar" here at all?
    //    @IBOutlet weak var customTabBarXib: CustomTabBarXib!
    var keyboardDismissTapGestureRecognizer: UITapGestureRecognizer!
    var currentYShiftForKeyboard: CGFloat = 0
    var coordinator: BaseCoordinator?
    var delegate: CreateGemDelegate?
    var userLocation: CLLocationCoordinate2D?
    var gemLocation: CLLocationCoordinate2D? {
        didSet {
            print("CreateGemVC.gemLocation was set")
            if let gemLocation = gemLocation {
                print(gemLocation)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleAddGemView()
        gemTitleTextField.delegate = self
        gemDescriptionTextView.delegate = self
        //        print(gemLocation)
        
        setupKeyboardDismissTapGestureRecognizer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func stopEditingTextInput() {
        if let gemTitleTextField = self.gemTitleTextField {
            
            gemTitleTextField.resignFirstResponder()
            
//            self.gemTitleTextField = nil
//            self.gemDescriptionTextView = nil
        } else if let gemDescriptionTextView = self.gemDescriptionTextView {
            
            gemDescriptionTextView.resignFirstResponder()
            
//            self.gemTitleTextField = nil
//            self.gemDescriptionTextView = nil
        }
        
        guard keyboardDismissTapGestureRecognizer.isEnabled else { return }
        
        keyboardDismissTapGestureRecognizer.isEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        gemTitleTextField = textField
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        gemDescriptionTextView = textView
        return true
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        keyboardDismissTapGestureRecognizer.isEnabled = true
        
        var keyboardSize: CGRect = .zero
        
        if let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            keyboardRect.height != 0 {
            keyboardSize = keyboardRect
        } else if let keyboardRect = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            keyboardSize = keyboardRect
        }
        if self.view.frame.origin.y == 0 {
            let yShift = yShiftWhenKeyboardAppearsFor(textInput: saveButton, keyboardSize: keyboardSize, nextY: keyboardSize.height)
            currentYShiftForKeyboard = yShift
            view.frame.origin.y -= yShift
        }
    }
    
    @objc func yShiftWhenKeyboardAppearsFor(textInput: UIView, keyboardSize: CGRect, nextY: CGFloat) -> CGFloat {
        
        let textFieldOrigin = self.view.convert(textInput.frame, from: textInput.superview!).origin.y
        let textFieldBottomY = textFieldOrigin + textInput.frame.size.height
        
        // This is the y point that the textField's bottom can be at before it gets covered by the keyboard
        let maximumY = self.view.frame.height - (keyboardSize.height + view.safeAreaInsets.bottom)
        
        if textFieldBottomY > maximumY {
            // This makes the view shift the right amount to have the text field being edited just above they keyboard if it would have been covered by the keyboard.
            return textFieldBottomY - maximumY
        } else {
            // It would go off the screen if moved, and it won't be obscured by the keyboard.
            return 0
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        if self.view.frame.origin.y != 0 {
            
            self.view.frame.origin.y += currentYShiftForKeyboard
        }
        
        stopEditingTextInput()
    }
    
    @objc func setupKeyboardDismissTapGestureRecognizer() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(stopEditingTextInput))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        view.addGestureRecognizer(tapGestureRecognizer)
        
        keyboardDismissTapGestureRecognizer = tapGestureRecognizer
        
    }
    
    
    func styleAddGemView() {
        addGemView.layer.cornerRadius = 20.0
        addGemView.clipsToBounds = true
        gemTitleTextField.layer.cornerRadius = 20.0
        
        gemDescriptionTextView.layer.cornerRadius = 10.0
        gemDescriptionTextView.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 10.0
    }
    
    //    @IBAction func locationButtonTapped(_ sender: Any) {
    ////        print("do something", coordinator)
    //        delegate?.getGemLocation()
    //    }
    //
    //    @IBAction func cancelButtonTapped(_ sender: Any) {
    //        print("cancelButtonTapped")
    //        navigationController?.popViewController(animated: true)
    //    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        //        print(gemDescriptionTextView.text ?? "No gemDesc text", gemLocation?.latitude ?? "No location")
        guard let title = gemTitleTextField.text,
            !title.isEmpty,
            let desc = gemDescriptionTextView.text,
            !desc.isEmpty,
            let location = gemLocation else { return }
        
        let gem = GemRepresentation(difficulty: 5, description: desc, id: nil, latitude: location.latitude, longitude: location.longitude, title: title)
        
        delegate?.createGem(gem)
    }
    
    
}

//extension CreateGemVC: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//        gemTitleTextField.resignFirstResponder()
//        gemDescriptionTextView.resignFirstResponder()
//
//        return true
//    }
//}
//
//extension CreateGemVC: UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            gemDescriptionTextView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
//}
