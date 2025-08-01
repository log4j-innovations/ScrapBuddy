# ScrapBuddy - AI-Powered Waste Classification App 🚀♻️

An intelligent waste management application that uses Vertex AI (Gemini 2.0 Flash) for waste classification and Sarvam AI for multilingual support. ScrapBuddy helps users identify waste types, get disposal instructions, and hear audio feedback in their native language.

![ScrapBuddy](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Vertex AI](https://img.shields.io/badge/Vertex%20AI-Gemini%202.0%20Flash-green.svg)
![Sarvam AI](https://img.shields.io/badge/Sarvam%20AI-TTS%20%26%20Translation-orange.svg)

## 🌟 Features

- ✅ **AI-Powered Classification**: Uses Vertex AI (Gemini 2.0 Flash) for accurate waste identification
- ✅ **Multi-Language Support**: Hindi, Tamil, Telugu, Bengali, Marathi, Gujarati, Kannada, English
- ✅ **Text-to-Speech**: Native language audio feedback using Sarvam AI
- ✅ **Smart Translation**: Automatic translation of classifications and disposal instructions
- ✅ **Monetary Value Estimation**: Get estimated value of recyclable items in INR
- ✅ **Proper Disposal Instructions**: Detailed guidelines for responsible waste management
- ✅ **Professional UI**: Modern design with bottom navigation and smooth animations
- ✅ **Offline Fallback**: Works even when translation APIs are unavailable
- ✅ **Real-time Stats**: Track your recycling points and environmental impact

## 📱 Screenshots

*Add your app screenshots here*

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android/iOS development environment
- API keys for Vertex AI and Sarvam AI

### 1. Clone the Repository

git clone https://github.com/yourusername/scrapbuddy.git
cd scrapbuddy

### 2. Install Dependencies

flutter pub get

### 3. Environment Configuration

**Step 1**: Copy the example environment file
cp .env.example .env

**Step 2**: Edit `.env` file and add your API keys:

Vertex AI (Gemini) API Configuration
VERTEX_AI_API_KEY=your_gemini_api_key_here

Sarvam AI API Configuration
SARVAM_API_KEY=your_sarvam_api_key_here

App Configuration
APP_NAME=ScrapBuddy
APP_VERSION=1.0.0
ENVIRONMENT=development


### 4. Run the Application

Clean build (recommended for first run)
flutter clean
flutter pub get

Run on connected device/emulator
flutter run

For release build
flutter build apk --release

text

## 🔑 API Keys Setup

### Vertex AI (Gemini) API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated key to `.env` file

### Sarvam AI API Key
1. Visit [Sarvam AI Console](https://www.sarvam.ai/)
2. Sign up for an account
3. Navigate to API Keys section
4. Generate a new API key
5. Copy the key (format: `sk_xxxxxxxxx`) to `.env` file

## 🏗️ Project Structure

scrapbuddy/
├── lib/
│ ├── config/
│ │ └── api_config.dart # API configuration with environment variables
│ ├── models/
│ │ └── waste_classification.dart # Data models for waste classification
│ ├── screens/
│ │ ├── splash_screen.dart # App launch screen
│ │ ├── language_selection_screen.dart # Language picker
│ │ ├── home_screen.dart # Main app interface
│ │ └── result_screen.dart # Classification results display
│ ├── services/
│ │ └── vertex_ai_service.dart # API integration services
│ ├── widgets/
│ │ └── stats_card.dart # Reusable UI components
│ └── main.dart # App entry point
├── android/ # Android-specific files
├── ios/ # iOS-specific files
├── .env.example # Environment variables template
├── .gitignore # Git ignore rules
├── pubspec.yaml # Flutter dependencies
└── README.md # This file

text

## 🛠️ Technical Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Flutter 3.0+ | Cross-platform mobile app |
| **AI Classification** | Vertex AI (Gemini 2.0 Flash) | Waste image analysis |
| **Translation** | Sarvam AI | Multi-language support |
| **Text-to-Speech** | Sarvam AI | Audio feedback |
| **State Management** | Shared Preferences | User settings persistence |
| **Image Processing** | Image Picker | Camera/gallery integration |
| **Audio Playback** | AudioPlayers | TTS audio playback |
| **Environment** | Flutter DotEnv | Secure API key management |

## 🌐 Supported Languages

- **Hindi (हिंदी)** - Default
- **English** - Fallback
- **Tamil (தமிழ்)**
- **Telugu (తెలుగు)**
- **Bengali (বাংলা)**
- **Marathi (मराठी)**
- **Gujarati (ગુજરાતી)**
- **Kannada (ಕನ್ನಡ)**

## 🔧 Configuration

### Build Configuration

Update `android/app/build.gradle.kts` for Android NDK version:

android {
ndkVersion = "27.0.12077973"
// ... other configurations
}

text

### Permissions

The app requires the following permissions (automatically handled):

- **Camera**: For taking photos of waste items
- **Storage**: For accessing gallery images
- **Internet**: For API calls to classification and TTS services

## 🧪 Testing

### Manual Testing Checklist

- [ ] Language selection persists after app restart
- [ ] Camera captures and processes images correctly
- [ ] Gallery image selection works
- [ ] Vertex AI classification returns accurate results
- [ ] Translation works for selected language
- [ ] TTS audio plays in correct language
- [ ] Bottom navigation functions properly
- [ ] Stats update after successful classification
- [ ] App handles network errors gracefully

### Running Tests

Run unit tests
flutter test

Run integration tests
flutter drive --target=test_driver/app.dart

text

## 🐛 Troubleshooting

### Common Issues

**1. API Key Errors**
Error: API keys not configured. Please check .env file.

text
**Solution**: Ensure `.env` file exists with valid API keys

**2. Translation Failures**
Translation failed: 403 - Subscription key is not provided

text
**Solution**: Verify Sarvam AI API key format and subscription status

**3. Audio Playback Issues**
TTS service temporarily unavailable

text
**Solution**: Check internet connection and Sarvam AI service status

**4. Build Errors**
A RenderFlex overflowed by X pixels

text
**Solution**: UI overflow issues are handled in the latest version

### Debug Mode

Enable debug logging by setting:
ENVIRONMENT=development

text

### API Rate Limits

- **Vertex AI**: 60 requests per minute (free tier)
- **Sarvam AI**: Check your subscription plan limits

## 📊 Performance Optimizations

- **Image Compression**: Images are compressed to 1024x1024 at 80% quality
- **Const Constructors**: All widgets use const constructors where possible
- **Lazy Loading**: API calls only when needed
- **Memory Management**: Proper disposal of controllers and audio players
- **Fallback Systems**: Offline translation for common waste items

## 🚀 Deployment

### Android APK Build

Debug build
flutter build apk --debug

Release build
flutter build apk --release

Build for specific architecture
flutter build apk --target-platform android-arm64

text

### iOS Build

iOS build (requires macOS and Xcode)
flutter build ios --release

text

### Environment-Specific Builds

Development build
flutter build apk --release --dart-define=ENVIRONMENT=development

Production build
flutter build apk --release --dart-define=ENVIRONMENT=production

text

## 🤝 Contributing

We welcome contributions to ScrapBuddy! Please follow these guidelines:

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Add tests if applicable
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Standards

- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure all widgets have const constructors where possible
- Test on both Android and iOS devices

### Adding New Languages

To add support for a new language:

1. Update `_languageCodeMap` in `vertex_ai_service.dart`
2. Add classification prompt in `_classificationPrompts`
3. Update fallback translations
4. Add language option in `language_selection_screen.dart`
5. Test TTS functionality

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

MIT License

Copyright (c) 2025 ScrapBuddy Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

text

## 🙏 Acknowledgments

- **Google AI** for providing Vertex AI (Gemini) API
- **Sarvam AI** for multilingual TTS and translation services
- **Flutter Team** for the amazing cross-platform framework
- **Open Source Community** for various packages and libraries used

## 📞 Support

For support, email support@scrapbuddy.app or join our community:

- **GitHub Issues**: [Report bugs and feature requests](https://github.com/yourusername/scrapbuddy/issues)
- **Discord**: [Join our community](https://discord.gg/scrapbuddy)
- **Documentation**: [Detailed guides](https://docs.scrapbuddy.app)

## 🔮 Roadmap

### Version 1.1.0 (Upcoming)
- [ ] History screen implementation
- [ ] User profile and achievements
- [ ] Offline classification capabilities
- [ ] Social sharing features
- [ ] Dark mode support

### Version 1.2.0
- [ ] Barcode scanning for packaged items
- [ ] Integration with local recycling centers
- [ ] Gamification and rewards system
- [ ] Community challenges

### Version 2.0.0
- [ ] Real-time waste tracking
- [ ] IoT device integration
- [ ] Blockchain-based reward system
- [ ] AR waste identification

---

**Made with ❤️ for a cleaner, greener planet 🌍**

---

## ⚠️ Important Security Notes

- **Never commit the `.env` file** to version control
- **Keep your API keys secure** and private
- **Rotate API keys regularly** for security
- **Follow rate limits** to avoid service interruptions
- **Monitor API usage** to prevent unexpected charges

---

