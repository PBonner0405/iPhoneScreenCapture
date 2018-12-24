//
//  ViewController.swift
//  ScreenCaptureApp
//
//  Created by iOS Developer on 11/30/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var btn_rotateV: UIButton!
    @IBOutlet weak var btn_rotateH: UIButton!
    @IBOutlet weak var img_screehshot: UIImageView!
    var counter = 0
    var thread_flag: Bool = true
    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        screencaptureThread(start_flag: false)
    }
    @IBAction func onClickShow(_ sender: Any) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 3
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            let totalImageCountNeeded = 3 // <-- The number of images to fetch
            fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
        }
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Perform the image request
        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            if let image = image {
                // Add the returned image to your array
                self.images += [image]
            }
            // If you haven't already reached the first
            // index of the fetch result and if you haven't
            // already stored all of the images you need,
            // perform the fetch request again with an
            // incremented index
            if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            } else {
                // Else you have completed creating your array
                print("Completed array: \(self.images)")
            }
        })
    }
    //rotate Image Vertically
    @IBAction func onClickV(_ sender: Any) {
//        print("you clicked on vertical button");
//        let alert = UIAlertController(title: "Alert", message: "my message", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
//        self.present(alert, animated: true, completion:nil)
        self.img_screehshot.image = flipImage(oldImage: self.img_screehshot.image!, flag: true)
    }
    //rotate Image Horizontally
    @IBAction func onClickH(_ sender: Any) {
//        self.img_screehshot.image = imageRotatedByDegrees(oldImage: self.img_screehshot.image!
//            , deg: 90)
        
        self.img_screehshot.image = flipImage(oldImage: self.img_screehshot.image!, flag: false)
    }
    

    @IBAction func onStart(_ sender: Any) {
        if thread_flag == true {
            _ =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(captureScreen)),userInfo: nil, repeats: true)
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "Thread Already Started ...", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc func captureScreen(scene: UIViewController){
        print("timer working \(counter)");
        counter+=1;

        var window: UIWindow? = UIApplication.shared.keyWindow
        window = UIApplication.shared.windows[0] as? UIWindow
        UIGraphicsBeginImageContextWithOptions(window!.frame.size, window!.isOpaque, 0.0)
        window!.layer.render(in: (UIGraphicsGetCurrentContext() ?? nil)!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
//        let mainScreenScreenshot = XCUIScreen.main.screenshot()

//        let mainScreenScreenshot = UIScreen.screens
        
        // Take a screenshot of an app's first window.
//        let app = UIApplication()
//        app.launch()
//        let windowScreenshot = app.windows.firstMatch.screenshot()
        
//        img_screehshot.image = image
    }
    
    func flipImage(oldImage: UIImage, flag: Bool) -> UIImage{
        if flag {
            let image = UIImage(cgImage: oldImage.cgImage!, scale: 1.0, orientation: .leftMirrored)
            let r_image = imageRotatedByDegrees(oldImage: image, deg: 90)

            return r_image
        }else {
            let image = UIImage(cgImage: oldImage.cgImage!, scale: 1.0, orientation: .downMirrored)
            return image
        }
    }
    
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat(Double.pi / 180))
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat(Double.pi / 180)))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIApplication {
    
    var screenShot: UIImage?  {
        return keyWindow?.layer.screenShot
    }
}

extension CALayer {
    
    var screenShot: UIImage?  {
        let scale = UIScreen.main.scale
//        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 0,height: 0), false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}
