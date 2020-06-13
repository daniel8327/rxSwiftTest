//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 장태현 on 2020/06/13.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {
    
    var menuObservable = BehaviorRelay<[Menu]>(value: []) // 외부에서 Menu Array를 받으면 그때마다 Observable이 등장한다.
    
    lazy var itemsCount = menuObservable.map { // menuObservable 이 바뀔때마다 아이템 갯수가 구해진다.
        $0.filter { $0.count > 0}.map {$0.count }.reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable.map { // menuObservable 이 바뀔때마다 총가격이 구해진다.
        $0.filter { $0.count > 0}.map {$0.price * $0.count }.reduce(0, +)
    }
    
    init() {
// 가 데이터
//        let menus: [Menu] = [
//            Menu(id: 0, name: "야채튀김", price: 1000, count: 0),
//            Menu(id: 1, name: "감자튀김", price: 3000, count: 0),
//            Menu(id: 2, name: "고구마튀김", price: 1000, count: 0),
//            Menu(id: 3, name: "군만두", price: 500, count: 0),
//            Menu(id: 4, name: "김말이", price: 500, count: 0)]
        // API 데이터
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
            }
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { index, item in
                    menus.append(Menu.fromMenuItems(id: 0, item: item))
                }
                return menus 
                
            }
            .take(1)
            .bind(to: menuObservable)
    
    }
    
    func changeCount(item: Menu, data: Int) {
        _ = menuObservable
            .map{ menus in
            
                menus.map {m in
                    if m.id == item.id {

                        
                        return Menu(id: m.id,
                                    name: m.name,
                                    price: m.price,
                                    count: max(m.count + data, 0))
                    } else {
    
                        return Menu(id: m.id,
                                    name: m.name,
                                    price: m.price,
                                    count: m.count)
                    }
                }
        }
        .take(1)
        .subscribe(onNext: {
            self.menuObservable.accept($0)
        })
    }
    
    func clearAllItemSelections() {
        _ = menuObservable
            .map{ menus in
                
                menus.map {m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
    
    func onOrder() {
        
    }
}
