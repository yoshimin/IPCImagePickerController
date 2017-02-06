//
//  UIImagePickerController+Rx.swift
//  IPCImagePickerController
//

import RxSwift
import RxCocoa

class UIImagePickerControllerDelegateProxy: DelegateProxy, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DelegateProxyType {
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let picker = object as! UIImagePickerController
        return picker.delegate
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let picker = object as! UIImagePickerController
        picker.delegate = delegate as! (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    }
}

extension Reactive where Base: UIImagePickerController {
    public var delegate: DelegateProxy {
        return UIImagePickerControllerDelegateProxy.proxyForObject(base)
    }
    
    public var imagePickerControllerDidCancel: Observable<Void> {
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map {_ in }
    }
    
    public var imagePickerControllerDidFinishPickingMedia: Observable<[String : Any]> {
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map {
                let info: [String : Any] = $0[1] as! [String : Any]
                return info
        }
    }
}
