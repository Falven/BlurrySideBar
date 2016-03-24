//
//  SideBar.swift
//  BlurrySideBar
//
//  Created by Francisco Aguilera on 7/24/15.
//  Copyright © 2015 Dapper-Apps LLC. All rights reserved.
//

import UIKit

@objc protocol SideBarDelegate {
    func sideBarDidSelectButtonAtIndex(index: Int)
    optional func sideBarWillClose()
    optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
    
    let sideBarWidth: CGFloat = 150.0
    let sideBarTableViewTopInset: CGFloat = 64.0
    let sideBarView = UIView()
    let sideBarTableViewController = SideBarTableViewController()
    
    let originView: UIView
    let animator: UIDynamicAnimator
    
    var delegate: SideBarDelegate?
    var isSideBarOpen = false
    
    init(sourceView: UIView, menuItems: Array<String>) {
        self.originView = sourceView
        self.animator = UIDynamicAnimator(referenceView: originView)
        
        super.init()
        
        sideBarTableViewController.tableData = menuItems
        setupSideBar()
        setupGestureRecognizers()
    }
    
    func setupSideBar() {
        // Setting up container view
        sideBarView.frame = CGRectMake(-sideBarWidth, originView.frame.origin.y, sideBarWidth, originView.frame.height)
        sideBarView.backgroundColor = UIColor.clearColor()
        sideBarView.clipsToBounds = false
        
        // Setting up blur view
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = sideBarView.bounds
        
        // Setting up table
        sideBarTableViewController.delegate = self // for sideBarControlDidSelectRow
        sideBarTableViewController.tableView.frame = sideBarView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideBarTableViewController.tableView.scrollsToTop = true
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        sideBarTableViewController.tableView.reloadData()
        
        sideBarView.addSubview(blurView)
        sideBarView.addSubview(sideBarTableViewController.tableView)
        originView.addSubview(sideBarView)
    }
    
    func setupGestureRecognizers() {
        let showGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.originView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.originView.addGestureRecognizer(hideGestureRecognizer)
    }
    
    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left {
            showSideBar(false)
            delegate?.sideBarWillClose?()
        } else {
            if recognizer.direction == UISwipeGestureRecognizerDirection.Right {
                showSideBar(true)
                delegate?.sideBarWillOpen?()
            }
        }
    }
    
    func showSideBar(shouldOpen: Bool) {
        animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        
        let gravityX: CGFloat = shouldOpen ? 0.5 : -0.5
        let magnitude: CGFloat = shouldOpen ? 20 : -20
        let boundaryX: CGFloat = shouldOpen ? sideBarWidth : -sideBarWidth
        
        // Graviy behavior
        let gravityBehavior: UIGravityBehavior = UIGravityBehavior(items: [sideBarView])
        gravityBehavior.gravityDirection = CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavior)
        
        // Collision behavior
        let collisionBehavior = UICollisionBehavior(items: [sideBarView])
        collisionBehavior.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
        // Push behavior
        let pushBehavior = UIPushBehavior(items: [sideBarView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        // Item behavior
        let sideBarBehavior = UIDynamicItemBehavior(items: [sideBarView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)
    }
    
    func sideBarControlDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectButtonAtIndex(indexPath.row)
    }
}
