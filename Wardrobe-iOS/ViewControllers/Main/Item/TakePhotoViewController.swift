//
//  TakePhotoViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/4/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit
import AVFoundation

enum TakePhotoType {
    case create
    case update
}

class TakePhotoViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var fleshButton: UIButton!
    private var captureSession = AVCaptureSession()
    private var frontCameraDeviceInput: AVCaptureDeviceInput?
    private var backCameraDeviceInput: AVCaptureDeviceInput?
    private var currentCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice!
    private var backCamera: AVCaptureDevice!
    private var torchMode: AVCaptureDevice.TorchMode = .off
    private var photoOutput: AVCapturePhotoOutput?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var imagePickerHelper = ImagePickerHelper()
    public var type: TakePhotoType = .create
    var updateCompletion: ((Data) -> ())?
    private let imageMixSize: CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        let cameraAccessStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAccessStatus == .authorized || cameraAccessStatus == .notDetermined {
            self.configureTakePhono()
        } else {
            self.showWantAccessAlert(true)
        }
    }
    
    func configureTakePhono() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        if frontCamera != nil && backCamera != nil {
            startRunningCaptureSession()
        }
    }
    
    private func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    private func setupDevice() {
        frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        currentCamera = backCamera
        if frontCamera != nil && backCamera != nil {
            frontCameraDeviceInput = try? AVCaptureDeviceInput(device: frontCamera!)
            backCameraDeviceInput = try? AVCaptureDeviceInput(device: backCamera!)
        }
    }
    
    private func setupInputOutput() {
        if backCameraDeviceInput != nil {
            captureSession.addInput(backCameraDeviceInput!)
        }
        photoOutput = AVCapturePhotoOutput()
        photoOutput?.isHighResolutionCaptureEnabled = true
        photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        captureSession.addOutput(photoOutput!)
    }
    
    private func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resize
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: cameraView.bounds.height) 
        cameraView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }

    
    private func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    
    private func configureUI() {
        imagePickerHelper.delegate = self
        cancelButton.layer.cornerRadius = cancelButton.bounds.width / 2
        titleLabel.text = "Take a Picture".localize()
    }
    
    private func openItemParamsView(_ imageData: Data) {
        if type == .create {
            let itemViewController: ItemParamsViewController = ItemParamsViewController.initFromStoryboard()
            itemViewController.viewModel.setImageData(imageData)
            itemViewController.type = .Edit
            navigationController?.pushViewController(itemViewController, animated: true)
        } else {
            updateCompletion?(imageData)
            dismiss(animated: true, completion: nil)
        }
    }
}

//MARK:- Button Action
extension TakePhotoViewController {
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
        fleshChange(torchMode)
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func fleshChangeAction(_ sender: Any) {
        if torchMode == .off {
            torchMode = .on
            fleshButton.setImage(UIImage(named: "fleshOn"), for: .normal)
        } else {
            torchMode = .off
            fleshButton.setImage(UIImage(named: "fleshOff"), for: .normal)
        }
    }
    
    @IBAction func galeryAction(_ sender: Any) {
        imagePickerHelper.libraryAction(completionHandler: { (controller, denied)  in
            DispatchQueue.main.async {[unowned self] in
                if denied {
                    self.showWantAccessAlert(false)
                } else {
                    controller?.modalPresentationStyle = .fullScreen
                    self.present(controller!, animated: true)
                }
            }
        })
    }
    
    @IBAction func cameraSwitchAction(_ sender: Any) {
        captureSession.beginConfiguration()
        if captureSession.inputs.contains(frontCameraDeviceInput!) == true {
            captureSession.removeInput(frontCameraDeviceInput!)
            captureSession.addInput(backCameraDeviceInput!)
            currentCamera = backCamera
        } else if captureSession.inputs.contains(backCameraDeviceInput!) == true {
            captureSession.removeInput(backCameraDeviceInput!)
            captureSession.addInput(frontCameraDeviceInput!)
            currentCamera = frontCamera
        }
        
        captureSession.commitConfiguration();
    }
    
    func fleshChange(_ cameraTorchMode: AVCaptureDevice.TorchMode) {
        if currentCamera!.hasTorch {
            // lock your device for configuration
            do {
                let _ = try currentCamera!.lockForConfiguration()
            } catch {

            }
            currentCamera!.torchMode = cameraTorchMode
            currentCamera!.unlockForConfiguration()
        }
    }
    
    func showWantAccessAlert(_ cameraAlert: Bool) {
        var message = ""
        if cameraAlert {
            message = "Unfortunately, you didn’t give access to your camera. You can allow camera access in Settings.".localize()
        } else {
            message = "Unfortunately, you didn’t give access to your Photos. You can allow Photos access in Settings.".localize()
        }
        AlertPresenter.presentInfoAlert(on: self, title: "Oops!".localize(), message: message, confirmButtonTitle: "Open Settings".localize(), cancelButtonTitle: "Cancel".localize()) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        } cancelButtonCompletion: { (_) in
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK:- AVCapturePhotoCaptureDelegate
extension TakePhotoViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            fleshChange(.off)
            let image = UIImage(data: imageData)!
            let cropImage = cropImageToSquare(image).scaledImage(width: imageMixSize, height: imageMixSize)
            checkAndOpenParamView(cropImage)
        }
    }
    
    func checkAndOpenParamView(_ image: UIImage) {
        var data = image.jpegData(compressionQuality: 1)
        var i: CGFloat = 1
        if data != nil {
            while (Int64(data!.count) * 4 / 3 > 200000) {
                data = image.jpegData(compressionQuality: i)
                i = i - 0.05
                
                if i < 0 {
                    break
                }
            }
        }
        openItemParamsView(data!)
    }
    
    func cropImageToSquare(_ image: UIImage) -> UIImage {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        var imageWidth = image.size.width
        var imageHeight = image.size.height
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            // Swap width and height if orientation is landscape
            imageWidth = image.size.height
            imageHeight = image.size.width
        default:
            break
        }
        
        // The center coordinate along Y axis
        let rcy = imageHeight * 0.5
        let rect = CGRect(x: rcy - imageWidth * 0.5, y: 0, width: imageWidth, height: imageWidth)
        let imageRef = image.cgImage?.cropping(to: rect)
        return UIImage(cgImage: imageRef!, scale: 1.0, orientation: image.imageOrientation)
    }
    
    
    // Used when image is taken from the front camera.
    func flipImage(image: UIImage!) -> UIImage! {
        let imageSize: CGSize = image.size
        UIGraphicsBeginImageContextWithOptions(imageSize, true, 1.0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.rotate(by: CGFloat(Double.pi/2.0))
        ctx.translateBy(x: 0, y: -imageSize.width)
        ctx.scaleBy(x: imageSize.height/imageSize.width, y: imageSize.width/imageSize.height)
        ctx.draw(image.cgImage!, in: CGRect(x: 0.0,
                                            y: 0.0,
                                            width: imageSize.width,
                                            height: imageSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

//MARK:- ImagePickerHelperDelegate
extension TakePhotoViewController: ImagePickerHelperDelegate {
    func imagePickerHelper(_ pickerHelper: ImagePickerHelper, didFinishGetData imageData: Data) {
        let galleryCropperViewController: GalleryCropperViewController = GalleryCropperViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe)
        galleryCropperViewController.modalPresentationStyle = .fullScreen
        galleryCropperViewController.setImage(UIImage(data: imageData)!)
        galleryCropperViewController.imageSetCompletion = { [weak self] image in
            guard let strongSelf = self else { return }
            var cropImage: UIImage?
            if image.size.width > strongSelf.imageMixSize {
                cropImage = image.scaledImage(width: strongSelf.imageMixSize, height: strongSelf.imageMixSize)
            } else {
                cropImage = image
            }
                
            strongSelf.checkAndOpenParamView(cropImage ?? UIImage())
        }
        present(galleryCropperViewController, animated: true, completion: nil)

    }
    
    func imagePickerHelperDidCancel(_ pickerHelper: ImagePickerHelper) {
        
    }
}

