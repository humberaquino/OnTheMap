//
//  CatastrophicViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/15/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

// View controller that presents a simple animation when there's a Failure.
// Used by the Login view controller
class CatastrophicViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var catastrophicImageView: UIImageView!    
    
    var tapRecognizer: UITapGestureRecognizer!
    
    var message: (top: String, bottom: String)!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialization
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
        
        topLabel.text = message.top
        bottomLabel.text = message.bottom
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.topLabel.alpha = 0
        self.bottomLabel.alpha = 0
        self.topLabel.transform = CGAffineTransformScale(self.topLabel.transform, 0.5, 0.5);
        self.bottomLabel.transform = CGAffineTransformScale(self.bottomLabel.transform, 0.5, 0.5);
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.topLabel.alpha = 1
            self.topLabel.transform = CGAffineTransformScale(self.topLabel.transform, 2, 2);

        }) { (complete) -> Void in
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.bottomLabel.alpha = 1
                self.bottomLabel.transform = CGAffineTransformScale(self.bottomLabel.transform, 2, 2);
            })
        }
        
    }
    
    // MARK: - Utils
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer)
    }
    
}
