import Foundation
import UIKit

class ActivityIndicator {
    
    private var view: UIView
    private var activityIndicator = UIActivityIndicatorView()
    
    init(view:  UIView) {
        self.view = view
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(activityIndicator)
    }
    
    public func startLoading() {
        
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    public func stopLoading() {
        
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
