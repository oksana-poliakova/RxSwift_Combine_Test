//
//  ViewController.swift
//  RxSwift_Test
//
//  Created by Oksana Poliakova on 30.05.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Combine

struct Event {
    let title: String?
}

class ViewController: UIViewController {
    
    // MARK: - Properties for RxSwift
    
    @IBOutlet weak var namesListLabel: UILabel!
    
    /// It's a wrapper with a default name
    var names = BehaviorRelay(value: ["Oksana"])
    
    /// It's a bag of disposables for memory management (like ARC in Swift)
    let bag = DisposeBag()
    
    // MARK: - Properties for Combine
    
    @IBOutlet weak var changeSwitchButton: UIButton!
    @IBOutlet weak var changeSwitch: UISwitch!
    
    @Published var isAllowed: Bool = false
    /// For memory management
    private var subscriber: AnyCancellable?
    
    @IBAction func changeSwitchTapped(_ sender: UISwitch) {
        isAllowed = sender.isOn
    }
    
    // MARK: - View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addingNames()
        printEvent()
        switchButton()
    
    }
    
    // MARK: - RxSwift
    // MARK: - Function for adding names to the list
    
    private func addingNames() {
        names.asObservable()
            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .filter({ value in
                value.count > 1
            }).map({ value in
                value.joined(separator: ", ")
            }).debug()
            .subscribe(onNext: { [weak self] value in
                self?.namesListLabel.text = value
            }).disposed(by: bag)
        
        names.accept(["Alex", "Maria", "Mira"])
      
    }
    
    // MARK: - Combine
    
    private func printEvent() {
        let newEventPublisher = NotificationCenter.Publisher(center: .default, name: .newEvent).map({ notification -> String? in
            (notification.object as? Event)?.title ?? ""
        })
        
        let newEventLabel = UILabel()
        let newEventSubscriber = Subscribers.Assign(object: newEventLabel, keyPath: \.text)
        newEventPublisher.subscribe(newEventSubscriber)
        
        let event = Event(title: "New event title")
        
        NotificationCenter.default.post(name: .newEvent, object: event)
        
        print(String(describing: newEventLabel.text))
        
    }
    
    private func switchButton() {
        subscriber = $isAllowed.receive(on: DispatchQueue.main).assign(to: \.isEnabled, on: changeSwitchButton)
    }
}

// MARK: - Extensions

extension Notification.Name {
    static let newEvent = Notification.Name("new_event")
}

