//
//  ViewController.swift
//  GuilleCameraInt
//
//  Created by Ramirez  on 12/1/18.
//  Copyright © 2018 Ramirez. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var camPreview: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var camWhiteLine: UIView!
    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var switchIcon: UIImageView!
    @IBOutlet weak var switchWhiteUI: UIView!
    
    private var isSettingThumbnail = false
    private var thumbImage: UIImage?
    
    //new dec 1 (the commeting ut is new)
    //@IBOutlet weak var cancelButton: UIButton!
    
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var image: UIImage?
    
    //INTEGRATION nov 24 --
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    var numForVid = 0
    var numForPic = 0
    
    
    //new dec 1 for cncel/preview
    //var newView: UIImageView?
    
    let cancelButton = UIButton(frame: CGRect(x: 0, y: 589, width: 145, height: 78))
    
    var numForCancel = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad RANNED")
        
        setupCamera()
        
        cancelButton.isHidden = true
        cancelButton.setTitle("Cancel", for: .normal)
        //cancelButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        cancelButton.setTitleColor(UIColor(red: 148/255, green: 23/255, blue: 51/255, alpha: 1.0), for: .normal)
        cancelButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        //self.view.superview?.addSubview(cancelButton)
        
    }
    
    
    
    
    func setupCamera() {
        print("\(movieOutput) <-- movie output  ")
        print("67423814700000000")
        
        if setupInputOutput() {
            print("in this gfgf")
            setupCaptureSession()
            setupDevice()
            startRunningCaptureSession()
        }
        //maybe below can go inside of the above if
        setupPreviewLayer()
        
        //cameraButton.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        cameraButton.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        longGesture.minimumPressDuration = 0.15
        //longGesture.allowableMovement = 100
        
        //this functionality below may be imp?
        //        longGesture.delaysTouchesBegan
        cameraButton.addGestureRecognizer(longGesture)
        
        camPreview.addSubview(cameraButton)
        
    }
    
    //for camera tap
    @objc func normalTap(_ sender: UIGestureRecognizer) {
        //self.numForPic = numForPic + 1
        let settings = AVCapturePhotoSettings()
        isSettingThumbnail = false
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    @objc func cancelTap(_ sender: UIGestureRecognizer) {
        camPreview.layer.addSublayer(previewLayer!)
        self.playerQueue?.removeAllItems()
        //tradof with where we place teh bellow func is that here it makes teh black thing apear after cancle but in teh other it makes the initial transition to preview slow and the cancel func fast
        //self.startRunningCaptureSession()
        
        cancelButton.isHidden = true
        switchIcon.isHidden = false
        switchWhiteUI.isHidden = false
        switchCamButton.isHidden = false
        camWhiteLine.isHidden = false
        cameraButton.isHidden = false
        print("cancel tap")
        
    }
    
    
    //for video hold
    @objc func longTap(_ sender: UIGestureRecognizer) {
        print("Long tap")
        
        self.numForVid = numForVid + 1 //shud change this number stuff: I think its not even used now
        print("\(numForVid)")
        
        cameraButton.isHidden = true
        
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            stopRecording()
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
            startCapture()
        }
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
    }
    
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func setupPreviewLayer() {
        //Configure previewLayer
        print("5642378962589")
        
        //nov 23: integrated code below
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer?.frame = camPreview.bounds
        camPreview.layer.addSublayer(previewLayer!)
    }
    
    func setupInputOutput() -> Bool {
        print("we in this 54?")
        
        guard let device: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return false } //**
        
        self.currentCamera = device //**
        print("\(device) <--- DEVICE YANDI!!")
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)//**
            print("\(captureDeviceInput) <-- this is input TACKY TOCK")
            
            if captureSession.canAddInput(captureDeviceInput) { //**
                print("\(captureSession.canAddInput(captureDeviceInput)) <-- DUC TRAN ,.")
                
                captureSession.addInput(captureDeviceInput)
                
                activeInput = captureDeviceInput
                
            } else {
                print("this it elsed bruh!>>!>!>!>!>!>!>")
            }
            
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            
            captureSession.addOutput(photoOutput!)


            
        } catch {
            print("error --> \(error)")
        }
        
        
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: .audio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            print("\(micInput) <-- this Mic input")
            if captureSession.canAddInput(micInput) {
                //ok so below printed true, so clearly the problem is that there are o cam back cam inputs trying to get dadded so i need to combine them the 2 above
                print("\(captureSession.canAddInput(micInput)) <-- BUGA UGA BUGA")
                
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        print("\(captureSession.canAddOutput(movieOutput)) <-- MOVIE OUTPUT CAN ADD INPUT??? BRUH>????")
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        } else {
            print("this clapp did not ")
        }
        
        print("r r nah??")
        return true
        
        
    }
    
    func setupDevice() {
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }

    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    @objc func startCapture() {
        startRecording()
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            print("\(path) < who is u PATH")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            let connection = movieOutput.connection(with: AVMediaType.video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
        else {
            stopRecording()
        }
    }
    
    func stopRecording() {
        if thumbImage != nil {
            camPreview.image = thumbImage!
        }
        previewLayer?.removeFromSuperlayer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            if self.movieOutput.isRecording == true {
                self.movieOutput.stopRecording()
            }
        })
        
    }
    
    private var playerQueue: AVQueuePlayer!
    private var playerItem1: AVPlayerItem!
    private var playerLooper: AVPlayerLooper!
    private var playerLayer: AVPlayerLayer!
    
    //below is called when the vid finishes (so u stop long tapping)
    func newViewVideoPlayback() { //videoURL: URL!
        self.numForCancel = 1
        self.view.superview?.addSubview(cancelButton) //maybe do newView, then subview
        cancelButton.isHidden = false //so instead i put this here
        //used to be outside of func dec 1 10pm
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(cancelTap(_:)))
        cancelGesture.numberOfTapsRequired = 1
        cancelButton.addGestureRecognizer(cancelGesture)
    }
    
    func playRecordedVideo(video: URL) {
        thumbImage = nil
        playerQueue = AVQueuePlayer(playerItem: AVPlayerItem(url: video))

        playerLayer = AVPlayerLayer(player: playerQueue)
        playerLayer.frame = (camPreview?.bounds)!
        playerLayer?.layoutIfNeeded()
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        camPreview?.layer.insertSublayer(playerLayer, above: previewLayer)
        
        playerItem1 = AVPlayerItem(url: video)
        
        playerLooper = AVPlayerLooper(player: playerQueue, templateItem: playerItem1)
        self.playerQueue?.play()
    }
    
    
}




//Extension for actual photo capture function
extension ViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        print("you in this !")
        
        if let imageData = photo.fileDataRepresentation() {
            print("\(UIImage(data: imageData)) <-- image DALUE FEFE DEDE KEKE LALY")
            if isSettingThumbnail {
                thumbImage = UIImage(data: imageData)
            } else {
                image = UIImage(data: imageData)
            }
            
            print("\(image) <-- dada dudu creoo IMAGE valu")
        }
        
    }
    
}

extension ViewController: AVCaptureFileOutputRecordingDelegate {
    //MARK: - Protocal stubs
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        isSettingThumbnail = true
        photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie11: \(error!.localizedDescription)") //error here, may be able to fix  with the snap camera sort of thing( if its longer than X then pic, rease vid etc...)
        } else {
            isSettingThumbnail = false
            newViewVideoPlayback()
            
            switchIcon.isHidden = true
            switchWhiteUI.isHidden = true
            switchCamButton.isHidden = true
            camWhiteLine.isHidden = true
            
            let videoRecorded = outputURL! as URL
            playRecordedVideo(video: videoRecorded)
            
            if !captureSession.isRunning {
                DispatchQueue.global(qos: .background).async {
                    self.startRunningCaptureSession()
                }
                
            }
        }
    }
}


