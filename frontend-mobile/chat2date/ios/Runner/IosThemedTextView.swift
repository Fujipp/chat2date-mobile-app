import Flutter
import UIKit

final class IosThemedTextViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    IosThemedTextViewPlatformView(
      frame: frame,
      viewId: viewId,
      args: args as? [String: Any] ?? [:],
      messenger: messenger
    )
  }
}

final class IosThemedTextViewPlatformView: NSObject, FlutterPlatformView, UITextViewDelegate {
  private let containerView: UIView
  private let textView: UITextView
  private let placeholderLabel: UILabel
  private let channel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewId: Int64,
    args: [String: Any],
    messenger: FlutterBinaryMessenger
  ) {
    containerView = UIView(frame: frame)
    textView = UITextView(frame: frame)
    placeholderLabel = UILabel()
    channel = FlutterMethodChannel(
      name: "chat2date/ios-themed-text-view/\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    let text = args["text"] as? String ?? ""
    let hintText = args["hintText"] as? String ?? ""
    let fontSize = args["fontSize"] as? CGFloat ?? 14
    let fontFamily = args["fontFamily"] as? String ?? "Inter"
    let textColor = UIColor(argb: args["textColor"] as? NSNumber)
    let hintColor = UIColor(argb: args["hintColor"] as? NSNumber)
    let cursorColor = UIColor(argb: args["cursorColor"] as? NSNumber)
    let selectionColor = UIColor(argb: args["selectionColor"] as? NSNumber)

    containerView.backgroundColor = .clear

    textView.delegate = self
    textView.backgroundColor = .clear
    textView.text = text
    textView.textColor = textColor
    textView.tintColor = cursorColor
    textView.autocorrectionType = .yes
    textView.spellCheckingType = .yes
    textView.smartQuotesType = .no
    textView.smartDashesType = .no
    textView.smartInsertDeleteType = .no
    textView.keyboardDismissMode = .interactive
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    textView.showsVerticalScrollIndicator = false
    textView.showsHorizontalScrollIndicator = false
    textView.font = UIFont(name: fontFamily, size: fontSize) ?? .systemFont(ofSize: fontSize)
    textView.markedTextStyle = [
      .backgroundColor: selectionColor,
      .foregroundColor: textColor
    ]

    placeholderLabel.text = hintText
    placeholderLabel.textColor = hintColor
    placeholderLabel.font = textView.font
    placeholderLabel.backgroundColor = .clear

    textView.translatesAutoresizingMaskIntoConstraints = false
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(textView)
    containerView.addSubview(placeholderLabel)

    NSLayoutConstraint.activate([
      textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      textView.topAnchor.constraint(equalTo: containerView.topAnchor),
      textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      placeholderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      placeholderLabel.topAnchor.constraint(equalTo: containerView.topAnchor)
    ])

    placeholderLabel.isHidden = !text.isEmpty

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }
      switch call.method {
      case "setText":
        let nextText = call.arguments as? String ?? ""
        if self.textView.text != nextText {
          self.textView.text = nextText
          self.placeholderLabel.isHidden = !nextText.isEmpty
        }
        result(nil)
      case "requestFocus":
        self.textView.becomeFirstResponder()
        result(nil)
      case "clearFocus":
        self.textView.resignFirstResponder()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView {
    containerView
  }

  func textViewDidChange(_ textView: UITextView) {
    placeholderLabel.isHidden = !textView.text.isEmpty
    channel.invokeMethod("textChanged", arguments: textView.text ?? "")
  }

  func textViewDidBeginEditing(_ textView: UITextView) {
    channel.invokeMethod("focusChanged", arguments: true)
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    channel.invokeMethod("focusChanged", arguments: false)
  }
}

private extension UIColor {
  convenience init(argb: NSNumber?) {
    let raw = argb?.uint32Value ?? 0xFF000000
    let alpha = CGFloat((raw >> 24) & 0xFF) / 255.0
    let red = CGFloat((raw >> 16) & 0xFF) / 255.0
    let green = CGFloat((raw >> 8) & 0xFF) / 255.0
    let blue = CGFloat(raw & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
