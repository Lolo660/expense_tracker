# Student Finance Tracker

A comprehensive Flutter mobile application designed to help students track daily expenses, manage budgets, and save money efficiently.

## Features

### 🏠 Home Dashboard
- Overview of weekly and monthly spending
- Current budget status and progress
- Savings goals overview
- Recent expenses list
- Personalized greeting messages

### 💰 Expense Management
- Add, edit, and delete expenses
- Categorize expenses (Food, Transport, Entertainment, Shopping, Education, Healthcare, Utilities, Other)
- Add notes and descriptions
- Date-based filtering
- Category-based filtering
- Search and sort functionality

### 📊 Budget Management
- Set monthly budgets
- Track spending progress
- Visual progress indicators
- Budget alerts and warnings
- Budget history tracking
- Tips and recommendations

### 🎯 Savings Goals
- Create multiple savings goals
- Set target amounts and dates
- Track progress over time
- Update savings progress
- Goal completion tracking
- Reminders and notifications

### 📈 Reports & Analytics
- Spending trends over time (weekly, monthly, yearly)
- Category breakdown with pie charts
- Budget vs actual comparisons
- Savings progress analytics
- Personalized insights and recommendations
- Export capabilities

### 🔔 Notifications
- Budget limit warnings
- Savings goal reminders
- Goal completion celebrations
- Overdue goal alerts

## Technical Stack

- **Framework**: Flutter (latest stable version)
- **State Management**: Provider pattern
- **Local Storage**: SQLite database
- **Charts**: fl_chart library
- **Notifications**: flutter_local_notifications
- **UI**: Material Design 3
- **Architecture**: Clean architecture with separation of concerns

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── expense.dart         # Expense entity
│   ├── budget.dart          # Budget entity
│   └── savings.dart         # Savings goal entity
├── providers/               # State management
│   ├── expense_provider.dart
│   ├── budget_provider.dart
│   └── savings_provider.dart
├── screens/                 # UI screens
│   ├── home_screen.dart
│   ├── expenses_screen.dart
│   ├── budgets_screen.dart
│   ├── savings_screen.dart
│   └── reports_screen.dart
├── services/                # Business logic
│   ├── database_service.dart
│   └── notification_service.dart
├── widgets/                 # Reusable UI components
│   ├── overview_card.dart
│   ├── budget_progress_card.dart
│   ├── savings_overview_card.dart
│   ├── expense_list_item.dart
│   ├── savings_goal_card.dart
│   ├── spending_chart.dart
│   ├── category_pie_chart.dart
│   ├── add_expense_dialog.dart
│   ├── add_budget_dialog.dart
│   └── add_savings_goal_dialog.dart
└── utils/                   # Utility functions
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/student_finance_tracker.git
cd student_finance_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Dependencies

The app uses the following key dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1          # State management
  sqflite: ^2.3.0           # Local database
  path: ^1.8.3              # File path utilities
  intl: ^0.18.1             # Internationalization
  fl_chart: ^0.65.0         # Charts and graphs
  shared_preferences: ^2.2.2 # Local preferences
  flutter_local_notifications: ^16.3.0 # Local notifications
```

## Database Schema

### Expenses Table
- `id` (INTEGER PRIMARY KEY)
- `amount` (REAL)
- `category` (TEXT)
- `description` (TEXT)
- `date` (TEXT)
- `note` (TEXT)

### Budgets Table
- `id` (INTEGER PRIMARY KEY)
- `amount` (REAL)
- `month` (TEXT)
- `year` (INTEGER)
- `createdAt` (TEXT)
- `isActive` (INTEGER)

### Savings Goals Table
- `id` (INTEGER PRIMARY KEY)
- `title` (TEXT)
- `description` (TEXT)
- `targetAmount` (REAL)
- `currentAmount` (REAL)
- `targetDate` (TEXT)
- `createdAt` (TEXT)
- `isCompleted` (INTEGER)
- `note` (TEXT)

## Features in Detail

### Expense Tracking
- **Manual Entry**: Users can manually add expenses with amount, category, description, date, and optional notes
- **Categories**: Predefined expense categories with color coding and icons
- **Filtering**: Filter expenses by date range and category
- **Search**: Search through expense descriptions and notes
- **History**: View complete expense history with sorting options

### Budget Management
- **Monthly Budgets**: Set spending limits for each month
- **Progress Tracking**: Visual progress bars showing budget utilization
- **Alerts**: Notifications when approaching or exceeding budget limits
- **Flexibility**: Adjust budgets throughout the month
- **Historical Data**: Track budget performance over time

### Savings Goals
- **Goal Creation**: Set multiple savings targets with descriptions
- **Progress Tracking**: Monitor savings progress with visual indicators
- **Deadlines**: Set target dates for goal completion
- **Updates**: Easily update current savings amounts
- **Motivation**: Celebrate goal completions and track achievements

### Analytics & Reports
- **Spending Trends**: Line charts showing spending patterns over time
- **Category Analysis**: Pie charts breaking down spending by category
- **Budget Comparison**: Visual comparison of budget vs actual spending
- **Insights**: AI-powered recommendations based on spending patterns
- **Export**: Generate reports for external analysis

## Best Practices Implemented

### Code Quality
- **Separation of Concerns**: Clear separation between UI, business logic, and data layers
- **Reusable Widgets**: Modular widget design for maintainability
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Loading States**: Proper loading indicators and state management
- **Form Validation**: Input validation with helpful error messages

### Performance
- **Efficient Queries**: Optimized database queries for better performance
- **Lazy Loading**: Load data only when needed
- **Memory Management**: Proper disposal of controllers and listeners
- **Image Optimization**: Efficient handling of icons and images

### User Experience
- **Material Design 3**: Modern, intuitive UI following latest design guidelines
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Accessibility**: Proper contrast ratios and touch targets
- **Offline Support**: Works without internet connection
- **Data Persistence**: All data stored locally for privacy

## Sample Data

The app comes with sample data for testing:

- Sample expenses across different categories
- Default monthly budget
- Sample savings goal (Emergency Fund)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Enhancements

- **Cloud Sync**: Backup and sync data across devices
- **Multiple Currencies**: Support for different currencies
- **Receipt Scanning**: OCR for automatic expense entry
- **Bill Reminders**: Payment due date notifications
- **Investment Tracking**: Monitor investment portfolios
- **Social Features**: Share goals and achievements with friends
- **Advanced Analytics**: Machine learning insights
- **Export Options**: PDF and CSV report generation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation

## Acknowledgments

- Flutter team for the amazing framework
- Provider package maintainers
- fl_chart library contributors
- SQLite team for the database engine
- Material Design team for design guidelines

---

**Note**: This app is designed specifically for students but can be used by anyone looking to track their personal finances. The interface is optimized for mobile use and provides a comprehensive solution for financial management.
# expense_tracker
