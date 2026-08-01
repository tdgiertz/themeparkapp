---
name: flutter-use-persistent-messages
description: Use `MaterialBanner` or inline error widgets to display ongoing states. Use when a condition affects the app's functionality and requires user resolution.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Sat, 01 Aug 2026 16:42:46 GMT
---
# Implementing Persistent Messages

## Contents
- [Global Banners vs. Inline Widgets](#global-banners-vs-inline-widgets)
- [Actions & Lifecycle Management](#actions--lifecycle-management)
- [Workflow: Displaying Ongoing States](#workflow-displaying-ongoing-states)
- [Examples](#examples)

## Global Banners vs. Inline Widgets

Determine the scope of the ongoing state to choose the correct UI component.

*   **MaterialBanner (Global Scope):** Use `MaterialBanner` for app-wide or screen-wide conditions that persist (e.g., "No internet connection", "Subscription expired"). It spans the full width of the screen, anchoring just below the `AppBar`.
*   **Inline Widgets (Local Scope):** Use a custom layout (like a `Card` or a centered `Column`) for localized states. If a single graph fails to load but the rest of the dashboard is functional, replace only the graph with an inline error widget.
*   **State-Driven:** Unlike SnackBars, persistent messages reflect the current state. If the state changes (e.g., internet is restored), the UI must update to remove the message.

## Actions & Lifecycle Management

Handle user interactions and explicitly control when the message is removed.

*   **Mandatory Actions:** A persistent message is taking up permanent screen real estate; it should always provide a way forward. Include buttons for "Retry", "Update Settings", or at the bare minimum, a "Dismiss" option.
*   **Manual Dismissal:** `MaterialBanner` does not auto-hide. You must programmatically remove it using `ScaffoldMessenger.of(context).hideCurrentMaterialBanner()` when the user resolves the issue or taps dismiss.
*   **Riverpod / State Management:** The most robust way to manage persistent messages is by listening to state streams and imperatively showing/hiding banners or declaratively swapping out inline widgets.

## Workflow: Displaying Ongoing States

Use the following checklist to implement and validate persistent message operations.

**Task Progress:**
- [ ] 1. Identify the ongoing state (e.g., disconnected, initial load failure).
- [ ] 2. Determine the scope: Global (use `MaterialBanner`) or Local (use Inline Widget).
- [ ] 3. Design the message with a clear description of the problem.
- [ ] 4. Provide at least one actionable resolution (Retry, Settings, or Dismiss).
- [ ] 5. **If using MaterialBanner:** Call `ScaffoldMessenger.of(context).showMaterialBanner(...)`.
- [ ] 6. **If using MaterialBanner:** Ensure the action callbacks include `hideCurrentMaterialBanner()`.
- [ ] 7. **Feedback Loop:** Run the app -> trigger the state -> verify the user cannot proceed without acknowledging the banner -> verify the banner completely disappears when resolved.

## Examples

### High-Fidelity Implementation: Inline Error and Global Banner

```dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isOffline = false;
  bool _hasLocalError = true; // Simulating a local widget failure

  void _toggleGlobalOfflineState() {
    setState(() {
      _isOffline = !_isOffline;
    });

    if (_isOffline) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          padding: const EdgeInsets.all(16),
          leading: const Icon(Icons.wifi_off, color: Colors.orange),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          content: const Text('You are currently offline. Some features are unavailable.'),
          actions: [
            TextButton(
              onPressed: () {
                // Hide banner and reset state
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                setState(() => _isOffline = false);
              },
              child: const Text('DISMISS'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_isOffline ? Icons.wifi_off : Icons.wifi),
            onPressed: _toggleGlobalOfflineState,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Local State Example:'),
            const SizedBox(height: 16),
            // INLINE ERROR WIDGET
            _hasLocalError
                ? Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load favorite rides',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              setState(() => _hasLocalError = false);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('RETRY'),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Card(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(child: Text('Data Loaded Successfully!')),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
```