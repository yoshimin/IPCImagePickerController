//
//  ViewController.swift
//  IPCImagePickerController
//

import UIKit
import Photos
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noImageLabel: UILabel!
    
    var textField = UITextField()
    
    let selectedImage = PublishSubject<UIImage?>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectButton.layer.cornerRadius = selectButton.frame.width*0.5
        deleteButton.layer.cornerRadius = selectButton.frame.width*0.5
       
        bind()
    }

    private func bind() {
        deleteButton.rx.tap
            .subscribe(onNext: {
                self.selectedImage.onNext(nil)
            })
            .addDisposableTo(disposeBag)
        
        selectButton.rx.tap
            .subscribe(onNext: {
                PHPhotoLibrary.requestAuthorization { (status) -> Void in
                    let queue = DispatchQueue.main
                    queue.async {
                        self.showImagePicker()
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        selectedImage
            .bindTo(imageView.rx.image)
            .addDisposableTo(disposeBag)
        
        let imageStream = selectedImage
            .startWith(nil)
        
        imageStream
            .map({
                return ($0 != nil)
            })
            .bindTo(noImageLabel.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        imageStream
            .subscribe(onNext: {
                if $0 == nil {
                    self.imageView.backgroundColor = UIColor.white
                } else {
                    self.imageView.backgroundColor = UIColor.black
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    private func showImagePicker() {
        let picker = ImagePickerController()
        picker.aspectRatio = 16/9
        picker.pickingResult
            .subscribe(onNext: {
                switch $0 {
                case .success(let image):
                    self.selectedImage.onNext(image)
                    break
                case .cancel():
                    break
                }
                picker.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(self.disposeBag)
        self.present(picker, animated: true, completion: nil)
    }
}

