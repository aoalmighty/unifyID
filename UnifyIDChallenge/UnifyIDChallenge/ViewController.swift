//
//  ViewController.swift
//  UnifyIDChallenge
//
//  Created by Ashraf Omar on 30/10/16.
//  Copyright (c) 2016 Ashraf Omar. All rights reserved.
//

import UIKit
import AVFoundation
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var TakePhoto: UIButton!
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var imageNumber:Int = 1
    
    override func viewWillAppear(animated: Bool) {
        
        let error = NSErrorPointer()
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // use front camera
        if device.position == AVCaptureDevicePosition.Front{
            let input = AVCaptureDeviceInput(device: device, error: error)
            
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
                sessionOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            }
            
            if captureSession.canAddOutput(sessionOutput){
                
                captureSession.addOutput(sessionOutput)
                captureSession.startRunning()
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraView.layer.addSublayer(previewLayer)
                
                previewLayer.position = CGPoint(x: self.cameraView.frame.width/2, y: self.cameraView.frame.height/2)
                previewLayer.bounds = cameraView.frame
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Takes Photo every 0.5sec
        takePhotos()
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("takePhotos"), userInfo: nil, repeats: true)
        
        // Stop taking photos after 10sec
        var timerAfterPhotos = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("doneTakingPhotos"), userInfo: nil, repeats: false)
        func doneTakingPhotos(){
            timer.invalidate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func takePhotos(){
        if let videoConnection = sessionOutput.connectionWithMediaType(AVMediaTypeVideo){
            sessionOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                buffer, error in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
                // Stores image in photo album (USED FOR TESTING IF IMAGE IS CAPTURED)
                // UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                
                // Stores image securely using keychain
                let isSaved:Bool = KeychainWrapper.setData(imageData, forKey: String(self.imageNumber))
                self.imageNumber++
                
                // Use "1/2/3/4/5" as keyname to retrieve desired image
                //KeychainWrapper.objectForKey(<#keyName: String#>)
                
            })
        }
    }
    
    
    // Manually Takes a photo (USED FOR TESTING CAMERA)
    @IBAction func takePhoto(sender: AnyObject) {
        
        if let videoConnection = sessionOutput.connectionWithMediaType(AVMediaTypeVideo){
            sessionOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                buffer, error in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
                // Stores image in photo album
                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
            })
        }
    }

}

