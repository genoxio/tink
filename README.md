# tink

Capacitor plugin for iOS to authenticate with [Tink](https://tink.com/) to retrieve Transaction data.
Currently this supports the one-time access flow to a bank account 

## Install

```bash
npm install tink
```

```bash
npx cap sync
```

### Android flow

Android is a noop, Tink integration is done using @capawesome/capacitor-in-app-browser using .openInWebView() and using the web instructions

## iOS flow

This first pass follows the official Tink iOS integration [pattern](https://docs.tink.com/resources/transactions/integrate-transactions-in-ios-apps): build a Tink Link URL, open it in a WKWebView, and handle app redirect callbacks through the native app lifecycle.

```ts
import { Tink } from 'tink';

const result = await Tink.openTink({
  clientId: 'YOUR_CLIENT_ID',
  market: 'SE',
  locale: 'en_US',
  redirectUri: 'example://callback',
  appUri: 'example://open',
  autoRedirectMobile: true,
});

if (result.success && result.code) {
  // exchange code for a user access token
}
```

For the app-level callback, add the same deep-link handling pattern described in Tink's iOS guide:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    let handled = Tink.shared.handleOpenURL(url)
    return handled["success"] as? Bool ?? false || true
}
```

Or post a notification:

```swift
NotificationCenter.default.post(name: .tinkLinkCallback, object: nil, userInfo: ["url": url])
```

## API

```typescript
openTink(options: {
  clientId: string;
  market: string;
  locale?: string;
  redirectUri: string;
  appUri: string;
  autoRedirectMobile?: boolean;
  state?: string;
  scope?: string;
  additionalParameters?: Record<string, string>;
}) => Promise<{
  success: boolean;
  code?: string;
  error?: string;
  userCancelled?: boolean;
  url?: string;
}>;
```
