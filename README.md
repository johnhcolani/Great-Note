# **Great Note App**

## **Notes Feature Overview**

The **Great-Note** app provides a seamless experience for creating, editing, and managing notes. The notes feature is designed to enhance productivity by offering tools such as rich text editing, sharing options, and now a sticky note header for better usability.

### **Features of the Notes Section**
- **Rich Text Editor**: Format your notes with **bold**, *italic*, and alignment tools, powered by `flutter_quill`.
- **Media Embedding**: Add **images** or **videos** directly to your notes.
- **Sharing Options**: Share notes as **text** or **PDF** with ease.
- **Smooth User Experience**: Sticky headers and preserved scroll positions ensure a streamlined workflow.

---

### **Platform-Specific Views**

#### iOS View
![iOS Screenshot](../../../../var/folders/9f/8k8t0w150811_4901vtg12mh0000gn/T/simulator_screenshot_5FCAF106-FD60-489E-9590-35B0D3808E33.png)

#### Android View
![Android Screenshot](../../Desktop/Screenshot_20241228_082432.png)

*Replace `path-to-ios-image` and `path-to-android-image` with the actual file paths or URLs of your images.*

---

## **Sticky Note Header with Preserved Scroll Position**

This feature improves the note-taking experience by ensuring users can scroll through long notes without losing access to key actions like editing, deleting, or sharing.

### **What’s New?**
- **Sticky Header**: The note’s title and buttons remain visible at the top of the card while the content scrolls independently.
- **Preserved Scroll Position**: When editing a note, the app remembers the last scroll position and starts the editor from the same point.

---

### **How It Works**
1. The scroll position of a note is tracked using `ScrollController`.
2. When navigating to the editor, the **scroll offset** is passed and restored automatically, enabling editing directly from the scrolled section.
3. The implementation uses Flutter widgets like `SingleChildScrollView` and `Column` to structure content for better usability.

---
