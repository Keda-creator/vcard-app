# BizKonec - Digital Card & vCard App

A premium Flutter application for managing physical business cards (pCards) and digital vCards.

## Features

### 1. Home Dashboard
- **Banner Carousel**: Auto-playing promotional banners.
- **News & Offers**: Content-driven lists for announcements and marketing.

### 2. My vCard
- **Direct Access**: Your own digital identity loaded via WebView.
- **URL**: `http://vcardpersonal.totalh.net/customer-login.php`

### 3. pCards (Physical Cards)
- **Digitization**: Capture front and back of physical cards.
- **3D Flip Interaction**: Realistic 3D rotation to view both sides of the card.
- **Local Storage**: Cards are saved locally with notes.

### 4. vCards (Digital Cards)
- **QR & NFC Scanning**: Easily add digital cards received from others.
- **Metadata Fetching**: Automatically extracts page title, description, and preview image using Open Graph tags.

### 5. Authentication
- **Secure Flow**: Email-based login and registration.
- **Verification**: Support for email verification and forgot password flows.

## Architecture

The project follows **Clean Architecture** principles:
- **Core**: Theme, routing, networking, and storage constants.
- **Features**: Modularized by feature (Auth, Home, pCards, vCards, Profile).
- **Shared**: Common widgets, models, and services.
- **State Management**: Powered by **Riverpod**.
- **Navigation**: Persistent state using **GoRouter**'s `StatefulShellRoute`.

## Setup Instructions

1.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Run the App**:
    ```bash
    flutter run
    ```

## Dependencies used
- `flutter_riverpod` & `riverpod_annotation`
- `go_router`
- `webview_flutter`
- `camera` & `image_picker`
- `image_cropper`
- `mobile_scanner`
- `nfc_manager`
- `hive` & `hive_flutter`
- `cached_network_image`
- `carousel_slider`
- `http` & `html` (for metadata)
