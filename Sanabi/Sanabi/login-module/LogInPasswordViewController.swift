//
//  LogInPasswordViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 24.05.2023.
//

import UIKit
import Alamofire
import FirebaseAuth

class LogInPasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var buttonLabel: UILabel!
    
    // MARK: - Variables
    
    var buttonBottomConstraintConstant: CGFloat = 0.0
    var id:Int?
    var eposta:String?
    let d = UserDefaults.standard
    
    //MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = eposta{
            emailLabel.text = "Log in with your password to \(email)"
        }
        
        passwordErrorLabel.alpha = 0

        passwordTextField.delegate = self
        
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.clipsToBounds = true
        passwordTextField.layer.borderWidth = 0.7
        passwordTextField.layer.borderColor = UIColor.darkGray.cgColor
        passwordTextField.clearButtonMode = .never
        passwordTextField.isSecureTextEntry = true
        
        button.layer.cornerRadius = 10
        buttonBottomConstraintConstant = buttonBottomConstraint.constant
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        passwordImage.addGestureRecognizer(imageTapGesture)
        passwordImage.isUserInteractionEnabled = true
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
        let buttonLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonLabelViewTapped))
        buttonLabel.addGestureRecognizer(buttonLabelTapGesture)
        buttonLabel.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Funcs
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        passwordTextField.layer.borderWidth = 1.5
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordErrorLabel.alpha = 0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        passwordTextField.layer.borderWidth = 0.7
        passwordTextField.layer.borderColor = UIColor.darkGray.cgColor
        passwordErrorLabel.alpha = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldError(){
        passwordTextField.layer.borderWidth = 1.5
        passwordTextField.layer.borderColor = UIColor.red.cgColor
        passwordErrorLabel.alpha = 1
    }
    
    func signIn(email:String, password:String){
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
          if let error = error {
              self.button.isEnabled = true
              self.textFieldError()
            print("Giriş Hatası: \(error.localizedDescription)")
          } else {
              self.button.isEnabled = false
              self.signInSucces()
          }
        }
    }
    
    func signInSucces(){
        print("Giriş başarılı")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? HomePageViewController {
            self.d.set(String(self.id!), forKey: "id")
            modalVC.modalTransitionStyle = .crossDissolve
            modalVC.modalPresentationStyle = .fullScreen
            self.present(modalVC, animated: true, completion: nil)
        }
        
    }
    
    func buttonActionFunc(){
        button.isEnabled = false
        if let password = passwordTextField.text, let email = eposta{
            signIn(email: email, password: password)
        }
    }

    // MARK: - objc Funcs
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let buttonFrame = button.convert(button.bounds, to: view)
            let buttonBottomY = buttonFrame.origin.y + buttonFrame.size.height
            let keyboardTopY = view.frame.size.height - keyboardFrame.size.height - 10

            if buttonBottomY > keyboardTopY {
                let difference = buttonBottomY - keyboardTopY
                buttonBottomConstraint.constant = buttonBottomConstraintConstant + difference
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        buttonBottomConstraint.constant = buttonBottomConstraintConstant
        view.layoutIfNeeded()
    }
    
    @objc func imageViewTapped() {
        if passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = false
            passwordImage.image = UIImage(systemName: "eye.slash")
        }
        else {
            passwordTextField.isSecureTextEntry = true
            passwordImage.image = UIImage(systemName: "eye")
        }
    }
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    @objc func buttonLabelViewTapped(){
        buttonActionFunc()
    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        buttonActionFunc()
    }
    



}
