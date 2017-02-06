//
//  ImageCropViewController.swift
//  IPCImagePickerController
//

import UIKit
import RxCocoa
import RxSwift

class ImageCropViewController: UIViewController {
    enum Result {
        case success(UIImage)
        case cancel()
    }
    
    public let croppingResult = PublishSubject<Result>()
    public var image: UIImage!
    public var aspectRatio: CGFloat = 1
    
    private let disposeBag = DisposeBag()
    private let cropMask = CAShapeLayer()
    private let cropMaskView = UntouchableView();
    
    @IBOutlet weak var scrollView: UIScrollView!
    let imageView = UIImageView()
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        imageView.image = image
        scrollView.addSubview(imageView)
        
        cropMaskView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.insertSubview(cropMaskView, aboveSubview: scrollView)
        
        scrollView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutScrollView()
        layoutCropMask()
    }
    
    
    // MARK: - Layout
    
    private func layoutCropMask() {
        cropMaskView.frame = view.bounds
        
        let mask = CAShapeLayer()
        mask.fillRule = kCAFillRuleEvenOdd
        
        // 切り取り部分を透明にくり抜く
        let maskPath = UIBezierPath.init(rect: cropMaskView.bounds)
        maskPath.move(to: CGPoint(x: scrollView.frame.minX, y: scrollView.frame.minY))
        maskPath.addLine(to: CGPoint(x: scrollView.frame.minX, y: scrollView.frame.maxY))
        maskPath.addLine(to: CGPoint(x: scrollView.frame.maxX, y: scrollView.frame.maxY))
        maskPath.addLine(to: CGPoint(x: scrollView.frame.maxX, y: scrollView.frame.minY))
        maskPath.addLine(to: CGPoint(x: scrollView.frame.minX, y: scrollView.frame.minY))
        mask.path = maskPath.cgPath
        cropMaskView.layer.mask = mask
    }
    
    private func layoutScrollView() {
        updateScrollViewFrame()
        updateScrollViewContentSize()
        updateScrollViewContentOffset()
    }
    
    private func updateScrollViewFrame() {
        var size: CGSize
        // 画面全体とクロップ枠の縦横比を比較して縦合わせなのか横合わせなのか判定する
        if view.frame.height/view.frame.width > aspectRatio {
            size = CGSize(width: view.frame.width, height: view.frame.width*aspectRatio)
        } else {
            size = CGSize(width: view.frame.height/aspectRatio, height: view.frame.height)
        }
        scrollView.frame.size = size;
        scrollView.center = view.center
    }
    
    private func updateScrollViewContentSize() {
        self.scrollView.zoomScale = 1
        
        // 画像とクロップ枠の縦横比を比較して縦合わせなのか横合わせなのか判定する
        let imageAspect = image.size.height/image.size.width
        var size: CGSize
        if imageAspect > aspectRatio {
            size = CGSize(width: scrollView.frame.width, height: scrollView.frame.width*imageAspect)
        } else {
            size = CGSize(width: scrollView.frame.height/imageAspect, height: scrollView.frame.height)
        }
        imageView.frame.size = size
        imageView.center = CGPoint(x: scrollView.frame.width*0.5, y: imageView.frame.height*0.5)
        scrollView.contentSize = imageView.frame.size
    }
    
    private func updateScrollViewContentOffset() {
        let offsetX = (imageView.frame.width - scrollView.frame.width)*0.5
        let offsetY = (imageView.frame.height - scrollView.frame.height)*0.5
        
        if imageView.frame.width != scrollView.frame.width {
            scrollView.contentInset = UIEdgeInsetsMake(0, offsetX, 0, -offsetX)
        }
        
        scrollView.contentOffset = CGPoint(x: offsetX - scrollView.contentInset.left,
                                           y: offsetY - scrollView.contentInset.top)
    }
    
    // MARK: - Action
    
    @IBAction func chooseButtonDidTap(sender:AnyObject) {
        // 切り取り範囲を超えてドラッグされていた場合はクロップ範囲内にoffsetを戻す
        backOffsetInRange()
        
        // 選択された範囲を切り取る
        let croppedImage = cropImage()
        croppingResult.onNext(Result.success(croppedImage))
    }
    
    @IBAction func cancelButtonDidTap(sender:AnyObject) {
        croppingResult.onNext(Result.cancel())
    }
    
    // MARK: - Cropping
    
    private func backOffsetInRange() {
        var offset = scrollView.contentOffset;
        if offset.x < -scrollView.contentInset.left {
            offset.x = -scrollView.contentInset.left
        }
        else if offset.x > (scrollView.contentSize.width -  scrollView.frame.width) + scrollView.contentInset.right {
            offset.x = (scrollView.contentSize.width -  scrollView.frame.width) + scrollView.contentInset.right
        }
        if offset.y < -scrollView.contentInset.top {
            offset.y = -scrollView.contentInset.top
        }
        else if offset.y > (scrollView.contentSize.height -  scrollView.frame.height) + scrollView.contentInset.bottom {
            offset.y = (scrollView.contentSize.height -  scrollView.frame.height) + scrollView.contentInset.bottom
        }
        self.scrollView.contentOffset = offset
    }
    
    private func cropImage() -> UIImage {
        // 切り取り範囲を計算
        let horizontalRatio = imageView.frame.width/image.size.width;
        let verticalRatio = imageView.frame.height/image.size.height;
        
        var cropRect = CGRect.zero
        cropRect.origin = CGPoint(x: (scrollView.contentOffset.x - imageView.frame.minX) / horizontalRatio,
                                  y:(scrollView.contentOffset.y - imageView.frame.minY) / verticalRatio)
        cropRect.size = CGSize(width: scrollView.frame.width / horizontalRatio,
                               height: scrollView.frame.height / verticalRatio)
        
        // 計算したCGRectを元に画像をクロップ
        let fixedImage = image.fixOrientation()
        let imageRef = fixedImage.cgImage!.cropping(to: cropRect)
        let croppedImage = UIImage(cgImage: imageRef!)
        
        return croppedImage
    }
}

extension ImageCropViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
