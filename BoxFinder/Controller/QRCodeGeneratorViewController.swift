//
//  QRCodeGeneratorViewController.swift
//  BoxFinder
//
//  Created by Alanda Syla on 6/20/18.
//  Copyright © 2018 Alanda Syla. All rights reserved.
//

import UIKit

class QRCodeGeneratorViewController: UIViewController {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    var boxId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let boxId = boxId {
            generateQRCodeForBox(boxId)
        }
    }
    
    //MARK: - QR Code
    func generateQRCodeForBox(_ boxId: String) {
        
        let data = boxId.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        if let cifilter = filter {
            cifilter.setValue(data, forKey: "inputMessage")
            cifilter.setValue("Q", forKey: "inputCorrectionLevel")
            
            let transform = CGAffineTransform(scaleX: 100, y: 100)
            
            if let outputImage = filter?.outputImage?.transformed(by: transform) {
                
                qrCodeImageView.image = UIImage(ciImage: outputImage)
            }
        }
    }
    
}
