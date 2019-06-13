//
//  AllPlacesViewController.swift
//  Weather
//
//  Created by Piotr Sirek on 08/11/2018.
//  Copyright © 2018 Piotr Sirek. All rights reserved.
//

import UIKit

class AllPlacesViewController: UIViewController {

    @IBOutlet weak var aboutApplicationButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutApplicationButton.layer.cornerRadius = 10
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
