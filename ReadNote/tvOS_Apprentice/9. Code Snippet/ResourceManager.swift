
import Foundation

let progressObservingContext: UnsafeMutableRawPointer? = nil

class ResourceManager {
  static let shared = ResourceManager()

  func requestVideoWith(tag: String,
    progressObserver: NSObject?,
    onSuccess: @escaping () -> Void,
    onFailure: @escaping (Error) -> Void) -> NSBundleResourceRequest {

      let videoRequest = NSBundleResourceRequest(tags: [tag])
      videoRequest.loadingPriority
        = NSBundleResourceRequestLoadingPriorityUrgent

      videoRequest.beginAccessingResources { error in
        OperationQueue.main.addOperation {
          if let progressObserver = progressObserver {
            videoRequest.progress.removeObserver(progressObserver,
              forKeyPath: "fractionCompleted")
          }

          if let error = error {
            onFailure(error)
          } else {
            onSuccess()
          }
        }
      }

      if let progressObserver = progressObserver {
        videoRequest.progress.addObserver(progressObserver,
          forKeyPath: "fractionCompleted",
          options: [.new, .initial],
          context: progressObservingContext)
      }

      return videoRequest
  }

  func requestCategoryWith(tag: String) -> NSBundleResourceRequest {
    let currentCategoryBundleRequest = NSBundleResourceRequest(tags: [tag])
    currentCategoryBundleRequest.loadingPriority = 0.5
    currentCategoryBundleRequest
      .beginAccessingResources { error in }
    return currentCategoryBundleRequest
  }
}



// 使用方式 
currentVideoResourceRequest?.progress.cancel()
 currentVideoResourceRequest?.endAccessingResources()

currentVideoResourceRequest = ResourceManager.shared
    .requestVideoWith(tag: video.videoName, progressObserver: self,
    onSuccess: { [weak self] in
        self?.progressView.isHidden = true
        guard let currentVideoResourceRequest =
        self?.currentVideoResourceRequest else { return }
        video.videoURL = currentVideoResourceRequest.bundle
        .url(forResource: video.videoName, withExtension: "mp4")
        let viewController = PlayVideoViewController
        .instanceWith(video: video, videoCategory: videoCategory)
        self?.navigationController?.pushViewController(viewController,
        animated: true)
    },
    onFailure: { [weak self] error in
        self?.progressView.isHidden = true
        self?.handleDownloadingError(error as NSError)
    }
)


func handleDownloadingError(_ error: NSError) {
switch error.code{
case NSBundleOnDemandResourceOutOfSpaceError:
    let message = "You don't have enough storage left to download this resource."
    let alert = UIAlertController(title: "Not Enough Space",
    message: message,
    preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK",
    style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
case NSBundleOnDemandResourceExceededMaximumSizeError:
    assert(false, "The bundle resource was too large.")
case NSBundleOnDemandResourceInvalidTagError:
    assert(false, "The requested tag(s) (\(currentVideoResourceRequest?.tags ?? [""])) does not exist.")
default:
    assert(false, error.description)
}
}

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if context == progressObservingContext
      && keyPath == "fractionCompleted" {

      OperationQueue.main.addOperation {
        self.progressView.progress
          = Float((object as! Progress).fractionCompleted)
      }
    }
  }
