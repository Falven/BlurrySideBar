//
//  ViewController.swift
//  BlurrySideBar
//
//  Created by Francisco Aguilera on 7/24/15.
//  Copyright © 2015 Dapper-Apps LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SideBarDelegate {

    var sideBar: SideBar!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideBar = SideBar(sourceView: self.view, menuItems: ["first item", "second item", "third item"])
        sideBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        if index == 0 {
            imageView.backgroundColor = UIColor.redColor()
            imageView.image = nil
        } else {
            imageView.backgroundColor = UIColor.clearColor()
            imageView.image = UIImage(named: "redhead")
        }
    }
}
