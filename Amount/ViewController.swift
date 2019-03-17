//
//  ViewController.swift
//  Amount
//
//  Created by Fabio Ferrero on 17/03/2019.
//  Copyright © 2019 FabFer Dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var currency1: UILabel!
    @IBOutlet weak var currency2: UILabel!
    @IBOutlet weak var currency3: UILabel!
    @IBOutlet weak var currency4: UILabel!
    @IBOutlet weak var currency5: UILabel!
    @IBOutlet weak var currency6: UILabel!
    @IBOutlet weak var currency7: UILabel!
    @IBOutlet weak var currency8: UILabel!
    @IBOutlet weak var currency9: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let amount1: Amount = 12000.00
        currency1.text = String(describing: amount1)
        
        let amount2: Amount = 12000.00
        currency2.display(amount: amount2)
        
        let amount3: Amount = 12000.00
        currency3.display(amount: amount3)
        
        let amount4: Amount = 12000.00
        currency4.display(amount: amount4)
        
        let amount5: Amount = 12000.00
        currency5.display(amount: amount5)
        
        let amount6: Amount = 12000.00
        currency6.display(amount: amount6)
        
        let amount7: Amount = 12000.00
        currency7.display(amount: amount7)
        
        let amount8: Amount = 12000.00
        currency8.display(amount: amount8)
        
        let amount9: Amount = 12000.00
        currency9.display(amount: amount9)
    }
}

