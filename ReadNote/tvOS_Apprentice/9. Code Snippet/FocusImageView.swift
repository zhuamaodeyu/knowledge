
class FocusImageView: UIImageView {
  override var canBecomeFocused: Bool {
    return true
  }
  
  // 1
  override init(image: UIImage?) {
    super.init(image: image)
    // 2
    isUserInteractionEnabled = true
    // 3
    adjustsImageWhenAncestorFocused = false
  }

  // 4
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // 1
  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    // 2
    if context.nextFocusedView == self {
      // 3
      coordinator.addCoordinatedAnimations({ () -> Void in
        self.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
      }, completion: nil)
      // 4
    } else if context.previouslyFocusedView == self {
      coordinator.addCoordinatedAnimations({ () -> Void in
        self.transform = CGAffineTransform.identity
      }, completion: nil)
    }
  }
}
