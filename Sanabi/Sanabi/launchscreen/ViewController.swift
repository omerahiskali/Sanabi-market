//
//  ViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 23.03.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var smiley: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        smiley.alpha = 0
        indicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.animation()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.performSegue(withIdentifier: "toHome", sender: nil)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        indicator.stopAnimating()
    }
    
    func animation(){
        UIView.animate(withDuration: 0.6, animations: {
            self.banner.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: {(true) in
            UIView.animate(withDuration: 0.2, animations: {
                self.banner.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                self.banner.alpha = 0
            }, completion: {(true) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.smiley.alpha = 1
                }, completion: {(true) in
                    UIView.animate(withDuration: 0.6, animations: {
                        self.smiley.transform = CGAffineTransform(rotationAngle: 45)
                    })
                })
            })
        })
    }
    
}

