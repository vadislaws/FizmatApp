# Firebase Cloud Functions - Kundelik API Backend

This directory contains Firebase Cloud Functions that act as a secure backend proxy for the Kundelik API integration in FizmatApp.

## 🌟 Features

- **kundelikLogin**: Authenticates users with Kundelik API using credentials (username/password)
- **kundelikSync**: Syncs existing Kundelik user data using stored access token
- Secure storage of API credentials using Firebase Functions Config
- Comprehensive error handling with localized error messages
- Automatic GPA calculation from student marks
- Retrieves user info, schools, birthday, and performance data

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Node.js 18 or higher** installed
2. **Firebase CLI** installed: `npm install -g firebase-tools`
3. **Firebase project** set up (fizmatapp)
4. **Kundelik API credentials** (client_id and client_secret)

## 🚀 Setup Instructions

### Step 1: Install Firebase CLI (if not already installed)

```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase

```bash
firebase login
```

### Step 3: Navigate to functions directory

```bash
cd functions
```

### Step 4: Install dependencies

```bash
npm install
```

### Step 5: Configure Kundelik API credentials

Set the Kundelik API client_id and client_secret in Firebase Functions config:

```bash
firebase functions:config:set kundelik.client_id="387d44e3-e0c9-4265-a9e4-a4caaad5111c"
firebase functions:config:set kundelik.client_secret="8a7d709c-fdbb-4047-b0ea-8947afe89d67"
```

**IMPORTANT**: These credentials are stored securely in Firebase and are never exposed to the client app.

### Step 6: Deploy the functions

```bash
firebase deploy --only functions
```

Or from the project root:

```bash
cd ..
firebase deploy --only functions
```

## 🧪 Testing Locally

You can test the functions locally using Firebase Emulators:

### Step 1: Start the emulator

```bash
firebase emulators:start --only functions
```

### Step 2: The functions will be available at:

- kundelikLogin: `http://localhost:5001/fizmatapp/us-central1/kundelikLogin`
- kundelikSync: `http://localhost:5001/fizmatapp/us-central1/kundelikSync`

### Step 3: Download runtime config for local testing

```bash
firebase functions:config:get > .runtimeconfig.json
```

This creates a `.runtimeconfig.json` file with your config values for local emulator testing.

**NOTE**: Never commit `.runtimeconfig.json` to Git! It's already in `.gitignore`.

## 📡 Using the Functions in Flutter

### 1. Add Firebase Functions dependency to pubspec.yaml

```yaml
dependencies:
  cloud_functions: ^4.5.0
```

### 2. Import and initialize

```dart
import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instance;
```

### 3. Call kundelikLogin function

```dart
try {
  final result = await functions.httpsCallable('kundelikLogin').call({
    'username': 'your_username',
    'password': 'your_password',
  });

  final data = result.data;
  final accessToken = data['accessToken'];
  final userId = data['userId'];
  final userInfo = data['userInfo'];
  final personSchools = data['personSchools'];
  final birthday = data['birthday'];
  final gpa = data['gpa'];

  print('Login successful! Access Token: $accessToken');
  print('GPA: $gpa');
} on FirebaseFunctionsException catch (e) {
  print('Error: ${e.code} - ${e.message}');

  // Handle specific errors
  switch (e.code) {
    case 'unauthenticated':
      // Invalid username or password
      showError('Invalid credentials');
      break;
    case 'unavailable':
      // Kundelik API is down or not responding
      showError('Service temporarily unavailable');
      break;
    case 'invalid-argument':
      // Missing username or password
      showError('Please enter username and password');
      break;
    default:
      showError('An error occurred: ${e.message}');
  }
}
```

### 4. Call kundelikSync function

```dart
try {
  final result = await functions.httpsCallable('kundelikSync').call({
    'accessToken': 'stored_access_token',
    'userId': 123456,
  });

  final data = result.data;
  final birthday = data['birthday'];
  final gpa = data['gpa'];

  print('Sync successful! Updated GPA: $gpa');
} on FirebaseFunctionsException catch (e) {
  if (e.code == 'unauthenticated') {
    // Access token expired, need to re-login
    navigateToKundelikLogin();
  }
}
```

## 🔒 Security

- **Client credentials** (client_id, client_secret) are stored securely in Firebase Functions Config and never exposed to the client app
- **User credentials** (username, password) are only used for authentication and are never stored
- **Access tokens** are returned to the Flutter app for future API calls
- All API calls are made server-side to prevent exposure of sensitive data

## 🛠️ Troubleshooting

### Error: "Server configuration error"

This means Kundelik API credentials are not configured. Run:

```bash
firebase functions:config:set kundelik.client_id="..." kundelik.client_secret="..."
firebase deploy --only functions
```

### Error: "Failed to connect to Kundelik API"

- Check your internet connection
- Verify Kundelik API is accessible: https://api.kundelik.kz
- Check Firebase Functions logs: `firebase functions:log`

### Error: "Access token expired"

The access token has expired. Call `kundelikLogin` again to get a new token.

### Viewing logs

View function execution logs:

```bash
firebase functions:log
```

View real-time logs:

```bash
firebase functions:log --only kundelikLogin
```

## 📚 API Reference

### kundelikLogin

**Input:**
```typescript
{
  username: string;  // Kundelik username
  password: string;  // Kundelik password
}
```

**Output:**
```typescript
{
  success: boolean;
  accessToken: string;          // Use for future API calls
  userId: number;               // Kundelik user ID
  userInfo: object;             // User information from /users/me
  personSchools: array;         // Schools data from /schools/person-schools
  personInfo: object | null;    // Person info from /persons/{personId}
  birthday: string | null;      // Birthday in YYYY-MM-DD format
  gpa: number | null;           // Calculated GPA (numerical marks only)
  performanceData: object | null; // Full performance data
}
```

**Errors:**
- `invalid-argument`: Username or password missing
- `unauthenticated`: Invalid credentials
- `unavailable`: Kundelik API unavailable or timeout
- `failed-precondition`: Server configuration error
- `internal`: Unexpected error

### kundelikSync

**Input:**
```typescript
{
  accessToken: string;  // Kundelik access token
  userId: number;       // Kundelik user ID
}
```

**Output:**
```typescript
{
  success: boolean;
  userInfo: object;
  personSchools: array;
  personInfo: object | null;
  birthday: string | null;
  gpa: number | null;
  performanceData: object | null;
}
```

**Errors:**
- `invalid-argument`: Access token or user ID missing
- `unauthenticated`: Access token expired
- `internal`: Failed to retrieve data

## 🌍 Kundelik API Endpoints Used

- `POST /v2/authorizations/bycredentials` - Authentication
- `GET /v2/users/me` - Get current user info
- `GET /v2/schools/person-schools` - Get person's schools
- `GET /v2/persons/{personId}` - Get person info (birthday)
- `GET /v2/students/{studentId}/performance` - Get student performance (for GPA)

## 📝 Notes

- Access tokens from Kundelik API do not expire immediately, but should be refreshed periodically
- GPA calculation only uses numerical marks (non-numerical marks are excluded)
- The function automatically handles HTML error responses from Kundelik API
- All timeouts are set to reasonable values (10-15 seconds) to prevent hanging

## 🔄 Updating Functions

After making changes to the code:

```bash
firebase deploy --only functions
```

To deploy a specific function:

```bash
firebase deploy --only functions:kundelikLogin
```

## 📦 Project Structure

```
functions/
├── index.js           # Main Cloud Functions code
├── package.json       # Node.js dependencies and scripts
├── .eslintrc.json    # ESLint configuration
├── .gitignore        # Git ignore rules
└── README.md         # This file
```

---

# Firebase Cloud Functions - Kundelik API Backend (Русский)

Эта директория содержит Firebase Cloud Functions, которые работают как безопасный backend-прокси для интеграции с API Kundelik в FizmatApp.

## 🚀 Инструкции по настройке

### Шаг 1: Установите Firebase CLI

```bash
npm install -g firebase-tools
```

### Шаг 2: Войдите в Firebase

```bash
firebase login
```

### Шаг 3: Перейдите в директорию functions

```bash
cd functions
```

### Шаг 4: Установите зависимости

```bash
npm install
```

### Шаг 5: Настройте учетные данные Kundelik API

```bash
firebase functions:config:set kundelik.client_id="387d44e3-e0c9-4265-a9e4-a4caaad5111c"
firebase functions:config:set kundelik.client_secret="8a7d709c-fdbb-4047-b0ea-8947afe89d67"
```

### Шаг 6: Разверните функции

```bash
firebase deploy --only functions
```

## 🧪 Локальное тестирование

```bash
firebase emulators:start --only functions
firebase functions:config:get > .runtimeconfig.json
```

## 📡 Использование в Flutter

```dart
final result = await FirebaseFunctions.instance
    .httpsCallable('kundelikLogin')
    .call({
  'username': 'your_username',
  'password': 'your_password',
});
```

## 🔒 Безопасность

- Client credentials хранятся в Firebase Functions Config и никогда не передаются клиенту
- Пароли пользователей используются только для аутентификации и не сохраняются
- Все запросы к API выполняются на стороне сервера

Для дополнительной информации см. английскую версию документации выше.
