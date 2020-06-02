//
//  ViewController.swift
//  MeusOlhos
//
//  Created by Bruno Cortez on 4/13/20.
//  Copyright © 2020 Bruno Cortez. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lbResult: UILabel!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        let visionModel = try! VNCoreMLModel(for: Resnet50().model)
        let request = VNCoreMLRequest(model: visionModel, completionHandler: { [weak self] (request, error) in
            self?.processObservations(for: request)
        })
        request.imageCropAndScaleOption = .scaleFit
        return request
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func showCamera(_ sender: Any) {
        showPicker(sourceType: .camera)
    }
    
    @IBAction func showLibrary(_ sender: Any) {
        showPicker(sourceType: .photoLibrary)
    }
    
    func showPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)

    }
    
    func processObservations(for requerst: VNRequest) {
        DispatchQueue.main.async {
            guard let observation = (requerst.results as? [VNClassificationObservation])?.first else { return }
            let confidence = "\(observation.confidence * 100)%"
            self.lbResult.text = "\(confidence): \(observation.identifier)"
        }
    }
    
    func classify(image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let ciimage = CIImage(image: image)!
            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            let handler = VNImageRequestHandler(ciImage: ciimage, orientation: orientation)
            try! handler.perform([self.classificationRequest])
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        classify(image: image)
        dismiss(animated: true, completion: nil)
    }
}

extension CGImagePropertyOrientation {
  init(_ orientation: UIImage.Orientation) {
    switch orientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    @unknown default:
      fatalError()
    }
  }
}

