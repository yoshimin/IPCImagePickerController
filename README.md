# IPCImagePickerController
Cut the image acquired from the camera roll at an arbitrary aspect ratio.


## Usage
To begin work you should create an instance of ImagePickerController.
If you want to specify the aspect ratio, you need to set the value.（default value is 1.）
```
let picker = ImagePickerController()
picker.aspectRatio = 16/9
```
And then present it.
```
self.present(picker, animated: true, completion: nil)
```

You can observe results on the ImagePickerController.
```
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
```

