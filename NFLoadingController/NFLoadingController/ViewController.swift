//
//  ViewController.swift
//  NFLoadingController
//
//  Created by Nour Sandid on 12/02/2016.
//  Copyright (c) 2016 Nour Sandid. All rights reserved.
//

import UIKit
import NFLoadingController
class ViewController: UIViewController {
    var loadingController = NFLoadingController()
    override func viewDidLoad() {
        super.viewDidLoad()
        let builder = NFLoadingControllerBuilder { (builder:NFLoadingControllerBuilder) in
            builder.alpha = 0.7
            builder.image = UIImage.gif(name: "loadcat")!
            builder.backgroundView = {
                let view = UIView()
                view.backgroundColor = UIColor.black
                return view
            }
            builder.frame = {
                return CGRect(x: self.view.frame.size.width/2 - 50, y: self.view.frame.size.height/2 - 50, width: 100, height: 100)
            }
            builder.presentingStyle = .popIn
            builder.dismissalStyle = .popOut
            builder.textColor = UIColor.red
            builder.textFont = UIFont.boldSystemFont(ofSize: 30)
        }
        self.loadingController = NFLoadingController(builder: builder)!
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadingController.present(from: self, completion: nil)
        let when = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: when+4) {
            self.loadingController.dismiss(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

