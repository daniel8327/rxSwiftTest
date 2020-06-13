//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
    // MARK: - Life Cycle
    
    let viewModel  = MenuListViewModel()
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.dataSource = nil
        
        viewModel.menuObservable // viewModel 의 menuObservable 값이 바뀌면 수행됨
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "MenuItemTableViewCell", cellType: MenuItemTableViewCell.self)) { index, item, cell in
                
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                
                cell.onChange = { [weak self] data in
                    self?.viewModel.changeCount(item: item, data: data)
                    
                }
        }.disposed(by: disposeBag)
        
        viewModel.itemsCount
            .map { "\($0)"}
            .catchErrorJustReturn("")
            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: {
//                self.itemCountLabel.text = $0
//            })
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.totalPrice
            .map { $0.currencyKR() }
//            .catchErrorJustReturn("")
//            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: "")
            .drive(totalPrice.rx.text)
            //.observeOn(MainScheduler.instance)
//            .subscribe(onNext: {
//                self.totalPrice.text = $0
//            })
            //.bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)
        
        /** 정리
                .subscribe(onNext: { 어딘가에 .text = $0 }) -> .bind(to: 어딘가에.rx.text) 로 간략화 될 수 있고
                .bind 는 무조건 main thread 에서 돌아야 하기 때문에 .observeOn(MainScheduler.instance) 을 달아줘야 안전하다
                그리고 에러를 방지하기 위해 .catchErrorJustReturn("") 을 설정해줘야하는데
                .observeOn(MainScheduler.instance)  와 .catchErrorJustReturn("")  을 합친것이  .asDriver(onErrorJustReturn: "") 이다.
                게다가 .bind(to: 어딘가에.rx.text) 를 묶어서 .drive(어딘가에.rx.text)  로 사용한다.
            결론
                UI 는 망가져선 안되고 main thread 에서 돌아야 하고 ui에 값을 맵핑해주기 위해
                .asDriver(onErrorJustReturn: "")
                .drive(어딘가에.rx.text)                두개를 동시에 사용하는 습관을 들이자
         */
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let identifier = segue.identifier ?? ""
//        if identifier == "OrderViewController",
//            let orderVC = segue.destination as? OrderViewController {
//            // TODO: pass selected menus
//        }
//    }
//
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
        viewModel.clearAllItemSelections()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
        //performSegue(withIdentifier: "OrderViewController", sender: nil)
        //viewModel.totalPrice.onNext(100)
        //viewModel.itemsCount += 10
        
        viewModel.onOrder()
    }
}
