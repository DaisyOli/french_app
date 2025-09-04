French App is a next-generation web application for learning French, featuring interactive activities, gamification, and a robust, scalable architecture. Built with Ruby on Rails, it delivers a seamless experience for both students and teachers.

---


## � Features

- **Dual Authentication System:** Separate flows for teachers and students, with tailored permissions
- **Multiple Exercise Types:**
  - Fill-in-the-blanks
  - Sentence and paragraph ordering
  - Column associations
  - Multiple choice questions
- **Gamification:** Daily streaks, motivational trophies, and progress tracking
- **Personalized Dashboards:** Custom interfaces for teachers and students
- **Invitation System:** Teachers can invite students via email
- **Production-Ready:**
  - Activity size limits (max 25 questions) to prevent timeouts
  - Asynchronous and batch processing for large activities
  - Email notifications for processing status
  - Timeout protection and robust error handling
  - Health checks and structured logging


## 🛠️ Tech Stack

- **Backend:** Ruby 3.3.5, Rails 7.1.3
- **Database:** PostgreSQL
- **Cache:** Redis
- **Authentication:** Devise, Devise Invitable
- **Frontend:** Bootstrap 5.3, Stimulus, Turbo, Importmap
- **Security:** Rack::Attack, Rack::Timeout, Secure Headers
- **Background Jobs:** Active Job (async)
- **Email:** Action Mailer (Gmail SMTP)
- **Containerization:** Docker, Docker Compose
- **Testing:** Minitest (comprehensive coverage)
- **Monitoring:** Health checks, structured logging

## 🚀 Installation and Setup

### Prerequisites

- Ruby 3.3.5
- PostgreSQL
- Node.js and Yarn
- Git

### 1. Clone the repository

```bash
git clone <repository-url>
cd french_app
```

### 2. Install dependencies

```bash
bundle install
yarn install
```

### 3. Configure environment variables

Create a `.env` file in the project root:

```bash
# Database Configuration
FRENCH_APP_DATABASE_PASSWORD=your_secure_password

# Rails Configuration (Generate with: bundle exec rails secret)
SECRET_KEY_BASE=generate_with_rails_secret_command
DEVISE_SECRET_KEY=generate_with_rails_secret_command

# Email Configuration
GMAIL_USERNAME=your_email@gmail.com
GMAIL_PASSWORD=your_gmail_app_password

# Application Settings
RAILS_ENV=development
RAILS_LOG_LEVEL=info

# Performance Settings (Optional - based on Portuguese app experience)
ACTIVITY_QUESTION_LIMIT=25
BATCH_PROCESSING_SIZE=5
```

### 4. Generate security keys

```bash
# Generate secret keys (NEVER commit these to version control)
bundle exec rails secret  # Use output for SECRET_KEY_BASE
bundle exec rails secret  # Use output for DEVISE_SECRET_KEY
```

### 5. Setup the database

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 6. Run the application

```bash
rails server
```

The application will be available at `http://localhost:3000`

## 🐳 Docker

### Development with Docker Compose (Recommended)

```bash
# Start all services (PostgreSQL, Redis, Rails)
docker-compose up

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f web

# Stop services
docker-compose down
```

### Production Docker Build

```bash
docker build -t french-app:production .
docker run -p 3000:3000 --env-file .env.production french-app:production
```

## 📚 How to Use

### For Teachers

1. Go to `/users/sign_up` to create an account
2. Login at `/users/sign_in`
3. Create activities in the dashboard
4. Invite students through the invitation system

### For Students

1. Receive an email invitation from the teacher
2. Accept the invitation and set your password
3. Login at `/students/sign_in`
4. Complete available activities

## ⚡ Performance & Production Optimizations

This application includes several production-ready optimizations based on real-world experience:

### Activity Size Management
- **Automatic validation**: Activities are limited to 25 questions maximum to prevent timeout issues
- **Smart counting**: Counts all question types (multiple choice, fill-blanks, orderings, associations)
- **User-friendly errors**: Clear French error messages when limits are exceeded

### Asynchronous Processing
- **Background jobs**: Large activities are processed asynchronously using Active Job
- **Batch processing**: Questions are processed in batches of 5 to optimize performance
- **Email notifications**: Users receive emails when processing completes or fails

### Timeout Protection
- **Rack::Timeout**: Configured with appropriate timeouts for production
- **Custom middleware**: Detects activity-related requests and applies extended timeouts
- **Graceful handling**: Proper error handling and user feedback

### Email System
- **Professional templates**: HTML email templates for processing notifications
- **Error reporting**: Detailed error messages with troubleshooting steps
- **Success confirmations**: Activity completion notifications with direct links

### Code Example - Activity Validation
```ruby
# Prevents timeout issues in production
validate :total_questions_limit

private

def total_questions_limit
  total_questions = questions.count + 
                   fill_blanks.sum { |fb| fb.blanks.count } +
                   sentence_orderings.count +
                   paragraph_orderings.sum { |po| po.paragraph_sentences.count } +
                   column_associations.sum { |ca| ca.association_pairs.count }
  
  if total_questions > 25
    errors.add(:base, "Une activité ne peut pas avoir plus de 25 questions pour éviter les problèmes de performance")
  end
end
```

## 🧪 Testing

```bash
# Run all tests
rails test

# Run specific tests
rails test test/models/
rails test test/controllers/

# Run performance-related tests
rails test test/models/activity_test.rb
```

## 🔒 Security Considerations

### Environment Variables
- **NEVER** commit `.env` files to version control
- Use different secret keys for development and production
- Generate new keys with: `bundle exec rails secret`
- Use strong, unique passwords for database and email

### Production Security
- Enable SSL/HTTPS in production
- Use environment-specific configurations
- Regularly rotate secret keys
- Monitor application logs for security issues


## 👩‍💻 About the Author

Developed by **Daisy Oli** — passionate about education, technology, and building impactful web applications. Always striving for code quality, user experience, and real-world results.

- [LinkedIn](https://www.linkedin.com/in/daisy-oliani-487a6379/)
- [GitHub](https://github.com/DaisyOli)

---

## 📦 Deployment

### Environment Variables for Production

```bash
# Core Rails Configuration
RAILS_ENV=production
SECRET_KEY_BASE=production_secret_key
RAILS_LOG_LEVEL=info

# Database
FRENCH_APP_DATABASE_PASSWORD=production_db_password

# Authentication
DEVISE_SECRET_KEY=production_devise_key

# Email Configuration
GMAIL_USERNAME=production_email
GMAIL_PASSWORD=production_password

# Application Settings
APP_HOST=yourdomain.com

# Cache and Performance
REDIS_URL=redis://localhost:6379/1

# Security (Optional)
RACK_ATTACK_ENABLED=true

# Performance Optimizations
ACTIVITY_QUESTION_LIMIT=25
BATCH_PROCESSING_SIZE=5
TIMEOUT_PROTECTION_ENABLED=true
```

### Deploy with Docker

```bash
docker build -t french-app:production .
docker run -d -p 80:3000 --env-file .env.production french-app:production
```

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## 📞 Support

For support, contact us at: practicefrsite@gmail.com
