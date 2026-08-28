import Foundation
import SafariServices
import UIKit
import WebKit
import os

public struct TinkLinkOptions {
    public let clientId: String
    public let market: String
    public let locale: String
    public let redirectUri: String
    public let appUri: String
    public let autoRedirectMobile: Bool
    public let state: String?
    public let scope: String?
    public let additionalParameters: [String: String]

    public static func from(capacitorOptions: [String: Any]) -> TinkLinkOptions {
        let clientId = capacitorOptions["clientId"] as? String ?? ""
        let market = capacitorOptions["market"] as? String ?? "SE"
        let locale = capacitorOptions["locale"] as? String ?? "en_US"
        let redirectUri = capacitorOptions["redirectUri"] as? String ?? ""
        let appUri = capacitorOptions["appUri"] as? String ?? ""
        let autoRedirectMobile = capacitorOptions["autoRedirectMobile"] as? Bool ?? true
        let state = capacitorOptions["state"] as? String
        let scope = capacitorOptions["scope"] as? String
        let additionalParameters = (capacitorOptions["additionalParameters"] as? [String: String]) ?? [:]

        return TinkLinkOptions(
            clientId: clientId,
            market: market,
            locale: locale,
            redirectUri: redirectUri,
            appUri: appUri,
            autoRedirectMobile: autoRedirectMobile,
            state: state,
            scope: scope,
            additionalParameters: additionalParameters
        )
    }
}

extension Notification.Name {
    static let tinkLinkOpen = Notification.Name("Tink.Link.Open")
    static let tinkLinkCallback = Notification.Name("Tink.Link.Callback")
}

@objc public class Tink: NSObject {
    public static let shared = Tink()
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.tink.plugin",
        category: "Tink"
    )

    private var activeCompletion: (([String: Any]) -> Void)?
    private var activeController: LinkViewController?

    override public init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLinkOpenNotification(_:)),
            name: .tinkLinkOpen,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLinkCallbackNotification(_:)),
            name: .tinkLinkCallback,
            object: nil
        )
    }

    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }

    public func openTink(options: TinkLinkOptions, from viewController: UIViewController, completion: @escaping ([String: Any]) -> Void) {
        let url = buildURL(from: options)

        DispatchQueue.main.async {
            self.activeCompletion = completion
            let controller = LinkViewController(url: url, completion: completion)
            self.activeController = controller
            viewController.present(controller, animated: true)
        }
    }

    @objc public func handleOpenURL(_ url: URL) -> [String: Any] {
        Tink.logger.info("Handling incoming URL: \(url.absoluteString, privacy: .public)")
        guard hasResultParams(url) else {
            Tink.logger.info("Ignoring URL without result params (expected code or error)")
            return [
                "success": false,
                "error": "IGNORED_NON_RESULT_URL",
                "url": url.absoluteString
            ]
        }

        let result = parseResponse(from: url)
        let success = (result["success"] as? Bool) ?? false
        let errorValue = (result["error"] as? String) ?? ""
        Tink.logger.info("Parsed callback result success=\(success, privacy: .public) error=\(errorValue, privacy: .public)")

        DispatchQueue.main.async {
            if let completion = self.activeCompletion {
                completion(result)
                self.activeCompletion = nil
            }

            self.activeController?.dismiss(animated: true)
            self.activeController = nil
        }

        return result
    }

    @objc public func dismissTink(from presentingViewController: UIViewController? = nil) -> [String: Any] {
        var result: [String: Any] = ["success": false]

        func dismissOnMainThread() {
//            if let controller = self.activeController {
//                controller.dismiss(animated: true)
//                self.activeController = nil
//                self.activeCompletion = nil
//                result["success"] = true
//                return
//            }

            if let presented = presentingViewController?.presentedViewController,
               presented is LinkViewController {
                presented.dismiss(animated: true)
                self.activeController = nil
                self.activeCompletion = nil
                result["success"] = true
            }
        }

        if Thread.isMainThread {
            dismissOnMainThread()
        } else {
            DispatchQueue.main.sync {
                dismissOnMainThread()
            }
        }

        return result
    }

    private func buildURL(from options: TinkLinkOptions) -> URL {
        let baseURL = URL(string: "https://link.tink.com/1.0/transactions/connect-accounts")!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!

        var items: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: options.clientId),
            URLQueryItem(name: "market", value: options.market),
            URLQueryItem(name: "locale", value: options.locale),
            URLQueryItem(name: "redirect_uri", value: options.redirectUri),
            URLQueryItem(name: "app_uri", value: options.appUri),
            URLQueryItem(name: "auto_redirect_mobile", value: options.autoRedirectMobile ? "true" : "false")
        ]

        if let state = options.state {
            items.append(URLQueryItem(name: "state", value: state))
        }

        if let scope = options.scope {
            items.append(URLQueryItem(name: "scope", value: scope))
        }

        for (key, value) in options.additionalParameters {
            items.append(URLQueryItem(name: key, value: value))
        }

        components.queryItems = items
        return components.url!
    }

    private func hasResultParams(_ url: URL) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        return queryItems.contains(where: { $0.name == "code" || $0.name == "error" })
    }

    private func parseResponse(from url: URL) -> [String: Any] {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        let code = components?.queryItems?.first(where: { $0.name == "code" })?.value
        let error = components?.queryItems?.first(where: { $0.name == "error" })?.value

        let queryDescription = queryItems
            .map { "\($0.name)=\($0.value ?? "")" }
            .joined(separator: "&")

        Tink.logger.info("parseResponse URL=\(url.absoluteString, privacy: .public)")
        Tink.logger.info("parseResponse query=\(queryDescription, privacy: .public)")

        if let code = code {
            Tink.logger.info("parseResponse found code (length=\(code.count, privacy: .public))")
            return [
                "success": true,
                "code": code,
                "url": url.absoluteString
            ]
        }
        
        let errorValue = error ?? "UNKNOWN_ERROR"
        return [
            "success": false,
            "error": errorValue,
            "userCancelled": errorValue == "USER_CANCELLED",
            "url": url.absoluteString
        ]
    }

    @objc private func handleLinkOpenNotification(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else { return }
        _ = handleOpenURL(url)
    }

    @objc private func handleLinkCallbackNotification(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else { return }
        _ = handleOpenURL(url)
    }
}

final class LinkViewController: UIViewController {
    private let webView = WKWebView()
    private let url: URL
    private let completion: ([String: Any]) -> Void
    private var safariViewController: SFSafariViewController?

    init(url: URL, completion: @escaping ([String: Any]) -> Void) {
        self.url = url
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        webView.load(URLRequest(url: url))
    }
}

extension LinkViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if url.host == "link.tink.com", navigationAction.targetFrame != nil {
            decisionHandler(.allow)
            return
        }

        if ["http", "https"].contains(url.scheme) {
            UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { [weak self] success in
                guard !success else { return }
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.modalPresentationStyle = .formSheet
                self?.present(safariViewController, animated: true)
                self?.safariViewController = safariViewController
            }
            decisionHandler(.cancel)
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        decisionHandler(.cancel)
    }
}
