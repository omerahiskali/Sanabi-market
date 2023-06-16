//
//  BirthDateViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 9.06.2023.
//

import UIKit
import Alamofire

class BirthDateViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    
    // MARK: - Variables
    
    var customer:Customer?
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    private var datePicker: UIDatePicker!
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()

        birthDateTextField.delegate = self
        
        birthDateTextField.layer.cornerRadius = 10
        birthDateTextField.clipsToBounds = true
        birthDateTextField.layer.borderWidth = 0.7
        birthDateTextField.layer.borderColor = UIColor.darkGray.cgColor
        birthDateTextField.clearButtonMode = .never
        
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
        
        setupDatePicker()
        
        if let customer = customer{
            birthDateTextField.text = customer.birtDate
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            if let birthDate = dateFormatter.date(from: customer.birtDate!) {
                datePicker.date = birthDate
            }
        }
        
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
                    // Başarılı
                    print("Update successful")
                    self.goBack()
                case .failure(let error):
                    // Hata
                    print("Hata oluştu: \(error.localizedDescription)")
                    self.button.isEnabled = true
                }
            }
    }
    
    func goBack() {
        
        customer!.birtDate = birthDateTextField.text!

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "userOperationsVC") as? UserOperationsViewController {
            
            modalVC.customer = self.customer
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
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
    
    // MARK: - objc Funcs
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let selectedDate = sender.date
        let dateString = dateFormatter.string(from: selectedDate)
        birthDateTextField.text = dateString
    }
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        button.isEnabled = false
        if let customer = customer, let birthDate = birthDateTextField.text{
            updateCustomer(id: customer.id, name: customer.name, surname: customer.surname, mail: customer.mail!, numberPhone: customer.numberPhone, birtDate: birthDate, createDate: customer.createDate!)
        }else{
            button.isEnabled = true
        }
    }
    

}
