//
//  UIImage+Orientation.swift
//  IPCImagePickerController
//

import UIKit

extension UIImage {
    func fixOrientation() -> UIImage {
        var transform = CGAffineTransform.identity;
        
        // 画像を上向きに直す
        switch (imageOrientation) {
        case .up, .upMirrored:
            break
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height);
            transform = transform.rotated(by: CGFloat(M_PI));
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0);
            transform = transform.rotated(by: CGFloat(M_PI_2));
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: -(CGFloat)(M_PI_2));
            break
        }
        
        // 反転を直す
        switch (imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
        default:
            break;
        }
        
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context!.concatenate(transform);
        
        // 横向きの場合は幅と高さを逆にして描画する
        var rect = CGRect.zero
        switch (imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            rect.size = CGSize(width: size.height, height:size.width)
            break
        default:
            rect.size = CGSize(width: size.width, height:size.height)
            break
        }
        
        context?.draw(cgImage!, in: rect)
        
        let fixedCGImage = context!.makeImage();
        let image = UIImage(cgImage: fixedCGImage!)
        return image
    }
}

