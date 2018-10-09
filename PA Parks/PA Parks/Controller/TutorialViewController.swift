//
//  TutorialViewController.swift
//
//  Most Work taken from Dr. Hannan
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var finishTutorialButton: UIButton!
    
    weak var delegate : ParkImageDelegate?
    
    var pageViewController : UIPageViewController?
    var nextIndex: Int?
    let parkModel = ParkModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        let firstPage =  contentController(at: 0)
        pageViewController!.setViewControllers([firstPage], direction: .forward, animated: false, completion: nil)
        
        // need these so that pageViewController delegate is told about orientation changes
        self.addChild(pageViewController!)
        pageViewController?.didMove(toParent: self)
        
        self.view.addSubview(pageViewController!.view)
        self.view.bringSubviewToFront(pageController)
        
        pageController.numberOfPages = parkModel.numberOfTutorialImages
        
        //
        
    }
    
    //MARK: - UIPageViewController Data Source
    
    // guarantee that index is within range (0...3)
    func contentController(at index:Int) -> TutorialPageController {
        let content = self.storyboard?.instantiateViewController(withIdentifier: "TutorialImageView") as! TutorialPageController
        
        let imageName = parkModel.parkTutorialImageNames(at: index)
        let image = UIImage(named: imageName)
        content.configure(with: image, index: index)
        pageController.currentPage = index
        return content
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let tutorialPageController = viewController as! TutorialPageController
        let index = tutorialPageController.imageIndex!
        
        guard index < parkModel.numberOfTutorialImages - 1 else {
            finishTutorialButton.isEnabled = true
            finishTutorialButton.isHidden = false
            self.view.bringSubviewToFront(finishTutorialButton)
            return nil
            
        }
        finishTutorialButton.isEnabled = false
        finishTutorialButton.isHidden = true
        
        let newController =  contentController(at: index+1)
        return newController
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let tutorialPageController = viewController as! TutorialPageController
        let index = tutorialPageController.imageIndex!
        
        guard index > 0 else {return nil}
        
        let newController =  contentController(at: index-1)
        return newController
    }
    
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let nextView = pendingViewControllers.first! as? TutorialPageController {
            self.nextIndex = nextView.imageIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageController.currentPage = nextIndex ?? 0
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
            
            self.pageViewController!.isDoubleSided = false
            return .min
        }
        
        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! TutorialPageController
        var viewControllers: [UIViewController]
        
        let indexOfCurrentViewController = currentViewController.imageIndex!
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
        
        return .mid
    }
    
    @IBAction func exitTutorial(_ sender: Any) {
        delegate?.dismissMe()
    }
}
