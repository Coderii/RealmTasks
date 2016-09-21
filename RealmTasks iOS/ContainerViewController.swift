/*************************************************************************
 *
 * REALM CONFIDENTIAL
 * __________________
 *
 *  [2016] Realm Inc
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Realm Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Realm Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Realm Incorporated.
 *
 **************************************************************************/

import Cartography
import RealmSwift
import UIKit

// MARK: Container View Controller Protocol

protocol ContainerNavigationProtocol {
    var createTopViewController: (() -> (UIViewController))? {get set}
    var topViewController: UIViewController? {get set}
    var createBottomViewController: (() -> (UIViewController))? {get set}
    var bottomViewController: UIViewController? {get set}

    func auxViewController(position: NavDirection) -> UIViewController?
    func createAuxViewController(position: NavDirection) -> (() -> (UIViewController))?
    
}

// MARK: Container View Controller

class ContainerViewController: UIViewController, ContainerNavigationProtocol {
    private var titleLabel = UILabel()
    private var titleTopConstraint: NSLayoutConstraint?
    override var title: String? {
        didSet {
            if let title = title {
                titleLabel.text = title
            }
            titleTopConstraint?.constant = (title != nil) ? 20 : 0
            UIView.animateWithDuration(0.2) {
                self.titleLabel.alpha = (self.title != nil) ? 1 : 0
                self.titleLabel.superview?.layoutIfNeeded()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        setupTitleBar()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    private func addChildVC() {
        let firstList = try! Realm().objects(TaskList.self).first!
        let vc = ViewController(navigation: self, parent: firstList, colors: UIColor.taskColors())
        title = firstList.text
        addChildViewController(vc)
        view.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
    }

    private func setupTitleBar() {
        let titleBar = UIToolbar()
        titleBar.barStyle = .BlackTranslucent
        view.addSubview(titleBar)
        constrain(titleBar) { titleBar in
            titleBar.left == titleBar.superview!.left
            titleBar.top == titleBar.superview!.top
            titleBar.right == titleBar.superview!.right
            titleBar.height >= 20
            titleBar.height == 20 ~ UILayoutPriorityDefaultHigh
        }

        titleLabel.font = .boldSystemFontOfSize(13)
        titleLabel.textAlignment = .Center
        titleLabel.textColor = .whiteColor()
        titleBar.addSubview(titleLabel)
        constrain(titleLabel) { titleLabel in
            titleLabel.left == titleLabel.superview!.left
            titleLabel.right == titleLabel.superview!.right
            titleLabel.bottom == titleLabel.superview!.bottom - 5
            titleTopConstraint = (titleLabel.top == titleLabel.superview!.top + 20)
        }
    }

    // MARK: ContainerNavigationProtocol methods
    var createTopViewController: (() -> (UIViewController))?
    var topViewController: UIViewController?
    var createBottomViewController: (() -> (UIViewController))?
    var bottomViewController: UIViewController?

    func auxViewController(position: NavDirection) -> UIViewController? {
        return (position == .Up) ? topViewController : bottomViewController
    }

    func createAuxViewController(position: NavDirection) -> (() -> (UIViewController))? {
        return (position == .Up) ? createTopViewController : createBottomViewController
    }

}
