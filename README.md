# CoStudio - Premium AI Assistant

A luxury, fluid, and premium AI chat interface with session management, multiple AI model support, and elegant design.

## Features

- **Luxury UI Design**: Premium color scheme, gradient backgrounds, and elegant typography
- **Fluid Animations**: Smooth transitions, hover effects, and loading animations
- **Session Management**: Create, switch, and delete chat sessions with proper delete icon functionality
- **Multiple AI Models**: Support for GPT-4, GPT-3.5, Claude 3, and Gemini
- **Responsive Design**: Works perfectly on desktop and mobile devices
- **Theme Toggle**: Dark and light mode support
- **Quick Actions**: Predefined prompts for common tasks
- **Real-time Typing Indicators**: Visual feedback when AI is responding
- **Persistent Storage**: All conversations are saved locally

## UI Highlights

- **Playfair Display & Inter Fonts**: Premium typography for headings and body text
- **Glass Morphism Effects**: Subtle blur effects on panels
- **Gradient Accents**: Beautiful gradient backgrounds and borders
- **Custom Scrollbars**: Styled scrollbars for better aesthetics
- **Hover Effects**: Interactive elements respond to user actions
- **Toast Notifications**: Non-intrusive notifications for user feedback

## Bug Fixes

- ✅ Fixed session delete icon bug - now properly stops event propagation
- ✅ Fixed session selection highlighting
- ✅ Fixed message scrolling to bottom
- ✅ Fixed textarea auto-resizing
- ✅ Fixed theme toggle persistence

## How to Use

1. Open `index.html` in a modern web browser
2. Click "New Chat" to start a conversation
3. Type your message and press Enter or click Send
4. Use the sidebar to switch between sessions
5. Click the delete icon on any session to remove it
6. Use the model selector to change AI models
7. Toggle between dark and light themes

## Technical Stack

- Pure HTML5, CSS3, and JavaScript
- No external dependencies (except Google Fonts)
- LocalStorage for data persistence
- Modern CSS features (Flexbox, Grid, CSS Variables)
- SVG icons for crisp visuals at any size

## Customization

You can customize the application by modifying the CSS variables at the top of the `index.html` file:

```css
:root {
    --primary: #6366f1;
    --secondary: #ec4899;
    --accent: #f59e0b;
    /* ... and more */
}
```

## License

MIT License - Feel free to use, modify, and distribute.

---

**Created with ❤️ for premium AI experiences**
