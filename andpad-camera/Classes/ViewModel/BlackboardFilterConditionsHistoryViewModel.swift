//
//  BlackboardFilterConditionsHistoryViewModel.swift
//  andpad-camera
//
//  Created by msano on 2022/01/17.
//

import RxCocoa
import RxSwift

final class BlackboardFilterConditionsHistoryViewModel {
    typealias DataSource = BlackboardFilterConditionsHistoryDataSource
    typealias SearchQuery = ModernBlackboardSearchQuery
    typealias History = BlackboardFilterConditionsHistory
    
    // MARK: - define Inputs, Outputs
    enum Input {
        case viewDidLoad
        case didTapCell(DataSource.Section.Item)
        case didTapDeleteButton(History)
        case didTapAcceptButtonInErrorAlert
    }

    enum Output {
        case dismiss(ModernBlackboardSearchQuery)
        case showLoadingView
        case hideLoadingView
        case changeEmptyViewState(isHidden: Bool)
        case showSimpleErrorAlert(title: String?, message: String)
        case showErrorAlert(title: String?, message: String)
    }
    
    // MARK: - StaticState
    private struct StaticState {
        let orderID: Int
        let title: String = L10n.Blackboard.History.title
    }
    
    let inputPort: PublishRelay<Input> = .init()
    let outputPort: ControlEvent<Output>
    let dataSource = DataSource()
    let items = BehaviorRelay<[DataSource.Section]>(value: [])
    
    private let staticState: StaticState
    private let disposeBag = DisposeBag()
    private let outputRelay: PublishRelay<Output>
    
    private let blackboardHistoryHandler: BlackboardHistoryHandlerProtocol
    
    init?(
        orderID: Int,
        advancedOptions: [ModernBlackboardConfiguration.AdvancedOption] /// 必要なオプションを含んでいない場合、イニシャライズ失敗となる
    ) {
        let relay = PublishRelay<Output>()
        self.outputPort = .init(events: relay)
        self.outputRelay = relay
        self.staticState = .init(orderID: orderID)
        
        // blackboardHistoryHandlerのセット
        var useHistoryViewConfigureArguments: ModernBlackboardConfiguration.UseHistoryViewConfigureArguments?
        optionsLoop: for advancedOption in advancedOptions {
            switch advancedOption {
            case .useHistoryView(let args):
                useHistoryViewConfigureArguments = args
                break optionsLoop
            case .useMiniatureMap:
                break
            }
        }
        guard let useHistoryViewConfigureArguments else { return nil }
        self.blackboardHistoryHandler = useHistoryViewConfigureArguments.blackboardHistoryHandler
        
        inputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .viewDidLoad:
                    self?.viewDidLoadEvent()
                case .didTapCell(let item):
                    self?.didTapCellEvent(item)
                case .didTapDeleteButton(let history):
                    self?.didTapDeleteButtonEvent(history)
                case .didTapAcceptButtonInErrorAlert:
                    self?.didTapAcceptButtonInErrorAlertEvent()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - variable (included private static state)
extension BlackboardFilterConditionsHistoryViewModel {
    var title: String {
        staticState.title
    }
}

// MARK: - event
extension BlackboardFilterConditionsHistoryViewModel {
    private func viewDidLoadEvent() {
        outputRelay.accept(.showLoadingView)
        blackboardHistoryHandler.getHistories(orderID: staticState.orderID)
            .do(onDispose: { [weak self] in self?.outputRelay.accept(.hideLoadingView) })
            .subscribe(
                onSuccess: { [weak self] in self?.set(histories: $0) },
                onFailure: { [weak self] in self?.catchError($0) }
            )
            .disposed(by: disposeBag)
    }
    
    private func didTapCellEvent(_ history: BlackboardFilterConditionsHistory?) {
        guard let history else { fatalError() }
        outputRelay.accept(.showLoadingView)
        blackboardHistoryHandler.save(latestHistory: history, orderID: staticState.orderID)
        blackboardHistoryHandler.save(history: history)
            .do(onDispose: { [weak self] in self?.outputRelay.accept(.hideLoadingView) })
            .subscribe(
                onCompleted: { [weak self] in self?.outputRelay.accept(.dismiss(history.query)) },
                onError: { [weak self] in self?.catchError($0) }
            )
            .disposed(by: disposeBag)
    }
    
    private func didTapDeleteButtonEvent(_ history: BlackboardFilterConditionsHistory) {
        outputRelay.accept(.showLoadingView)
        blackboardHistoryHandler.delete(history: history)
            .andThen(blackboardHistoryHandler.getHistories(orderID: staticState.orderID))
            .do(onDispose: { [weak self] in self?.outputRelay.accept(.hideLoadingView) })
            .subscribe(
                onSuccess: { [weak self] in self?.set(histories: $0) },
                onFailure: { [weak self] in self?.catchError($0) }
            )
            .disposed(by: disposeBag)
    }
    
    private func didTapAcceptButtonInErrorAlertEvent() {
        items.accept([])
        outputRelay.accept(.changeEmptyViewState(isHidden: false))
    }
}

// MARK: - private
extension BlackboardFilterConditionsHistoryViewModel {
    private func set(histories: [History]) {
        items.accept([DataSource.Section(items: histories)])
        outputRelay.accept(.changeEmptyViewState(isHidden: !histories.isEmpty))
    }
}

// MARK: - private (error)
extension BlackboardFilterConditionsHistoryViewModel {
    private func catchError(_ error: Error) {
        guard let historyHandlerError = error as? BlackboardHistoryHandlerError else {
            catchAnotherError(error)
            return
        }
        catchBlackboardHistoryHandlerError(historyHandlerError)
    }
    
    private func catchBlackboardHistoryHandlerError(_ error: BlackboardHistoryHandlerError) {
        switch error {
        case .uncorrectArguments, .cannotInitLocalDB, .cannotFindTargetData, .failToHandleDB:
            outputRelay.accept(
                .showSimpleErrorAlert(
                    title: "",
                    message: L10n.Blackboard.Error.failToHandleHistories
                )
            )
        case .unknown:
            outputRelay.accept(
                .showErrorAlert(
                    title: L10n.Blackboard.Error.CannotGetHistories.alertTitle,
                    message: L10n.Blackboard.Error.CannotGetHistories.alertDescription
                )
            )
        }
    }
    
    private func catchAnotherError(_ error: Error) {
        outputRelay.accept(
            .showSimpleErrorAlert(
                title: "",
                message: L10n.Common.Error.unknown
            )
        )
    }
}
