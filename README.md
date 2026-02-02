# Reports App

Flutter/Dart app developed for a **university project**. It lets users sign up, log in, and create reports stored on Firebase. Users can browse reports from other (unblocked) users and delete only their own; an Admin account can manage users (block, permissions) and enable deletion of any report.

---

## What the app does

- **Authentication**: sign up, login, password reset (email/password via Firebase Auth).
- **Reports**: create reports with title, place, description, and optional photo; data is stored on Firestore.
- **Reports list**: view all reports from unblocked users; swipe to delete (only your own, unless “master deleting” is enabled for admin).
- **My reports**: list and manage your own reports.
- **Admin**: panel to enable “master deleting” (delete any report) and access the users list.
- **User management** (admin): view registered users, block/unblock, promote to admin.
- **Settings**: theme (light/dark/system), app info, version check (e.g. for Android).

Each report has author, place, submission date, description, and optional image.

---

## Architecture: MVVM

The app uses the **MVVM** (Model–View–ViewModel) pattern with **Riverpod** for state:

- **Model** (`lib/model/`): domain models (e.g. `ReportModel`, `AppUserModel`).
- **ViewModel** (`lib/viewModel/`): business logic and state; expose data and actions to Views via `ChangeNotifier`.
- **View** (`lib/view/`): screens and UI widgets that observe ViewModels via `ref.watch` / `ref.read`.
- **Providers** (`lib/providers/providers.dart`): Riverpod provider definitions that create and hold ViewModels.

Views do not contain business logic: they only display data and call ViewModel methods. All logic (Firebase, validation, state) lives in the ViewModels.

---

## Tech stack

- **Flutter** / **Dart**
- **Firebase**: Auth, Firestore, Storage (for images)
- **Riverpod** for state management
- **dotenv** for sensitive keys (e.g. `keys.env`; see `keys.env.example`)
