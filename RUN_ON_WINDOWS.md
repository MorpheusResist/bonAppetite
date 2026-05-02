# How To Run WasteLess Kitchen On Windows

You now have two versions in this folder:

1. `WasteLessKitchen.xcodeproj`
   - Native SwiftUI iOS project.
   - Requires macOS + Xcode.
   - Keep this as the native iOS architecture portfolio artifact.

2. `WasteLessKitchenExpo`
   - Expo/React Native version.
   - Runs from Windows.
   - Use this for your actual demo right now.

## Best Option Now: Run In Your Windows Browser

This avoids iPhone QR code problems completely.

1. Open PowerShell.

2. Go to the Expo app folder:

```powershell
cd "C:\Users\apbry\OneDrive\Documents\New project\building daily apps\WasteLessKitchen\WasteLessKitchenExpo"
```

3. Start the browser version:

```powershell
npm.cmd run web
```

4. Expo should open the app in your browser automatically.

If it does not open automatically, look for a local URL in the terminal, usually:

```text
http://localhost:8081
```

Open that URL in Chrome or Edge.

## Optional: Run On Phone With Expo Go

The project is now upgraded to Expo SDK 54, which matches the current Expo Go app shown on iPhone.

1. Install Expo Go on your phone:
   - iPhone: App Store -> Expo Go
   - Android: Play Store -> Expo Go

2. Open PowerShell.

3. Go to the Expo app folder:

```powershell
cd "C:\Users\apbry\OneDrive\Documents\New project\building daily apps\WasteLessKitchen\WasteLessKitchenExpo"
```

4. Start the app:

```powershell
npm.cmd start
```

Use `npm.cmd`, not `npm`, because this Windows machine blocks PowerShell npm scripts.

5. A QR code will appear.

6. Scan the QR code:
   - iPhone: open Expo Go and use its scanner if the Camera app says "no usable data found".
   - Android: open Expo Go and scan the QR code.

7. The app should open on your phone through Expo Go.

## If The QR Code Does Not Work

Make sure your phone and laptop are on the same Wi-Fi.

Then try:

```powershell
npx.cmd expo start --tunnel
```

Tunnel mode is slower, but it usually works across difficult Wi-Fi networks.

If mobile still fights you, use the browser version. It is good enough for screenshots, GitHub, and a portfolio demo.

If Expo still shows an SDK mismatch, stop the terminal with `Ctrl+C` and restart with a clean cache:

```powershell
npx.cmd expo start --clear
```

Then scan the new QR code from inside Expo Go.

## What This Expo App Includes

- Home dashboard
- Demo AI scan flow
- Inventory tracking
- Expiry badges
- Recipe matching
- Cooking mode with read-aloud alerts
- Shopping list
- Purchased-to-inventory flow
- Analytics dashboard
- Settings for diet, allergens, household, reminders, and accessibility

## What To Say On Your Resume

Use this wording:

> Built WasteLess Kitchen, a cross-platform smart kitchen assistant with a native SwiftUI architecture prototype and a Windows-runnable Expo demo. Implemented pantry scanning mocks, inventory tracking, expiry risk ranking, recipe recommendations, cooking mode with speech, shopping list automation, analytics, and accessibility-focused settings.

If you specifically want an iOS-focused bullet, use:

> Designed a native SwiftUI iOS architecture for WasteLess Kitchen using SwiftData-style models, App Intents, WidgetKit, notifications, Charts, AVFoundation speech, and mock AI service protocols; mirrored the product in Expo for Windows-based testing and demo.

Do not claim it was shipped to the App Store or tested in Xcode unless you later run the SwiftUI project on a Mac.

## Practical Portfolio Strategy

- Demo the Expo app from Windows in the browser.
- Put screenshots or a screen recording in your portfolio.
- Mention that the SwiftUI version is included as the native iOS implementation target.
- When you eventually get Mac access, open `WasteLessKitchen.xcodeproj`, fix any Xcode-specific build issues, and record the native iOS demo.

## Verified Locally

The Expo web export was tested with:

```powershell
npx.cmd expo export --platform web
```

It completed successfully and generated a `dist` folder.

Expo dependency validation was also checked:

```powershell
npx.cmd expo install --check
```

It reports that dependencies are up to date for SDK 54.
