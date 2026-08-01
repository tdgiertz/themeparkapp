---
name: flutter-use-snackbars
description: Use the `SnackBar` widget to communicate transient events. Use when you need to provide brief feedback about an action without interrupting the user experience.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Sat, 01 Aug 2026 16:42:46 GMT
---
# Implementing Flutter SnackBars

## Contents
- [Core Concepts & Context](#core-concepts--context)
- [Behavior & Actions](#behavior--actions)
- [Workflow: Displaying Transient Events](#workflow-displaying-transient-events)
- [Examples](#examples)

## Core Concepts & Context

Configure the environment and context required to display temporary event notifications.

*   **ScaffoldMessenger:** SnackBars are managed by the `ScaffoldMessenger`, which coordinates visual notifications across your app's `Scaffold` widgets. Always call it using `ScaffoldMessenger.of(context)`.
*   **Event-Driven:** SnackBars should only trigger in response to discrete events (e.g., "Item deleted", "Message sent", or a background refresh failure). Do not use them for ongoing app states.
*   **Visibility:** SnackBars disappear automatically after a set duration. Never place critical, unrecoverable error information inside a SnackBar.

## Behavior & Actions

Customize the visual presentation and interactivity of the SnackBar.

*   **Behavior:** Modern Material 3 guidelines favor floating SnackBars over fixed ones. Use `behavior: SnackBarBehavior.floating` to elevate the SnackBar above bottom navigation bars and floating action buttons.
*   **Actions:** Provide a single optional action (like "Undo" or "Retry") using the `action` property. If the user ignores the action, the app must continue functioning normally.
*   **Duration:** The default duration is 4 seconds. You can override this using the `duration` property, but keep it brief (3 to 10 seconds maximum).
*   **Queueing:** Rapidly triggering multiple SnackBars queues them. If actions are highly repetitive (like deleting multiple items in a row), consider clearing the queue first using `ScaffoldMessenger.of(context).clearSnackBars()` or batching the notifications.

## Workflow: Displaying Transient Events

Use the following checklist to implement and validate SnackBar operations.

**Task Progress:**
- [ ] 1. Identify the discrete event that requires lightweight user feedback.
- [ ] 2. Ensure the triggering widget is a descendant of a `Scaffold` (or use a global navigator key if executing from outside the UI layer).
- [ ] 3. Construct the `SnackBar` widget with concise `content` (usually a single `Text` widget).
- [ ] 4. Set `behavior: SnackBarBehavior.floating` for modern styling.
- [ ] 5. (Optional) Add a `SnackBarAction` for optional resolution, such as "Undo".
- [ ] 6. Call `ScaffoldMessenger.of(context).showSnackBar(snackBar)` to execute.
- [ ] 7. **Feedback Loop:** Run the app -> trigger the event -> ensure the SnackBar does not obscure critical UI elements -> verify it dismisses automatically.

## Examples

### High-Fidelity Implementation: Floating SnackBar with Undo Action

```dart
import 'package:flutter/material.dart';

class FavoriteItemsScreen extends StatefulWidget {
  const FavoriteItemsScreen({super.key});

  @override
  State<FavoriteItemsScreen> createState() => _FavoriteItemsScreenState();
}

class _FavoriteItemsScreenState extends State<FavoriteItemsScreen> {
  final List<String> _items = ['Thunder Mountain', 'Space Cruiser', 'Splash Log'];

  void _removeItem(int index) {
    final removedItem = _items[index];
    
    setState(() {
      _items.removeAt(index);
    });

    // Clear existing SnackBars to prevent a massive queue if the user taps fast
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$removedItem removed from favorites'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Re-insert the item if the user taps undo
            setState(() {
              _items.insert(index, removedItem);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_items[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeItem(index),
            ),
          );
        },
      ),
    );
  }
}
```