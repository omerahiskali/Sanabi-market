//
//  SignInViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 26.05.2023.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var epostaInfoLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorMessageLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordHiddenImage: UIImageView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    
    //Şifre kuralları
    @IBOutlet weak var onKarakterImage: UIImageView!
    @IBOutlet weak var buyukHarfImage: UIImageView!
    @IBOutlet weak var kucukHarfImage: UIImageView!
    @IBOutlet weak var birRakamImage: UIImageView!
    @IBOutlet weak var birOzelKarakterImage: UIImageView!
    
    @IBOutlet weak var onKarakterLabel: UILabel!
    @IBOutlet weak var buyukHarfLabel: UILabel!
    @IBOutlet weak var kucukHarfLabel: UILabel!
    @IBOutlet weak var birRakamLabel: UILabel!
    @IBOutlet weak var birOzelKarakterLabel: UILabel!
    
    
    // MARK: - Variables
    
    var eposta:String?
    var passwordControl:Bool = false
    var control:Bool = false
    private var datePicker: UIDatePicker!

    // MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if let ep = eposta{
            epostaInfoLabel.text = "Önce \(ep) ile Sanabi hesabınızı oluşturalım"
        }
        
        nameTextField.delegate = self
        surnameTextField.delegate = self
        birthDateTextField.delegate = self
        passwordTextField.delegate = self
        
        textFieldSetGray(textField: nameTextField)
        textFieldSetGray(textField: surnameTextField)
        textFieldSetGray(textField: birthDateTextField)
        textFieldSetGray(textField: passwordTextField)
        
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        passwordErrorMessageLabel.alpha = 0
        
        passwordTextField.addTarget(self, action: #selector(passwordDidChange(_:)), for: .editingChanged)
        
        setupDatePicker()
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        passwordHiddenImage.addGestureRecognizer(imageTapGesture)
        passwordHiddenImage.isUserInteractionEnabled = true
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
        let buttonLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonLabelViewTapped))
        buttonLabel.addGestureRecognizer(buttonLabelTapGesture)
        buttonLabel.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs

    func textFieldSetGray(textField:UITextField){
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func textFieldSetBlack(textField:UITextField){
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.black.cgColor
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldSetBlack(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldSetGray(textField: textField)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = -18
        if let maximumDate = calendar.date(byAdding: dateComponents, to: Date()) {
            datePicker.maximumDate = maximumDate
            datePicker.date = maximumDate
        }
        
        birthDateTextField.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    func checkTextFields() -> Bool {
        let nameTextFieldIsEmpty = nameTextField.text?.isEmpty ?? true
        let surnameTextFieldIsEmpty = surnameTextField.text?.isEmpty ?? true
        let birthDateTextFieldIsEmpty = birthDateTextField.text?.isEmpty ?? true

        if nameTextFieldIsEmpty || surnameTextFieldIsEmpty || birthDateTextFieldIsEmpty {
            control = false
            let alert = UIAlertController(title: "Uyarı", message: "Lütfen tüm alanları doldurun.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            if passwordControl {
                control = true
                passwordErrorMessageLabel.alpha = 0
                passwordTextField.layer.borderWidth = 1.5
                passwordTextField.layer.borderColor = UIColor.black.cgColor
            } else {
                control = false
                passwordErrorMessageLabel.alpha = 1
                passwordTextField.layer.borderWidth = 1.5
                passwordTextField.layer.borderColor = UIColor.red.cgColor
            }
        }

        return control
    }
    
    func buttonActionFunc(){
        button.isEnabled = false
        if checkTextFields(){
            print("kayıt yapıldı")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let modalVC = storyboard.instantiateViewController(withIdentifier: "signInTelVC") as? SignInTelViewController {
                
                modalVC.email = eposta!
                modalVC.name = nameTextField.text!
                modalVC.surname = surnameTextField.text!
                modalVC.birthDate = birthDateTextField.text!
                modalVC.password = passwordTextField.text!
                
                modalVC.modalTransitionStyle = .coverVertical
                modalVC.modalPresentationStyle = .fullScreen
                
                self.present(modalVC, animated: true, completion: nil)
            }
        }
    }

    // MARK: - objc Funcs
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let selectedDate = sender.date
        let dateString = dateFormatter.string(from: selectedDate)
        birthDateTextField.text = dateString
    }
    
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
        birRakamLabel.textColor = numberValid ? .systemGreen : .red
        birOzelKarakterLabel.textColor = specialCharacterValid ? .systemGreen : .red
        
        onKarakterImage.tintColor = lengthValid ? .systemGreen : .red
        buyukHarfImage.tintColor = uppercaseValid ? .systemGreen : .red
        kucukHarfImage.tintColor = lowercaseValid ? .systemGreen : .red
        birRakamImage.tintColor = numberValid ? .systemGreen : .red
        birOzelKarakterImage.tintColor = specialCharacterValid ? .systemGreen : .red
        
        onKarakterImage.image = lengthValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        buyukHarfImage.image = uppercaseValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        kucukHarfImage.image = lowercaseValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        birRakamImage.image = numberValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        birOzelKarakterImage.image = specialCharacterValid ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        
        let allRulesValid = lengthValid && uppercaseValid && lowercaseValid && numberValid && specialCharacterValid
        passwordControl = allRulesValid
    }
    
    @objc func imageViewTapped() {
        if passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = false
            passwordHiddenImage.image = UIImage(systemName: "eye.slash")
        }
        else {
            passwordTextField.isSecureTextEntry = true
            passwordHiddenImage.image = UIImage(systemName: "eye")
        }
    }
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    @objc func buttonLabelViewTapped(){
        buttonActionFunc()
    }
    
    //MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        buttonActionFunc()
    }
    
}
