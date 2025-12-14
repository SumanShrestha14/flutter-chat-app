# Notification Setup Guide

This guide explains how notifications are set up in your Flutter chat app using **Firebase Cloud Messaging (FCM)** and **flutter_local_notifications**.

## Overview

The app now supports notifications in three scenarios:
1. **App Closed/Terminated**: FCM push notifications handle this
2. **App in Background**: FCM triggers local notifications
3. **App in Foreground**: Local notifications show for incoming messages

## Implementation Details

### Files Created/Modified

1. **`lib/services/notification_service.dart`**
   - Handles FCM initialization and permissions
   - Manages local notifications
   - Sets up notification channels for Android
   - Handles notification taps

2. **`lib/services/message_notification_listener.dart`**
   - Listens to Firestore for new incoming messages
   - Shows local notifications when messages arrive
   - Prevents duplicate notifications
   - Ignores notifications for the currently open chat

3. **`lib/main.dart`**
   - Initializes notification service on app startup
   - Sets up message listener when user is authenticated
   - Handles navigation when notifications are tapped

4. **`lib/pages/chat_page.dart`**
   - Integrates with message listener to prevent notifications for current chat

5. **`android/app/src/main/AndroidManifest.xml`**
   - Added required permissions for notifications
   - Configured FCM notification channel

6. **`ios/Runner/AppDelegate.swift`**
   - Added notification delegate setup for iOS

## How It Works

### When App is Running

1. `MessageNotificationListener` listens to all chat rooms where the user is a participant
2. When a new message arrives in Firestore, it checks:
   - Is this a new message? (not already processed)
   - Is this from the current chat? (skip if yes)
   - Is the sender the current user? (skip if yes)
3. If all checks pass, a local notification is shown

### When App is Closed/Background

1. FCM receives push notifications from Firebase
2. Background handler processes the notification
3. Local notification is displayed

### Notification Tapping

When a user taps a notification:
- The app opens (if closed)
- Navigation callback is triggered
- User is taken to the chat with the message sender

## Dependencies Added

```yaml
firebase_messaging: ^16.0.4
flutter_local_notifications: ^18.0.1
```

## Firebase Console Setup (Required for FCM)

To enable push notifications when the app is closed, you need to:

1. **Configure FCM in Firebase Console:**
   - Go to Firebase Console → Cloud Messaging
   - Ensure your app is registered

2. **For Testing Push Notifications:**
   - You can send test notifications from Firebase Console
   - Or set up Cloud Functions to send notifications when messages are sent

3. **Store FCM Tokens (Optional but Recommended):**
   - The app gets FCM token on initialization
   - Store tokens in Firestore under each user's document
   - Use these tokens to send targeted notifications via Cloud Functions

## Testing

### Test Local Notifications (App Running)

1. Open the app and log in
2. Have another user send you a message (or use a test account)
3. You should see a notification appear

### Test FCM Push Notifications (App Closed)

1. Close the app completely
2. Send a test notification from Firebase Console
3. You should receive a push notification

## Next Steps (Optional Enhancements)

1. **Cloud Functions Integration:**
   - Create a Cloud Function that triggers on new message creation
   - Send FCM notification to the receiver's device
   - Include sender info and message preview in notification data

2. **Notification Badges:**
   - Implement unread message count badges
   - Update badge when messages arrive

3. **Rich Notifications:**
   - Add user avatars to notifications
   - Support action buttons (Reply, Mark as Read)

4. **Notification Settings:**
   - Allow users to enable/disable notifications
   - Configure notification sound preferences

## Troubleshooting

### Notifications Not Appearing

1. **Check Permissions:**
   - Android: Ensure notification permissions are granted (Android 13+)
   - iOS: Check notification permissions in device settings

2. **Check FCM Token:**
   - Look for "FCM Token: ..." in debug console
   - If missing, check Firebase configuration

3. **Check Firestore Rules:**
   - Ensure users can read messages in chat rooms
   - Check that message listener has proper access

### Android Issues

- Make sure `google-services.json` is in `android/app/`
- Check that notification channel is created
- Verify POST_NOTIFICATIONS permission in AndroidManifest

### iOS Issues

- Ensure APNs certificates are configured in Firebase Console
- Check that notification permissions are requested
- Verify AppDelegate is properly configured

## Notes

- Notifications are automatically suppressed when the user is in the chat with the sender
- Processed message IDs are tracked to prevent duplicate notifications
- The message listener starts automatically when a user logs in
- The listener stops when the user logs out

