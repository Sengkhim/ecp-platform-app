// lib/core/utils/app_utils.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

// ── Formatting ────────────────────────────────────────────────────────────────

String formatCurrency(double amount, {String currency = 'USD'}) {
  return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
}

String formatDate(String? iso) {
  if (iso == null) return '—';
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('MMM d, yyyy').format(dt);
  } catch (_) {
    return iso;
  }
}

String formatDateTime(String? iso) {
  if (iso == null) return '—';
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('MMM d, yyyy · h:mm a').format(dt);
  } catch (_) {
    return iso;
  }
}

// ── Snackbar helpers ──────────────────────────────────────────────────────────

void showSuccess(String message) {
  Get.snackbar(
    'Success',
    message,
    backgroundColor: AppColors.success.withOpacity(0.15),
    colorText: AppColors.textPrimary,
    icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(16),
  );
}

void showError(String message) {
  Get.snackbar(
    'Error',
    message,
    backgroundColor: AppColors.error.withOpacity(0.15),
    colorText: AppColors.textPrimary,
    icon: const Icon(Icons.error_outline, color: AppColors.error),
    duration: const Duration(seconds: 4),
    margin: const EdgeInsets.all(16),
  );
}

void showInfo(String message) {
  Get.snackbar(
    'Info',
    message,
    backgroundColor: AppColors.info.withOpacity(0.15),
    colorText: AppColors.textPrimary,
    icon: const Icon(Icons.info_outline, color: AppColors.info),
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(16),
  );
}
