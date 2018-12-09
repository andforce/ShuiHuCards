//
//  MainController.swift
//  HFCardCollectionViewLayoutExample
//
//  Created by Hendrik Frahmann on 28.10.16.
//  Copyright © 2016 Hendrik Frahmann. All rights reserved.
//

import UIKit

struct CardInfo {
    var color: UIColor
}

class ExampleViewController : UICollectionViewController, HFCardCollectionViewLayoutDelegate {
    
    var cardCollectionViewLayout: HFCardCollectionViewLayout?
    
    var revealCell:WaterMarginFrontCell?

    var frontShowed:Bool? = true
    
    @IBOutlet var backgroundView: BackGroundActionUIView?
    @IBOutlet var backgroundNavigationBar: UINavigationBar?
    
    var cardLayoutOptions: CardLayoutSetupOptions?
    var shouldSetupBackgroundView = true
    
    var cardArray: [CardInfo] = []
    
    override func viewDidLoad() {
        self.setupExample()
        super.viewDidLoad()
        self.collectionView.contentInset = UIEdgeInsets.init(top: 16, left: 16, bottom: 0, right: 16)
    }


    @IBAction func showBackground(_ sender: UIButton) {
        if frontShowed! {
            self.revealCell?.buttonFlipAction()

            frontShowed = false;
        } else {
            self.cardCollectionViewLayout?.flipBackRevealedCardAction()
            frontShowed = true;
        }
    }
    
    // MARK: CollectionView
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didRevealCardAtIndex index: Int) {

        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? WaterMarginFrontCell {

            self.revealCell = cell

            self.backgroundView?.alpha = 1.0

            let actionRootView = self.backgroundView?.actionRootView

            let currentFrame = actionRootView?.frame

            let achorViewFrame:CGRect = cell.contentView.frame

            let newFrame = CGRect.init(x: (currentFrame?.origin.x)!,
                    y: achorViewFrame.origin.y + achorViewFrame.height + 44 + self.collectionView.contentInset.top * 2,
                    width: (currentFrame?.width)!, height: (currentFrame?.height)!)

            actionRootView?.frame = newFrame

        }
    }

    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didUnrevealCardAtIndex index: Int) {
        frontShowed = true;
    }

    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willRevealCardAtIndex index: Int) {

        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? WaterMarginFrontCell {


            let array : Array = cell.name!.components(separatedBy: " ")

            self.backgroundView?.starLabel.text = array[0]
            self.backgroundView?.nameLabel.text = array[1]

            cell.cardCollectionViewLayout = self.cardCollectionViewLayout
            cell.setCardRevealed(true)

            let reverseUrl = URL(string: ImageLoader.reverseImagePaths[index])
            cell.shuihuBackImageView?.kf.setImage(with: reverseUrl)
        }
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnrevealCardAtIndex index: Int) {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? WaterMarginFrontCell {
            self.backgroundView?.alpha = 0

            cell.cardCollectionViewLayout = self.cardCollectionViewLayout
            cell.setCardRevealed(false)
        }
    }

    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, touchMove yDistance: CGFloat) {
        print("cardCollectionViewLayout touchMove : ", yDistance)

        if yDistance > 50 {
            backgroundView?.alpha = 0
            return
        }
        backgroundView?.alpha = 1.0 - (yDistance / 50.0)

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cardArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! WaterMarginFrontCell
        cell.backgroundColor = self.cardArray[indexPath.item].color

        let url = URL(string: ImageLoader.frontImagePaths[indexPath.item])
        cell.imageIcon?.kf.setImage(with: url)
        
        let reverseUrl = URL(string: ImageLoader.reverseImagePaths[indexPath.item])
        cell.shuihuBackImageView?.kf.setImage(with: reverseUrl)

        cell.item = indexPath.item

        cell.name = ImageLoader.names[indexPath.item]

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cardCollectionViewLayout?.revealCardAt(index: indexPath.item)
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempItem = self.cardArray[sourceIndexPath.item]
        self.cardArray.remove(at: sourceIndexPath.item)
        self.cardArray.insert(tempItem, at: destinationIndexPath.item)
    }
 
    // MARK: Actions
    
    @IBAction func goBackAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addCardAction() {
        let index = 0
        let newItem = createCardInfo()
        self.cardArray.insert(newItem, at: index)
        self.collectionView?.insertItems(at: [IndexPath(item: index, section: 0)])
        
        if(self.cardArray.count == 1) {
            self.cardCollectionViewLayout?.revealCardAt(index: index)
        }
    }
    
    @IBAction func deleteCardAtIndex0orSelected() {
        var index = 0
        if(self.cardCollectionViewLayout!.revealedIndex >= 0) {
            index = self.cardCollectionViewLayout!.revealedIndex
        }
        self.cardCollectionViewLayout?.flipRevealedCardBack(completion: {
            self.cardArray.remove(at: index)
            self.collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
        })
    }
    
    // MARK: Private Functions
    
    private func setupExample() {
        if let cardCollectionViewLayout = self.collectionView?.collectionViewLayout as? HFCardCollectionViewLayout {
            self.cardCollectionViewLayout = cardCollectionViewLayout
        }
        if(self.shouldSetupBackgroundView == true) {
            self.setupBackgroundView()
        }
        if let cardLayoutOptions = self.cardLayoutOptions {
            self.cardCollectionViewLayout?.firstMovableIndex = cardLayoutOptions.firstMovableIndex
            self.cardCollectionViewLayout?.cardHeadHeight = cardLayoutOptions.cardHeadHeight
            self.cardCollectionViewLayout?.cardShouldExpandHeadHeight = cardLayoutOptions.cardShouldExpandHeadHeight
            self.cardCollectionViewLayout?.cardShouldStretchAtScrollTop = cardLayoutOptions.cardShouldStretchAtScrollTop
            self.cardCollectionViewLayout?.cardMaximumHeight = cardLayoutOptions.cardMaximumHeight
            self.cardCollectionViewLayout?.bottomNumberOfStackedCards = cardLayoutOptions.bottomNumberOfStackedCards
            self.cardCollectionViewLayout?.bottomStackedCardsShouldScale = cardLayoutOptions.bottomStackedCardsShouldScale
            self.cardCollectionViewLayout?.bottomCardLookoutMargin = cardLayoutOptions.bottomCardLookoutMargin
            self.cardCollectionViewLayout?.spaceAtTopForBackgroundView = cardLayoutOptions.spaceAtTopForBackgroundView
            self.cardCollectionViewLayout?.spaceAtTopShouldSnap = cardLayoutOptions.spaceAtTopShouldSnap
            self.cardCollectionViewLayout?.spaceAtBottom = cardLayoutOptions.spaceAtBottom
            self.cardCollectionViewLayout?.scrollAreaTop = cardLayoutOptions.scrollAreaTop
            self.cardCollectionViewLayout?.scrollAreaBottom = cardLayoutOptions.scrollAreaBottom
            self.cardCollectionViewLayout?.scrollShouldSnapCardHead = cardLayoutOptions.scrollShouldSnapCardHead
            self.cardCollectionViewLayout?.scrollStopCardsAtTop = cardLayoutOptions.scrollStopCardsAtTop
            self.cardCollectionViewLayout?.bottomStackedCardsMinimumScale = cardLayoutOptions.bottomStackedCardsMinimumScale
            self.cardCollectionViewLayout?.bottomStackedCardsMaximumScale = cardLayoutOptions.bottomStackedCardsMaximumScale
            
            let count = 108//cardLayoutOptions.numberOfCards
            
            for index in 0..<count {
                self.cardArray.insert(createCardInfo(), at: index)
            }
        } else {

            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isToolbarHidden = true
            self.shouldSetupBackgroundView = true

            let count = 108//cardLayoutOptions.numberOfCards
            
            for index in 0..<count {
                self.cardArray.insert(createCardInfo(), at: index)
            }
        }
        self.collectionView?.reloadData()
    }
    
    private func createCardInfo() -> CardInfo {
        let newItem = CardInfo(color: self.getRandomColor())
        return newItem
    }
    
    private func setupBackgroundView() {
        if(self.cardLayoutOptions?.spaceAtTopForBackgroundView == 0) {
            self.cardLayoutOptions?.spaceAtTopForBackgroundView = 44 // Height of the NavigationBar in the BackgroundView
        }
        if let collectionView = self.collectionView {
            collectionView.backgroundView = self.backgroundView
            self.backgroundNavigationBar?.shadowImage = UIImage()
            self.backgroundNavigationBar?.setBackgroundImage(UIImage(), for: .default)
        }
    }
    
    private func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

