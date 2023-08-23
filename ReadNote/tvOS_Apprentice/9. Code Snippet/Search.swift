 private func addSearchController() {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let resultsController = storyBoard.instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsController
    let searchController = UISearchController(searchResultsController: resultsController)
    searchController.searchResultsUpdater = resultsController
    searchController.hidesNavigationBarDuringPresentation = true
    searchController.obscuresBackgroundDuringPresentation = true

    let searchPlaceholderText = NSLocalizedString("Enter movie title", comment: "")
    searchController.searchBar.placeholder = searchPlaceholderText
    searchController.searchBar.returnKeyType = .search

    let searchContainer = UISearchContainerViewController(searchController: searchController)
    searchContainer.title = "Search"

    let nav = UINavigationController(rootViewController: searchContainer)
    (window?.rootViewController as! UITabBarController).viewControllers?.append(nav)
  }