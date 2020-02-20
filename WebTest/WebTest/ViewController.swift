//
//  ViewController.swift
//  WebTest
//
//  Created by xuyunshi on 2019/7/4.
//  Copyright © 2019年 mingdu. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class ViewController: TableAndWebMixViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isAutoSizeCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "main") as? SelfSizeTableViewCell
            let height = CGFloat(arc4random() % 100)
            cell?.height = height
            return cell!
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    var isAutoSizeCell = false
    
    var itemCount: Int = 10 {
        didSet {
            setAllScrollComponentsOffsetToZero()
            isAutoSizeCell  = false
            tableView.reloadData()
        }
    }
    
    var url: URL = URL(string: "https://merchant-api-f.netmi.com.cn/item/item-info/info?id=1414")! {
        didSet {
            setAllScrollComponentsOffsetToZero()
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item = UIBarButtonItem(title: "切换Web", style: .done, target: self, action: #selector(onClickTransContent))
        navigationItem.rightBarButtonItem = item
        
        let left = UIBarButtonItem(title: "切换TableItem", style: .done, target: self, action: #selector(onClickChangeTable))
        navigationItem.leftBarButtonItem = left
        
        tableView.register(SelfSizeTableViewCell.self, forCellReuseIdentifier: "main")
    }
    
    @objc func onClickChangeTable() {
        
        let vc = self
        
        let alert = UIAlertController(title: "切换ItemCount", message: nil, preferredStyle: .actionSheet)
        
        let action0 = UIAlertAction(title: "10", style: .default) { (_) in
            
            vc.itemCount = 10
        }
        
        let action1 = UIAlertAction(title: "50", style: .default) { (_) in
            
            vc.itemCount = 50
        }
        
        let action2 = UIAlertAction(title: "50个selfSize", style: .default) { (_) in
            
            vc.itemCount = 50
            vc.isAutoSizeCell = true
        }
        
        alert.addAction(action0)
        alert.addAction(action1)
        alert.addAction(action2)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func onClickTransContent() {
        
        let vc = self
        
        let alert = UIAlertController(title: "切换模式", message: nil, preferredStyle: .actionSheet)
        
        let action0 = UIAlertAction(title: "特大", style: .default) { (_) in
            
            vc.url = URL(string: "https://www.baidu.com")!
        }
        
        let action1 = UIAlertAction(title: "小", style: .default) { (_) in
            
            vc.url = URL(string: "https://merchant-api-f.netmi.com.cn/item/item-info/info?id=1622")!
        }
        
        let action2 = UIAlertAction(title: "web无", style: .default) { (_) in
            
            vc.webView.loadHTMLString("", baseURL: nil)
        }
        
        let action3 = UIAlertAction(title: "少量html", style: .default) { (_) in
            
            vc.webView.loadHTMLString("dfgkjdfkgjkdfjgkldfgjdfgdfgdfg", baseURL: nil)
        }
        
        alert.addAction(action0)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        present(alert, animated: true, completion: nil)
    }

}
