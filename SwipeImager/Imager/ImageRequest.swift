
//  Created by Jeroen Dunselman on 02/04/2017.
//  Copyright © 2017 Jeroen Dunselman. All rights reserved.
//

import Foundation
import UIKit

class ImageRequest : NSObject {
    
//    var client: Any = false
//    var path: IndexPath? = nil
    
    var imageView: UIImageView?
    var activityView: UIActivityIndicatorView?
    
    var started: Bool = false
    var finished: Bool = false
    var assignedToRow: Int?
    
//    var service: LibraryAssetService?
    public var layOut: LayOut!
    
    var view:DrawTartanView?
    
    init(_ design: LayOut) {
        self.layOut = design
        view = nil
    }

//    init(_ board: LayOut, service: LibraryAssetService) {
//        self.layOut = board
////        self.service = service
//    }

    func downloadImage() {
        guard !self.started else {
            return
            
        }
//        self.activityView?.startAnimating()
//        self.activityView?.isHidden = false
        var image = UIImage()
        DispatchQueue.global(qos: .default).async { //.background
            
            self.started = true
            //.build() not needed for input as [SwipeEvent]
            
            image = self.layOut.visualizeTartan()
            
            self.finished = true
            if self.imageView != nil {
                DispatchQueue.main.async() { () -> Void in
                    
                    //  Update view once downloaded.
                    self.imageView?.image = image
                    self.activityView?.stopAnimating()
                    self.activityView?.isHidden = true
                    
//                    if let model = self.client as? ColorPickerViewModel, let controller = model.client.tableView.cellForRow(at: self.path!) as? PaletCell {
//                        controller.activityIndicator.isHidden = true
//                        controller.activityIndicator.stopAnimating()
//                    }
//
//                    if let model = self.client as? TartanLibraryViewModel {
//                        model.reportForFinished(at: self.path!)
//                    }
//                    if let model = self.client as? ColorPickerViewModel {
//                        model.reportForFinished(at: self.path!)
//                    }
                }
            }
            

        }
    }

}
