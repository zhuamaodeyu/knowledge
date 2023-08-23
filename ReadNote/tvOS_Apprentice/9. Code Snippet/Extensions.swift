func showError(_ error: Error?, inController controller: UIViewController?) {
  DispatchQueue.main.async {
    let controller = controller ?? UIApplication.shared.windows.first!.rootViewController!
    let error: NSError? = error as NSError?

    let title = "An error occurred."

    var message = error?.localizedDescription ?? ""
    if error?.domain == CKErrorDomain {
      if error!.code == CKError.Code.notAuthenticated.rawValue {
        message += "\n Log in to iCloud in the Settings app."
      }
    }

    let acceptButtonTitle = NSLocalizedString("OK", comment: "")

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    // Create the action.
    let acceptAction = UIAlertAction(title: acceptButtonTitle, style: .cancel) { _ in
    }

    // Add the action.
    alertController.addAction(acceptAction)

    controller.present(alertController, animated: true, completion: nil)

  }
}
