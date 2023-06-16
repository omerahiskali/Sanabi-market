//
//  LogInViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 22.05.2023.
//

import UIKit
import Alamofire

class LogInViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Structs
    
    struct APIResponse: Decodable {
        let data: Int?
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldErrorMessageLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    
    //MARK: - Variables
    
    var buttonBottomConstraintConstant: CGFloat = 0.0
    
    //MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        
        emailTextField.layer.cornerRadius = 10
        emailTextField.clipsToBounds = true
        emailTextField.layer.borderWidth = 0.7
        emailTextField.layer.borderColor = UIColor.darkGray.cgColor
        
        textFieldErrorMessageLabel.alpha = 0
        
        button.layer.cornerRadius = 10
        buttonBottomConstraintConstant = buttonBottomConstraint.constant
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
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
        emailTextField.layer.borderWidth = 1.5
        emailTextField.layer.borderColor = UIColor.black.cgColor
        emailTextField.clearButtonMode = .always
        if let clearButton = emailTextField.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = .black
        }
        textFieldErrorMessageLabel.alpha = 0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailTextField.layer.borderWidth = 0.7
        emailTextField.layer.borderColor = UIColor.darkGray.cgColor
        emailTextField.clearButtonMode = .never
        textFieldErrorMessageLabel.alpha = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func getCustomerId(withEmail email: String, completion: @escaping (Int?) -> Void) {
        let urlString = "https://ozerhamza.xyz/api/Customers/GetIdWithMail?mail=\(email)"
        
        AF.request(urlString).responseDecodable(of: APIResponse.self) { response in
            switch response.result {
            case .success(let apiResponse):
                completion(apiResponse.data)
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(nil)
            }
        }
    }
    
    func devamEtAction(){
        if let email = emailTextField.text{
            let emailControl = isValidEmail(email)
            if emailControl == true{
                getCustomerId(withEmail: email) { customerId in
                    if let customerId = customerId {
                        self.emailFound(id: customerId)
                    } else {
                        self.emailNotFound()
                    }
                }
            }else{
                textFieldError()
            }
        }else{
            textFieldError()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        guard !email.isEmpty, email.contains("@") else {
            return false
        }
        
        let parts = email.split(separator: "@")
        guard parts.count == 2 else {
            return false
        }
        
        let username = String(parts[0])
        let domain = String(parts[1])
        
        guard isValidUsername(username), isValidDomain(domain) else {
            return false
        }
        
        return true
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890._")
        return username.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }

    func isValidDomain(_ domain: String) -> Bool {
        let ipPattern = #"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$"#
        let domainPattern = #"^[a-zA-Z0-9]+([-.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,63}$"#
        return domain.range(of: ipPattern, options: .regularExpression) != nil || domain.range(of: domainPattern, options: .regularExpression) != nil
    }
    
    func textFieldError(){
        emailTextField.layer.borderWidth = 1.5
        emailTextField.layer.borderColor = UIColor.red.cgColor
        emailTextField.clearButtonMode = .always
        if let clearButton = emailTextField.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = .red
        }
        textFieldErrorMessageLabel.alpha = 1
    }
    
    func emailFound(id: Int){
        print("Customer ID: \(id)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "logInPasswordVC") as? LogInPasswordViewController {
            modalVC.id = id
            modalVC.eposta = emailTextField.text!
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
    
    func emailNotFound(){
        print("Customer ID not found or an error occurred.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController {
            modalVC.eposta = emailTextField.text!
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
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
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions

    @IBAction func devamEtButtonAction(_ sender: Any) {
        button.isEnabled = false
        devamEtAction()
    }
    
}
