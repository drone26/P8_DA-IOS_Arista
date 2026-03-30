## [unreleased]

### 🚀 Features

- *(data)* Add coredata entities for User, Exercise, and Sleep
- *(models)* Implement repository pattern and domain error handling
- *(viewmodels)* Add observable viewmodels for all app modules
- *(views)* Implement main TabView and specialized feature views
- *(models)* Use do-try-catch for loadStores() with withCheckedThrowingContinuation

### 🐛 Bug Fixes

- *(models)* Change error variable test for loadStores()
- *(models-viewmodels)* Typo

### 💼 Other

- Remove unused files

### 📚 Documentation

- Ajouter le README détaillé en français
- Add comments
- Add CHANGELOG
- Update CHANGELOG
- Add comments
- Update CHANGELOG

### 🧪 Testing

- *(models)* Add unit tests for repository data operations
- *(viewmodels)* Add integration tests for viewmodel logic and error states
- *(models)* Add unit tests for validator in ExerciceRepository
- *(viewmodels)* Add unit tests for validator in AddExerciseViewModel

### ⚙️ Miscellaneous Tasks

- *(swift6)* Enable strict concurrency and MainActor isolation
