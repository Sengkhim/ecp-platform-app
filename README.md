# ECP Platform — Flutter Mobile App

Order management mobile app for the ECP microservices platform.

## Stack
- **Flutter** 3.x / Dart 3.x
- **GetX** — state management, DI, routing
- **Dio** — HTTP client with interceptors
- **flutter_animate** — smooth animations
- **shimmer** — loading skeletons
- **google_fonts** — Syne + DM Sans

## Structure
```
lib/
├── core/
│   ├── constants/    app_constants.dart, app_routes.dart
│   ├── network/      api_client.dart (Dio + auth interceptor)
│   ├── theme/        app_theme.dart (dark ink/amber palette)
│   └── utils/        app_utils.dart (formatting, snackbars)
├── data/
│   ├── models/       order_model.dart
│   ├── repositories/ order_repository.dart
│   └── providers/    app_bindings.dart
└── modules/
    └── orders/
        ├── controllers/  order_list_controller.dart, create_order_controller.dart
        ├── views/         order_list_view.dart, order_detail_view.dart, create_order_view.dart
        └── widgets/       order_widgets.dart
```

## Setup

```bash
flutter pub get
flutter run
```

## API Configuration

Update `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'http://api-gateway.ecp-dev.svc.cluster.local';
```

For local dev with port-forward:
```bash
kubectl port-forward svc/api-gateway 8080:80 -n ecp-dev
```
Then change `baseUrl` to `http://localhost:8080`.

## Features
- Order list with stats bar (total / pending / active)
- Status filter pills + search
- Pull-to-refresh
- Order detail with items, financials, timeline
- Cancel order with reason
- Create order form with dynamic items, currency & payment method selection
- Shimmer loading skeletons
- Staggered fade-in animations
- Consistent dark editorial theme