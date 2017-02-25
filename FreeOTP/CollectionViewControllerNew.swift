//
//  CollectionViewControllerNew.swift
//  FreeOTP
//
//  Created by Mike Meyer on 2014/11/10.
//  Copyright (c) 2014 Mike Meyer. All rights reserved.
//


import UIKit

class CollectionViewControllerNew: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverControllerDelegate {
    var store: TokenStore
    var lastPath: NSIndexPath?
    var longPressGesture: UILongPressGestureRecognizer
    var swipeGesture: UISwipeGestureRecognizer
    var popover: UIPopoverController

    required init(coder aDecoder: NSCoder) {
        println("wowow")
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("MFACard", forIndexPath: indexPath) as TokenCell

//        Press and hold to rearrange
        longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress"))
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)

//        Swipe to delete
        swipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe"))
        collectionView.addGestureRecognizer(swipeGesture!)
        
        if cell.bind(store?.get(UInt(indexPath.row))) {
            return cell
        }

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        Perform animation.
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

//        Get the current cell.
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as TokenCell
        if cell == nil { return }

//        Get the selected token.
        let token = store?.get(UInt(indexPath.row))
        if token == nil { return }

//        Get the token code and save the token state.
        let tc = token.code
        store?.save(token)

        cell.state = tc
        
        return
    }

    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        println("LONGPRESSING")

        var cell: UICollectionViewCell? = nil

        var p: CGPoint = gestureRecognizer.locationInView(self)
        var currPath: NSIndexPath = self.indexPathForItemAtPoint(p)!

        return
    }

    func handleSwipe(gestureRecognizer: UISwipeGestureRecognizer){
        println("SWIPING")
        return
    }

    @IBAction func addClicked(sender){
        let storyboard = UIStoryboard(name: "Main")
        var c = storyboard.instantiateViewControllerWithIdentifier("addToken") as AddTokenViewController
        var nc = UINavigationController(rootViewController: c)

        c.popover = UIPopoverController(contentViewController: nc)
        self.popover.delegate = self
        self.popover.popoverContentSize = CGSizeMake(320, 715)
        self.popover.presentPopoverFromBarButtonItem(sender)
    }
}