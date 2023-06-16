//
//  UserOperationsViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 9.06.2023.
//

import UIKit

class UserOperationsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var birthDateContainerView: UIView!
    @IBOutlet weak var telNumberContainerView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var telNumberLabel: UILabel!
    
    @IBOutlet weak var nameImage: UIImageView!
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var birthDateImage: UIImageView!
    @IBOutlet weak var telNumberImage: UIImageView!
    
    @IBOutlet weak var cancelImage: UIImageView!
    
    // MARK: - Variables
    
    var customer:Customer?
    
    // MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setContainerViews()
        setLabels()
        
        let nameImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(nameImageViewTapped))
        nameImage.addGestureRecognizer(nameImageTapGesture)
        nameImage.isUserInteractionEnabled = true
        
        let birthDateImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(birthDateImageViewTapped))
        birthDateImage.addGestureRecognizer(birthDateImageTapGesture)
        birthDateImage.isUserInteractionEnabled = true
        
        let telNumberImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(telNumberImageViewTapped))
        telNumberImage.addGestureRecognizer(telNumberImageTapGesture)
        telNumberImage.isUserInteractionEnabled = true
        
        let passwordImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(passwordImageViewTapped))
        passwordImage.addGestureRecognizer(passwordImageTapGesture)
        passwordImage.isUserInteractionEnabled = true
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs
    
    func setLabels(){
        if let customer = customer{
            nameLabel.text = "\(customer.name) \(customer.surname)"
            emailLabel.text = customer.mail
            birthDateLabel.text = customer.birtDate
            telNumberLabel.text = customer.numberPhone
        }

    }
    
    func setContainerViews(){
        // name
        nameContainerView.layer.cornerRadius = 10
        nameContainerView.clipsToBounds = true

        nameContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        nameContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        nameContainerView.layer.shadowOpacity = 0.5
        nameContainerView.layer.shadowRadius = 2.0
        nameContainerView.layer.masksToBounds = false
        
        // email
        emailContainerView.layer.cornerRadius = 10
        emailContainerView.clipsToBounds = true

        emailContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        emailContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        emailContainerView.layer.shadowOpacity = 0.5
        emailContainerView.layer.shadowRadius = 2.0
        emailContainerView.layer.masksToBounds = false
        
        // password
        passwordContainerView.layer.cornerRadius = 10
        passwordContainerView.clipsToBounds = true

        passwordContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        passwordContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        passwordContainerView.layer.shadowOpacity = 0.5
        passwordContainerView.layer.shadowRadius = 2.0
        passwordContainerView.layer.masksToBounds = false
        
        // birthDate
        birthDateContainerView.layer.cornerRadius = 10
        birthDateContainerView.clipsToBounds = true

        birthDateContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        birthDateContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        birthDateContainerView.layer.shadowOpacity = 0.5
        birthDateContainerView.layer.shadowRadius = 2.0
        birthDateContainerView.layer.masksToBounds = false
        
        // telNumber
        telNumberContainerView.layer.cornerRadius = 10
        telNumberContainerView.clipsToBounds = true

        telNumberContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        telNumberContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        telNumberContainerView.layer.shadowOpacity = 0.5
        telNumberContainerView.layer.shadowRadius = 2.0
        telNumberContainerView.layer.masksToBounds = false
    }
    
    
    // MARK: - objc Funcs
    
    @objc func nameImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "nameSurnameVC") as? NameSurnameViewController {
            
            modalVC.customer = customer
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }

    @objc func birthDateImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "birthDateVC") as? BirthDateViewController {
            
            modalVC.customer = customer
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
    
    @objc func telNumberImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "telNumberVC") as? TelNumberViewController {
            
            modalVC.customer = customer
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
    
    @objc func passwordImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "passwordVC") as? PasswordViewController {
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }

    @objc func cancelImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? HomePageViewController {
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            present(modalVC, animated: true, completion: nil)
        }
    }
    
}
