# Mistral AI CLI Client

A GUI-like terminal chat client for Mistral AI, built with `flutter_terminal_layout`.

## Setup

1.  Get your API Key from [Mistral AI Console](https://console.mistral.ai/).
2.  Create a `.env` file in the project root (or copy `.env.example`).
3.  Add your API key to `.env`:
    ```env
    MISTRAL_API_KEY=your_actual_api_key_here
    ```

## Usage

Run the client from the project root:

```bash
dart bin/mistral/main.dart
```

*   **Type** your message in the input field.
*   **Press Enter** or click **Send** to chat.
*   **Ctrl+C** to exit the application.