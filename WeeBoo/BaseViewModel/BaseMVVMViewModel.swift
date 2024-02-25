//
//  BaseMVVMViewModel.swift
//  WeeBoo
//
//  Created by Cường Trần on 25/02/2024.
//

import Foundation
import RxSwift
import RxRelay

protocol BaseMVVMViewModel: AnyObject {
    associatedtype State
    associatedtype Action
    associatedtype Mutation
    
    var state       : BehaviorRelay<State>      { get }
    var action      : PublishRelay<Action>      { get }
    var mutation    : PublishRelay<Mutation>   { get }
    
    func mutate(action: Action, with state: State)
    
    func reduce(previousState: State, mutation: Mutation) -> State?
}

extension BaseMVVMViewModel {
    func setupFlow(disposeBag: DisposeBag) {
        action
            .withLatestFrom(state, resultSelector: { (action, state) -> (Action, State) in
                return (action, state)
            })
            .subscribe(onNext: { [weak self] (action, state) in
                self?.mutate(action: action, with: state)
            })
            .disposed(by: disposeBag)
        
        mutation
            .withLatestFrom(state, resultSelector: { (mutation, state) -> (Mutation, State) in
                return (mutation, state)
            })
            .compactMap { [weak self] (mutation, state) in
                self?.reduce(previousState: state, mutation: mutation)
            }
            .bind(to: state)
            .disposed(by: disposeBag)
    }
}
