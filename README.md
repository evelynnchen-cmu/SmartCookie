# SmartCookie

CMU F24 67443 Mobile Application Design and Development  
by Alanna Cao, Emma Tong, Evelynn Chen, and Vicky Chen

<img src="https://github.com/user-attachments/assets/6c937999-0caa-458a-b657-9bd95e74da98" alt="SmartCookie logo" width="6%">

SmartCookie is an iOS app that streamlines students' studying by offering tools for organizing class materials of different formats and interacting with AI-powered features such as a context-aware chatbot and dynamically generated quizzes with error tracking. Its mobile-first design enables learning on the go, providing students with a centralized, interactive, and intelligent platform for note management and learning enhancement.

<img src="https://github.com/user-attachments/assets/43e0e8b7-22c2-4dfb-ba17-e79d098dc57e" alt="SmartCookie poster" width="50%">

## Tech stack
- Swift
- SwiftUI
- Firebase
- Firebase Storage
- OpenAI API
- UIKit
- PDFKit

## Installation and Setup
**Important:** This project relies on Firebase and OpenAI APIs, but our subscriptions for these services are no longer active. These instructions apply to anyone who wishes to personally install our app, as well as those who want to test or develop it further. To set up the app locally, follow the steps below:

1. Clone the repository
   ```
    git clone https://github.com/evelynnchen-cmu/67443-team10.git
   ```
2. Prepare Local Environment
   Replace the Secrets.plist (OpenAI API) and GoogleService-Info.plist (Firebase) files with your own configuration files:
      - GoogleService-Info.plist: Obtain this by setting up your own Firebase project. Follow [Firebase's setup guide](https://firebase.google.com/docs/web/setup) to configure Firestore and Storage. Then update the app to connect to your Firebase project (modify Info.plist file).
      - Secrets.plist: Replace the OpenAI API key with your own key. Follow the [OpenAI API setup guide](https://platform.openai.com/docs/quickstart) to obtain this key.

3. Open the project in Xcode. Build and run the app on an iPhone (not simulator), iOS version 18. If necessary, can downgrade our app to run on lower iOS versions although some icons are not available in lower iOS versions and will not display (icons for notes and add new note icon (located in the top right) in CourseView/FolderView and icons for uploading new image/pdf in NoteView (located in the top right)). UI will also be slightly different.
   - Can downgrade to iOS version >= 17.6. If the minimum iOS version is 18.0, can change it by going to Targets->Team10Firebase->General->Minimum Deployments. You must also change the Info.plist
   - If the bundleID does not work/it says it is taken, change it in Signing & Capabilities to [your name].Team10Firebase. You must also make this change in the Info.plist bundle ID field (update to match signing team, [yourname].Team10Firebase).

## Design Decisions
SmartCookie's design prioritizes user-centric features, guided by iterative feedback and testing. The following are some of our key design decisions we want to highlight:

- **Organized Note Uploads:**
PDF uploads are restricted to the course view, while images can be uploaded throughout the app. This distinction was made to centralize note organization and streamline workflows based on user feedback emphasizing the importance of structure in course-based contexts.

- **Streamlined Settings Management:**
A centralized settings page reduces navigation complexity. Users can configure AI features, choosing whether to restrict functionality (e.g., chat responses, quiz generation) to their notes or include external sources. This design balances flexibility with simplicity, catering to diverse study preferences.

- **Chat Prompt Recommendations:**
Pre-filled prompt suggestions (e.g., "Summarize the key points of...") enable faster AI chatbot interactions, reducing typing effort and enhancing usability during high-stress study sessions.

- **Focused PDF Text Extraction:**
Designed the PDF upload feature to focus specifically on text-based PDFs, as these are more compatible with the app’s current parsing technologies. While the app does not currently extract images embedded within PDFs, this limitation reflects the trade-offs in development prioritization, with the potential for future updates to address it. This feature was prioritized because most users expressed a desire to migrate existing materials, such as their professor’s lecture slides, into the app. By enabling students to integrate these resources seamlessly, the app enhances their ability to apply its features—like summarization, organization, and quiz generation—directly to their learning.

- **Streak-Based Incentives:**
Streak-based incentives replaced a traditional points system after feedback indicated greater alignment with students' intrinsic motivators such as maintaining daily or weekly study goals. This feature encourages consistent usage without unnecessary gamification.

## Tech Decisions 
- OCR (Parsing Images): OpenAI API vs. AWS Textract, Google Cloud Vision
   - Chose OpenAI's gpt4o-mini model because it was best suited for our use case and was the most cost effective. AWS Textract broke down the given image into individual words and gave more information (like its bounding box and confidence score) that we didn't need. OpenAI's gpt-vision model performed about the same as 4o-mini, but took significantly longer to parse than 4o-mini.
- PDFKit vs. OpenAI API parse pdf
   - Chose PDFKit over OpenAI for parsing to optimize for local processing and cost efficiency.
   - While using the OpenAI API for parsing a PDF similarly to how images are parsed would've allowed us to maintain consistency within our app, PDFKit offered all of the basic functionality for supporting PDF upload and parse that our users wanted prioritized the most. 
- Firebase Firestore vs AWS S3
   - Chose Firebase Firestore because there was more classroom help with this service and it is built to integrate with Firebase.


## Testing Issues 
SmartCookie leverages a combination of real-environment and mock-based testing strategies to ensure functionality and reliability.

- **UI Testing**

  To avoid slow and fragile tests, we focused on model and service testing rather than extensive UI testing. While this impacted coverage, our approach emphasized validating core functionalities over fragile, time-intensive UI test cases.

- **Firebase Testing**

  Testing utilized both mocks and real Firebase calls. While real-environment tests validate end-to-end integration, they introduced potential risks such as data conflicts, mitigated through careful teardown processes. Mocks were used where possible to minimize Firebase call costs and side effects.

- **OpenAI Testing**

  OpenAI API calls were tested exclusively using mocks due to cost considerations. Coverage focused on core OpenAI-related functions, ensuring robust testing within practical constraints.

- **View Model Testing**
  
   Three of four view models achieved over 90% test coverage, demonstrating the correctness of essential app components. Testing QuizViewModel proved challenging due to variable quiz generation but remains a future area for refinement.


### Test Coverage
Screenshots below demonstrate our Xcode testing suite and test coverage report:

   <img width="447" alt="IMG_8307" src="https://github.com/user-attachments/assets/eade1409-e747-4261-88de-1bbd7ed78dae" />

   <img width="681" alt="IMG_6225" src="https://github.com/user-attachments/assets/b65f025f-6294-4ae2-8bff-4a4b1097dc80" />

## Future Extensions
- Expand app to support accessibility features like audio transcriptions
- Offer better support for parsing and displaying advanced content such as code, math symbols, etc.
- Support PDF image extraction
- Allow users to friend other users to keep each other accountable or start friend streaks similar to Duolingo.
