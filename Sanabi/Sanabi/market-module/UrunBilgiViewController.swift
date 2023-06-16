//
//  UrunBilgiViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 2.06.2023.
//

import UIKit

class UrunBilgiViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var productNumLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var cartImage: UIImageView!
    
    // MARK: - Variables
    
    var product:Products?
    let cartManager = CartManager.shared
    var productId:Int16?
    var productNum:Int16?
    var viewControllerId:String?
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        
        productId = Int16(product!.id)
        
        let productControl = cartManager.hasProduct(withId: productId!)
        
        if productControl{
            productNum = cartManager.getProductNum(forProductId: productId!)
        }else{
            productNum = 0
        }

        setImage()
        productName.text = product!.name
        productPrice.text = "\(product!.price) TL"
        productDescription.text = product!.description
        
        button.alpha = 1
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        buttonContainerView.alpha = 0
        buttonContainerView.layer.cornerRadius = 10
        buttonContainerView.clipsToBounds = true
        buttonContainerView.layer.borderWidth = 0.3
        buttonContainerView.layer.borderColor = UIColor.darkGray.cgColor
        
        let rightImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(rightImageViewTapped))
        rightImageView.addGestureRecognizer(rightImageTapGesture)
        rightImageView.isUserInteractionEnabled = true
        
        let leftImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(leftImageViewTapped))
        leftImageView.addGestureRecognizer(leftImageTapGesture)
        leftImageView.isUserInteractionEnabled = true
        
        leftImageView.image = UIImage(systemName: "trash")
        if productNum == 1{
            buttonContainerView.alpha = 1
        }else if productNum! > 1{
            buttonContainerView.alpha = 1
            leftImageView.image = UIImage(systemName: "minus")
        }
        productNumLabel.text = String(productNum!)
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
        let cartImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cartImageViewTapped))
        cartImage.addGestureRecognizer(cartImageTapGesture)
        cartImage.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs
    
    func setImage(){
        if let url = URL(string: "https://ozerhamza.com.tr/img/\(product!.image)") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.productImage.image = image
                    }
                }
            }
        }
    }
    
    func addProduct(){
        if productNum == 0{
            productNum! += 1
            cartManager.addProduct(productId: productId!, productNum: productNum!)
        }else{
            productNum! += 1
            cartManager.updateProduct(productId: productId!, newProductNum: productNum!)
        }
        productNumLabel.text = String(productNum!)
    }
    
    func removeProduct(){
        productNum! -= 1
        cartManager.updateProduct(productId: productId!, newProductNum: productNum!)
        productNumLabel.text = String(productNum!)
    }
    
    func deleteProduct(){
        productNum! = 0
        cartManager.deleteProduct(productId: productId!)
    }
    
    // MARK: - objc Funcs
    
    @objc func rightImageViewTapped() {
        addProduct()
        if productNum! > 1{
            leftImageView.image = UIImage(systemName: "minus")
        }
    }
    
    @objc func leftImageViewTapped() {
        if leftImageView.image == UIImage(systemName: "trash"){
            deleteProduct()
            buttonContainerView.alpha = 0
            button.alpha = 1
        }else if leftImageView.image == UIImage(systemName: "minus"){
            removeProduct()
            if productNum == 1{
                leftImageView.image = UIImage(systemName: "trash")
            }
        }
    }

    @objc func backImageViewTapped(){
        if viewControllerId == "searchBarVC"{
            dismiss(animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let modalVC = storyboard.instantiateViewController(withIdentifier: viewControllerId!)
                
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
                
            present(modalVC, animated: true, completion: nil)
        }
    }

    @objc func cartImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "sepetVC") as? SepetViewController {
            
            urunlerVC.modalTransitionStyle = .coverVertical
            urunlerVC.modalPresentationStyle = .fullScreen
            
            present(urunlerVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions

    @IBAction func buttonAction(_ sender: Any) {
        print("\(product!.name) sepete eklendi")
        addProduct()
        button.alpha = 0
        buttonContainerView.alpha = 1
    }
}
