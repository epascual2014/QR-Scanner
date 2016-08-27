//
//  ViewController.swift
//  QR Scanner
//
//  Created by Edrick Pascual on 8/26/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var qrCodeLabel: UILabel!
    
    @IBOutlet weak var qrCodeResultLabel: UILabel!
    
    var objCaptureSession: AVCaptureSession?
    var objCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var vwQRCode:UIView?
    
    
    // Configure Video Capture Function
    func configureVideoCapture(){
        let objCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        let objCaptureDeviceInput: AnyObject!
        do {
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
        }
        
        if (error != nil) {
            let alertView:UIAlertView = UIAlertView(title: "Device Error", message: "Device not supported", delegate: nil, cancelButtonTitle: "OK Done")
            alertView.show()
            return
        }
        
        objCaptureSession = AVCaptureSession()
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    // Video Preview Layer Function
    func addVideoPreviewLayer(){
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        objCaptureSession?.startRunning()
        
        self.view.bringSubviewToFront(qrCodeResultLabel)
        //self.view.bringSubviewToFront(qrCodeLabel)
    }
    
    // Func to put the QRCode image can detect and display on the device
    func initiliazeQRView() {
        vwQRCode = UIView()
        vwQRCode?.layer.borderColor = UIColor.redColor().CGColor
        vwQRCode?.layer.borderWidth = 5
        self.view.addSubview(vwQRCode!)
        self.view.bringSubviewToFront(vwQRCode!)
        
        
    }
    
    
//    func captureQRCode() {
//        
//        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
//        
//        let input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: nil) as AVCaptureDeviceInput
//        session.addInput(input)
//        
//       let output = AVCaptureMetadataOutput()
//        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
//        session.addOutput(output)
//        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
//        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        let bounds = self.view.layer.bounds
//        previewLayer.bounds = bounds
//        previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
//        
//        self.view.layer.addSublayer(previewLayer)
//        session.startRunning()
//    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initiliazeQRView()
        
    }

}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            vwQRCode?.frame = CGRectZero
            qrCodeResultLabel.text = "NO QRCode Text detected"
            return
        }
        
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            let objBarCode = objCaptureVideoPreviewLayer?.transformedMetadataObjectForMetadataObject(objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            vwQRCode?.frame = objBarCode.bounds;
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                qrCodeResultLabel.text = objMetadataMachineReadableCodeObject.stringValue
            }
        }
    }
    
}
