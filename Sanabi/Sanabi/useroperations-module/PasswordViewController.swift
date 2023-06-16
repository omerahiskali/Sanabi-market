//
//  PasswordViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 9.06.2023.
//

import UIKit
import FirebaseAuth

class PasswordViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var availablePasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var availablePasswordHiddenImage: UIImageView!
    @IBOutlet weak var newPasswordHiddenImage: UIImageView!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var onKarakterImage: UIImageView!
    @IBOutlet weak var buyukHarfImage: UIImageView!
    @IBOutlet weak var kucukHarfImage: UIImageView!
    @IBOutlet weak var rakamImage: UIImageView!
    @IBOutlet weak var ozelKarakterImage: UIImageView!
    
    @IBOutlet weak var onKarakterLabel: UILabel!
    @IBOutlet weak var buyukHarfLabel: UILabel!
    @IBOutlet weak var kucukHarfLabel: UILabel!
    @IBOutlet weak var rakamLabel: UILabel!
    @IBOutlet weak var ozelKarakterLabel: UILabel!
    
    @IBOutlet weak var backImage: UIImageView!
    
    // MARK: - Variables
    
    var passwordControl:Bool = false
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()

        availablePasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        
        availablePasswordTextField.layer.cornerRadius = 10
        availablePasswordTextField.clipsToBounds = true
        availablePasswordTextField.layer.borderWidth = 0.7
        availablePasswordTextField.layer.borderColor = UIColor.darkGray.cgColor
        availablePasswordTextField.clearButtonMode = .never
        
        newPasswordTextField.layer.cornerRadius = 10
        newPasswordTextField.clipsToBounds = true
        newPasswordTextField.layer.borderWidth = 0.7
        newPasswordTextField.layer.borderColor = UIColor.darkGray.cgColor
        newPasswordTextField.clearButtonMode = .never
        
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        buttonContainer.layer.cornerRadius = 25
        buttonContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonContainer.clipsToBounds = true

        buttonContainer.layer.shadowColor = UIColor.black.cgColor
        buttonContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        buttonContainer.layer.shadowOpacity = 0.8
        buttonContainer.layer.shadowRadius = 4.0
        buttonContainer.layer.masksToBounds = false
        
        newPasswordTextField.addTarget(self, action: #selector(passwordDidChange(_:)), for: .editingChanged)
        
        let avaliablePasswordImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(avaliablePasswordImageViewTapped))
        availablePasswordHiddenImage.addGestureRecognizer(avaliablePasswordImageTapGesture)
        availablePasswordHiddenImage.isUserInteractionEnabled = true
        
        let newPasswordImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(newPasswordImageViewTapped))
        newPasswordHiddenImage.addGestureRecognizer(newPasswordImageTapGesture)
        newPasswordHiddenImage.isUserInteractionEnabled = true
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.black.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updatePassword(currentPassword: String, newPassword: String) {
        if let user = Auth.auth().currentUser {
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
            
            user.reauthenticate(with: credential) { (result, error) in
                if let error = error {

                    print("Yeniden oturum açma hatası: \(error.localizedDescription)")
                    print("Şifre güncelleme hatası: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Şifre Hatalı", message: "Mevcut şifrenizi hatalı veya eksik girdiniz.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.button.isEnabled = true
                    return
                }
                
                user.updatePassword(to: newPassword) { (error) in
                    if let error = error {

                        print("Şifre güncelleme hatası: \(error.localizedDescription)")
                        self.button.isEnabled = true
                        
                    } else {

                        print("Şifre güncelleme başarılı.")
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func passwordDidChange(_ textField: UITextField) {
        guard let password = textField.text else { return }
        
        let lengthValid = password.count >= 10
        let uppercaseValid = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let lowercaseValid = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let numberValid = password.rangeOfCharacter(from: .decimalDigits) != nil
        let specialCharacterValid = password.rangeOfCharacter(from: .punctuationCharacters) != nil
        
        onKarakterLabel.textColor = lengthValid ? .systemGreen : .red
        buyukHarfLabel.textColor = uppercaseValid ? .systemGreen : .red
        kucukHarfLabel.textColor = lowercaseValid ? .systemGreen : .red
        rakamLabel.textColor = numberValid ? .systemGreen : .red
        ozelKarakterLabel.textColor = specialCharacterValid ? .systemGreen : .red
        
        onKarakterImage.tintColor = lengthValid ? .systemGreen : .red
        buyukHarfImage.tintColor = uppercaseValid ? .systemGreen : .red
        kucukHarfImage.tintColor = lowercaseValid ? .systemGreen : .red
        rakamImage.tintColor = numberValid ? .systemGreen : .red
        ozelKarakterImage.tintColor = specialCharacterValid ? .systemGreen : .red
        
        onKarakterImage.image = lengthValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        buyukHarfImage.image = uppercaseValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        kucukHarfImage.image = lowercaseValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        rakamImage.image = numberValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        ozelKarakterImage.image = specialCharacterValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        
        let allRulesValid = lengthValid && uppercaseValid && lowercaseValid && numberValid && specialCharacterValid
        passwordControl = allRulesValid
    }
    
    @objc func avaliablePasswordImageViewTapped(){
        if availablePasswordTextField.isSecureTextEntry {
            availablePasswordTextField.isSecureTextEntry = false
            availablePasswordHiddenImage.image = UIImage(systemName: "eye.slash")
        }
        else {
            availablePasswordTextField.isSecureTextEntry = true
            availablePasswordHiddenImage.image = UIImage(systemName: "eye")
        }
    }
    
    @objc func newPasswordImageViewTapped(){
        if newPasswordTextField.isSecureTextEntry {
            newPasswordTextField.isSecureTextEntry = false
            newPasswordHiddenImage.image = UIImage(systemName: "eye.slash")
        }
        else {
            newPasswordTextField.isSecureTextEntry = true
            newPasswordHiddenImage.image = UIImage(systemName: "eye")
        }
    }
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        self.button.isEnabled = false
        if passwordControl{
            if let newPassword = newPasswordTextField.text, let availablePassword = availablePasswordTextField.text{
                updatePassword(currentPassword: availablePassword, newPassword: newPassword)
            }
        }else{
            let alertController = UIAlertController(title: "Şifre Hatalı", message: "Girdiğiniz yeni şifre kurallara uymuyor.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            self.button.isEnabled = true
        }

    }
    
}
