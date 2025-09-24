import 'package:devhub_gpt/shared/notifications/providers/firebase_messaging_providers.dart';
import 'package:devhub_gpt/shared/widgets/app_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PushNotificationsCard extends ConsumerWidget {
  const PushNotificationsCard({required this.titleStyle, super.key});

  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PushNotificationStatus> statusAsync = ref.watch(
      pushNotificationStatusProvider,
    );
    final PushTestState pushTestState = ref.watch(pushTestControllerProvider);
    final PushTestController pushTestController = ref.read(
      pushTestControllerProvider.notifier,
    );

    ref.listen<PushTestState>(pushTestControllerProvider, (previous, next) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }
      if (next.isScheduling && (previous?.isScheduling ?? false) == false) {
        messenger
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Тестове сповіщення заплановано. Очікуйте близько 10 секунд.',
              ),
            ),
          );
        return;
      }

      final wasScheduling = previous?.isScheduling ?? false;
      if (!next.isScheduling && wasScheduling) {
        messenger.clearSnackBars();
        if (next.lastError != null && next.lastError!.isNotEmpty) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Не вдалося показати сповіщення: ${next.lastError}',
              ),
            ),
          );
        } else if (next.lastSuccess) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Сповіщення має з’явитися у браузері.'),
            ),
          );
        }
      }
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statusAsync.when(
          data: (status) {
            final theme = Theme.of(context);
            final ready = status.isReady;
            final permissionState = status.permissionState;
            final isScheduling = pushTestState.isScheduling;

            String primaryMessage;
            if (!status.firebaseEnabled) {
              primaryMessage = 'Firebase вимкнено для цієї збірки.';
            } else if (!status.webNotificationsSupported) {
              primaryMessage =
                  'Браузер не підтримує Web Notifications, тому push-сповіщення неможливі.';
            } else if (!status.permissionGranted) {
              primaryMessage = permissionState == 'denied'
                  ? 'Сповіщення заблоковані у браузері. Розблокуйте їх у налаштуваннях сайту.'
                  : 'Дозвольте показ сповіщень у браузері, щоб активувати тест.';
            } else {
              primaryMessage =
                  'Сповіщення дозволені. Можна запускати тестове повідомлення.';
            }

            final token = status.token;
            final smallStyle = theme.textTheme.bodySmall;

            final requestedAt = pushTestState.lastRequestedAt;
            final deliveredAt = pushTestState.lastDeliveredAt;
            final dateFormat = DateFormat('HH:mm:ss');

            String lastActionMessage;
            if (isScheduling && requestedAt != null) {
              lastActionMessage =
                  'Сповіщення готується. Очікувана поява: ${dateFormat.format(requestedAt.add(const Duration(seconds: 10)))}.';
            } else if (deliveredAt != null) {
              lastActionMessage =
                  'Останнє тестове сповіщення показано о ${dateFormat.format(deliveredAt.toLocal())}.';
            } else {
              lastActionMessage = 'Тестове сповіщення ще не запускалося.';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Firebase push-сповіщення',
                        style: titleStyle,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Оновити статус',
                      onPressed: () {
                        refreshPushNotificationStatus(ref);
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(primaryMessage),
                if (token != null && token.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SelectableText('FCM token:\n$token', style: smallStyle),
                ],
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: ready && !isScheduling
                      ? () => pushTestController.sendTestPush()
                      : null,
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(
                    isScheduling
                        ? 'Надсилаємо…'
                        : 'Надіслати тестове сповіщення з затримкою 10 с',
                  ),
                ),
                const SizedBox(height: 8),
                Text(lastActionMessage, style: smallStyle),
                if (!ready)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Порада: переконайтеся, що сервісний працівник зареєстрований і дозволено показ сповіщень.',
                      style: smallStyle?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                if (pushTestState.lastError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      pushTestState.lastError!,
                      style: smallStyle?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: AppProgressIndicator(size: 24)),
          ),
          error: (error, _) => Text(
            'Помилка ініціалізації сповіщень: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}
