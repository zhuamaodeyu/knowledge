override func viewDidLoad() {
    super.viewDidLoad()

    cityTextField.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
    countryTextField.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)

    titleTopConstraint.constant = -logoView.frame.height
  }

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
        self.cityTextField.transform = CGAffineTransform.identity
      }, completion: nil)

    UIView.animate(withDuration: 2.0, delay: 0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
        self.countryTextField.transform = CGAffineTransform.identity
      }, completion: nil)

    // 1
    titleTopConstraint.constant = 60.0
    UIView.animate(withDuration: 1.0) {
      // 2
      self.view.layoutIfNeeded()
    }
  }


// 

