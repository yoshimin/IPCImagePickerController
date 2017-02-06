//
//  ImagePickerController.swift
//  IPCImagePickerController
//

import UIKit
import RxCocoa
import RxSwift

class ImagePickerController: UIImagePickerController {
    enum Result {
        case success(UIImage)
        case cancel()
    }
    
    public let pickingResult = PublishSubject<Result>()
    public var aspectRatio: CGFloat = 1
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    private func bind() {
        self.rx.imagePickerControllerDidCancel
            .subscribe(onNext: { _ in
                self.pickingResult.onNext(Result.cancel())
            })
            .addDisposableTo(disposeBag)
        
        self.rx.imagePickerControllerDidFinishPickingMedia
            .subscribe(onNext: {
                let image = $0[UIImagePickerControllerOriginalImage] as! UIImage?
                self.pushImageCropViewController(image!)
            })
            .addDisposableTo(disposeBag)
    }
    
    private func pushImageCropViewController(_ image: UIImage) {
        let storyboard = UIStoryboard(name: "ImageCropView", bundle: nil)
        let viewController: ImageCropViewController = storyboard.instantiateInitialViewController() as! ImageCropViewController
        viewController.image = image
        viewController.aspectRatio = aspectRatio
        
        viewController.croppingResult
            .subscribe(onNext: {
                switch $0 {
                case .success(let image):
                    self.pickingResult.onNext(Result.success(image))
                    break
                case .cancel():
                    _ = viewController.navigationController?.popViewController(animated: true)
                    break
                }
            })
            .addDisposableTo(self.disposeBag)
        pushViewController(viewController, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
