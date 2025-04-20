# AI Doorbell

![AI Doorbell Logo](https://via.placeholder.com/150?text=AI+Doorbell)

## Overview

AI Doorbell is an intelligent facial recognition system that utilizes camera technology to welcome guests, track employee attendance, and identify suspicious individuals. The system is developed for multiple platforms, including Web, Android, iOS, and IoT devices.

## Key Features

- **Real-time Facial Recognition**: Utilizing AI technology to identify familiar faces and strangers.
- **Smart Welcome**: Automatically greets visitors by name when recognizing registered faces.
- **Employee Attendance**: Automatically records employee entry and exit times.
- **Suspicious Subject Alerts**: Detects and notifies when unknown or suspicious individuals are present.
- **Cross-Platform**: Works across Web, Android, iOS, and IoT devices.
- **Real-time Notifications**: Sends instant alerts to users when new events occur.

## Technologies Used

- **AI/Machine Learning**: YOLO and advanced machine learning models from Kaggle
- **Frontend**: Flutter (cross-platform)
- **Backend**: Node.js, Express
- **Database**: MongoDB
- **IoT**: Raspberry Pi, Arduino
- **Cloud**: AWS/Azure for processing and storage

## Installation

### System Requirements

- Node.js (v14+)
- MongoDB (v4+)
- Python (v3.8+) for AI models
- Camera device (webcam or IP camera)

### Backend Installation

```bash
# Clone repository
git clone https://github.com/tmone/ai-doorbell.git
cd ai-doorbell/backend

# Install dependencies
npm install

# Install Python libraries for AI
pip install -r requirements.txt

# Run server
npm start
```

### Flutter App Installation (Web, Android, iOS)

```bash
cd ../flutter_app
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Build for production
flutter build apk     # Android
flutter build ios     # iOS
flutter build web     # Web
```

### IoT Device Setup

See detailed instructions in the `/iot-setup` directory

## Project Structure

```
ai-doorbell/
├── backend/             # API Server and AI processing
├── flutter_app/         # Cross-platform Flutter application (Web, Android, iOS)
├── iot-setup/           # Source code and instructions for IoT devices
├── models/              # Trained AI models (YOLO and Kaggle models)
├── training/            # Source code and data for model training
└── docs/                # Documentation and guides
```

## Usage

1. **Register New Faces**:
   - Use the web interface or mobile app to register new faces
   - Take at least 5 photos from different angles

2. **Employee Management**:
   - Add, edit, delete employee information
   - View attendance reports

3. **Alert Configuration**:
   - Set up alert rules
   - Configure notification methods

## API Reference

API documentation is available at `/docs/api-reference.md`

## Contributing

We welcome contributions from the community:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is distributed under the MIT License. See the `LICENSE` file for more information.

## Contact

- Website: [ai-doorbell.example.com](https://ai-doorbell.example.com)
- Email: contact@ai-doorbell.example.com
- GitHub: [https://github.com/tmone/ai-doorbell](https://github.com/tmone/ai-doorbell)
