//
//  TableAndWebMixViewController.swift
//  WebTest
//
//  Created by xuyunshi on 2019/7/8.
//  Copyright © 2019年 mac. All rights reserved.
//  Table 和 WebView混合视图

import UIKit
import WebKit

open class TableAndWebMixViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Public Propertys
    
    // content height
    
    public var tableViewContentHeight: CGFloat = 0
    public var webContentHeight: CGFloat = 0
    
    // frame height (related to tableview content)
    public private(set) var currentTableViewHeight: CGFloat = 0
    
    // MARK: - Private Propertys
    
    // max value - equal to main view
    private var tableviewMaxHeight: CGFloat
    
    // webViewHeight is equal to main view
    private var webViewHeight: CGFloat
    
    // MARK: - Public Function
    
    /// call it when table or web content changed to keep UI fluent
    public func setAllScrollComponentsOffsetToZero() {
        scrollView.setContentOffset(.zero, animated: false)
        tableView.setContentOffset(.zero, animated: false)
        webView.scrollView.setContentOffset(.zero, animated: false)
    }
    
    // MARK: - Life Cycle
    
    deinit {
        
        removeObserver()
    }
    
    public init() {
        self.tableviewMaxHeight = 0
        self.webViewHeight = 0
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.tableviewMaxHeight = 0
        self.webViewHeight = 0
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupObserver()
        loadDefaultData()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initializeComponentsFrame()
    }
    
    // MARK: - KVO
    
    private func setupObserver() {
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "scrollView.contentSize", options: .new, context: nil)
    }
    
    private func removeObserver() {
        
        tableView.removeObserver(self, forKeyPath: "contentSize")
        webView.removeObserver(self, forKeyPath: "scrollView.contentSize")
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let path = keyPath {
            
            if path == "contentSize" {
                
                if let newOffset = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    
                    guard newOffset.height != tableViewContentHeight else { return }
                    tableViewContentHeight = newOffset.height
                    syncContentSize(from: tableView)
                }
            } else if path == "scrollView.contentSize" {
                if let newOffset = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    
                    guard newOffset.height != webContentHeight else { return }
                    webContentHeight = newOffset.height
                    syncContentSize(from: webView)
                }
            } else {
                
                return
            }
        }
    }
    
    // MARK: - UI Sync
    
    // update the distance between scrollView and contentView in vision.
    // not in commonly known as frame.
    private func updateContentTop(_ top: CGFloat) {
        
        let scrollY = scrollView.contentOffset.y
        
        var new = contentView.frame
        new.origin.y = top + scrollY
        
        self.contentView.frame = new
    }
    
    // initialize the frame about scrollView, contentView, TableView, WebView
    private func initializeComponentsFrame() {
        
        let width = view.bounds.width
        tableviewMaxHeight = view.bounds.size.height
        webViewHeight = view.bounds.size.height
        scrollView.frame = view.bounds
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: tableviewMaxHeight)
        webView.frame = CGRect(x: 0, y: tableviewMaxHeight, width: width, height: webViewHeight)
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: tableviewMaxHeight + webViewHeight)
        
        currentTableViewHeight = tableviewMaxHeight
        
        adjustTableViewFrameIfNeed()
    }
    
    // call it when scroll view contentSize modified.
    // it will adjust tableview frame if need.
    fileprivate func adjustTableViewFrameIfNeed() {
        
        func adjuctWithTableViewHeight(_ height: CGFloat) {
            
            let lastTableViewFrame = tableView.frame
            tableView.frame = CGRect(x: 0, y: 0, width: lastTableViewFrame.size.width, height: height)
            currentTableViewHeight = height
            
            let lastWebViewFrame = webView.frame
            webView.frame = CGRect(x: 0, y: tableView.frame.maxY, width: lastWebViewFrame.size.width, height: lastWebViewFrame.size.height)
            
            contentView.frame = CGRect(x: 0, y: 0, width: lastTableViewFrame.size.width, height: webView.frame.maxY)
        }
        
        guard currentTableViewHeight <= tableviewMaxHeight else {
            
            adjuctWithTableViewHeight(tableviewMaxHeight)
            return
        }
        
        if currentTableViewHeight > tableViewContentHeight {
            
            guard tableViewContentHeight != currentTableViewHeight else { return }
            adjuctWithTableViewHeight(tableViewContentHeight)
        } else if currentTableViewHeight == tableViewContentHeight {
            
            return
        } else {
            
            let target = min(tableviewMaxHeight, tableViewContentHeight)
            guard target != currentTableViewHeight else { return }
            adjuctWithTableViewHeight(target)
        }
    }
    
    // MARK: - Mock Data
    
    private func loadDefaultData() {
        webView.load(URLRequest(url: URL(string: "https://github.com/xuyunshi")!))
    }
    
    // MARK: - Private
    
    private func setupSubviews() {
        
        contentView.addSubview(webView)
        contentView.addSubview(tableView)
        
        scrollView.addSubview(contentView)
        
        view.addSubview(scrollView)
    }
    
    // call when tableView or webView contentSize modified.
    // sync scrollView ContentSize to their's add up.
    private func syncContentSize(from: UIView) {
        
        let width = view.bounds.size.width
        let height = tableViewContentHeight + webContentHeight
        
        let size = CGSize(width: width, height: height)
        let lastSize = scrollView.contentSize
        
        guard size != lastSize else { return }
        
        scrollView.contentSize = size
        
        if from is UITableView {
            
            adjustTableViewFrameIfNeed()
        }
        
        #if DEBUG
        print("scrollView ContentSize updated: table height = \(tableViewContentHeight), webHeight = \(webContentHeight), contentSize = \(height)")
        #endif
    }
    
    // MARK: - Lazy var
    
    lazy var contentView: UIView = {
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .gray
        return view
    }()
    
    open lazy var webView: WKWebView = {
        
        let controller = WKUserContentController()
        let view = WKWebView(frame: .zero)
        view.scrollView.isScrollEnabled = false
        return view
    }()
    
    /// do not change it contentInsetAdjustmentBehavior
    /// or it will become out of control when web is too small.
    open lazy var scrollView: UIScrollView = {
        
        let view = UIScrollView(frame: .zero)
        view.delegate = self
        return view
    }()
    
    open lazy var tableView: UITableView = {
        
        let view = UITableView(frame: .zero)
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "a")
        view.isScrollEnabled = false
        return view
    }()
    
    // MARK: - UITableViewDatasource & UITableviewDelegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "a") as? UITableViewCell
        cell?.textLabel?.text = "test" + indexPath.row.description
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you did click at \(indexPath)")
    }
}

extension TableAndWebMixViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        
        print("scrollView offset: " + y.description)
        
        if y <= 0 {
            
            // rest the state
            staickContentToScrollTop()
            tableView.setContentOffset(.zero, animated: false)
            webView.scrollView.setContentOffset(.zero, animated: false)
            
            #if DEBUG
            print("part 1")
            #endif
            
            return
        } else if y >= 0, y <= tableViewContentHeight - currentTableViewHeight {
            
            // scroll table only
            tableView.setContentOffset(CGPoint(x: 0, y: y), animated: false)
            updateContentTop(0)
            
            #if DEBUG
            print("part 2")
            #endif
            return
        } else if y <= tableViewContentHeight {
            
            // maybe the last operation was ignored, complete it.
            // then do nothing
            if tableView.contentOffset.y != (tableViewContentHeight - currentTableViewHeight) {
                tableView.setContentOffset(CGPoint(x: 0, y: (tableViewContentHeight - currentTableViewHeight)), animated: false)
            }
            
            #if DEBUG
            print("part 3")
            #endif
            return
        } else if webContentHeight > webViewHeight {
            
            if y <= tableViewContentHeight + webContentHeight - webViewHeight {
                
                // if the scroll is too fast, maybe the last operation ignored, complete it.
                updateContentTop(-currentTableViewHeight)
                // scroll the webView
                webView.scrollView.setContentOffset(CGPoint(x: 0, y: y - tableViewContentHeight), animated: false)
                
                #if DEBUG
                print("part 4")
                #endif
                return
            } else if y <= tableViewContentHeight + webContentHeight {
                
                // if the scroll is too fast, maybe the last operation ignored, complete it.
                stickContentToScrollViewBottom()
                if webView.scrollView.contentOffset.y != (webContentHeight - webViewHeight) {
                    webView.scrollView.setContentOffset(CGPoint(x: 0, y: (webContentHeight - webViewHeight)), animated: false)
                }
                
                #if DEBUG
                print("part 5")
                #endif
                return
            } else {
                return
            }
            
        } else {
            
            // when offset is bigger than content, do nothing.
            #if DEBUG
            print("part 6")
            #endif
            return
        }
    }
    
    // MARK: - Rest for too fast
    
    fileprivate func staickContentToScrollTop() {
        
        var frame = contentView.frame
        frame.origin.y = 0
        contentView.frame = frame
    }
    
    fileprivate func stickContentToScrollViewBottom() {
        
        var frame = contentView.frame
        frame.origin.y = scrollView.contentSize.height - contentView.frame.height
        contentView.frame = frame
    }
}
