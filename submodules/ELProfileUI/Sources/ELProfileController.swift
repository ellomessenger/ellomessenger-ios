//
//  ELProfileController.swift
//  _idx_ELProfileUI_B5B6554B_ios_min11.0
//
//

import UIKit
import ELBase
import ELCommonUI
import ElloAppCore
import Display
import ELLanguageUI
import SwiftSignalKit
import AccountContext
import ElloAppApi
import Postbox

final public class ELProfileController {
    
    public static var onPrivacyAndSecurity: VoidClosure?
    public static var navigationController: UINavigationController?
    public static var accountContext: AccountContext?
    public static var onSendVerifyRequest: EventClosure<EventClosure<String>>?
    public static var user: ElloAppUser?
    
    public static var blockedUsersCount: Int = 0 {
        didSet{privacyVC?.privacyObject?.blockedUsers = blockedUsersCount}
    }
    
    private static var privacyVC: PrivacyDataViewController?
    
    // MARK: - Earnings
    
    public static func earnings(onTapOption: EventClosure<EarningOption>?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = EarningsViewController.controller {
            vc.onTapOption = {
                onTapOption?($0)
            }
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func subscribedChannels(accountContext: AccountContext) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = SubscriptionChannelsViewController.controller {
            vc.requestService = RequestService(accountContext: accountContext)
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func layalityViewController(accountContext: AccountContext) -> ViewController {
        if let vc = LoyaltyViewController.controller {
            let adopt = AdaptingController(viewController: UINavigationController(rootViewController: vc))
            vc.accountContext = accountContext
            vc.requestService = RequestService(accountContext: accountContext)
            
            vc.onTapBack = {[weak adopt] in
                adopt?.navigationController?.popViewController(animated: true)
            }

            return adopt
        }
   
        return AdaptingController(viewController: nil)
    } 
    
    public static func infoViewController(input: ProfileInfoViewController.Input) -> ViewController {
        if let vc = ProfileInfoViewController.controller {
            let adopt = AdaptingController(viewController: UINavigationController(rootViewController: vc))
            vc.input = input
            
            vc.onTapBack = {[weak adopt] in
                adopt?.navigationController?.popViewController(animated: true)
            }

            return adopt
        }
   
        return AdaptingController(viewController: nil)
    }
    
    public static func transactions(_ transactions: [Transaction], selected: EventClosure<Transaction>? = nil) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = TransactionsViewController.controller {
            vc.transactions = transactions
            vc.onTapItem = {
                selected?($0)
            }
            vc.onTapFilter = {
                adopt.navigationController?.pushViewController(transactionFilter(options: nil, onUpdate: nil), animated: true)
            }
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func transactionFilter(options: Any?, onUpdate:EventClosure<Any?>?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = TransactionsFilterViewController.controller {
            vc.filter = Filter(channel: "Sample channel")
            vc.onTapChannel = {
                let items = [Item(title: "Test1"), Item(title: "Test2"), Item(title: "Test3"), Item(title: "Test4"), Item(title: "Test5"), Item(title: "Test6"), Item(title: "Test7"), Item(title: "Test8"),]
                let lvc = listSelection(items: items, onSelect: { print($0)})
                vc.view.addSubview(lvc.view)
            }
            vc.onTapDateFrom = {
                let dvc = dateSelection(Date(), onChange: {print($0)})
                vc.view.addSubview(dvc.view)
            }
            vc.onTapDateTo = {
                let dvc = dateSelection(Date(), onChange: {print($0)})
                vc.view.addSubview(dvc.view)
            }
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            adopt.altController = vc
        }
        return adopt
    }
    
    // MARK: - Settings
    
    public static func settings(onTapOption: EventClosure<SettingsOption>?, onDeleteAccount: VoidClosure?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)

        if let vc = SettingsViewController.controller {
            vc.onTapOption = {
                onTapOption?($0)
            }
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.onTapDeleteAccount = {
                onDeleteAccount?()
            }
            adopt.altController = vc
        }
        
        return adopt
    }
    
//    public static func invite() -> ViewController {
//        let adopt = AdaptingController(viewController: nil)
//        if let vc = InviteViewController.controller {
////            vc.onTapOption = {
////                selectedOption?($0)
////            }
//            
//            vc.onTapBack = {
//                adopt.navigationController?.popViewController(animated: true)
//            }
//            
//            adopt.altController = vc
//        }
//        return adopt
//    }

    public static func languages(selectedLanguage: EventClosure<Language>?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = LanguagesViewController.controller {
            vc.onTapLanguage = {
                selectedLanguage?($0)
            }
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func changePassAndEmail(selectedOption: EventClosure<ChangeOption>?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = ChangeViewController.controller {
            vc.onTapOption = {
                selectedOption?($0)
            }
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func deleteAccount(_ changePassword: EventClosure<ConfirmPasswordViewController.Result>?, onError: @escaping ErrorCallback) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = ConfirmPasswordViewController.controller {
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.onTapConfirmPasswordTo = changePassword
            vc.onPasswordError = onError
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func deletePrivacy(_ onNext: @escaping VoidClosure) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = PrivacyInfoViewController.controller {
            vc.onTapBack = { [weak adopt] in
                adopt?.navigationController?.popViewController(animated: true)
            }
            vc.onTapNext = onNext
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func accountInfo(context: AccountContext?, 
                                   onOpenAiBot: VoidClosure?,
                                   onOpenOwner: VoidClosure?,
                                   onOpenChat: EventClosure<PeerId>?,
                                   onTapDelete: VoidClosure?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        
        if let vc = AccountInfoViewController.controller {
            vc.requestContext = context
            vc.onTapBack = { [weak adopt] in
                adopt?.navigationController?.popViewController(animated: true)
            }
            
            vc.onTapGoToSubsciptions = { [weak context, weak adopt] in
                guard let accountContext = context else { return }
                adopt?.navigationController?.pushViewController(subscribedChannels(accountContext: accountContext), animated: true)
            }
            
            vc.onTapGoToOwner = onOpenOwner
            vc.onTapGoToElloPay = { [weak adopt] wallets in
                adopt?.navigationController?.pushViewController(walletDashboard(with: wallets), animated: true)
            }
            
            vc.onTapGoToAI = onOpenAiBot
            vc.onTapDelete = onTapDelete
            vc.onOpenChat = onOpenChat
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func changeEmail(helpSupport: VoidClosure?, changeEmailTo: EventClosure<String>?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = ChangeEmailViewController.controller {
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.onTapHelpSupport = helpSupport
            vc.onTapChangeEmailTo = changeEmailTo
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func changePassword(_ changePassword: EventClosure<(ChangePasswordViewController.Result, EventClosure<Bool>)>?, onError: @escaping ErrorCallback) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = ChangePasswordViewController.controller {
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.onTapChangePasswordTo = changePassword
            vc.onPasswordError = onError
            adopt.altController = vc
        }
        return adopt
    }
    
    public static var countriesSignal: Signal<[Country], Never>?
    {
        didSet{
           reloadCountries(complete: nil)
        }
    }
    
    public static func reloadCountries(complete: (([Country]) -> ())?) {
        _ = (countriesSignal! |> deliverOnMainQueue).start(next: { result in
            complete?(result)
        })
    }
    
    public static func profileEdit(with profile:ProfileEditObject?, aboutMaxLength: Int? = nil, avatarChange: EventClosure<ViewController>?, onUpdateProfile: EventClosure<ProfileEditObject?>?, onUsernameChanged: EventClosure<(String, UsernameUpdatable)>? = nil) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = ProfileEditViewController.controller {
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.profileObject = profile
            vc.onUsernameChanged = onUsernameChanged
            vc.onTapConfirm = {
                print("Changed profile: \($0!)")
                onUpdateProfile?($0)
            }
            vc.onTapChangePhoto = {
                avatarChange?(adopt)
            }
            if let aboutMaxLength {
                vc.aboutMaxLength = aboutMaxLength
            }

            adopt.altController = vc
        }
        return adopt
    }
    
    public static func privacy(with object: PrivacyDataObject, onUpdate: ReturnClosure<PrivacyDataObject?>?,  onSelectOption: EventClosure<PrivacyDataOption>?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = PrivacyDataViewController.controller {
            privacyVC = vc
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.onRequestUpdate = {
                return onUpdate?()
            }
            vc.onTapOption = {
                onSelectOption?($0)
            }
            vc.privacyObject = object
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func privacyData(_ object: PrivacyDataOptionObject?, onUpdate: EventClosure<PrivacyDataOptionObject?>?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = PrivacyDataSetupViewController.controller {
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.object = object
            vc.onUpdate = {
                print($0!)
                onUpdate?($0)
            }
            
            adopt.altController = vc
        }
        return adopt
    }
    
    // MARK: - Wallets
    public static func wallets(onSelectOption: VoidClosure?) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        
        if let vc = WalletWelcomeViewController.controller {

            vc.onTapOption = {
                guard let accountContext else { return }
                
                let requestService = RequestService(accountContext: accountContext)
                requestService.createWallet { walletItem in
                    Task { @MainActor in
                        let walletItems = (try? await requestService.getWallets()) ?? []
                        adopt.navigationController?.pushViewController(walletDashboard(with: walletItems), animated: true)
                    }
                }
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func walletDashboard(with walletItems: [Api.wallet.WalletItem]) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = WalletDashboardViewController.controller {
            vc.walletItems = walletItems
            
            if let accountContext {
                vc.requestService = RequestService(accountContext: accountContext)
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            vc.onTapOption = { parameters in
                let (walletItem, methodTypes, walletItems) = parameters
                if methodTypes == .deposit {
                    adopt.navigationController?.pushViewController(inAppPurchaseViewController(), animated: true)
                } else {
                    adopt.navigationController?.pushViewController(
                        topUpMethodsViewController(with: walletItem, methodTypes: methodTypes, walletItems: walletItems),
                        animated: true
                    )
                }
            }
            
            vc.onTapSeeAll = { walletItem in
                adopt.navigationController?.pushViewController(graphsActivityViewController(wallet: walletItem), animated: true)
            }
            
            vc.onTapTransaction = { transactionItem in
                adopt.navigationController?.pushViewController(transactionDetailsViewController(with: transactionItem), animated: true)
            }
            
            vc.onTapSeeAll = { walletItem in
                adopt.navigationController?.pushViewController(graphsActivityViewController(wallet: walletItem), animated: true)
            }
            
            vc.onTapWalletInfo = { type in
                adopt.present(walletInfoViewController(type: type), animated: true, completion: nil)
            }
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func getWalletsSignal(network: Network) -> Signal<[Api.wallet.WalletItem], WalletError> {
        network.request(Api.wallet.getUserWallets(with: 2))
        |> mapError { error -> WalletError in
                .message(error.errorDescription)
        }
        |> mapToSignal { result -> Signal<[Api.wallet.WalletItem], WalletError> in
                .single(result.wallets)
        }
    }
    
    public static func walletsController(network: Network, completionHandler: @escaping (_ controller: ViewController) -> Void) {
        let signal = getWalletsSignal(network: network)
        _ = (signal |> deliverOnMainQueue).start { walletItems in
            if walletItems.isEmpty {
                completionHandler(ELProfileController.wallets(onSelectOption: { }))
            } else {
                completionHandler(ELProfileController.walletDashboard(with: walletItems))
            }
        } error: { error in
            debugPrint(error)
        } completed: {
            debugPrint("\(#function) completed!")
        }
    }
    
    public static func paymentOption() -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = PaymentOptionViewController.controller {
           
//            vc.onTapChannel = {
//                let items = [Item(title: "Test1"), Item(title: "Test2"), Item(title: "Test3"), Item(title: "Test4"), Item(title: "Test5"), Item(title: "Test6"), Item(title: "Test7"), Item(title: "Test8"),]
//                let lvc = listSelection(items: items, onSelect: {print($0)})
//                vc.view.addSubview(lvc.view)
//            }
//            vc.onTapDateFrom = {
//                let dvc = dateSelection(Date(), onChange: {print($0)})
//                vc.view.addSubview(dvc.view)
//            }
//            vc.onTapDateTo = {
//                let dvc = dateSelection(Date(), onChange: {print($0)})
//                vc.view.addSubview(dvc.view)
//            }
            
//            vc.onTapOption = {
//                adopt.navigationController?.pushViewController(topUpMethodsViewController(with: <#Api.wallet.WalletItem#>), animated: true)
//            }
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func topUpMethodsViewController(with walletItem: Api.wallet.WalletItem, methodTypes: MethodTypes, walletItems: [Api.wallet.WalletItem]) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = WalletTopUpMethodsViewController.controller {
            vc.walletItem = walletItem
            vc.methodTypes = methodTypes
            vc.walletItems = walletItems
            vc.onTapOption = { paymentSystem in
                adopt.navigationController?.show(topUpViewController(with: walletItem,
                                                                     paymentSystem: paymentSystem,
                                                                     methodType: methodTypes,
                                                                     wallets: walletItems),
                                                 sender: nil)
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            adopt.altController = vc
        }
        
        return adopt
    }
    
    public static func inAppPurchaseViewController() -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        guard let vc = WalletInAppPurchaseViewController.controller else {
            return adopt
        }
        
        if let accountContext {
            vc.requestService = RequestService(accountContext: accountContext)
        }
        
        vc.onTapBack = { [weak adopt] in
            adopt?.navigationController?.popViewController(animated: true)
        }
        
        vc.onInAppPurchaseMade = { [weak adopt] isSuccess, amount in
            let paymentStatusVC = paymentStatus(
                with: .inAppPurchase,
                topUpAmount: Double(amount),
                isSuccess: isSuccess,
                methodType: .deposit)
            adopt?.navigationController?.show(paymentStatusVC, sender: nil)
        }
        
        adopt.altController = vc
        
        return adopt
    }
    
    public static func graphsActivityViewController(wallet: Api.wallet.WalletItem) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = GraphsActivityViewController.controller {
            if let accountContext {
                vc.requestService = RequestService(accountContext: accountContext)
            }
            vc.wallet = wallet
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            vc.onTapTransaction = { transactionItem in
                adopt.navigationController?.pushViewController(transactionDetailsViewController(with: transactionItem), animated: true)
            }
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func topUpViewController(with walletItem: Api.wallet.WalletItem,
                                           paymentSystem: TopUpMethodModel,
                                           methodType: MethodTypes,
                                           wallets: [Api.wallet.WalletItem]) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = WalletTopUpViewController.controller {
            vc.balance = walletItem.amount
            vc.paymentSystem = paymentSystem
            vc.methodTypes = methodType
            vc.wallet = walletItem
            vc.wallets = wallets
            
            if let accountContext {
                vc.requestService = RequestService(accountContext: accountContext)
            }
            
            vc.onTapOption = { [weak adopt] withdrawParams in
                switch paymentSystem {
                case .payPal:
                    switch methodType {
                    case .deposit:
//                        adopt.navigationController?.show(connectPaypal(with: walletItem, topUpAmount: withdrawParams.amount, methodType: methodType, topUpProvider: .paypal), sender: nil)
                        adopt?.navigationController?.show(paypalWebViewViewController(with: walletItem, 
                                                                                      topUpAmount: withdrawParams.amount,
                                                                                      methodType: methodType,
                                                                                      topUpProvider: .paypal),
                                                          sender: nil)
                    case .withdrawal:
                        adopt?.navigationController?.show(paypalWithdrawEmail(with: walletItem, 
                                                                              withdrawParams: withdrawParams,
                                                                              methodType: methodType),
                                                          sender: nil)
                    }
                    
                case .bankCard:
                    switch methodType {
                    case .deposit:
//                        adopt?.navigationController?.show(paymentCard(with: walletItem,
//                                                                      topUpAmount: withdrawParams.amount,
//                                                                      methodType: methodType),
//                                                         sender: nil)
                        adopt?.navigationController?.show(paypalWebViewViewController(with: walletItem,
                                                                                      topUpAmount: withdrawParams.amount,
                                                                                      methodType: methodType,
                                                                                      topUpProvider: .bank),
                                                          sender: nil)
                    case .withdrawal:
                        if let accountContext {
                            onSendVerifyRequest?({ code in
                                let handleError: ErrorCallback = { error in
                                    let presentationData = accountContext.sharedContext.currentPresentationData.with { $0 }
                                    adopt?.present(standardTextAlertController(theme: .init(presentationData: presentationData), 
                                                                               title: nil,
                                                                               text: "\(error.localizedDescription)",
                                                                               actions: [.init(type: .defaultAction,
                                                                                               title: presentationData.strings.Common_OK,
                                                                                               action: {})]),
                                                   in: .window(.root))
                                }
                                
                                let bankTransferViewControllerAdopt = AdaptingController(viewController: nil)
                                let bankTransferViewController = BankTransferViewController.controller!
                                bankTransferViewController.service = RequestService(accountContext: accountContext)
                                
                                bankTransferViewController.onAdd = {[weak bankTransferViewControllerAdopt]in
                                    bankTransferViewControllerAdopt?.navigationController?.pushViewController(
                                        createWithdrawEditPersonalInfoViewController(with: walletItem,
                                                                                     code: code,
                                                                                     withdrawParams: withdrawParams), animated: true)
                                }
                                
                                bankTransferViewController.onEdit = {[weak bankTransferViewControllerAdopt] bankWithdrawsItem in
                                    bankTransferViewControllerAdopt?.navigationController?.pushViewController(
                                        createWithdrawEditPersonalInfoViewController(with: walletItem,
                                                                                     code: code,
                                                                                     withdrawParams: withdrawParams,
                                                                                     bankWithdrawsItemWrapper: BankWithdrawsItemWrapper( bankWithdrawsItem)), animated: true)
                                }

                                bankTransferViewController.onConfirm = {[weak bankTransferViewControllerAdopt] bankWithdrawsItem in
                                    
                                    let withdrawalInfoAdaptingController = AdaptingController(viewController: nil)
                                    if let vc = WithdrawalInfoViewController.controller {
                                        vc.bankWithdrawsItem = bankWithdrawsItem
                                        vc.amount = withdrawParams.amount
                                        
                                        vc.onTapOption = { _ in
                                            let service = RequestService(accountContext: accountContext)
                                            service.createWithdrawPayment(assetId: BaseAsset.usd.rawValue,
                                                                          walletId: walletItem.id,
                                                                          currency: walletItem.assetSymbol,
                                                                          paymentId: withdrawParams.paymentId,
                                                                          bankWithdrawRequisitesId: bankWithdrawsItem.requisitesId,
                                                                          amount: withdrawParams.amount) { result in
                                                switch result {
                                                case let .success(paymentItem):
                                                    service.approveWithdrawPayment(with: walletItem.id,
                                                                                   paymentId: paymentItem.paymentId,
                                                                                   approveCode: code,
                                                                                   paypalEmail: nil,
                                                                                   bankWithdrawRequisitesId:bankWithdrawsItem.requisitesId) { result in
                                                        switch result {
                                                        case .success:
                                                            bankTransferViewControllerAdopt?.navigationController?.show(paymentStatus(.success(description: methodType == .withdrawal ?             "Payment.Status.Success.DescriptionWithdraw".localized : "Payment.Status.Success.Description".localized,
                                                                        value: withdrawParams.amount
                                                                    )
                                                                ), sender: nil
                                                            )
                                                        case let .failure(error):
                                                            handleError(error)
                                                            bankTransferViewControllerAdopt?.navigationController?.show(paymentStatus(.failure(title: Localization.paymentFailureTitle.localized, description: Localization.paymentFailureDescription.localized)), sender: nil)
                                                        }
                                                    }
                                                    
                                                case let .failure(error):
                                                    handleError(error)
                                                    bankTransferViewControllerAdopt?.navigationController?.show(paymentStatus(.failure(title: Localization.paymentFailureTitle.localized, description: Localization.paymentFailureDescription.localized)), sender: nil)
                                                }
                                            }
                                        }

                                        vc.onTapBack = {[weak withdrawalInfoAdaptingController] in
                                            withdrawalInfoAdaptingController?.navigationController?.popViewController(animated: true)
                                        }

                                        withdrawalInfoAdaptingController.altController = vc
                                    }
                                    
                                    adopt?.navigationController?.show(withdrawalInfoAdaptingController, sender: nil)
                                    

                                }
                                
                                bankTransferViewController.onTapBack = {[weak adopt]in
                                    adopt?.navigationController?.popViewController(animated: true)
                                }
                                
                                bankTransferViewControllerAdopt.altController = bankTransferViewController
                                adopt?.navigationController?.popViewController(animated: false)
                                adopt?.navigationController?.show(bankTransferViewControllerAdopt, sender: nil)
                            })
                        }
                    }
                    
                case .elloai, .apple:
                    debugPrint("TODO")
                case .myBalance:
                    if let accountContext {
                        guard let adopt else { return }
                        
                        Task {
                            let requestService = RequestService(accountContext: accountContext)
                            guard let walletItems = (try? await requestService.getWallets()),
                                  let myBalanceWalletItem = walletItems.first(where: {$0.type == .main}) else {
                                Task { @MainActor in
                                    adopt.navigationController?.show(paymentStatus(.failure(title: Localization.paymentFailureTitle.localized, description: Localization.paymentFailureDescription.localized)), sender: nil)
                                }
                                return
                            }
                            
                            requestService.transferMoneyBetweenWallets(
                                with: Api.wallet.TransferMoneyBetweenWalletsItem(
                                    from_wallet_id: walletItem.id,
                                    to_wallet_id: myBalanceWalletItem.id,
                                    amount: withdrawParams.amount
                                ),
                                completionHandler: { result in
                                    Task { @MainActor in
                                        switch result {
                                        case .success:
                                            adopt.navigationController?.show(
                                                paymentStatus(
                                                    .success(
                                                        description: methodType == .withdrawal ? "Payment.Status.Success.DescriptionWithdraw".localized : "Payment.Status.Success.Description".localized,
                                                        value: withdrawParams.amount
                                                    )
                                                ),
                                                sender: nil
                                            )
                                        case .failure:
                                            adopt.navigationController?.show(paymentStatus(.failure()), sender: nil)
                                        }
                                    }
                                })
                        }
                    }
                }
           }
            
            vc.onTapBack = { [weak adopt] in
                adopt?.navigationController?.popViewController(animated: true)
            }
            
            adopt.altController = vc
        }
        
        return adopt
    }
    
    static func transactionDetailsViewController(with transactionItem: WalletTransaction) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = TransactionDetailsViewController.controller {
            vc.transactionItem = transactionItem
            
            if let accountContext {
                vc.requestService = RequestService(accountContext: accountContext)
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func paymentCard(with walletItem: Api.wallet.WalletItem, 
                                   topUpAmount: Double,
                                   methodType:MethodTypes) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = PaymentCardViewController.controller {
            vc.topUpAmount = topUpAmount
            vc.walletItem = walletItem
            vc.onTapOption = { paymentItem in
                adopt.navigationController?.show(paymentStatus(with: .bank(paymentItem), 
                                                               topUpAmount: topUpAmount,
                                                               methodType: methodType),
                                                 sender: nil)
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            adopt.altController = vc
        }
        
        return adopt
    }
    
//    static func connectPaypal(with walletItem: Api.wallet.WalletItem, topUpAmount: Double, methodType: MethodTypes, topUpProvider: PaypalConnectViewController.TopUpProvider) -> ViewController {
//        let adopt = AdaptingController(viewController: nil)
//        if let vc = PaypalConnectViewController.controller {
//            if let accountContext {
//                vc.requestService = RequestService(accountContext: accountContext)
//            }
//            vc.paymentItem = .init(
//                assetId: 2,
//                walletId: walletItem.id,
//                currency: walletItem.assetSymbol,
//                message: "",
//                amount: topUpAmount
//            )
//            vc.topUpProvider = topUpProvider
//            vc.onTapOption = { link, topUpProvider in
//                adopt.navigationController?.show(
//                    paypalWebViewViewController(
//                        with: link,
//                        topUpAmount: topUpAmount,
//                        methodType: methodType,
//                        topUpProvider: topUpProvider),
//                    sender: nil
//                )
//            }
//            
//            vc.onTapBack = {
//                adopt.navigationController?.popViewController(animated: true)
//            }
//            
//            adopt.altController = vc
//        }
//        
//        return adopt
//    }
    
    static func paypalWebViewViewController(with walletItem: Api.wallet.WalletItem, 
                                            topUpAmount: Double,
                                            methodType: MethodTypes,
                                            topUpProvider: PaypalConnectViewController.TopUpProvider) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = PaypalWebViewController.controller {
            vc.topUpProvider = topUpProvider
            vc.paymentItem = .init(
                assetId: 2,
                walletId: walletItem.id,
                currency: walletItem.assetSymbol,
                message: "",
                amount: topUpAmount
            )
            
            if let accountContext {
                vc.requestService = RequestService(accountContext: accountContext)
            }
            
            vc.onTapBack = { [weak adopt] in
                adopt?.navigationController?.popViewController(animated: true)
            }
            
            vc.onTapDoneOption = { [weak vc, weak adopt] in
                adopt?.navigationController?.show(paymentStatus(with: .paypal, topUpAmount: topUpAmount, isSuccess: vc?.isSuccess, methodType: methodType), sender: nil)
            }
            
            vc.onTapOption = { [weak vc, weak adopt] in
                adopt?.navigationController?.show(paymentStatus(with: .paypal, topUpAmount: topUpAmount, isSuccess: vc?.isSuccess, methodType: methodType), sender: nil)
            }
            
            adopt.altController = vc
        }
        
        return adopt
    }
    
    public static func paypalWithdrawEmail(with walletItem: Api.wallet.WalletItem, withdrawParams: WithdrawParams, methodType:MethodTypes) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = PaypalEmailViewController.controller {
            vc.onTapOption = { email in
                onSendVerifyRequest?({ [weak adopt] code in
                    adopt?.navigationController?.show(progress(), sender: nil)
                    if let accountContext {
                        let handleError: ErrorCallback = { [weak adopt] in
                            if let commonError = $0 as? CommonError {
                                adopt?.navigationController?.show(paymentStatus(.failure(description: commonError.errorDescription)), sender: nil)
                            } else {
                                adopt?.navigationController?.show(paymentStatus(.failure()), sender: nil)
                            }
                        }
                        
                        let service = RequestService(accountContext: accountContext)
                        service.createWithdrawPayment(assetId: BaseAsset.usd.rawValue,
                                                      walletId: walletItem.id,
                                                      currency: walletItem.assetSymbol,
                                                      paypalEmail: email,
                                                      paymentId: withdrawParams.paymentId,
                                                      amount: withdrawParams.amount,
                                                      withdrawSystem: WithdrawSystem.paypal.rawValue) { result in
                            switch result {
                            case let .success(paymentItem):
                                service.approveWithdrawPayment(with: walletItem.id, 
                                                               paymentId: paymentItem.paymentId,
                                                               approveCode: code,
                                                               paypalEmail: paymentItem.paypalEmail,
                                                               bankWithdrawRequisitesId: nil) { result in
                                    switch result {
                                    case let .success(approveResult):
                                        adopt?.navigationController?.show(paymentStatus(.success(
                                            description: MethodTypesViewModel.subtitle(withMethodType: methodType),
                                            value: approveResult.amount)), sender: nil)
                                    case let .failure(error):
                                        handleError(error)
                                    }
                                }
                            case let .failure(error):
                                handleError(error)
                            }
                        }
                    } else {
                        adopt?.navigationController?.show(paymentStatus(.failure()), sender: nil)
                    }
                })
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            vc.getFullUserDisposable.set((getFullUser(network: (self.accountContext?.account.network)!) |> deliverOnMainQueue)
                .start(next: { user in
                    switch user {
                    case let .userFull(_, _, _, _, _, _, _, email, _, _, _, _, _, _, _, _, _, _, _, _):
                        if vc.email.isEmpty, let email = email {
                            vc.email = email
                        }
                    }
            }))
            
            adopt.altController = vc
        }
        
        return adopt
    }
    
//    public static func createBankTransfer(with walletItem: Api.wallet.WalletItem,
//                                         withdrawAmount: Double) -> ViewController {
//        let adopt = AdaptingController(viewController: nil)
//        
//        if let vc = BankWithdrawalUserInfoViewController.controller {
//            vc.onTapOption = { object in
//                let isChosenCountryUS = object.country == "USA" ? true : false
//                adopt.navigationController?.show(createBankWithdrawRequisites(with: walletItem,
//                                                                              withdrawAmount: withdrawAmount,
//                                                                              userInfoObject: object,
//                                                                              isChosenCountryUS: isChosenCountryUS),
//                                                 sender: nil)
//            }
//            
//            vc.onTapBack = {
//                adopt.navigationController?.popViewController(animated: true)
//            }
//            
//            adopt.altController = vc
//        }
//        
//        return adopt
//    }
//    
//    public static func createBankWithdrawRequisites(with walletItem: Api.wallet.WalletItem,
//                                                    withdrawAmount: Double,
//                                                    userInfoObject: UserInfoObject,
//                                                    isChosenCountryUS: Bool) -> ViewController {
//        let adopt = AdaptingController(viewController: nil)
//        if let vc = BankWithdrawalUserAddressViewController.controller {
//            vc.isUSA = user?.country == "USA" ? true : false
//            vc.isBusiness = user?.isBusiness ?? false
//            vc.onTapOption = { userAddressObject in
//                adopt.navigationController?.show(createBankWithdrawRequisites(with: walletItem,
//                                                                              withdrawAmount: withdrawAmount,
//                                                                              userInfoObject: userInfoObject,
//                                                                              userAddressObject: userAddressObject,
//                                                                              isChosenCountryUS: isChosenCountryUS), 
//                                                 sender: nil)
//            }
//            
//            vc.onTapBack = {
//                adopt.navigationController?.popViewController(animated: true)
//            }
//            adopt.altController = vc
//        }
//        
//        return adopt
//    }
//    
//    public static func createBankWithdrawRequisites(with walletItem: Api.wallet.WalletItem,
//                                                    withdrawAmount: Double,
//                                                    userInfoObject: UserInfoObject,
//                                                    userAddressObject: UserAddressObject,
//                                                    isChosenCountryUS: Bool) -> ViewController {
//        let adopt = AdaptingController(viewController: nil)
//        if let vc = WithdrawalBankInfoViewController.controller {
//            vc.isUSA = user?.country == "USA" ? true : false
//            vc.isBusiness = user?.isBusiness ?? false
//            vc.userAddressObject = userAddressObject
//            vc.isChosenCountryUS = isChosenCountryUS
//            vc.amount = withdrawAmount
//            print(userInfoObject)
//            vc.onTapOption = { object in
//                adopt.navigationController?.show(createBankWithdrawRequisites(userInfoObject: userInfoObject,
//                                                                              userAddressObject: userAddressObject,
//                                                                              bankInfoObject: object,
//                                                                              amount: withdrawAmount,
//                                                                              isChosenCountryUS: isChosenCountryUS),
//                                                 sender: nil)
//            }
//            
//            vc.onTapBack = {
//                adopt.navigationController?.popViewController(animated: true)
//            }
//            
//            adopt.altController = vc
//        }
//        
//        return adopt
//    }
//
//    public static func createBankWithdrawRequisites(userInfoObject: UserInfoObject,
//                                                    userAddressObject: UserAddressObject,
//                                                    bankInfoObject: BankInfoObject,
//                                                    amount: Double,
//                                                    isChosenCountryUS: Bool) -> ViewController {
//        let adopt = AdaptingController(viewController: nil)
//        if let vc = WithdrawalInfoViewController.controller {
//            vc.isUSA = user?.country == "USA" ? true : false
//            vc.isBusiness = user?.isBusiness ?? false
//            vc.isChosenCountryUS = isChosenCountryUS
//            vc.userInfoObject = userInfoObject
//            vc.userAddressObject = userAddressObject
//            vc.bankInfoObject = bankInfoObject
//            vc.amount = amount
//            vc.onTapOption = { object in
//                if let accountContext {
//                    let service = RequestService(accountContext: accountContext)
//                    service.createBankWithdrawRequisites(with: object) { result in
//                        switch result {
//                        case let .success(result):
//                            adopt.navigationController?.show(paymentStatus(.failure(description: Localization.paymentSuccessDescriptionWithdraw.localized,
//                                                                                    value: amount)), sender: nil)
//                            print(result)
//                        case let .failure(error):
//                            adopt.navigationController?.show(paymentStatus(.failure()), sender: nil)
//                            print(error)
//                        }
//                    }
//                }
//            }
//            
//            vc.onTapBack = {
//                adopt.navigationController?.popViewController(animated: true)
//            }
//            
//            adopt.altController = vc
//        }
//        
//        return adopt
//    }
    
    private static func createWithdrawEditPersonalInfoViewController(with walletItem: Api.wallet.WalletItem,
                                                                     code: String,
                                                                     withdrawParams: WithdrawParams,
                                                                     bankWithdrawsItemWrapper: BankWithdrawsItemWrapper? = nil) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = WithdrawEditPersonalInfoViewController.controller {
            vc.walletItem = walletItem
            vc.bankWithdrawsItemWrapper = bankWithdrawsItemWrapper ?? BankWithdrawsItemWrapper(BankWithdrawsItem(/*isUSA: user?.isUSA,*/
                                                                          /*isBusiness: user?.isBusiness ?? false*/))
            let mode:WithdrawEditMode = nil == bankWithdrawsItemWrapper?.bankWithdrawsItem ? .add : .edit
            vc.mode = mode
            
            vc.onNextTap = { bankWithdrawsItemWrapper in
                adopt.navigationController?.show(createWithdrawEditBankInfoViewController(with: walletItem,
                                                                                          code: code,
                                                                                          withdrawParams: withdrawParams,
                                                                                          mode: mode,
                                                                                          bankWithdrawsItemWrapper: bankWithdrawsItemWrapper),
                                                 sender: nil)
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            adopt.altController = vc
        }
        
        return adopt
    }

    private static func createWithdrawEditBankInfoViewController(with walletItem: Api.wallet.WalletItem,
                                                                 code: String,
                                                                 withdrawParams: WithdrawParams,
                                                                 mode: WithdrawEditMode = .add,
                                                                 bankWithdrawsItemWrapper: BankWithdrawsItemWrapper? = nil) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = WithdrawEditBankInfoViewController.controller {
            vc.amount = withdrawParams.amount
            vc.walletItem = walletItem
            vc.bankWithdrawsItemWrapper = bankWithdrawsItemWrapper ?? BankWithdrawsItemWrapper(BankWithdrawsItem(/*isUSA: user?.isUSA,*/
                                                                          /*isBusiness: user?.isBusiness ?? false*/))
            vc.mode = mode
            let requestService = RequestService(accountContext: accountContext!)
            vc.onWithdraw = { bankWithdrawsItem in
                switch mode {
                case .edit:
                    requestService.editWithdrawTemplate(with: BankWithdrawalInfoObject(
                        templateId: bankWithdrawsItem.requisitesId,
                        recipientType: bankWithdrawsItem.recipientType ?? "",
                        bankRoutingNumber: bankWithdrawsItem.bankInfo?.routingNumber ?? "",
                        businessIdNumber: bankWithdrawsItem.businessIdNumber ?? "",
                        personalFirstName: bankWithdrawsItem.personInfo?.firstName ?? "",
                        personalLastName: bankWithdrawsItem.personInfo?.lastName ?? "",
                        personalPhone: bankWithdrawsItem.personInfo?.phoneNumber ?? "",
                        personalEmail: bankWithdrawsItem.personInfo?.email ?? "",
                        message: "",
                        currency: bankWithdrawsItem.currency ?? "",
                        bankCountry: bankWithdrawsItem.bankInfo?.country ?? "",
                        bankName: bankWithdrawsItem.bankInfo?.name ?? "",
                        bankStreet: bankWithdrawsItem.bankInfo?.street ?? "",
                        bankCity: bankWithdrawsItem.bankInfo?.city ?? "",
                        bankState: bankWithdrawsItem.bankInfo?.state ?? "",
                        bankSwift: bankWithdrawsItem.bankInfo?.swift ?? "",
                        bankAddress: bankWithdrawsItem.bankInfo?.address ?? "",
                        bankPostalCode: bankWithdrawsItem.bankInfo?.postalCode ?? "",
                        bankZipCode: bankWithdrawsItem.bankInfo?.zipCode ?? "",
                        bankRecipientAccountNumber: bankWithdrawsItem.bankInfo?.recipientAccountNumber ?? "",
                        userAddressAddres: bankWithdrawsItem.addressInfo?.address ?? "",
                        userAddressStreet: bankWithdrawsItem.addressInfo?.street ?? "",
                        userAddressCity: bankWithdrawsItem.addressInfo?.city ?? "",
                        userAddressState: bankWithdrawsItem.addressInfo?.state ?? "",
                        userAddressRegion: bankWithdrawsItem.addressInfo?.region ?? "",
                        userAddressZipCode: bankWithdrawsItem.addressInfo?.zipCode ?? "",
                        userAddressPostalCode: bankWithdrawsItem.addressInfo?.postalCode ?? "")) {[weak adopt] result in
                            switch result {
                            case .success(let requisites):
                                print(requisites)
                                adopt?.navigationController?.popViewController(animated: false)
                            case let .failure(error):
                                print(error)
                                let alert = UIAlertController(title: "Payment.Status.Failure.Description".localized,
                                                              message: nil,
                                                              preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                                adopt?.present(alert, animated: true)
                            }
                        }

                case .add:
                    requestService.createBankWithdrawRequisites(with: BankWithdrawalInfoObject(
                        isTemplate: bankWithdrawsItem.isTemplate ?? false,
                        recipientType: bankWithdrawsItem.recipientType ?? "",
                        bankRoutingNumber: bankWithdrawsItem.bankInfo?.routingNumber ?? "",
                        businessIdNumber: bankWithdrawsItem.businessIdNumber ?? "",
                        personalFirstName: bankWithdrawsItem.personInfo?.firstName ?? "",
                        personalLastName: bankWithdrawsItem.personInfo?.lastName ?? "",
                        personalPhone: bankWithdrawsItem.personInfo?.phoneNumber ?? "",
                        personalEmail: bankWithdrawsItem.personInfo?.email ?? "",
                        message: "",
                        currency: bankWithdrawsItem.currency ?? "",
                        bankCountry: bankWithdrawsItem.bankInfo?.country ?? "Country",
                        bankName: bankWithdrawsItem.bankInfo?.name ?? "",
                        bankStreet: bankWithdrawsItem.bankInfo?.street ?? "",
                        bankCity: bankWithdrawsItem.bankInfo?.city ?? "",
                        bankState: bankWithdrawsItem.bankInfo?.state ?? "",
                        bankSwift: bankWithdrawsItem.bankInfo?.swift ?? "",
                        bankAddress: bankWithdrawsItem.bankInfo?.address ?? "",
                        bankPostalCode: bankWithdrawsItem.bankInfo?.postalCode ?? "",
                        bankZipCode: bankWithdrawsItem.bankInfo?.zipCode ?? "",
                        bankRecipientAccountNumber: bankWithdrawsItem.bankInfo?.recipientAccountNumber ?? "",
                        userAddressAddres: bankWithdrawsItem.addressInfo?.address ?? "",
                        userAddressStreet: bankWithdrawsItem.addressInfo?.street ?? "",
                        userAddressCity: bankWithdrawsItem.addressInfo?.city ?? "",
                        userAddressState: bankWithdrawsItem.addressInfo?.state ?? "",
                        userAddressRegion: bankWithdrawsItem.addressInfo?.region ?? "",
                        userAddressZipCode: bankWithdrawsItem.addressInfo?.zipCode ?? "",
                        userAddressPostalCode: bankWithdrawsItem.addressInfo?.postalCode ?? "")) { result in
                            switch result {
                            case .success(let requisites):
                                requestService.createWithdrawPayment(assetId: BaseAsset.usd.rawValue,
                                                                     walletId: walletItem.id,
                                                                     currency: walletItem.assetSymbol,
                                                                     paymentId: withdrawParams.paymentId,
                                                                     bankWithdrawRequisitesId: bankWithdrawsItem.requisitesId,
                                                                     amount: withdrawParams.amount) { result in
                                    switch result {
                                    case let .success(paymentItem):
                                        requestService.approveWithdrawPayment(with: walletItem.id,
                                                                              paymentId: paymentItem.paymentId,
                                                                              approveCode: code,
                                                                              paypalEmail: nil,
                                                                              bankWithdrawRequisitesId: requisites.requisitesId) { result in
                                            switch result {
                                            case .success:
                                                adopt.navigationController?.show(paymentStatus(.success(title: "Payment.Status.Success.DescriptionWithdraw".localized,
                                                                                                        value: walletItem.amount
                                                                                                       )
                                                ), sender: nil
                                                )
                                                
                                            case let .failure(error):
                                                print(error)
                                                //                                    handleError(error)
                                                adopt.navigationController?.show(paymentStatus(.failure(title: Localization.paymentFailureTitle.localized, description: Localization.paymentFailureDescription.localized)), sender: nil)
                                            }
                                        }
                                        
                                    case let .failure(error):
                                        print(error)
                                        //                            handleError(error)
                                        adopt.navigationController?.show(paymentStatus(.failure(title: Localization.paymentFailureTitle.localized, description: Localization.paymentFailureDescription.localized)), sender: nil)
                                    }
                                }
                                
                            case let .failure(error):
                                print(error)
    //                            handleError(error)
                                adopt.navigationController?.show(paymentStatus(.failure(title: Localization.paymentFailureTitle.localized, description: Localization.paymentFailureDescription.localized)), sender: nil)
                            }
                        }
                }
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            adopt.altController = vc
        }
        
        return adopt
    }

    
            
    public static func paymentStatus(with paymentSystemStatus: PaymentSystemStatus, topUpAmount: Double, isSuccess: Bool? = true, methodType:MethodTypes) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = PaymentStatusViewController.controller {
            if let accountContext {
                vc.isSuccess = isSuccess
                vc.requestService = RequestService(accountContext: accountContext)
                vc.paymentSystemStatus = paymentSystemStatus
                vc.topUpBalance = topUpAmount
                vc.methodType = methodType
            }
            
            vc.onTapOption = {
                popToWallet(from: adopt)
            }
            
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            adopt.altController = vc
        }
        
        return adopt
    }
    
    public static func crypto() -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = CryptoSectionViewController.controller {
           
//            vc.onTapChannel = {
//                let items = [Item(title: "Test1"), Item(title: "Test2"), Item(title: "Test3"), Item(title: "Test4"), Item(title: "Test5"), Item(title: "Test6"), Item(title: "Test7"), Item(title: "Test8"),]
//                let lvc = listSelection(items: items, onSelect: {print($0)})
//                vc.view.addSubview(lvc.view)
//            }
//            vc.onTapDateFrom = {
//                let dvc = dateSelection(Date(), onChange: {print($0)})
//                vc.view.addSubview(dvc.view)
//            }
//            vc.onTapDateTo = {
//                let dvc = dateSelection(Date(), onChange: {print($0)})
//                vc.view.addSubview(dvc.view)
//            }
            
            vc.onTapOption = {
                adopt.navigationController?.show(cryptoDetails(), sender: nil)
            }
            
//            vc.onTapOption = {
//                adopt.navigationController?.show(walletDashboard(), sender: nil)
//            }
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func cryptoDetails() -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = CryptoDetailsViewController.controller {
           
//            vc.onTapChannel = {
//                let items = [Item(title: "Test1"), Item(title: "Test2"), Item(title: "Test3"), Item(title: "Test4"), Item(title: "Test5"), Item(title: "Test6"), Item(title: "Test7"), Item(title: "Test8"),]
//                let lvc = listSelection(items: items, onSelect: {print($0)})
//                vc.view.addSubview(lvc.view)
//            }
//            vc.onTapDateFrom = {
//                let dvc = dateSelection(Date(), onChange: {print($0)})
//                vc.view.addSubview(dvc.view)
//            }
//            vc.onTapDateTo = {
//                let dvc = dateSelection(Date(), onChange: {print($0)})
//                vc.view.addSubview(dvc.view)
//            }
            
           
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            vc.onTapOption = {
                adopt.navigationController?.show(cryptoQr(), sender: nil)
            }
            
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func cryptoQr() -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = CryptoQrViewController.controller {
           
//            vc.onTapChannel = {
//                let items = [Item(title: "Test1"), Item(title: "Test2"), Item(title: "Test3"), Item(title: "Test4"), Item(title: "Test5"), Item(title: "Test6"), Item(title: "Test7"), Item(title: "Test8"),]
//                let lvc = listSelection(items: items, onSelect: {print($0)})
//                vc.view.addSubview(lvc.view)
//            }
//            vc.onTapDateFrom = {
//                let dvc = dateSelection(Date(), onChange: {print($0)})
//                vc.view.addSubview(dvc.view)
//            }
//            vc.onTapDateTo = {
//                let dvc = dateSelection(Date(), onChange: {print($0)})
//                vc.view.addSubview(dvc.view)
//            }
            
           
            vc.onTapBack = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func progress() -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = ProgressViewController.controller {
            vc.headerTitle = "Payment.InProgress.Header".localized
            vc.progressTitle = "Payment.InProgress.Title".localized
            vc.progressDesription = "Payment.InProgress.Description".localized
            vc.closeButtonTitle = "Common.Cancel".localized
            vc.onTapClose = {
                adopt.navigationController?.popViewController(animated: true)
            }
            
            adopt.altController = vc
        }
        return adopt
    }
    
    
    public static func paymentStatus(_ status: StatusViewController.Status, value:Double? = nil) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = StatusViewController.controller {
            vc.status = status
            
            vc.closeButtonTitle = "Common.OK".localized
            
            vc.onTapClose = {
                popToWallet(from: adopt)
            }
            
            adopt.altController = vc
        }
        return adopt
    }
    
    public static func popToWallet(from adopt: ViewController) {
        if let walletAdoptVC = adopt.navigationController?.viewControllers.first(where: { ($0 as? AdaptingController)?.altController is WalletDashboardViewController }) as? AdaptingController {
            adopt.navigationController?.popToViewController(walletAdoptVC, animated: true)
            guard let walletVC = walletAdoptVC.altController as? WalletDashboardViewController else {
                return
            }
            walletVC.updateWallets()
            walletVC.transactionController?.requestTransaction()
        } else {
            adopt.navigationController?.popToRootViewController(animated: true)
        }
            
    }
    
    // MARK: - Other
    
    private static func dateSelection(_ date: Date, onChange:EventClosure<Date>?) -> UIViewController {
        if let vc = DateSelectionViewController.controller {
            vc.date = date
            vc.dateChanged = {
                onChange?($0)
            }
            vc.onTapBack = {
                vc.view.removeFromSuperview()
            }
            return vc
        }
        return UIViewController()
    }
    
    private static func listSelection(items: [Item], onSelect: EventClosure<Item>?) -> UIViewController {
        if let vc = ItemsListViewController.controller {
            vc.items = items
            vc.onTapItem = {
                onSelect?($0)
            }
            vc.onTapBack = {
                vc.view.removeFromSuperview()
            }
            return vc
        }
        return UIViewController()
    }
    
    static func walletInfoViewController(type: WalletType) -> ViewController {
        let adopt = AdaptingController(viewController: nil)
        if let vc = WalletInfoViewController.controller {
            vc.walletType = type
            vc.didTapBack = {
                adopt.dismiss(animated: true)
            }
            adopt.modalPresentationStyle = .overCurrentContext
            adopt.modalTransitionStyle = .crossDissolve
            adopt.altController = vc
        }
        return adopt
    }
}

// MARK: - Profile Items

private enum Localization: String {
    case paymentSuccessTitle = "Payment.Status.Success.Title",
         paymentSuccessDescription = "Payment.Status.Success.Description",
         paymentSuccessDescriptionWithdraw = "Payment.Status.Success.DescriptionWithdraw",
         paymentFailureTitle = "Payment.Status.Failure.Title",
         paymentFailureDescription = "Payment.Status.Failure.Description"
}
