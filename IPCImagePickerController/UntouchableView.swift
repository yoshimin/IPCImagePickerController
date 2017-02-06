//
//  UntouchableView.swift
//  IPCImagePickerController
//

import UIKit

class UntouchableView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self {
            return nil
        }
        
        return view
    }
}
