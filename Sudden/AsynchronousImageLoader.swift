//
//  AsynchronousImageLoader.swift
//  Sudden
//
//  Created by youcef bouhafna on 12/6/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
import UIKit
class AsynchronousImageLoader {
    
    // loading the images from facebook ASYNCHRONOUSLY & caching them in system cache so we save loading time and memory energy.
    var imageCache = NSCache<AnyObject, AnyObject>()
    // create sharedInstance for singlton pattern
    static let sharedImageInstance = AsynchronousImageLoader()
    
    // load image using NSURLSESSION
    func imageForUrl(urlString: String, completion: @escaping(_ image: UIImage?, _ url: String) -> Void) {
        // create the queue in the background so we DON'T BLOCK the MAIN THREAD!!! very important....
        DispatchQueue.global(qos: .background).async {
            // caching
            let data: NSData? = self.imageCache.object(forKey: urlString as NSString) as? NSData
            
            if let data = data {
                let image = UIImage(data: data as Data)
                // bring to main queue
                DispatchQueue.main.async {
                completion(image, urlString)
                }
            }
            let session = URLSession.shared
            let request = URLRequest(url: URL(string: urlString)!)
            session.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    completion(nil, urlString)
                }
                
                if let data = data {
                    let image = UIImage(data: data)
                    self.imageCache.setObject(data as AnyObject, forKey: urlString as NSString)
                    // bring to main queue
                    DispatchQueue.main.async {
                        completion(image, urlString)
                    }
                }
            })
            .resume()
        }
    }
}
