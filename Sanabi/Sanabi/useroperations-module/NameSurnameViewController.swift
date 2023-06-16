//
//  NameSurnameViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 9.06.2023.
//

import UIKit
import Alamofire

class NameSurnameViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var backImage: UIImageView!
    
    // MARK: - Variables
    
    var customer:Customer?
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    
    // MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        surnameTextField.delegate = self
        
        nameTextField.layer.cornerRadius = 10
        nameTextField.clipsToBounds = true
        nameTextField.layer.borderWidth = 0.7
        nameTextField.layer.borderColor = UIColor.darkGray.cgColor
        
        surnameTextField.layer.cornerRadius = 10
        surnameTextField.clipsToBounds = true
        surnameTextField.layer.borderWidth = 0.7
        surnameTextField.layer.borderColor = UIColor.darkGray.cgColor
        
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        buttonContainerView.layer.cornerRadius = 25
        buttonContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonContainerView.clipsToBounds = true

        buttonContainerView.layer.shadowColor = UIColor.black.cgColor
        buttonContainerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        buttonContainerView.layer.shadowOpacity = 0.8
        buttonContainerView.layer.shadowRadius = 4.0
        buttonContainerView.layer.masksToBounds = false
        
        if let customer = customer{
            nameTextField.text = customer.name
            surnameTextField.text = customer.surname
        }
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.black.cgColor
        textField.clearButtonMode = .always
        if let clearButton = textField.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = .black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.7
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.clearButtonMode = .never
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldError(textField:UITextField){
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.red.cgColor
        textField.clearButtonMode = .always
        if let clearButton = textField.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = .red
        }
    }
    
    func updateCustomer(id: Int, name: String, surname: String, mail: String, numberPhone: String, birtDate: String, createDate: String) {
        let url = "https://ozerhamza.xyz/api/Customers"
        
        let params: Parameters = [
            "id": id,
            "name": name,
            "surname": surname,
            "mail": mail,
            "numberPhone": numberPhone,
            "birtDate": birtDate,
            "createDate": createDate
        ]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: Empty.self) { response in
                switch response.result {
                case .success:

                    print("Update successful")
                    
                    self.goBack()
                    
                case .failure(let error):
                    print("Hata oluştu: \(error.localizedDescription)")
                    self.button.isEnabled = true
                }
            }
    }


    
    func goBack() {
        
        customer!.name = nameTextField.text!
        customer!.surname = surnameTextField.text!
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "userOperationsVC") as? UserOperationsViewController {
            
            modalVC.customer = self.customer
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        button.isEnabled = false
        if let nameText = nameTextField.text, let surnameText = surnameTextField.text{
            if nameText.count < 3{
                textFieldError(textField: nameTextField)
                button.isEnabled = true
            }else if surnameText.count < 3{
                textFieldError(textField: surnameTextField)
                button.isEnabled = true
            }else{
                print("başarılı")
                if let customer = customer{
                    updateCustomer(id: customer.id, name: nameText, surname: surnameText, mail: customer.mail!, numberPhone: customer.numberPhone, birtDate: customer.birtDate!, createDate: customer.createDate!)
                }else{
                    button.isEnabled = true
                }
            }
        }else{
            textFieldError(textField: nameTextField)
            textFieldError(textField: surnameTextField)
            button.isEnabled = true
        }
    }
    
}
