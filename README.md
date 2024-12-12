# 67443-team10

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

3. Build and run the app on an iPhone (not simulator) iOS version 18. If necessary, can downgrade our app to run on lower iOS versions.

## Design Decisions
Generally, many of our design decisions were based on user feedback received throughout the ideation and development process. Our user testing reports cover these decisions in much greated depth, and can be found here: [Sprint 2](https://docs.google.com/document/d/1jH_xv7wfiSZur2KKgGq4W6AJhWWvTzmzcy_XwHZ1FUo/edit?usp=sharing), and [Sprint 5](https://docs.google.com/document/d/1nSijWxFvLL3BzYLVRLy4AT7Zor1WZ2SGQcPo0ch3bOw/edit?usp=sharing)

- Making a general settings page
  - Supporting functionality of allowing users to select if they want chat responses and quiz questions to be limited to their notes only or also be able to access intern
- Chat prompt recommendations - quick usability
- Upload pdfs since most users have notes as pdf
  - Intended use of upload pdf is to upload text-only PDFs (use of pdfkit over open ai), currently images within a pdf are not extracted with pdf
- Clarify intended flows and flows TAs/prof H should not attempt
- Simplified navigation by centralizing settings.
- Removed points system in favor of streak-based incentives due to lack of user interest.

Some specific design decisions we wanted to highlight/justify:
- Upload PDF Functionality
  Restricted to within course view only, while images can be uploaded/scanned throughout the app. This decision allows us to centralize note organization, ensuring that uploaded PDFs are directly associated with specific courses. By limiting where users can perform this action, this prevents clutter or confusion and also aligns with user feedback received emphasizing the need for structured workflows within a course-based context.

- General Settings Page
Centralized location for managing app preferences, reducing navigation complexity.
Added flexibility for users to choose the scope of AI features (notes-only vs. external data).
Simplifies the app’s cognitive load by eliminating multiple settings scattered across various views.

- Chat Prompt Recommendations
Enable quick usability by suggesting commonly used prompts (e.g., "Summarize this note," "Create a quiz from this topic").
Minimizes typing effort, making the app more efficient and user-friendly.


- PDF Upload and Text Extraction
PDF uploads focus on text-based notes, as these are more compatible with current parsing technologies.
Recognized limitation: PDFs with embedded images are not fully supported, but future updates could address this.

- Streak-Based Incentives
Why Not Points?
User testing showed low engagement with point systems.
Streak-based rewards, such as maintaining daily or weekly study goals, align more closely with intrinsic motivators.


## Tech Decisions 
- OCR (Parsing Images): OpenAI API vs. AWS Textract, Google Cloud Vision
- PDFKit vs. OpenAI API parse pdf
   - Chose PDFKit over OpenAI for parsing to optimize for local processing and cost efficiency.


## Testing Issues 
Based on what was mentioned in lecture, we did not do UI tests. We recognize that this impacted our testing code coverage because much of our code logic is in views. :)

We also made the decision to write most of our tests using Firebase directly, rather than using mocks. We felt that testing with the real Firebase environment would allow us to ensure no discrepancies between our app and Firebase services, as well as validate the end-to-end functionality of our app. A limitation of this approach is that amount of extra calls we would be making to Firebase while testing, as well as the potential for messing up our app's data if tests are not properly teared down.


## Future Extensions
- Expand app to support accessibility features like audio transcriptions
- Offer better support for parsing and displaying advanced content such as code, math symbols, etc.
