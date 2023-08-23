import Foundation
import StoreKit

private let productIdentifierPrefix = Bundle.main.bundleIdentifier! + "."
private let unlockModernFeatures = productIdentifierPrefix + "unlockModern"
private let movieCredits = productIdentifierPrefix + "movieCredits"
private let movieCredits10Pack = productIdentifierPrefix + "movieCredits.10pack"

let productPurchasedNotification = "ProductsPurchased"

class IAPHelper: NSObject {
  static let Instance = IAPHelper()

  var request: SKProductsRequest?
  var completion: (([SKProduct]?, Error?) -> Void)?

  class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }

  override init() {
    super.init()

    // add transaction observer code here:
    SKPaymentQueue.default().add(self)
  }

  // MARK: - UPGRADE TO HD

  func getUpgradeProduct(_ completion:
    @escaping (([SKProduct]?, Error?) -> Void)) {
    self.completion = completion
    getProducts([unlockModernFeatures])
  }

  func completeUnlock() {
    UserDefaults.standard.set(true, forKey: "upgraded")
    postPurchaseUpdate()
  }

  var upgradePurchased: Bool {
    return UserDefaults.standard.bool(forKey: "upgraded")
  }

  // MARK: - REUSABLE CODE

  private func getProducts(_ productIdentifiers: [String]) {
    // 1
    guard request == nil else { return }

    // 2
    request = SKProductsRequest(
      productIdentifiers: Set(productIdentifiers))
    // 3
    request?.delegate = self
    // 4
    request?.start()
  }

  func buyProduct(_ product: SKProduct) {
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  private func postPurchaseUpdate() {
    NotificationCenter.default.post(name: Notification.Name(rawValue: productPurchasedNotification), object: nil)
  }

  // MARK: -

  func restoreCompletedTransactions() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }

  // MARK: - Movie Credits

  var creditsRemaining: Int {
    return UserDefaults.standard.integer(forKey: "credits")
  }

  func buyCredits(_ completion:
    @escaping (([SKProduct]?, Error?) -> Void)) {
    self.completion = completion
    getProducts([movieCredits, movieCredits10Pack])
  }

  func addCredits(_ numberOfCredits: Int) {
    let credits = creditsRemaining + numberOfCredits
    UserDefaults.standard.set(credits, forKey: "credits")
    postPurchaseUpdate()
  }

  func useCredit() -> Bool {
    let credits = creditsRemaining
    guard credits > 0 else { return false }

    UserDefaults.standard.set(credits - 1, forKey: "credits")
    return true
  }
}

extension IAPHelper: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest,
                       didReceive response: SKProductsResponse) {
    let products = response.products

    let invalidProducts = response.invalidProductIdentifiers
    if !invalidProducts.isEmpty {
      print("Invalid identifiers \(invalidProducts)")
    }

    completion?(products, nil)
  }

  func request(_ request: SKRequest, didFailWithError error: Error) {
    self.request = nil
    completion?(nil, error as NSError?)
  }

  func requestDidFinish(_ request: SKRequest) {
    self.request = nil
  }

}

extension IAPHelper: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue,
                    updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased:
        completeTransaction(transaction)
      case .failed:
        failedTransaction(transaction)
      case .restored:
        restoreTransaction(transaction)
      case .deferred:
        break
      case .purchasing:
        break
      }
    }
  }

  private func completeTransaction(
    _ transaction: SKPaymentTransaction) {
    let productIdentifier = transaction.payment.productIdentifier
    handlePurchase(productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func restoreTransaction(
    _ transaction: SKPaymentTransaction) {
    guard let original = transaction.original else {
      return
    }

    let productIdentifier = original.payment.productIdentifier
    handlePurchase(productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func handlePurchase(_ productIdentifier: String) {
    switch productIdentifier {
    case unlockModernFeatures:
      completeUnlock()
    case movieCredits:
      addCredits(1)
    case movieCredits10Pack:
      addCredits(10)
    default:
      print("Unknown item purchased: \(productIdentifier)")
    }
  }

  private func failedTransaction(_ transaction: SKPaymentTransaction) {
    print("failedTransaction...")
    if (transaction.error! as NSError).code != SKError.Code.paymentCancelled.rawValue {
      print("Transaction error: \(transaction.error!.localizedDescription)")
    }
    SKPaymentQueue.default().finishTransaction(transaction)
  }
}

extension String: Error {

}
