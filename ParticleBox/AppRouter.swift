//  Created by Michal Ciurus

import UIKit
import SharedTools
import NetworkAPI

fileprivate enum AppRouterConstants {
    static let mainStoryboard = "BoxFeed"
    static let mainViewController = "BoxFeedViewController"
}

final class AppRouter: Routable {
    
    fileprivate typealias C = AppRouterConstants
    
    //MARK: Private Properties
    
    private var window: UIWindow
    private let navigationController = UINavigationController()
    private let routerCollection = RouterCollection()
    private var boxFeed: BoxFeedViewController?
    
    //MARK: Public Properties
    
    var didFinishRouting = EventObservable<Void>()

    //MARK: Public Methohds
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        
        BoxAPI.shared.login()
        
        let boxFeedStoryboard = UIStoryboard(name: C.mainStoryboard, bundle: nil)
        guard let boxFeedViewController = boxFeedStoryboard.instantiateViewController(withIdentifier: C.mainViewController) as? BoxFeedViewController else {
            fatalError("Can't load main feed view controller")
        }
        
        boxFeedViewController.createBoxEvent.observe { [weak self] _ in
            self?.showCreateBox()
        }
        
        navigationController.pushViewController(boxFeedViewController, animated: false)
        window.rootViewController = navigationController
        
        self.boxFeed = boxFeedViewController
    }
    
}

private extension AppRouter {
    func showCreateBox() {
        let createBoxRouter = CreateBoxRouter(navigationController: self.navigationController)
        
        createBoxRouter.didCreateBox.observe { [weak self] box in
            if let box = box {
                self?.boxFeed?.interactor.add(box: box)
            }
        }
        
        self.routerCollection.add(router: createBoxRouter)
        createBoxRouter.start()
    }
}
