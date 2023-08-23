// load image resource 


import JavaScriptCore

@objc protocol ResourceLoaderExport: JSExport {
  static func create() -> ResourceLoaderExport
  func loadBundleResource(_ name: String) -> String
  func urlForResource(_ name: String) -> String
}

@objc class ResourceLoader: NSObject, ResourceLoaderExport {
  
  static func create() -> ResourceLoaderExport {
    return ResourceLoader()
  }
  
  func loadBundleResource(_ name: String) -> String {
    let path = Bundle.main.path(forResource: name, ofType: nil)
    do {
      return try String(contentsOfFile: path!,
        encoding: String.Encoding.utf8)
    } catch {
      print("There was a problem")
      return ""
    }
  }
  
  func urlForResource(_ name: String) -> String {
    return Bundle.main.url(forResource: name, withExtension: nil)!.absoluteString
  }
}





// native ----> TVML element 

import TVMLKit

private let CalendarElementName = "calendar"
private let CalendarTopColorStyleName = "calendar-top-color"
private let CalendarBottomColorStyleName = "calendar-bottom-color"

// 1
private class ExtendedTVInterfaceCreator: NSObject, TVInterfaceCreating {
  // 2
  fileprivate func resourceURL(name resourceName: String)
    -> URL? {
      // 3
      return Bundle.main
        .url(forResource: resourceName, withExtension: "png")
  }

  // 1
  fileprivate func makeView(element: TVViewElement,
                            existingView: UIView?) -> UIView? {
    // 2
    guard element.name == CalendarElementName else {
      return .none
    }
    // 3
    let width = Int(element.attributes?["width"] ?? "") ?? 100
    let height = Int(element.attributes?["height"] ?? "") ?? 100
    let calendar = CalendarView(frame:
      CGRect(x: 0, y: 0, width: width, height: height))

    calendar.dateString = element.attributes?["day"]
    calendar.monthString = element.attributes?["month"]

    if let topColor = element.style?
      .value(propertyName: CalendarTopColorStyleName)
      as? TVColor {
      calendar.topColor = topColor.color
    }
    if let bottomColor = element.style?
      .value(propertyName: CalendarBottomColorStyleName)
      as? TVColor {
      calendar.bottomColor = bottomColor.color
    }

    return calendar
  }
}

private func registerNewCreatorWithInterfaceFactory() {
  // 1
  let factory = TVInterfaceFactory.shared()
  // 2
  let newCreator = ExtendedTVInterfaceCreator()

  // 3
  factory.extendedInterfaceCreator = newCreator
}

func registerTVMLExtensions() {
  registerNewCreatorWithInterfaceFactory()
  registerNewTVMLElementWithElementFactory()
  registerNewStylesWithStyleFactory()
}

private func registerNewTVMLElementWithElementFactory() {
  TVElementFactory.registerViewElementClass(TVViewElement.self,
                                            elementName: CalendarElementName)
}

private func registerNewStylesWithStyleFactory() {
  TVStyleFactory.registerStyleName(CalendarTopColorStyleName,
                                   type: .color, inherited: false)
  TVStyleFactory.registerStyleName(CalendarBottomColorStyleName,
                                   type: .color, inherited: false)
}




// 