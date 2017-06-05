//
//  ZComboBox.swift
//  ZComboBox
//
//  Created by haipv on 4/18/17.
//  Copyright © 2017 haipv. All rights reserved.
//

import UIKit

class ZComboBox : UITextField, UITextFieldDelegate {
    static let kPopupStypeWithIndicator = 0
    static let kPopupStypeWithoutIndicator = 1
    private var menuItems:[String] = []
    private var popupView = ComboBoxPopupView(menuItems: [])
    private var _selectedItem: Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView()
    {
        self.delegate = self
        self.popupView.textFont = self.font
        self.popupView.refernceView = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.orientationChanged(notification:)),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil
        )
    }
    
    func orientationChanged(notification: Notification) {
        // handle rotation here
        self.popupView.showPopupMenu()
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.popupView.showPopupMenu()
        UIApplication.shared.keyWindow?.addSubview(self.popupView)
        return false
    }
    
    public var items: [String] {
        set(newValue) {
            menuItems.removeAll()
            menuItems = newValue
            self.popupView.items = newValue
            
        }
        get {
            return menuItems
        }
    }
    
    public var popupStyle: Int {
        set(newValue) {
            self.popupView.popupStyle = newValue
            
        }
        get {
            return self.popupView.popupStyle
        }
    }
    
    public var selectedItem: Int {
        set(newValue) {
            self._selectedItem = newValue
            
        }
        get {
            return self._selectedItem
        }
    }
    
    
    internal class ComboBoxPopupView: UIView, UITableViewDataSource, UITableViewDelegate {
        private let kItemHeight:CGFloat = 50.0
        private let kItemFontSize:CGFloat = 16.0
        private let kPadding:CGFloat = 10
        private var _indicatorPosition: CGPoint?
        private var triangleView: TriangleView?
        private var menuTableView: UITableView?
        private var contentView:UIView?
        private var menuItems = [String]()
        public var popupStyle = kPopupStypeWithIndicator
        var textFont: UIFont?
        var didSelectItem: ((_ index: Int) -> ())?
        var refernceView:ZComboBox? = nil
        
        internal class TriangleView: UIView {
            static let kPopupPositionTop = 0
            static let kPopupPositionBottom: Int = 1
            let drawBackgroundColor = UIColor.white
            var direction: Int = kPopupPositionBottom
            
            
            override func draw(_ rect: CGRect) {
                // Drawing code
                super.draw(rect)
                if (direction == TriangleView.kPopupPositionBottom) {
                    drawBackgroundColor.setFill()
                    let indicatorPath = UIBezierPath()
                    indicatorPath.move(to: CGPoint(x: 5, y: 0))
                    indicatorPath.addLine(to: CGPoint(x: 0, y: 5))
                    indicatorPath.addLine(to: CGPoint(x: 10, y: 5))
                    indicatorPath.close()
                    indicatorPath.fill()
                } else {
                    drawBackgroundColor.setFill()
                    let indicatorPath = UIBezierPath()
                    indicatorPath.move(to: CGPoint(x: 0, y: 0))
                    indicatorPath.addLine(to: CGPoint(x: 10, y: 0))
                    indicatorPath.addLine(to: CGPoint(x: 5, y: 5))
                    indicatorPath.close()
                    indicatorPath.fill()
                }
                
            }
        }
        
        init(menuItems: [String]?) {
            let size = UIScreen.main.bounds.size
            super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            if let menus = menuItems {
                self.menuItems.append(contentsOf: menus)
            }
            
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.triangleView = TriangleView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
            self.triangleView?.backgroundColor = UIColor.clear
            self.addSubview(self.triangleView!)
            
            let portraitScreenWidht = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
            self.contentView = UIView(frame: CGRect(x: kPadding, y: 5, width: portraitScreenWidht - CGFloat(2) * kPadding, height: 1 * kItemHeight))
            self.contentView?.backgroundColor = UIColor.white
            self.contentView?.clipsToBounds = true
            self.contentView?.layer.cornerRadius = 5.0
            
            self.menuTableView = UITableView(frame: CGRect(x: kPadding, y: 0, width: (self.contentView?.frame.size.width)! - CGFloat(2) * kPadding, height: 1 * kItemHeight))
            self.menuTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            self.menuTableView?.backgroundColor = UIColor.clear
            self.menuTableView?.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self.menuTableView?.dataSource = self
            self.menuTableView?.delegate = self
            self.menuTableView?.reloadData()
            self.menuTableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.contentView?.addSubview(self.menuTableView!)
            self.addSubview(self.contentView!)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        func showPopupMenu() {
            let comboBoxPos = self.refernceView?.superview?.convert((self.refernceView?.frame.origin)!, to: nil)
            let xComboBoxPos = (comboBoxPos?.x)! + (self.refernceView?.frame.width)! - 5.0
            let yComboBoxPos = (comboBoxPos?.y)!
            
            let screenWidth: CGFloat = UIScreen.main.bounds.size.width
            let screenHeight: CGFloat = UIScreen.main.bounds.size.height
            
            self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            UIView.animate(withDuration: 0.1, animations: {
                if (self.popupStyle == kPopupStypeWithIndicator) {
                    let bottomComboxY = yComboBoxPos + (self.refernceView?.frame.size.height)!
                    
                    var popupDirection = TriangleView.kPopupPositionBottom
                    if (bottomComboxY - screenHeight / CGFloat(2)) >= (CGFloat(2.0) * self.kItemHeight) {
                        popupDirection = TriangleView.kPopupPositionTop
                    }
                    
                    self.triangleView?.direction = popupDirection
                    self.triangleView?.setNeedsDisplay()
                    if (popupDirection == TriangleView.kPopupPositionBottom) {
                        let pos = CGPoint(x: xComboBoxPos, y: bottomComboxY)
                        
                        //Set triangle view position
                        self.triangleView?.isHidden = false
                        let triangleViewPosition = CGPoint(x: pos.x - 5, y: pos.y)
                        let triangleViewSize = CGSize(width: 10, height: 5)
                        
                        self.triangleView?.frame = CGRect(origin: triangleViewPosition, size: triangleViewSize)
                        
                        
                        //Set content view position
                        let maxMenuSize = screenHeight - pos.y - CGFloat(1.5) * self.kItemHeight
                        let contentViewHeight = min(self.kItemHeight * CGFloat(self.items.count), maxMenuSize)
                        var contentViewPos = CGPoint(x: self.kPadding, y: pos.y + 5);
                        let contentViewSize = CGSize(width: (self.contentView?.frame.size.width)!, height: contentViewHeight)
                        if ((pos.x + 15) >=  (contentViewSize.width + 5)) {
                            contentViewPos = CGPoint(x: pos.x - contentViewSize.width + 15, y:  pos.y + 5)
                        }
                        
                        
                        let menuTableViewPos = self.menuTableView?.frame.origin
                        let menuTableViewSize = CGSize(width: (self.menuTableView?.frame.size.width)!, height: contentViewHeight)
                        self.menuTableView?.frame = CGRect(origin: menuTableViewPos!, size: menuTableViewSize)
                        
                        //update content view height
                        self.contentView?.frame = CGRect(origin: contentViewPos, size: contentViewSize)
                    } else {
                        let pos = CGPoint(x: xComboBoxPos, y: yComboBoxPos)
                        
                        //Set triangle view position
                        self.triangleView?.isHidden = false
                        let triangleViewPosition = CGPoint(x: pos.x - 5, y: pos.y - 5)
                        let triangleViewSize = CGSize(width: 10, height: 5)
                        self.triangleView?.frame = CGRect(origin: triangleViewPosition, size: triangleViewSize)
                        
                        
                        //Set content view position
                        let maxMenuSize = pos.y - CGFloat(1.5) * self.kItemHeight
                        let contentViewHeight = min(self.kItemHeight * CGFloat(self.items.count), maxMenuSize)
                        var contentViewPos = CGPoint(x: self.kPadding, y: pos.y - 5 - contentViewHeight);
                        let contentViewSize = CGSize(width: (self.contentView?.frame.size.width)!, height: contentViewHeight)
                        if ((pos.x + 15) >=  (contentViewSize.width + 5)) {
                            contentViewPos = CGPoint(x: pos.x - contentViewSize.width + 15, y:  pos.y + 5)
                        }
                        
                        
                        let menuTableViewPos = self.menuTableView?.frame.origin
                        let menuTableViewSize = CGSize(width: (self.menuTableView?.frame.size.width)!, height: contentViewHeight)
                        self.menuTableView?.frame = CGRect(origin: menuTableViewPos!, size: menuTableViewSize)
                        
                        //update content view height
                        self.contentView?.frame = CGRect(origin: contentViewPos, size: contentViewSize)
                    }
                    
                } else if (self.popupStyle == kPopupStypeWithoutIndicator) {
                    self.triangleView?.isHidden = true
                    let maxMenuSize = screenHeight - CGFloat(4) * self.kItemHeight
                    let contentViewHeight = min(self.kItemHeight * CGFloat(self.items.count), maxMenuSize)
                    let contentViewSize = CGSize(width: (self.contentView?.frame.size.width)!, height: contentViewHeight)
                    
                    
                    let menuTableViewPos = self.menuTableView?.frame.origin
                    let menuTableViewSize = CGSize(width: (self.menuTableView?.frame.size.width)!, height: contentViewSize.height)
                    self.menuTableView?.frame = CGRect(origin: menuTableViewPos!, size: menuTableViewSize)
                    
                    
                    let contentViewPos = CGPoint(x: (screenWidth - contentViewSize.width) / CGFloat(2), y: (screenHeight - contentViewHeight) / CGFloat(2));
                    self.contentView?.frame = CGRect(origin: contentViewPos, size: contentViewSize)
                }
                self.menuTableView?.reloadData()
                
            })
        }
        
        var indicatorPosition: CGPoint? {
            set (newValue) {
                if let pos = newValue {
                    _indicatorPosition = pos
                    
                    let screenWidth: CGFloat = UIScreen.main.bounds.size.width
                    let screenHeight: CGFloat = UIScreen.main.bounds.size.height
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        if (self.popupStyle == kPopupStypeWithIndicator) {
                            //Set triangle view position
                            self.triangleView?.isHidden = false
                            let triangleViewPosition = CGPoint(x: pos.x - 5, y: pos.y)
                            let triangleViewSize = CGSize(width: 10, height: 5)
                            self.triangleView?.frame = CGRect(origin: triangleViewPosition, size: triangleViewSize)
                            
                            
                            //Set content view position
                            var numberOfVisibleRow: Int = 3
                            var contentViewPos = CGPoint(x: 5, y: pos.y + 5);
                            let contentViewSize = CGSize(width: (self.contentView?.frame.size.width)!, height: self.kItemHeight * CGFloat(numberOfVisibleRow))
                            if ((pos.x + 15) >=  (contentViewSize.width + 5)) {
                                contentViewPos = CGPoint(x: pos.x - contentViewSize.width + 15, y:  pos.y + 5)
                            }
                            
            
                            let menuTableViewPos = self.menuTableView?.frame.origin
                            let menuTableViewSize = CGSize(width: (self.menuTableView?.frame.size.width)!, height: self.kItemHeight * CGFloat(numberOfVisibleRow))
                            self.menuTableView?.frame = CGRect(origin: menuTableViewPos!, size: menuTableViewSize)
                            
                            //update content view height
                            self.contentView?.frame = CGRect(origin: contentViewPos, size: contentViewSize)
                            
                        } else if (self.popupStyle == kPopupStypeWithoutIndicator) {
                            self.triangleView?.isHidden = true
                            let maxMenuSize = screenHeight - CGFloat(4) * self.kItemHeight
                            let contentViewHeight = min(self.kItemHeight * CGFloat(self.items.count), maxMenuSize)
                            let contentViewSize = CGSize(width: (self.contentView?.frame.size.width)!, height: contentViewHeight)
                            
                            
                            let menuTableViewPos = self.menuTableView?.frame.origin
                            let menuTableViewSize = CGSize(width: (self.menuTableView?.frame.size.width)!, height: contentViewSize.height)
                            self.menuTableView?.frame = CGRect(origin: menuTableViewPos!, size: menuTableViewSize)
                            
                            
                            let contentViewPos = CGPoint(x: (screenWidth - contentViewSize.width) / CGFloat(2), y: (screenHeight - contentViewHeight) / CGFloat(2));
                            self.contentView?.frame = CGRect(origin: contentViewPos, size: contentViewSize)
                        }
                        self.menuTableView?.reloadData()
                        
                    })
                    
                    
                }
                
            }
            get {
                return _indicatorPosition
            }
        }
        
        var indicatorOffset = CGSize.zero
        
        
        func reload() {
            self.menuTableView?.reloadData()
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.removeFromSuperview()
        }
        
        public var items: [String] {
            set(newValue) {
                menuItems.removeAll()
                menuItems.append(contentsOf: newValue)
                self.menuTableView?.reloadData()
            }
            get {
                return menuItems
            }
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.items.count
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 0
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            return kItemHeight
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                if self.textFont != nil {
                    cell?.textLabel?.font? = self.textFont!
                } else {
                    cell?.textLabel?.font? = UIFont.systemFont(ofSize: kItemFontSize)
                }
                
                cell?.textLabel?.textColor = UIColor.black
                                cell?.selectionStyle = .none
            }
            cell?.textLabel?.text = self.items[indexPath.item]
            if (self.refernceView?.selectedItem == indexPath.item) {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else
            {
                cell?.accessoryType = UITableViewCellAccessoryType.none
            }

            return cell!
        }
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let callback = didSelectItem {
                callback(indexPath.item)
            }
            self.refernceView?.text = self.items[indexPath.item]
            self.refernceView?.selectedItem = indexPath.item
            self.removeFromSuperview()
        }
    }
    
    
}
