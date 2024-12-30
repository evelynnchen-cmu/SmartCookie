# SmartCookie
CMU F24 67-443 Mobile Application Design and Development  
by Alanna Cao, Emma Tong, Evelynn Chen, and Vicky Chen

SmartCookie is an iOS app designed to streamline studying for students by offering tools for organizing class materials of different formats and interacting with AI-powered features such as a context-aware chatbot and dynamically generated quizzes with error tracking. Its mobile-first design enables learning on the go, providing students with a centralized, interactive, and intelligent platform for note management and learning enhancement.

## Installation and Setup
**Important:** Add Secrets.plist and GoogleService-Info.plist (provided to Prof H via Slack) to the root of Team10Firebase project. 

1. Clone the repository
   ```
    git clone https://github.com/evelynnchen-cmu/67443-team10.git
   ```
2. Open project in Xcode and add required files (provided to Prof H via Slack) to the root of the Team10Firebase project.
   - Secrets.plist file contains the OpenAI API key
   - GoogleService-Info.plist file for Firebase configuration

3. Build and run the app on an iPhone (not simulator), iOS version 18. If necessary, can downgrade our app to run on lower iOS versions although some icons are not available in lower iOS versions and will not display (icons for notes and add new note icon (located in the top right) in CourseView/FolderView and icons for uploading new image/pdf in NoteView (located in the top right)). UI will also be slightly different.
   - Can downgrade to iOS version >= 17.6. If the minimum iOS version is 18.0, can change it by going to Targets->Team10Firebase->General->Minimum Deployments. You must also change the Info.plist
   - If the bundleID does not work/it says it is taken, change it in Signing & Capabilities to [your name].Team10Firebase. You must also make this change in the Info.plist bundle ID field (update to match signing team, [yourname].Team10Firebase).

## Design Decisions
Generally, most of our design decisions were based on user feedback received throughout the ideation and development process. Our user testing reports cover these decisions in much greated depth, and can be found here: [Sprint 2](https://docs.google.com/document/d/1jH_xv7wfiSZur2KKgGq4W6AJhWWvTzmzcy_XwHZ1FUo/edit?usp=sharing), and [Sprint 5](https://docs.google.com/document/d/1nSijWxFvLL3BzYLVRLy4AT7Zor1WZ2SGQcPo0ch3bOw/edit?usp=sharing)

**Some specific design decisions we wanted to highlight/justify:**

- Upload PDF Functionality
  
   Restricted to within course view only, while images can be uploaded/scanned throughout the app. This decision allows us to centralize note organization, ensuring that uploaded PDFs are directly associated with specific courses. By limiting where users can perform this action, this prevents clutter or confusion and also aligns with user feedback received emphasizing the need for structured workflows within a course-based context.

- General Settings Page
  
   Centralized app settings in one location to reduce navigation complexity and improve usability. This decision eliminates the need for users to search across different views for scattered settings, making it easier for them to configure the app. Specifically, it allows users to control whether AI features (e.g., chat responses and quiz questions) are restricted to their own notes or can also utilize external internet data, supporting flexibility and personal preference.

- Chat Prompt Recommendations

  Introduced pre-filled chat prompt recommendations (e.g., "Summarize the key points of," "Explain this concept") to enable faster interactions with the AI assistant. This minimizes typing effort and caters to user feedback highlighting the importance of quick usability, especially during high-stress study sessions.

- PDF Upload and Text Extraction

   Designed the PDF upload feature to focus specifically on text-based PDFs, as these are more compatible with the app’s current parsing technologies. While the app does not currently extract images embedded within PDFs, this limitation reflects the trade-offs in development prioritization, with the potential for future updates to address it. This feature was prioritized because most users expressed a desire to migrate existing materials, such as their professor’s lecture slides, into the app. By enabling students to integrate these resources seamlessly, the app enhances their ability to apply its features—like summarization, organization, and quiz generation—directly to their learning.

- Streak-Based Incentives

   Replaced the originally planned points system with streak-based rewards after user testing revealed a lack of interest in points. Streak-based incentives, such as maintaining daily or weekly study goals, are more aligned with students' intrinsic motivators, promoting consistency without unnecessary gamification elements.


## Tech Decisions 
- OCR (Parsing Images): OpenAI API vs. AWS Textract, Google Cloud Vision
   - Chose OpenAI's gpt4o-mini model because it was best suited for our use case and was the most cost effective. AWS Textract broke down the given image into individual words and gave more information (like its bounding box and confidence score) that we didn't need. OpenAI's gpt-vision model performed about the same as 4o-mini, but took significantly longer to parse than 4o-mini.
- PDFKit vs. OpenAI API parse pdf
   - Chose PDFKit over OpenAI for parsing to optimize for local processing and cost efficiency.
   - While using the OpenAI API for parsing a PDF similarly to how images are parsed would've allowed us to maintain consistency within our app, PDFKit offered all of the basic functionality for supporting PDF upload and parse that our users wanted prioritized the most. 
- Firebase Firestore vs AWS S3
   - Chose Firebase Firestore because there was more classroom help with this service and it is built to integrate with Firebase.


## Testing Issues 
Based on what was mentioned in lecture about how UI tests are very slow and fragile, we did not write any tests for views. We recognize that this impacted our testing code coverage because much of our code logic is in views.

We also made the decision to write our tests using a combination of both mocks and Firebase directly. We felt that testing with the real Firebase environment would allow us to ensure no discrepancies between our app and Firebase services, as well as validate the end-to-end functionality of our app. A limitation of this approach is that amount of extra calls we would be making to Firebase while testing, as well as the potential for messing up our app's data if tests are not properly teared down. This is why we used mocks where we could, in order to minimize the amount of side effects.

For our OpenAI tests, we used only mocks since the API calls to Open AI are more costly than the calls to Firebase. We aimed to achieve test coverage by testing the three functions located within the OpenAI class, although couldn’t achieve full test coverage due to being able to not mock the Open AI API endpoint.

Overall, testing coverage for three of our four view models reached over 90% coverage. QuizViewModel was difficult to fully test due to the nature of quizzes generated being variable in length. Since our project follows the MVVM architecture, thorough testing of these files allowed us to meaningfully guarantee the correctness of a significant aspect of our app. Below are screenshots showing our passing XCode testing suite and test coverage report.

   <img width="447" alt="IMG_8307" src="https://github.com/user-attachments/assets/eade1409-e747-4261-88de-1bbd7ed78dae" />

   <img width="681" alt="IMG_6225" src="https://github.com/user-attachments/assets/b65f025f-6294-4ae2-8bff-4a4b1097dc80" />

## Future Extensions
- Expand app to support accessibility features like audio transcriptions
- Offer better support for parsing and displaying advanced content such as code, math symbols, etc.
- Support PDF image extraction
- Allow users to friend other users to keep each other accountable or start friend streaks similar to Duolingo.
