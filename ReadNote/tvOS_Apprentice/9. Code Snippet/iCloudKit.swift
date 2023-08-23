
protocol Movie {
  var title: String { get }
  var poster: String? { get }
  var synopsis: String? { get }
  var year: Int? { get }
  var record: CKRecord { get }
}

extension Movie {
  var record: CKRecord {
    let record = CKRecord(recordType: MovieRecordType)
    record.title = title
    record.synopsis = synopsis
    record.year = year

    if let posterURL = poster {
      let newURL = try! FileManager.default
        .url(for: .cachesDirectory,
             in: .userDomainMask,
             appropriateFor: nil,
             create: true)
      let fileURL = newURL.appendingPathComponent(NSUUID().uuidString)
      let posterData = NSData(contentsOf: URL(string: posterURL)!)
      posterData?.write(to: fileURL, atomically: true)
      record.poster = fileURL.absoluteString
    }

    return record
  }
}

extension CKRecord: Movie {
  subscript(key: MovieFields) -> CKRecordValue? {
    get {
      return self[key.rawValue]
    }
    set {
      self[key.rawValue] = newValue
    }
  }

  var record: CKRecord { return self }

  var title: String {
    get { return self[.title] as! String }
    set { self[.title] = newValue as NSString}
  }

  var year: Int? {
    get { return self[.year] as? Int }
    set { self[.year] = newValue != nil ? NSNumber(value: newValue!) : nil  }
  }

  var averageRating: Double? {
    get { return self[.averageRating] as? Double }
    set { self[.averageRating] = newValue != nil ? NSNumber(value: newValue!) : nil }
  }

  var numberOfRatings: Int {
    get { return self[.numberOfRatings] as? Int ?? 0 }
    set { self[.numberOfRatings] = NSNumber(value: newValue) }
  }

  var synopsis: String? {
    get { return self[.synopsis] as? String }
    set { self[.synopsis] = newValue != nil ? newValue! as NSString : nil }
  }

  var poster: String? {
    get {
      if let asset = self[.poster] as? CKAsset {
        return asset.fileURL.path
      }
      return nil
    }
    set {
      guard let path = newValue else {
        self[.poster] = nil
        return
      }
      self[.poster] = CKAsset(fileURL: URL(string: path)!)
    }
  }
}




class CloudKitManager {
    var container: CKContainer { return CKContainer.default() }
    var publicDatabase: CKDatabase { return container.publicCloudDatabase }
    var privateDatabase: CKDatabase { return container.privateCloudDatabase }

    init() {
    NotificationCenter.default.addObserver(
      forName: .CKAccountChanged, object: nil, queue: nil)
    { [weak self] _ in
      DispatchQueue.main.async {
        NotificationCenter.default
          .post(name: MyMovieNotification, object: self)
      }
    }
  }


  func checkAccountStatus(_ completion:
    @escaping (CKAccountStatus) -> Void) {
    container.accountStatus { status, error in
      if error != nil {
        showError(error, inController: nil)
      }
      DispatchQueue.main.async {
        completion(status)
      }
    }
  }

  func fetchUserId(_ completion:
    @escaping (CKRecordID) -> Void) {
    container.fetchUserRecordID { recordId, error in
      if let id = recordId {
        completion(id)
      } else {
        showError(error, inController: nil)
      }
    }
  }

 func withUserRecord(_ completion: @escaping (CKRecord) -> Void) {
    fetchUserId { userId in
      self.fetchUserRecord(userId, completion: completion)
    }
  }

  private func fetchUserRecord(_ userId: CKRecordID,
                               completion: @escaping (CKRecord) -> Void) {
    privateDatabase.fetch(withRecordID: userId) { record, error in
      if let user = record {
        completion(user)
      } else {
        showError(error, inController: nil)
      }
    }
  }

}



// 增删改查

// MARK: - Adding and Finding a Movie
extension Model {
  func createNewMovie(_ movie: Movie,
                      handler: @escaping (CKRecord) -> Void) {
    let movieRecord = movie.record
    publicDatabase.save(movieRecord) { record, error in
      guard let record = record, error == nil else {
        showError(error, inController: nil)
        return
      }
      handler(record)
    }
  }

  func movieForTitle(_ title: String,
                     completion: @escaping (CKRecord?, Error?) -> Void) {
    let titlePredicate = NSPredicate(format: "title == %@", title)
    let query = CKQuery(recordType: MovieRecordType,
                        predicate: titlePredicate)
    publicDatabase.perform(query, inZoneWith: nil) { records, error in
      guard let records = records, !records.isEmpty &&
        error == nil else {
          completion(nil, error)
          return
      }
      let record = records[0]
      completion(record, nil)
    }
  }

  func withMovieRecord(_ movie: Movie,
                       completion: @escaping (CKRecord) -> Void) {

    if let movie = movie as? CKRecord {
      publicDatabase.fetch(withRecordID: movie.recordID, completionHandler: { record, _ in
        if let newRecord = record {
          completion(newRecord)
        } else {
          completion(movie)
        }
      })
      return
    }

    movieForTitle(movie.title) { record, error in
      if let record = record {
        completion(record)
        return
      }
      if let error = error as NSError? {
        if error.domain == CKErrorDomain &&
          error.code == CKError.Code.unknownItem.rawValue {
          // This is the first time before any movies are created (probably not a good idea in prod)
          self.createNewMovie(movie) { record in
            completion(record)
          }
        } else {
          showError(error, inController: nil)
        }
      } else {
        self.createNewMovie(movie) { record in
          completion(record)
        }
      }
    }
  }
}

// MARK: - My Movies
extension Model {

  func fetchMovies(_ completion:
    @escaping ([CKRecord]?, Error?) -> Void) {
    withUserRecord { user in

      guard let movieReferences = user["movies"] as? [CKReference],
        !movieReferences.isEmpty else { return }

      let fetch = CKFetchRecordsOperation(
        recordIDs: movieReferences.map { $0.recordID })
      fetch.desiredKeys = [MovieFields.title.rawValue,
                           MovieFields.poster.rawValue]

      fetch.fetchRecordsCompletionBlock = { records, error in
        guard let movieRecords = records else {
          showError(error, inController: nil)
          return
        }

        let fetchedMovies: [CKRecord] = Array(movieRecords.values)
        let sortedMovies = fetchedMovies.sorted {
          return ($0.title as NSString)
            .caseInsensitiveCompare($1.title) == .orderedAscending
        }
        DispatchQueue.main.async {
          completion(sortedMovies, nil)
        }
      }
      self.publicDatabase.add(fetch)
    }
  }

  func addToMyMovies(_ movie: Movie) {
    withMovieRecord(movie) { movieRecord in
      self.addRecordToMyMovies(movieRecord)
    }
  }

  private func addRecordToMyMovies(_ movieRecord: CKRecord) {
    withUserRecord { user in
      var movies = user["movies"] as? [CKReference]
      if movies == nil {
        movies = []
      }
      let movieReference = CKReference(record: movieRecord,
                                       action: .none)
      movies?.append(movieReference)
      user["movies"] = movies as NSArray?
      self.privateDatabase.save(user) { _, error in
        if error == nil {
          // 6
          DispatchQueue.main.async {
            NotificationCenter.default.post(
              name: MyMovieNotification,
              object: self)
          }
        } else {
          showError(error, inController: nil)
        }
      }
    }
  }

  // This will remove the move from "my movies". Removing from "My Queue" is left as an exercise to the reader.
  // Hint: It's mostly the same as this. Check out `MovieViewController.swift` to add the UI for it.
  func removeFromMyMovies(_ movie: Movie) {
    withMovieRecord(movie) { movieRecord in
      self.withUserRecord { user in
        guard var myMovies = user["movies"] as? [CKReference] else { return } // no movies, so skip
        let movieReference = CKReference(record: movieRecord, action: .none)
        guard let movieIndex = myMovies.index(of: movieReference) else { return } // not in my movies
        myMovies.remove(at: movieIndex)
        user["movies"] = myMovies as NSArray?
        self.privateDatabase.save(user) { _, error in
          if error == nil {
            DispatchQueue.main.async {
              NotificationCenter.default.post(name: MyMovieNotification, object: self)
            }
          } else {
            showError(error as NSError?, inController: nil)
          }
        }
      }
    }
  }

}

// MARK: - My Queue
extension Model {
  // The `My Queue` is exactly the same as `My Movies` except in a different field on the user record.
  // The main difference is that the queue can be re-ordered by the user holding down on a movie in the queue and moving it left or right

  func fetchQueue(completion: @escaping (_ movies: [CKRecord]?, _ error: NSError?) -> Void) {
    withUserRecord { user in
      if let movieReferences = user["queue"] as? [CKReference] {
        let queueIds = movieReferences.map { $0.recordID }
        let fetch = CKFetchRecordsOperation(recordIDs: queueIds)
        fetch.database = self.publicDatabase
        fetch.fetchRecordsCompletionBlock = { records, error in
          if let movieRecords = records {
            var queueMovies = [CKRecord]()
            for recordId in queueIds {
              queueMovies.append(movieRecords[recordId]!)
            }
            DispatchQueue.main.async {
              completion(queueMovies, nil)
            }
          } else {
            showError(error as NSError?, inController: nil)
          }
        }
        fetch.start()
      }
    }
  }

  func addToMyQueue(_ movie: Movie) {
    withMovieRecord(movie) { movieRecord in
      self.addRecordToMyQueue(movieRecord)
    }
  }

  private func addRecordToMyQueue(_ movieRecord: CKRecord) {
    withUserRecord { user in
      var movies = user["queue"] as? [CKReference]
      if movies == nil {
        movies = [CKReference]()
      }
      let movieReference = CKReference(record: movieRecord, action: .none)
      movies?.append(movieReference)
      user["queue"] = movies as NSArray?
      self.privateDatabase.save(user, completionHandler: { _, error in
        if error == nil {
          DispatchQueue.main.async {
            NotificationCenter.default.post(name: MyQueueNotification, object: self)
          }
        } else {
          showError(error as NSError?, inController: nil)
        }
      })
    }
  }

  func updateQueue(_ newQueue: [CKRecord]) {
    withUserRecord { user in
      let queueRefs = newQueue.map { return CKReference(record: $0, action: .none)}
      user["queue"] = queueRefs as NSArray?
      self.privateDatabase.save(user, completionHandler: { _, error in
        if error == nil {
           DispatchQueue.main.async {
            NotificationCenter.default.post(name: MyQueueNotification, object: self)
          }
        } else {
          showError(error as NSError?, inController: nil)
        }
      })
    }
  }
}

// MARK: - Recommendations
extension Model {

  func getTopTen(_ completion:
    @escaping ([CKRecord], Error?) -> Void) {
    // 1
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: MovieRecordType,
                        predicate: predicate)
    // 2
    let ratingSort = NSSortDescriptor(key:
      MovieFields.averageRating.rawValue, ascending: false)
    query.sortDescriptors = [ratingSort]
    // 3
    let queryOperation = CKQueryOperation(query: query)
    // 4
    queryOperation.resultsLimit = 10
    // 5
    var results = [CKRecord]()
    queryOperation.recordFetchedBlock = { record in
      results.append(record)
    }
    // 6
    queryOperation.queryCompletionBlock = { cursor, queryError in
      // 1
      guard let error = queryError as NSError?,
        self.isRetriableCKError(error) else {
          DispatchQueue.main.async {
            completion(results, queryError)
          }
          return
      }

      // 2
      let userInfo = error.userInfo
      guard let retryAfter = userInfo[CKErrorRetryAfterKey]
        as? NSNumber else {
          DispatchQueue.main.async {
            completion(results, error)
          }
          return
      }

      // 3
      let delayTime = DispatchTime.now() + retryAfter.doubleValue * Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: delayTime) {
        self.getTopTen(completion)
      }
    }
    // 7
    publicDatabase.add(queryOperation)
  }

}

// MARK: - Rating
extension Model {

  // Ratings are in the value of 1 to 5 stars. If the rating is zero, then it ratins is unset and it should be deleted
  func setRating(_ movie: Movie, rating: Int) {
    fetchUserId { userId in
      self.withMovieRecord(movie) { movieRecord in
        let movieRef = CKReference(record: movieRecord,
                                   action: .deleteSelf)
        let predicate = NSPredicate(format:
          "movie == %@ AND creatorUserRecordID == %@",
                                    movieRef, userId)
        let query = CKQuery(recordType: RatingRecordType,
                            predicate: predicate)
        self.publicDatabase.perform(query, inZoneWith: nil)
        { records, error in
          guard error == nil && records != nil &&
            !records!.isEmpty else {
              if error == nil ||
                ((error! as NSError).domain == CKErrorDomain &&
                  (error! as NSError).code ==
                  CKError.unknownItem.rawValue) {
                self.makeNewRating(rating, movieRef: movieRef,
                                   movieRecord: movieRecord)
              } else {
                showError(error, inController: nil)
              }
              return
          }
          self.updateRating(records![0],
                            rating: rating,
                            movie: movieRecord)
        }
      }
    }
  }

  private func makeNewRating(_ rating: Int, movieRef: CKReference,
                             movieRecord: CKRecord) {
    // 1
    guard rating > 0 else { return }

    // 2
    let ratingRecord = CKRecord(recordType: RatingRecordType)
    ratingRecord.movieRef = movieRef
    ratingRecord.rating = Double(rating)

    // 3
    let averageRating = movieRecord.averageRating ?? 0
    movieRecord.averageRating = ((averageRating *
      Double(movieRecord.numberOfRatings)) + Double(rating)) /
      Double(movieRecord.numberOfRatings + 1)
    movieRecord.numberOfRatings += 1

    // 4
    let modifyOperation = CKModifyRecordsOperation(
      recordsToSave: [ratingRecord, movieRecord],
      recordIDsToDelete: nil)
    modifyOperation.savePolicy = .ifServerRecordUnchanged
    modifyOperation.modifyRecordsCompletionBlock = {
      savedRecords, deletedRecords, error in
      if let error = error {
        showError(error, inController: nil)
      }
    }

    // 5
    publicDatabase.add(modifyOperation)
  }

  private func updateRating(_ ratingRecord: CKRecord, rating: Int,
                            movie: CKRecord) {
    // 1
    let lastRating = ratingRecord.rating!
    var modifyOperation: CKModifyRecordsOperation?
    if rating > 0 {

      // 2
      ratingRecord.rating = Double(rating)
      let averageRating = movie.averageRating ?? 0
      movie.averageRating = ((averageRating *
        Double(movie.numberOfRatings)) - lastRating +
        Double(rating)) / Double(movie.numberOfRatings)

      // 3
      modifyOperation = CKModifyRecordsOperation(
        recordsToSave: [ratingRecord, movie],
        recordIDsToDelete: nil)
    } else {
      // 4
      let averageRating = movie.averageRating ?? lastRating
      movie.averageRating = ((averageRating *
        Double(movie.numberOfRatings)) - lastRating) /
        Double(movie.numberOfRatings - 1)
      movie.numberOfRatings -= 1

      // 5
      modifyOperation = CKModifyRecordsOperation(
        recordsToSave: [movie],
        recordIDsToDelete: [ratingRecord.recordID])
    }

    // 6
    modifyOperation?.savePolicy = .ifServerRecordUnchanged
    modifyOperation?.modifyRecordsCompletionBlock = {
      savedRecords, deletedRecords, error in
      guard let error = error as NSError? else { return }

      // 1
      guard error.domain == CKErrorDomain &&
        error.code == CKError.Code.partialFailure.rawValue else {
          showError(error, inController: nil)
          return
      }

      // 2
      guard let partialErrors = error
        .userInfo[CKPartialErrorsByItemIDKey]
        as? NSDictionary else { return }
      var updatedMovie = movie
      var updatedRating = ratingRecord

      // 3
      if let movieError = partialErrors[movie.recordID] as? NSError,
        let serverRecord =
        movieError.userInfo[CKRecordChangedErrorServerRecordKey] as?
        CKRecord, movieError.code ==
        CKError.Code.serverRecordChanged.rawValue {
        updatedMovie = serverRecord
      }

      // 4
      if let ratingError = partialErrors[ratingRecord.recordID]
        as? NSError,
        let serverRecord =
        ratingError.userInfo[CKRecordChangedErrorServerRecordKey]
          as? CKRecord, ratingError.code ==
        CKError.Code.serverRecordChanged.rawValue {
        updatedRating = serverRecord
      }

      // 5
      self.updateRating(updatedRating,
                        rating: rating,
                        movie: updatedMovie)
    }

    publicDatabase.add(modifyOperation!)
  }

  func isRetriableCKError(_ error: NSError?) -> Bool {
    guard let error = error, let code = CKError.Code(rawValue: error.code), error.domain == CKErrorDomain else { return false }
    switch code {
    case .serviceUnavailable, .requestRateLimited, .zoneBusy, .networkFailure:
      return true
    default:
      return false
    }
  }
}
