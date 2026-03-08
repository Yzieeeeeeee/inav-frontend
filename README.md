# Payment Collection App

This repository contains the complete solution for the Payment Collection App hiring test, consisting of a Flutter frontend and a Node.js/Express backend, interacting with a MySQL database.

## 1. Project Setup & Prerequisites

Make sure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js & npm](https://nodejs.org/en/download/)
- MySQL Server

## 2. Backend Setup (Node.js)

1. Open a terminal and navigate to the `backend` folder:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up the Database:
   - Make sure your MySQL server is running.
   - Run the script located at `backend/init.sql` against your MySQL server. This will create the database, tables, and insert dummy data.
4. Configure Environment Variables:
   - Check the `backend/.env` file. You might need to change the DB credentials (user/password) depending on your local MySQL setup.
5. Start the Server:
   ```bash
   npm start
   ```
   The server will run on port `3000`.

## 3. Frontend Setup (Flutter)

1. Open a new terminal and navigate to the root folder (where `pubspec.yaml` is located):
   ```bash
   cd ..
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Configure the API URL:
   - The API URL is set in `lib/services/api_service.dart`.
   - By default, it uses `http://10.0.2.2:3000` which works locally for the Android Emulator.
   - If you test on Chrome/Web instead, change it to `http://localhost:3000`.
   - If deploying, update it to your AWS EC2 public IP.
4. Run the App:
   ```bash
   flutter run
   ```

## 4. CI/CD Pipeline Configuration

Two GitHub actions have been created under `.github/workflows`:
- `frontend.yml`: Automatically sets up Flutter, fetches dependencies, and builds the Web version of the application on push/pull requests to the `main` branch.
- `backend.yml`: Automatically sets up Node.js and installs npm dependencies to ensure the backend builds successfully.

## 5. Deployment Steps on AWS EC2

To deploy this architecture to an AWS EC2 instance:

1. **Launch an EC2 Instance:**
   - Go to AWS Console -> EC2 -> Launch Instance.
   - Select an Ubuntu Server AMI (e.g., Ubuntu 22.04 LTS).
   - Configure Security Groups: Open Ports `22` (SSH), `80` (HTTP), and `3000` (Backend API).

2. **Setup the EC2 Instance:**
   - SSH into your instance.
   - Install MySQL Server, Node.js, and Nginx.
   - Run the `init.sql` script into the MySQL running on EC2.

3. **Deploy the Backend:**
   - Clone your backend repository into the EC2 instance.
   - Run `npm install`.
   - Use a process manager like `pm2` to run the backend:
     `npm install -g pm2`
     `pm2 start server.js`

4. **Deploy the Frontend (Web Build):**
   - For web access, simply run the build generated via GitHub actions (`flutter build web`) or locally, and copy the `build/web` folder to the EC2 server.
   - Serve the static files using Nginx or Apache.
   - Important: Remember to update the `baseUrl` in `api_service.dart` to the IP Address/Domain Name of the EC2 instance before building for production.
