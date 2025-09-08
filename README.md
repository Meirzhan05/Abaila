## Abaila

Abaila is an iOS app (SwiftUI) with a Node.js backend. It supports media uploads to S3, geolocation-based alerts, and push notifications via APNs with Redis for device management.

### Repository Structure

- `Abaila/` — iOS app (SwiftUI)
- `server/` — Node.js/Express backend (MongoDB, Redis, APNs)

### Prerequisites

- Node.js 18+ (recommended 20.x)
- npm 9+
- Xcode 15+
- MongoDB running and reachable
- Redis running and reachable
- Apple Developer account with Push Notifications enabled

### Backend Setup

1) Install dependencies

```bash
cd server
npm install
```

2) Create `.env` in `server/`

```bash
# Server
PORT=3000
MONGO_URI=mongodb://localhost:27017/abaila
ACCESS_TOKEN_SECRET=replace_me
REFRESH_TOKEN_SECRET=replace_me

# Redis
REDIS_URL=redis://localhost:6379

# APNs (token-based auth)
APNS_BUNDLE_ID=com.yourcompany.Abaila
APNS_KEY_ID=AAAAAAAAAA
APNS_TEAM_ID=BBBBBBBBBB
# One of the following must be provided:
# APNS_KEY_PATH=/absolute/path/to/AuthKey_XXXXXX.p8
# OR base64 contents of the .p8 file
# APNS_KEY=BASE64_ENCODED_P8_CONTENTS

# APNS environment (true for production)
APNS_PRODUCTION=false
```

3) Run the backend

```bash
npm run devStart
```

The server listens at `http://localhost:3000`.

### Notable Endpoints

- `POST /register` — create user: `{ username, email, password }`
- `POST /login` — login: `{ email, password }` → `{ accessToken, refreshToken }`
- `POST /token` — refresh access token: `{ refreshToken }`
- `DELETE /logout` — revoke refresh token
- `GET /profile` — authenticated user profile
- `PUT /profile/update` — update profile
- `PUT /media/presigned-url` — S3 upload URL
- `GET /media/getSignedUrl?keys=[...]` — S3 download URLs
- `POST /alerts/create` — create alert (sends APNs to the current user)
- `POST /devices/apns/register` — save APNs device token for the current user: `{ deviceToken }`

### iOS App Setup

1) Open Xcode project

Open `Abaila/Abaila.xcodeproj` in Xcode.

2) Capabilities

- Enable Push Notifications
- Enable Background Modes → Remote notifications

3) Bundle Identifier

- Set the app bundle identifier to match `APNS_BUNDLE_ID` in the server `.env`.

4) Signing

- Use a provisioning profile with Push Notifications enabled.

5) Build Target

- Use a real device for APNs testing (APNs does not deliver to Simulator).

### Push Notifications Flow

- On launch and after successful login, the app requests notification permission and registers for remote notifications.
- The device token is sent to the backend via `POST /devices/apns/register` with the current user’s access token.
- When an alert is created via `POST /alerts/create`, the backend sends an APNs notification to all registered devices for that user.

Relevant iOS files:
- `Abaila/Abaila/AppDelegate.swift` — handles APNs registration callbacks
- `Abaila/Abaila/Managers/PushNotificationManager.swift` — requests permission, saves token, syncs with backend
- `Abaila/Abaila/AbailaApp.swift` — triggers registration and token sync on launch
- `Abaila/Abaila/Managers/AuthViewModel.swift` — triggers registration and token sync after login

Relevant backend file:
- `server/server.js` — Redis and APNs provider setup, device registration endpoint, alert creation and APNs send

### Redis Usage

- The backend stores APNs device tokens per user in Redis Sets with the key pattern `apns:devices:<userId>`.
- Ensure your Redis instance is secured and not exposed publicly.

### Development Tips

- Use ngrok or a reachable host if you run the server on a different machine from the iPhone.
- Keep `ACCESS_TOKEN_SECRET` and `REFRESH_TOKEN_SECRET` strong and private.
- For APNs `.p8` handling, you can either:
  - Set `APNS_KEY_PATH` to the absolute path of your `.p8` file, or
  - Base64-encode the `.p8` contents and set `APNS_KEY` to that value.

### Scripts

- `npm run devStart` — start the backend with nodemon

### License

This project is for personal/educational use. Replace with your desired license.
