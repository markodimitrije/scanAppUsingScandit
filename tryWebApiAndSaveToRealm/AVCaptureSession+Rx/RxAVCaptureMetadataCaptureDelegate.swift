//
//  RxAVCaptureMetadataCaptureDelegate.swift
//  tryScanner
//
//  Created by Marko Dimitrijevic on 31/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import AVFoundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public typealias MetadataCaptureOutput = (output: AVCaptureMetadataOutput, metadataObjects: [AVMetadataObject], connection: AVCaptureConnection?)

final class RxAVCaptureMetadataCaptureDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    typealias Observer = AnyObserver<MetadataCaptureOutput>
    
    var observer: Observer?
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        //print("emitujem metadata....")
        observer?.on(.next(MetadataCaptureOutput(output, metadataObjects: metadataObjects, connection: connection)))
        
    }
    
}
