//
//  DeliveringTouchView.swift
//  IPCImagePickerController
//

import UIKit

class DeliveringTouchView: UIView {
    @IBOutlet weak var targetView: UIView!
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event);
        if view != nil && view == self {
            return targetView
        }
        return view
    }
}
