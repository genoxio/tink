import UIKit
import Capacitor

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = CAPBridgeViewController()
        window?.makeKeyAndVisible()

        SceneDelegateProxy.shared.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if url.scheme == "taxoapp" && url.host == "callback" {
                NotificationCenter.default.post(
                    name: Notification.Name("Tink.Link.Callback"),
                    object: nil,
                    userInfo: ["url": url]
                )
            }
        }

        SceneDelegateProxy.shared.scene(scene, openURLContexts: URLContexts)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let url = userActivity.webpageURL {
            if url.scheme == "taxoapp" && url.host == "callback" {
                NotificationCenter.default.post(
                    name: Notification.Name("Tink.Link.Callback"),
                    object: nil,
                    userInfo: ["url": url]
                )
            }
        }

        SceneDelegateProxy.shared.scene(scene, continue: userActivity)
    }
}
