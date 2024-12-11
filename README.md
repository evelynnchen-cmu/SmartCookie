# 67443-team10

README requirements: include all justifications and disclaimers and explanations

The SmartCookie app is designed to streamline studying for students by offering tools for organizing notes, extracting text, and interacting with AI-powered features such as chat-based study assistance and quizzes. Its mobile-first design enables learning on the go, providing students with a centralized, interactive, and intelligent platform for note management and learning enhancement.

## Installation and Setup
**Important:** Add Secrets.plist and GoogleService-Info.plist (provided to Prof H via Slack) to the root of Team10Firebase project. 

1. Clone the repository
   ```
    git clone https://github.com/evelynnchen-cmu/67443-team10.git
   ```
2. Open project in Xcode and add required files (provided to Prof H via Slack) to the root of the Team10Firebase project.
   - Secrets.plist file contains the OpenAI API key
   - GoogleService-Info.plist file for Firebase configuration

3. Build and run the app on an iPhone (not simulator) iOS version 18. If necessary, can downgrade our app to run on lower iOS versions. @EMMA ADD TO THIS

## Key Features
1. Image Parser: Upload or capture photos of notes and extract their contents for editing or storage purposes.
2. Study Assistant: Answer questions, summarize notes, and reference stored content

## Design Decisions
- Upload pdf only possible within course view, not in any other views
- Majority of our design decisions were informed by user feedback during user testing, see reports (link here)
- Making a general settings page
  - Supporting functionality of allowing users to select if they want chat responses and quiz questions to be limited to their notes only or also be able to access intern
- Chat prompt recommendations - quick usability
- Upload pdfs since most users have notes as pdf
  - Intended use of upload pdf is to upload text-only PDFs (use of pdfkit over open ai), currently images within a pdf are not extracted with pdf
- Clarify intended flows and flows TAs/prof H should not attempt
- Simplified navigation by centralizing settings.
- Removed points system in favor of streak-based incentives due to lack of user interest.

## Future Extensions
- Expand app to support accessibility features like audio transcriptions
