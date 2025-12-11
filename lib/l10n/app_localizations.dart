import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Fizmat App',
      'login_title': 'Sign In',
      'email_or_phone': 'Email',
      'password': 'Password',
      'sign_in': 'Sign In',
      'forgot_password': 'Forgot password?',
      'no_account': 'Don\'t have an account?',
      'register': 'Register',
      'register_title': 'Create Account',
      'full_name': 'Full Name',
      'email': 'Email',
      'confirm_password': 'Confirm Password',
      'create_account': 'Create Account',
      'have_account': 'Already have an account?',
      'sign_in_link': 'Sign In',
      'forgot_password_title': 'Reset Password',
      'enter_email': 'Enter your email',
      'send_code': 'Send Code',
      'enter_code': 'Enter Code',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'reset_password': 'Reset Password',
      'verification_title': 'Email Verification',
      'verification_subtitle': 'Enter the 6-digit code sent to',
      'verify': 'Verify',
      'resend_code': 'Resend Code',
      'code_sent': 'Code sent successfully',
      'invalid_code': 'Invalid code',
      'invalid_email': 'Invalid email address',
      'email_required': 'Email is required',
      'password_required': 'Password is required',
      'name_required': 'Name is required',
      'passwords_dont_match': 'Passwords don\'t match',
      'password_too_short': 'Password must be at least 6 characters',
      'error': 'Error',
      'success': 'Success',
      'verified': 'Verified',
      'loading': 'Loading...',
      'enter_fizmat_email': 'Enter your @fizmat.kz email',
      'fizmat_email_hint': 'your.email@fizmat.kz',
      'fizmat_email_required': 'Fizmat email is required for full access',
      'partial_access_message':
          'You are using a non-fizmat email. Some features will be limited.',
      'full_access': 'Full access granted',
      'limited_access': 'Limited access',
      'russian': 'Russian',
      'kazakh': 'Kazakh',
      'english': 'English',
      'reset_password_description':
          'Enter your email address and we\'ll send you instructions to reset your password',
      'send_reset_link': 'Send Reset Link',
      'back_to_login': 'Back to Login',
      'reset_email_sent': 'Reset Email Sent!',
      'check_email_for_instructions':
          'Please check your email for password reset instructions',
      'theme_settings': 'Theme Settings',
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'auto_theme': 'Auto',
      // Email Verification Screen
      'verify_email_title': 'Verify Your Email',
      'verify_email_sent_to': 'We have sent a verification email to:',
      'verify_email_check': 'Please check your email and click the verification link to continue.',
      'verify_email_waiting': 'Waiting for verification...',
      'verify_email_spam_warning': 'Important: Check your spam/junk folder! Verification emails often end up there.',
      'verify_email_no_email': 'Did not receive the email?',
      'verify_email_resend': 'Resend Verification Email',
      'verify_email_resend_in': 'Resend in {seconds} seconds',
      'verify_email_back': 'Back to Login',
      'verify_email_sent_success': 'Verification email sent! Please check your inbox.',
      'verify_email_create_profile_failed': 'Failed to create user profile. Please try logging in.',
      'verify_email_send_failed': 'Failed to send verification email',
      'verify_email_too_many_requests': 'Too many requests. Please wait a few minutes and try again.',
      'verify_email_send_error': 'Failed to send email',
      // Success Messages
      'success_verification_email_sent': 'Verification email sent. Please check your inbox',
      'success_password_reset_sent': 'Password reset email sent. Please check your inbox',
      'success_profile_updated': 'Profile updated successfully',
      // Auth Errors
      'auth_error_wrong_password': 'Incorrect password. Please try again.',
      'auth_error_invalid_credential': 'Invalid email or password.',
      'auth_error_user_not_found': 'No account found with this email.',
      'auth_error_email_not_verified': 'Email not verified. Please check your inbox.',
      'auth_error_network_request_failed': 'No internet connection. Please check your network.',
      'auth_error_too_many_requests': 'Too many attempts. Please try again later.',
      'auth_error_user_disabled': 'This account has been disabled.',
      'auth_error_operation_not_allowed': 'This operation is not allowed.',
      'auth_error_weak_password': 'Password is too weak. Please use a stronger password.',
      'auth_error_email_already_in_use': 'This email is already registered.',
      'auth_error_invalid_email': 'Invalid email address format.',
      'auth_error_sign_in_failed': 'Sign in failed. Please try again.',
      'auth_error_permission_denied': 'Permission denied. Please contact support.',
      'auth_error_firestore_error': 'Database error. Please try again later.',
      'auth_error_unknown': 'An error occurred. Please try again.',
      // Unverified Email Dialog
      'unverified_email_title': 'Email Not Verified',
      'unverified_email_message': 'This email is already registered but not verified. Please check your inbox or resend the verification email.',
      'unverified_email_resend': 'Resend Verification Email',
      'unverified_email_close': 'Close',
      'unverified_email_success': 'Verification email sent! Please check your inbox.',
      // Profile Screen
      'profile_title': 'Profile',
      'edit_profile': 'Edit Profile',
      'username': 'Username',
      'bio': 'Bio',
      'class_grade': 'Class',
      'gpa': 'GPA',
      'privacy': 'Privacy',
      'public_profile': 'Public',
      'private_profile': 'Private',
      'connect_kundelik': 'Connect Kundelik',
      'disconnect_kundelik': 'Disconnect Kundelik',
      'kundelik_connected': 'Kundelik Connected',
      'kundelik_not_connected': 'Not Connected',
      'edit_photo': 'Change Photo',
      'change_username': 'Username',
      'change_name': 'Full Name',
      'change_bio': 'Bio',
      'change_class': 'Class',
      'username_required': 'Username is required',
      'username_taken': 'This username is already taken',
      'username_invalid': 'Username can only contain letters, numbers, and underscores',
      'username_too_short': 'Username must be at least 3 characters',
      'username_too_long': 'Username must be less than 20 characters',
      'profile_updated': 'Profile updated successfully',
      'logout': 'Logout',
      'settings': 'Settings',
      'account_settings': 'Account Settings',
      'appearance': 'Appearance',
      'save': 'Save',
      'cancel': 'Cancel',
      'enter_username': 'Enter username',
      'enter_bio': 'Tell us about yourself',
      'enter_class': 'Enter your class (e.g., 9A)',
      'no_bio': 'No bio yet',
      'no_class': 'No class specified',
      'no_username': 'Set username',
      'confirm_logout': 'Are you sure you want to logout?',
      'yes': 'Yes',
      'no': 'No',
      // Class & Position
      'grade_number': 'Grade',
      'letter': 'Letter',
      'graduated': 'Graduated',
      'position': 'Position',
      'position_student': 'Student',
      'position_teacher': 'Teacher',
      'position_director': 'Director',
      'position_school_government': 'School Government',
      'position_admin': 'Administrator',
      // Avatar
      'change_avatar': 'Change Avatar',
      'upload_photo': 'Upload Photo',
      'take_photo': 'Take Photo',
      'remove_photo': 'Remove Photo',
      // Friends
      'friends': 'Friends',
      'add_friend': 'Add Friend',
      'remove_friend': 'Remove Friend',
      'friend_requests': 'Friend Requests',
      'accept': 'Accept',
      'decline': 'Decline',
      'no_friends': 'No friends yet',
      'search_users': 'Search users',
      'send_request': 'Send Request',
      'request_sent': 'Request sent',
      'already_friends': 'Already friends',
      // Kundelik
      'kundelik': 'Kundelik',
      'sync_kundelik': 'Sync Kundelik',
      'last_synced': 'Last synced',
      'never_synced': 'Never synced',
      'birthday': 'Birthday',
      'connect': 'Connect',
      'disconnect': 'Disconnect',
      // Admin
      'admin_panel': 'Admin Panel',
      'manage_users': 'Manage Users',
      'change_role': 'Change Role',
      'select_role': 'Select Role',
      'role_updated': 'Role updated successfully',
      'admin_only': 'Admin only',
      // Avatar Upload
      'choose_from_gallery': 'Choose from Gallery',
      'remove_avatar': 'Remove Avatar',
      'avatar_removed': 'Avatar removed',
      'avatar_updated': 'Avatar updated successfully',
      'avatar_upload_failed': 'Failed to upload avatar',
      // General
      'coming_soon': 'Coming soon',
      'language': 'Language',
      // Validation
      'field_required': 'This field is required',
      'select_grade': 'Select grade',
      'select_letter': 'Select letter',
      // Kundelik Integration
      'kundelik_login_description': 'Enter your Kundelik credentials to sync your data',
      'kundelik_username': 'Kundelik Username',
      'kundelik_username_hint': 'Your login',
      'enter_kundelik_password': 'Enter your password',
      'kundelik_error_invalid_credentials': 'Incorrect username or password',
      'kundelik_error_maintenance': 'Kundelik API is temporarily unavailable',
      'kundelik_error_no_internet': 'No internet connection',
      'kundelik_error_invalid_token': 'Session expired. Please login again',
      'kundelik_error_api': 'API error',
      'kundelik_error_unknown': 'An unknown error occurred',
      'kundelik_syncing': 'Syncing data',
      'kundelik_sync_success': 'Data synced successfully',
      'kundelik_sync_failed': 'Failed to sync data',
      // Home Screen
      'welcome': 'Welcome',
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'schedules': 'Schedules',
      'select_class': 'Select Class',
      'select_class_to_view_schedule': 'Select a class to view the schedule',
      'no_lessons_today': 'No lessons scheduled for today',
      'room': 'Room',
      'break': 'Break',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      // Olympiads
      'olympiads': 'Olympiads',
      'filter': 'Filter',
      'no_events_on_this_day': 'No events on this day',
      'registration_open': 'Open',
      'registration_closed': 'Closed',
      'location_tba': 'To be announced',
      'date': 'Date',
      'location': 'Location',
      'grades': 'Grades',
      'all_grades': 'All grades',
      'registration': 'Registration',
      'description': 'Description',
      'subjects': 'Subjects',
      'open_website': 'Open Website',
      'filter_events': 'Filter Events',
      'filter_by_subject': 'By Subject',
      'filter_by_type': 'By Type',
      'all': 'All',
      'event_name': 'Event Name',
      'type': 'Type',
      'status': 'Status',
      'ended': 'Ended',
      'open': 'Open',
      'closed': 'Closed',
      'all_subjects': 'All Subjects',
      'all_types': 'All Types',
      'international': 'International',
      'national': 'National',
      'regional': 'Regional',
      'school': 'School',
      'no_events_found': 'No events found',
      'my_grade_only': 'My grade only',
      'clear_filters': 'Clear Filters',
      'events_on': 'Events on',
      'details': 'Details',
      'select_date_range': 'Select Date Range',
      'clear': 'Clear',
      'close': 'Close',
      'retry': 'Retry',
      'select_grade_description': 'Choose your grade to view available books',
      'birthdays': 'Birthdays',
      'today_birthdays': "Today's Birthdays",
      'upcoming_birthdays': 'Upcoming Birthdays',
      'no_upcoming_birthdays': 'No upcoming birthdays in the next 7 days',
      'books': 'Books',
      'formulas': 'Formulas',
      'volunteer': 'Volunteer',
      'clubs': 'Clubs',
      'ranking': 'Ranking',
      // Functions Menu
      'functions': 'Functions',
      'functions_description': 'Access all app features',
      // Notifications & News
      'notifications': 'Notifications',
      'news': 'News',
      'no_notifications': 'No notifications yet',
      'no_news': 'No news yet',
      'view_all_notifications': 'View All',
      'ago': 'ago',
      'today': 'Today',
      'yesterday': 'Yesterday',
      // Example notifications
      'notification_example_1': 'New schedule available',
      'notification_example_1_desc': 'Your class schedule for next week has been updated',
      'notification_example_2': 'Assignment reminder',
      'notification_example_2_desc': 'Math homework is due tomorrow',
      'notification_example_3': 'Achievement unlocked',
      'notification_example_3_desc': 'You received a perfect score on your physics test!',
      // Example news
      'news_example_1': 'School Science Fair Next Month',
      'news_example_1_desc': 'Join us for the annual science fair where students showcase their innovative projects. Registration is now open!',
      'news_example_2': 'New Online Resources Available',
      'news_example_2_desc': 'Check out our new collection of educational videos and interactive learning materials in the Books section.',
    },
    'ru': {
      'app_title': 'Fizmat App',
      'login_title': 'Вход в аккаунт',
      'email_or_phone': 'Email',
      'password': 'Пароль',
      'sign_in': 'Войти',
      'forgot_password': 'Забыли пароль?',
      'no_account': 'Нет аккаунта?',
      'register': 'Зарегистрироваться',
      'register_title': 'Регистрация',
      'full_name': 'Полное имя',
      'email': 'Email',
      'confirm_password': 'Подтвердите пароль',
      'create_account': 'Создать аккаунт',
      'have_account': 'Уже есть аккаунт?',
      'sign_in_link': 'Войти',
      'forgot_password_title': 'Восстановление пароля',
      'enter_email': 'Введите ваш email',
      'send_code': 'Отправить код',
      'enter_code': 'Введите код',
      'new_password': 'Новый пароль',
      'confirm_new_password': 'Подтвердите новый пароль',
      'reset_password': 'Сбросить пароль',
      'verification_title': 'Подтверждение почты',
      'verification_subtitle': 'Введите 6-значный код, отправленный на',
      'verify': 'Подтвердить',
      'resend_code': 'Отправить код повторно',
      'code_sent': 'Код успешно отправлен',
      'invalid_code': 'Неверный код',
      'invalid_email': 'Неверный адрес почты',
      'email_required': 'Требуется email',
      'password_required': 'Требуется пароль',
      'name_required': 'Требуется имя',
      'passwords_dont_match': 'Пароли не совпадают',
      'password_too_short': 'Пароль должен быть не менее 6 символов',
      'error': 'Ошибка',
      'success': 'Успешно',
      'verified': 'Подтверждено',
      'loading': 'Загрузка...',
      'enter_fizmat_email': 'Введите вашу почту @fizmat.kz',
      'fizmat_email_hint': 'ваша.почта@fizmat.kz',
      'fizmat_email_required': 'Почта fizmat необходима для полного доступа',
      'partial_access_message':
          'Вы используете не-физмат почту. Некоторые функции будут ограничены.',
      'full_access': 'Полный доступ предоставлен',
      'limited_access': 'Ограниченный доступ',
      'russian': 'Русский',
      'kazakh': 'Қазақша',
      'english': 'English',
      'reset_password_description':
          'Введите ваш email и мы отправим вам инструкции по восстановлению пароля',
      'send_reset_link': 'Отправить ссылку',
      'back_to_login': 'Назад к входу',
      'reset_email_sent': 'Email отправлен!',
      'check_email_for_instructions':
          'Пожалуйста, проверьте вашу почту для инструкций по восстановлению пароля',
      'theme_settings': 'Настройки темы',
      'light_theme': 'Светлая',
      'dark_theme': 'Темная',
      'auto_theme': 'Авто',
      // Email Verification Screen
      'verify_email_title': 'Подтвердите Email',
      'verify_email_sent_to': 'Мы отправили письмо для подтверждения на:',
      'verify_email_check': 'Пожалуйста, проверьте вашу почту и нажмите на ссылку подтверждения.',
      'verify_email_waiting': 'Ожидание подтверждения...',
      'verify_email_spam_warning': 'Важно: Проверьте папку спам! Письма подтверждения часто попадают туда.',
      'verify_email_no_email': 'Не получили письмо?',
      'verify_email_resend': 'Отправить письмо повторно',
      'verify_email_resend_in': 'Повтор через {seconds} сек',
      'verify_email_back': 'Вернуться ко входу',
      'verify_email_sent_success': 'Письмо отправлено! Проверьте почту.',
      'verify_email_create_profile_failed': 'Не удалось создать профиль. Попробуйте войти.',
      'verify_email_send_failed': 'Не удалось отправить письмо',
      'verify_email_too_many_requests': 'Слишком много запросов. Подождите несколько минут.',
      'verify_email_send_error': 'Не удалось отправить email',
      // Success Messages
      'success_verification_email_sent': 'Письмо отправлено! Проверьте почту',
      'success_password_reset_sent': 'Письмо для восстановления пароля отправлено. Проверьте почту',
      'success_profile_updated': 'Профиль успешно обновлен',
      // Auth Errors
      'auth_error_wrong_password': 'Неверный пароль. Попробуйте снова.',
      'auth_error_invalid_credential': 'Неверный email или пароль.',
      'auth_error_user_not_found': 'Аккаунт с таким email не найден.',
      'auth_error_email_not_verified': 'Email не подтвержден. Проверьте почту.',
      'auth_error_network_request_failed': 'Нет интернет-соединения. Проверьте сеть.',
      'auth_error_too_many_requests': 'Слишком много попыток. Попробуйте позже.',
      'auth_error_user_disabled': 'Этот аккаунт заблокирован.',
      'auth_error_operation_not_allowed': 'Эта операция запрещена.',
      'auth_error_weak_password': 'Пароль слишком слабый. Используйте более надежный пароль.',
      'auth_error_email_already_in_use': 'Этот email уже зарегистрирован.',
      'auth_error_invalid_email': 'Неверный формат email.',
      'auth_error_sign_in_failed': 'Вход не удался. Попробуйте снова.',
      'auth_error_permission_denied': 'Доступ запрещен. Обратитесь в поддержку.',
      'auth_error_firestore_error': 'Ошибка базы данных. Попробуйте позже.',
      'auth_error_unknown': 'Произошла ошибка. Попробуйте снова.',
      // Unverified Email Dialog
      'unverified_email_title': 'Email не подтвержден',
      'unverified_email_message': 'Этот email уже зарегистрирован, но не подтвержден. Проверьте почту или отправьте письмо повторно.',
      'unverified_email_resend': 'Отправить письмо повторно',
      'unverified_email_close': 'Закрыть',
      'unverified_email_success': 'Письмо отправлено! Проверьте почту.',
      // Profile Screen
      'profile_title': 'Профиль',
      'edit_profile': 'Редактировать профиль',
      'username': 'Никнейм',
      'bio': 'О себе',
      'class_grade': 'Класс',
      'gpa': 'Средний балл',
      'privacy': 'Приватность',
      'public_profile': 'Публичный',
      'private_profile': 'Приватный',
      'connect_kundelik': 'Подключить Kundelik',
      'disconnect_kundelik': 'Отключить Kundelik',
      'kundelik_connected': 'Kundelik подключен',
      'kundelik_not_connected': 'Не подключен',
      'edit_photo': 'Сменить фото',
      'change_username': 'Никнейм',
      'change_name': 'Полное имя',
      'change_bio': 'О себе',
      'change_class': 'Класс',
      'username_required': 'Никнейм обязателен',
      'username_taken': 'Этот никнейм уже занят',
      'username_invalid': 'Никнейм может содержать только буквы, цифры и подчеркивания',
      'username_too_short': 'Никнейм должен быть не менее 3 символов',
      'username_too_long': 'Никнейм должен быть менее 20 символов',
      'profile_updated': 'Профиль успешно обновлен',
      'logout': 'Выйти',
      'settings': 'Настройки',
      'account_settings': 'Настройки аккаунта',
      'appearance': 'Внешний вид',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'enter_username': 'Введите никнейм',
      'enter_bio': 'Расскажите о себе',
      'enter_class': 'Введите класс (напр., 9A)',
      'no_bio': 'Нет описания',
      'no_class': 'Класс не указан',
      'no_username': 'Установить никнейм',
      'confirm_logout': 'Вы уверены, что хотите выйти?',
      'yes': 'Да',
      'no': 'Нет',
      // Class & Position
      'grade_number': 'Класс',
      'letter': 'Буква',
      'graduated': 'Выпускник',
      'position': 'Должность',
      'position_student': 'Ученик',
      'position_teacher': 'Учитель',
      'position_director': 'Директор',
      'position_school_government': 'Школьное самоуправление',
      'position_admin': 'Администратор',
      // Avatar
      'change_avatar': 'Сменить аватар',
      'upload_photo': 'Загрузить фото',
      'take_photo': 'Сделать фото',
      'remove_photo': 'Удалить фото',
      // Friends
      'friends': 'Друзья',
      'add_friend': 'Добавить в друзья',
      'remove_friend': 'Удалить из друзей',
      'friend_requests': 'Запросы в друзья',
      'accept': 'Принять',
      'decline': 'Отклонить',
      'no_friends': 'Пока нет друзей',
      'search_users': 'Поиск пользователей',
      'send_request': 'Отправить запрос',
      'request_sent': 'Запрос отправлен',
      'already_friends': 'Уже в друзьях',
      // Kundelik
      'kundelik': 'Кунделик',
      'sync_kundelik': 'Синхронизировать Кунделик',
      'last_synced': 'Последняя синхронизация',
      'never_synced': 'Ещё не синхронизирован',
      'birthday': 'День рождения',
      'connect': 'Подключить',
      'disconnect': 'Отключить',
      // Admin
      'admin_panel': 'Панель администратора',
      'manage_users': 'Управление пользователями',
      'change_role': 'Изменить роль',
      'select_role': 'Выберите роль',
      'role_updated': 'Роль успешно обновлена',
      'admin_only': 'Только для администраторов',
      // Avatar Upload
      'choose_from_gallery': 'Выбрать из галереи',
      'remove_avatar': 'Удалить аватар',
      'avatar_removed': 'Аватар удален',
      'avatar_updated': 'Аватар успешно обновлен',
      'avatar_upload_failed': 'Не удалось загрузить аватар',
      // General
      'coming_soon': 'Скоро',
      'language': 'Язык',
      // Validation
      'field_required': 'Это поле обязательно',
      'select_grade': 'Выберите класс',
      'select_letter': 'Выберите букву',
      // Kundelik Integration
      'kundelik_login_description': 'Введите данные для входа в Kundelik для синхронизации',
      'kundelik_username': 'Логин Kundelik',
      'kundelik_username_hint': 'Ваш логин',
      'enter_kundelik_password': 'Введите пароль',
      'kundelik_error_invalid_credentials': 'Неверный логин или пароль',
      'kundelik_error_maintenance': 'API Kundelik временно недоступен',
      'kundelik_error_no_internet': 'Нет интернет-соединения',
      'kundelik_error_invalid_token': 'Сессия истекла. Войдите снова',
      'kundelik_error_api': 'Ошибка API',
      'kundelik_error_unknown': 'Произошла неизвестная ошибка',
      'kundelik_syncing': 'Синхронизация данных',
      'kundelik_sync_success': 'Данные успешно синхронизированы',
      'kundelik_sync_failed': 'Не удалось синхронизировать данные',
      // Home Screen
      'welcome': 'Добро пожаловать',
      'good_morning': 'Доброе утро',
      'good_afternoon': 'Добрый день',
      'good_evening': 'Добрый вечер',
      'schedules': 'Расписание',
      'select_class': 'Выберите класс',
      'select_class_to_view_schedule': 'Выберите класс для просмотра расписания',
      'no_lessons_today': 'Сегодня нет уроков',
      'room': 'Кабинет',
      'break': 'Перемена',
      'monday': 'Понедельник',
      'tuesday': 'Вторник',
      'wednesday': 'Среда',
      'thursday': 'Четверг',
      'friday': 'Пятница',
      // Olympiads
      'olympiads': 'Олимпиады',
      'filter': 'Фильтр',
      'no_events_on_this_day': 'В этот день нет событий',
      'registration_open': 'Открыта',
      'registration_closed': 'Закрыта',
      'location_tba': 'Будет объявлено',
      'date': 'Дата',
      'location': 'Место проведения',
      'grades': 'Классы',
      'all_grades': 'Все классы',
      'registration': 'Регистрация',
      'description': 'Описание',
      'subjects': 'Предметы',
      'open_website': 'Открыть сайт',
      'filter_events': 'Фильтр событий',
      'filter_by_subject': 'По предмету',
      'filter_by_type': 'По типу',
      'all': 'Все',
      'event_name': 'Название события',
      'type': 'Тип',
      'status': 'Статус',
      'ended': 'Завершено',
      'open': 'Открыто',
      'closed': 'Закрыто',
      'all_subjects': 'Все предметы',
      'all_types': 'Все типы',
      'international': 'Международная',
      'national': 'Национальная',
      'regional': 'Региональная',
      'school': 'Школьная',
      'no_events_found': 'Событий не найдено',
      'my_grade_only': 'Только мой класс',
      'clear_filters': 'Очистить фильтры',
      'events_on': 'События',
      'details': 'Подробнее',
      'select_date_range': 'Выбрать период',
      'clear': 'Очистить',
      'close': 'Закрыть',
      'retry': 'Повторить',
      'select_grade_description': 'Выберите класс для просмотра доступных книг',
      'birthdays': 'Дни рождения',
      'today_birthdays': 'Сегодняшние дни рождения',
      'upcoming_birthdays': 'Предстоящие дни рождения',
      'no_upcoming_birthdays': 'Нет предстоящих дней рождения в ближайшие 7 дней',
      'books': 'Книги',
      'formulas': 'Формулы',
      'volunteer': 'Волонтерство',
      'clubs': 'Клубы',
      'ranking': 'Рейтинг',
      // Functions Menu
      'functions': 'Функции',
      'functions_description': 'Доступ ко всем функциям приложения',
      // Notifications & News
      'notifications': 'Уведомления',
      'news': 'Новости',
      'no_notifications': 'Нет уведомлений',
      'no_news': 'Нет новостей',
      'view_all_notifications': 'Показать все',
      'ago': 'назад',
      'today': 'Сегодня',
      'yesterday': 'Вчера',
      // Example notifications
      'notification_example_1': 'Доступно новое расписание',
      'notification_example_1_desc': 'Ваше расписание на следующую неделю обновлено',
      'notification_example_2': 'Напоминание о задании',
      'notification_example_2_desc': 'Домашнее задание по математике нужно сдать завтра',
      'notification_example_3': 'Достижение получено',
      'notification_example_3_desc': 'Вы получили отличную оценку за тест по физике!',
      // Example news
      'news_example_1': 'Школьная научная ярмарка в следующем месяце',
      'news_example_1_desc': 'Присоединяйтесь к ежегодной научной ярмарке, где ученики представляют свои инновационные проекты. Регистрация открыта!',
      'news_example_2': 'Доступны новые онлайн-ресурсы',
      'news_example_2_desc': 'Ознакомьтесь с нашей новой коллекцией образовательных видео и интерактивных учебных материалов в разделе Книги.',
    },
    'kk': {
      'app_title': 'Fizmat App',
      'login_title': 'Кіру',
      'email_or_phone': 'Email',
      'password': 'Құпия сөз',
      'sign_in': 'Кіру',
      'forgot_password': 'Құпия сөзді ұмыттыңыз ба?',
      'no_account': 'Аккаунт жоқ па?',
      'register': 'Тіркелу',
      'register_title': 'Тіркелу',
      'full_name': 'Толық аты-жөні',
      'email': 'Email',
      'confirm_password': 'Құпия сөзді растау',
      'create_account': 'Аккаунт жасау',
      'have_account': 'Аккаунт бар ма?',
      'sign_in_link': 'Кіру',
      'forgot_password_title': 'Құпия сөзді қалпына келтіру',
      'enter_email': 'Email енгізіңіз',
      'send_code': 'Код жіберу',
      'enter_code': 'Кодты енгізіңіз',
      'new_password': 'Жаңа құпия сөз',
      'confirm_new_password': 'Жаңа құпия сөзді растау',
      'reset_password': 'Құпия сөзді қалпына келтіру',
      'verification_title': 'Поштаны растау',
      'verification_subtitle': 'Жіберілген 6 таңбалы кодты енгізіңіз',
      'verify': 'Растау',
      'resend_code': 'Кодты қайта жіберу',
      'code_sent': 'Код сәтті жіберілді',
      'invalid_code': 'Қате код',
      'invalid_email': 'Қате пошта мекенжайы',
      'email_required': 'Email қажет',
      'password_required': 'Құпия сөз қажет',
      'name_required': 'Аты-жөні қажет',
      'passwords_dont_match': 'Құпия сөздер сәйкес келмейді',
      'password_too_short': 'Құпия сөз кемінде 6 таңбадан тұруы керек',
      'error': 'Қате',
      'success': 'Сәтті',
      'verified': 'Расталды',
      'loading': 'Жүктелуде...',
      'enter_fizmat_email': '@fizmat.kz поштаңызды енгізіңіз',
      'fizmat_email_hint': 'сіздің.пошта@fizmat.kz',
      'fizmat_email_required': 'Толық қол жеткізу үшін fizmat поштасы қажет',
      'partial_access_message':
          'Сіз fizmat емес пошта пайдаланудасыз. Кейбір мүмкіндіктер шектеулі болады.',
      'full_access': 'Толық қол жеткізу берілді',
      'limited_access': 'Шектеулі қол жеткізу',
      'russian': 'Русский',
      'kazakh': 'Қазақша',
      'english': 'English',
      'reset_password_description':
          'Email мекенжайыңызды енгізіңіз және біз сізге құпия сөзді қалпына келтіру нұсқауларын жібереміз',
      'send_reset_link': 'Сілтеме жіберу',
      'back_to_login': 'Кіруге оралу',
      'reset_email_sent': 'Email жіберілді!',
      'check_email_for_instructions':
          'Құпия сөзді қалпына келтіру нұсқаулары үшін поштаңызды тексеріңіз',
      'theme_settings': 'Тақырып баптаулары',
      'light_theme': 'Ашық',
      'dark_theme': 'Қараңғы',
      'auto_theme': 'Авто',
      // Email Verification Screen
      'verify_email_title': 'Email-ді растаңыз',
      'verify_email_sent_to': 'Растау хатын жібердік:',
      'verify_email_check': 'Email-ді тексеріңіз және растау сілтемесін басыңыз.',
      'verify_email_waiting': 'Растауды күтуде...',
      'verify_email_spam_warning': 'Маңызды: Спам қалтасын тексеріңіз! Растау хаттары жиі сонда болады.',
      'verify_email_no_email': 'Хат келмеді ме?',
      'verify_email_resend': 'Хатты қайта жіберу',
      'verify_email_resend_in': 'Қайталау {seconds} сек-та',
      'verify_email_back': 'Кіруге оралу',
      'verify_email_sent_success': 'Растау хаты жіберілді! Поштаңызды тексеріңіз.',
      'verify_email_create_profile_failed': 'Профиль жасау сәтсіз аяқталды. Кіруге тырысыңыз.',
      'verify_email_send_failed': 'Растау хатын жіберу сәтсіз аяқталды',
      'verify_email_too_many_requests': 'Тым көп сұраулар. Бірнеше минут күтіңіз.',
      'verify_email_send_error': 'Email жіберу сәтсіз аяқталды',
      // Success Messages
      'success_verification_email_sent': 'Растау хаты жіберілді! Поштаңызды тексеріңіз',
      'success_password_reset_sent': 'Құпия сөзді қалпына келтіру хаты жіберілді. Поштаңызды тексеріңіз',
      'success_profile_updated': 'Профиль сәтті жаңартылды',
      // Auth Errors
      'auth_error_wrong_password': 'Қате құпия сөз. Қайталап көріңіз.',
      'auth_error_invalid_credential': 'Қате email немесе құпия сөз.',
      'auth_error_user_not_found': 'Бұл email-мен аккаунт табылмады.',
      'auth_error_email_not_verified': 'Email расталмаған. Поштаңызды тексеріңіз.',
      'auth_error_network_request_failed': 'Интернет байланысы жоқ. Желіні тексеріңіз.',
      'auth_error_too_many_requests': 'Тым көп әрекет. Кейінірек қайталап көріңіз.',
      'auth_error_user_disabled': 'Бұл аккаунт бұғатталған.',
      'auth_error_operation_not_allowed': 'Бұл әрекет тыйым салынған.',
      'auth_error_weak_password': 'Құпия сөз тым әлсіз. Күшті құпия сөз қолданыңыз.',
      'auth_error_email_already_in_use': 'Бұл email тіркелген.',
      'auth_error_invalid_email': 'Қате email форматы.',
      'auth_error_sign_in_failed': 'Кіру сәтсіз аяқталды. Қайталап көріңіз.',
      'auth_error_permission_denied': 'Рұқсат жоқ. Қолдауға хабарласыңыз.',
      'auth_error_firestore_error': 'Дерекқор қатесі. Кейінірек қайталап көріңіз.',
      'auth_error_unknown': 'Қате орын алды. Қайталап көріңіз.',
      // Unverified Email Dialog
      'unverified_email_title': 'Email расталмаған',
      'unverified_email_message': 'Бұл email тіркелген, бірақ расталмаған. Поштаңызды тексеріңіз немесе хатты қайта жіберіңіз.',
      'unverified_email_resend': 'Хатты қайта жіберу',
      'unverified_email_close': 'Жабу',
      'unverified_email_success': 'Хат жіберілді! Поштаңызды тексеріңіз.',
      // Profile Screen
      'profile_title': 'Профиль',
      'edit_profile': 'Профильді өңдеу',
      'username': 'Пайдаланушы аты',
      'bio': 'Өзім туралы',
      'class_grade': 'Сынып',
      'gpa': 'Орташа балл',
      'privacy': 'Құпиялылық',
      'public_profile': 'Ашық',
      'private_profile': 'Жабық',
      'connect_kundelik': 'Kundelik қосу',
      'disconnect_kundelik': 'Kundelik ажырату',
      'kundelik_connected': 'Kundelik қосылған',
      'kundelik_not_connected': 'Қосылмаған',
      'edit_photo': 'Суретті өзгерту',
      'change_username': 'Пайдаланушы аты',
      'change_name': 'Толық аты',
      'change_bio': 'Өзім туралы',
      'change_class': 'Сынып',
      'username_required': 'Пайдаланушы аты қажет',
      'username_taken': 'Бұл пайдаланушы аты бос емес',
      'username_invalid': 'Пайдаланушы атында тек әріптер, сандар және астын сызу болуы мүмкін',
      'username_too_short': 'Пайдаланушы аты кемінде 3 таңбадан тұруы керек',
      'username_too_long': 'Пайдаланушы аты 20 таңбадан аз болуы керек',
      'profile_updated': 'Профиль сәтті жаңартылды',
      'logout': 'Шығу',
      'settings': 'Баптаулар',
      'account_settings': 'Аккаунт баптаулары',
      'appearance': 'Сыртқы түрі',
      'save': 'Сақтау',
      'cancel': 'Болдырмау',
      'enter_username': 'Пайдаланушы атын енгізіңіз',
      'enter_bio': 'Өзіңіз туралы айтыңыз',
      'enter_class': 'Сыныпты енгізіңіз (мыс., 9A)',
      'no_bio': 'Сипаттама жоқ',
      'no_class': 'Сынып көрсетілмеген',
      'no_username': 'Пайдаланушы атын орнату',
      'confirm_logout': 'Шығуға сенімдісіз бе?',
      'yes': 'Иә',
      'no': 'Жоқ',
      // Class & Position
      'grade_number': 'Сынып',
      'letter': 'Әріп',
      'graduated': 'Бітірген',
      'position': 'Лауазым',
      'position_student': 'Оқушы',
      'position_teacher': 'Мұғалім',
      'position_director': 'Директор',
      'position_school_government': 'Мектеп өзін-өзі басқару',
      'position_admin': 'Әкімші',
      // Avatar
      'change_avatar': 'Аватарды өзгерту',
      'upload_photo': 'Фото жүктеу',
      'take_photo': 'Фото түсіру',
      'remove_photo': 'Фотоны жою',
      // Friends
      'friends': 'Достар',
      'add_friend': 'Досқа қосу',
      'remove_friend': 'Достардан жою',
      'friend_requests': 'Дос сұраулары',
      'accept': 'Қабылдау',
      'decline': 'Қабылдамау',
      'no_friends': 'Әзірше достар жоқ',
      'search_users': 'Пайдаланушыларды іздеу',
      'send_request': 'Сұрау жіберу',
      'request_sent': 'Сұрау жіберілді',
      'already_friends': 'Достарда бар',
      // Kundelik
      'kundelik': 'Күнделік',
      'sync_kundelik': 'Күнделікті синхрондау',
      'last_synced': 'Соңғы синхрондау',
      'never_synced': 'Әлі синхрондалмаған',
      'birthday': 'Туған күн',
      'connect': 'Қосу',
      'disconnect': 'Ажырату',
      // Admin
      'admin_panel': 'Әкімші панелі',
      'manage_users': 'Пайдаланушыларды басқару',
      'change_role': 'Рөлді өзгерту',
      'select_role': 'Рөлді таңдаңыз',
      'role_updated': 'Рөл сәтті жаңартылды',
      'admin_only': 'Тек әкімшілерге',
      // Avatar Upload
      'choose_from_gallery': 'Галереядан таңдау',
      'remove_avatar': 'Аватарды жою',
      'avatar_removed': 'Аватар жойылды',
      'avatar_updated': 'Аватар сәтті жаңартылды',
      'avatar_upload_failed': 'Аватарды жүктеу сәтсіз аяқталды',
      // General
      'coming_soon': 'Жақын арада',
      'language': 'Тіл',
      // Validation
      'field_required': 'Бұл өріс міндетті',
      'select_grade': 'Сыныпты таңдаңыз',
      'select_letter': 'Әріпті таңдаңыз',
      // Kundelik Integration
      'kundelik_login_description': 'Деректерді синхрондау үшін Kundelik тіркелгі деректерін енгізіңіз',
      'kundelik_username': 'Kundelik логині',
      'kundelik_username_hint': 'Сіздің логиніңіз',
      'enter_kundelik_password': 'Құпия сөзді енгізіңіз',
      'kundelik_error_invalid_credentials': 'Қате логин немесе құпия сөз',
      'kundelik_error_maintenance': 'Kundelik API уақытша қолжетімсіз',
      'kundelik_error_no_internet': 'Интернет байланысы жоқ',
      'kundelik_error_invalid_token': 'Сессия аяқталды. Қайта кіріңіз',
      'kundelik_error_api': 'API қатесі',
      'kundelik_error_unknown': 'Белгісіз қате орын алды',
      'kundelik_syncing': 'Деректерді синхрондау',
      'kundelik_sync_success': 'Деректер сәтті синхрондалды',
      'kundelik_sync_failed': 'Деректерді синхрондау сәтсіз аяқталды',
      // Home Screen
      'welcome': 'Қош келдіңіз',
      'good_morning': 'Қайырлы таң',
      'good_afternoon': 'Қайырлы күн',
      'good_evening': 'Қайырлы кеш',
      'schedules': 'Кесте',
      'select_class': 'Сыныпты таңдаңыз',
      'select_class_to_view_schedule': 'Кестені көру үшін сыныпты таңдаңыз',
      'no_lessons_today': 'Бүгін сабақтар жоқ',
      'room': 'Кабинет',
      'break': 'Үзіліс',
      'monday': 'Дүйсенбі',
      'tuesday': 'Сейсенбі',
      'wednesday': 'Сәрсенбі',
      'thursday': 'Бейсенбі',
      'friday': 'Жұма',
      // Olympiads
      'olympiads': 'Олимпиадалар',
      'filter': 'Сүзгі',
      'no_events_on_this_day': 'Бұл күні оқиғалар жоқ',
      'registration_open': 'Ашық',
      'registration_closed': 'Жабық',
      'location_tba': 'Жарияланбаған',
      'date': 'Күні',
      'location': 'Орын',
      'grades': 'Сыныптар',
      'all_grades': 'Барлық сыныптар',
      'registration': 'Тіркелу',
      'description': 'Сипаттама',
      'subjects': 'Пәндер',
      'open_website': 'Сайтты ашу',
      'filter_events': 'Оқиғаларды сүзу',
      'filter_by_subject': 'Пән бойынша',
      'filter_by_type': 'Түрі бойынша',
      'all': 'Барлығы',
      'event_name': 'Оқиға атауы',
      'type': 'Түрі',
      'status': 'Күйі',
      'ended': 'Аяқталды',
      'open': 'Ашық',
      'closed': 'Жабық',
      'all_subjects': 'Барлық пәндер',
      'all_types': 'Барлық түрлері',
      'international': 'Халықаралық',
      'national': 'Республикалық',
      'regional': 'Облыстық',
      'school': 'Мектептік',
      'no_events_found': 'Оқиғалар табылмады',
      'my_grade_only': 'Тек менің сыныбым',
      'clear_filters': 'Сүзгілерді тазалау',
      'events_on': 'Оқиғалар',
      'details': 'Егжей-тегжейлі',
      'select_date_range': 'Кезеңді таңдау',
      'clear': 'Тазалау',
      'close': 'Жабу',
      'retry': 'Қайталау',
      'select_grade_description': 'Қол жетімді кітаптарды көру үшін сыныпты таңдаңыз',
      'birthdays': 'Туған күндер',
      'today_birthdays': 'Бүгінгі туған күндер',
      'upcoming_birthdays': 'Алдағы туған күндер',
      'no_upcoming_birthdays': 'Алдағы 7 күнде туған күн жоқ',
      'books': 'Кітаптар',
      'formulas': 'Формулалар',
      'volunteer': 'Волонтерлік',
      'clubs': 'Клубтар',
      'ranking': 'Рейтинг',
      // Functions Menu
      'functions': 'Функциялар',
      'functions_description': 'Барлық қолданба функцияларына қолжетімділік',
      // Notifications & News
      'notifications': 'Хабарландырулар',
      'news': 'Жаңалықтар',
      'no_notifications': 'Хабарландырулар жоқ',
      'no_news': 'Жаңалықтар жоқ',
      'view_all_notifications': 'Барлығын көру',
      'ago': 'бұрын',
      'today': 'Бүгін',
      'yesterday': 'Кеше',
      // Example notifications
      'notification_example_1': 'Жаңа кесте қолжетімді',
      'notification_example_1_desc': 'Келесі аптаға арналған кестеңіз жаңартылды',
      'notification_example_2': 'Тапсырма туралы еске салу',
      'notification_example_2_desc': 'Математика бойынша үй тапсырмасын ертең тапсыру керек',
      'notification_example_3': 'Жетістікке жеттіңіз',
      'notification_example_3_desc': 'Сіз физика тестінен тамаша баға алдыңыз!',
      // Example news
      'news_example_1': 'Мектептік ғылыми жәрмеңке келесі айда',
      'news_example_1_desc': 'Оқушылар өздерінің инновациялық жобаларын көрсететін жыл сайынғы ғылыми жәрмеңкеге қосылыңыз. Тіркеу ашық!',
      'news_example_2': 'Жаңа онлайн ресурстар қолжетімді',
      'news_example_2_desc': 'Кітаптар бөлімінде білім беру бейнелері мен интерактивті оқу материалдарының жаңа жинағымен танысыңыз.',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('app_title');
  String get loginTitle => translate('login_title');
  String get emailOrPhone => translate('email_or_phone');
  String get password => translate('password');
  String get signIn => translate('sign_in');
  String get forgotPassword => translate('forgot_password');
  String get noAccount => translate('no_account');
  String get register => translate('register');
  String get registerTitle => translate('register_title');
  String get fullName => translate('full_name');
  String get email => translate('email');
  String get confirmPassword => translate('confirm_password');
  String get createAccount => translate('create_account');
  String get haveAccount => translate('have_account');
  String get signInLink => translate('sign_in_link');
  String get forgotPasswordTitle => translate('forgot_password_title');
  String get enterEmail => translate('enter_email');
  String get sendCode => translate('send_code');
  String get enterCode => translate('enter_code');
  String get newPassword => translate('new_password');
  String get confirmNewPassword => translate('confirm_new_password');
  String get resetPassword => translate('reset_password');
  String get verificationTitle => translate('verification_title');
  String get verificationSubtitle => translate('verification_subtitle');
  String get verify => translate('verify');
  String get resendCode => translate('resend_code');
  String get codeSent => translate('code_sent');
  String get invalidCode => translate('invalid_code');
  String get invalidEmail => translate('invalid_email');
  String get emailRequired => translate('email_required');
  String get passwordRequired => translate('password_required');
  String get nameRequired => translate('name_required');
  String get passwordsDontMatch => translate('passwords_dont_match');
  String get passwordTooShort => translate('password_too_short');
  String get error => translate('error');
  String get success => translate('success');
  String get verified => translate('verified');
  String get loading => translate('loading');
  String get enterFizmatEmail => translate('enter_fizmat_email');
  String get fizmatEmailHint => translate('fizmat_email_hint');
  String get fizmatEmailRequired => translate('fizmat_email_required');
  String get partialAccessMessage => translate('partial_access_message');
  String get fullAccess => translate('full_access');
  String get limitedAccess => translate('limited_access');
  String get russian => translate('russian');
  String get kazakh => translate('kazakh');
  String get english => translate('english');
  String get resetPasswordDescription => translate('reset_password_description');
  String get sendResetLink => translate('send_reset_link');
  String get backToLogin => translate('back_to_login');
  String get resetEmailSent => translate('reset_email_sent');
  String get checkEmailForInstructions =>
      translate('check_email_for_instructions');
  String get themeSettings => translate('theme_settings');
  String get lightTheme => translate('light_theme');
  String get darkTheme => translate('dark_theme');
  String get autoTheme => translate('auto_theme');

  // Email Verification Screen
  String get verifyEmailTitle => translate('verify_email_title');
  String get verifyEmailSentTo => translate('verify_email_sent_to');
  String get verifyEmailCheck => translate('verify_email_check');
  String get verifyEmailWaiting => translate('verify_email_waiting');
  String get verifyEmailSpamWarning => translate('verify_email_spam_warning');
  String get verifyEmailNoEmail => translate('verify_email_no_email');
  String get verifyEmailResend => translate('verify_email_resend');
  String verifyEmailResendIn(int seconds) {
    final template = translate('verify_email_resend_in');
    return template.replaceAll('{seconds}', seconds.toString());
  }
  String get verifyEmailBack => translate('verify_email_back');
  String get verifyEmailSentSuccess => translate('verify_email_sent_success');
  String get verifyEmailCreateProfileFailed => translate('verify_email_create_profile_failed');
  String get verifyEmailSendFailed => translate('verify_email_send_failed');
  String get verifyEmailTooManyRequests => translate('verify_email_too_many_requests');
  String get verifyEmailSendError => translate('verify_email_send_error');

  // Success Messages
  String get successVerificationEmailSent => translate('success_verification_email_sent');
  String get successPasswordResetSent => translate('success_password_reset_sent');
  String get successProfileUpdated => translate('success_profile_updated');

  // Auth Errors
  String get authErrorWrongPassword => translate('auth_error_wrong_password');
  String get authErrorInvalidCredential => translate('auth_error_invalid_credential');
  String get authErrorUserNotFound => translate('auth_error_user_not_found');
  String get authErrorEmailNotVerified => translate('auth_error_email_not_verified');
  String get authErrorNetworkRequestFailed => translate('auth_error_network_request_failed');
  String get authErrorTooManyRequests => translate('auth_error_too_many_requests');
  String get authErrorUserDisabled => translate('auth_error_user_disabled');
  String get authErrorOperationNotAllowed => translate('auth_error_operation_not_allowed');
  String get authErrorWeakPassword => translate('auth_error_weak_password');
  String get authErrorEmailAlreadyInUse => translate('auth_error_email_already_in_use');
  String get authErrorInvalidEmail => translate('auth_error_invalid_email');
  String get authErrorSignInFailed => translate('auth_error_sign_in_failed');
  String get authErrorPermissionDenied => translate('auth_error_permission_denied');
  String get authErrorFirestoreError => translate('auth_error_firestore_error');
  String get authErrorUnknown => translate('auth_error_unknown');

  // Unverified Email Dialog
  String get unverifiedEmailTitle => translate('unverified_email_title');
  String get unverifiedEmailMessage => translate('unverified_email_message');
  String get unverifiedEmailResend => translate('unverified_email_resend');
  String get unverifiedEmailClose => translate('unverified_email_close');
  String get unverifiedEmailSuccess => translate('unverified_email_success');

  // Profile Screen
  String get profileTitle => translate('profile_title');
  String get editProfile => translate('edit_profile');
  String get username => translate('username');
  String get bio => translate('bio');
  String get classGrade => translate('class_grade');
  String get gpa => translate('gpa');
  String get privacy => translate('privacy');
  String get publicProfile => translate('public_profile');
  String get privateProfile => translate('private_profile');
  String get connectKundelik => translate('connect_kundelik');
  String get disconnectKundelik => translate('disconnect_kundelik');
  String get kundelikConnected => translate('kundelik_connected');
  String get kundelikNotConnected => translate('kundelik_not_connected');
  String get editPhoto => translate('edit_photo');
  String get changeUsername => translate('change_username');
  String get changeName => translate('change_name');
  String get changeBio => translate('change_bio');
  String get changeClass => translate('change_class');
  String get usernameRequired => translate('username_required');
  String get usernameTaken => translate('username_taken');
  String get usernameInvalid => translate('username_invalid');
  String get usernameTooShort => translate('username_too_short');
  String get usernameTooLong => translate('username_too_long');
  String get profileUpdated => translate('profile_updated');
  String get logout => translate('logout');
  String get settings => translate('settings');
  String get accountSettings => translate('account_settings');
  String get appearance => translate('appearance');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get enterUsername => translate('enter_username');
  String get enterBio => translate('enter_bio');
  String get enterClass => translate('enter_class');
  String get noBio => translate('no_bio');
  String get noClass => translate('no_class');
  String get noUsername => translate('no_username');
  String get confirmLogout => translate('confirm_logout');
  String get yes => translate('yes');
  String get no => translate('no');

  // Class & Position
  String get gradeNumber => translate('grade_number');
  String get letter => translate('letter');
  String get graduated => translate('graduated');
  String get position => translate('position');
  String get positionStudent => translate('position_student');
  String get positionTeacher => translate('position_teacher');
  String get positionDirector => translate('position_director');
  String get positionSchoolGovernment => translate('position_school_government');
  String get positionAdmin => translate('position_admin');

  // Avatar
  String get changeAvatar => translate('change_avatar');
  String get uploadPhoto => translate('upload_photo');
  String get takePhoto => translate('take_photo');
  String get removePhoto => translate('remove_photo');
  String get chooseFromGallery => translate('choose_from_gallery');
  String get removeAvatar => translate('remove_avatar');
  String get avatarRemoved => translate('avatar_removed');
  String get avatarUpdated => translate('avatar_updated');
  String get avatarUploadFailed => translate('avatar_upload_failed');

  // Friends
  String get friends => translate('friends');
  String get addFriend => translate('add_friend');
  String get removeFriend => translate('remove_friend');
  String get friendRequests => translate('friend_requests');
  String get accept => translate('accept');
  String get decline => translate('decline');
  String get noFriends => translate('no_friends');
  String get searchUsers => translate('search_users');
  String get sendRequest => translate('send_request');
  String get requestSent => translate('request_sent');
  String get alreadyFriends => translate('already_friends');

  // Kundelik
  String get kundelik => translate('kundelik');
  String get syncKundelik => translate('sync_kundelik');
  String get lastSynced => translate('last_synced');
  String get neverSynced => translate('never_synced');
  String get birthday => translate('birthday');
  String get connect => translate('connect');
  String get disconnect => translate('disconnect');

  // Admin
  String get adminPanel => translate('admin_panel');
  String get manageUsers => translate('manage_users');
  String get changeRole => translate('change_role');
  String get selectRole => translate('select_role');
  String get roleUpdated => translate('role_updated');
  String get adminOnly => translate('admin_only');

  // General
  String get comingSoon => translate('coming_soon');
  String get language => translate('language');

  // Validation
  String get fieldRequired => translate('field_required');
  String get selectGrade => translate('select_grade');
  String get selectLetter => translate('select_letter');

  // Helper method to get localized error message by code
  String getAuthErrorMessage(String? code) {
    if (code == null) return authErrorUnknown;

    switch (code) {
      case 'wrong-password':
        return authErrorWrongPassword;
      case 'invalid-credential':
        return authErrorInvalidCredential;
      case 'user-not-found':
        return authErrorUserNotFound;
      case 'email-not-verified':
      case 'email-not-verified-login':
      case 'email-not-verified-retry':
        return authErrorEmailNotVerified;
      case 'network-request-failed':
        return authErrorNetworkRequestFailed;
      case 'too-many-requests':
        return authErrorTooManyRequests;
      case 'user-disabled':
        return authErrorUserDisabled;
      case 'operation-not-allowed':
        return authErrorOperationNotAllowed;
      case 'weak-password':
        return authErrorWeakPassword;
      case 'email-already-in-use':
        return authErrorEmailAlreadyInUse;
      case 'invalid-email':
        return authErrorInvalidEmail;
      case 'sign-in-failed':
        return authErrorSignInFailed;
      case 'permission-denied':
        return authErrorPermissionDenied;
      case 'firestore-error':
      case 'user-document-creation-failed':
        return authErrorFirestoreError;
      default:
        return authErrorUnknown;
    }
  }

  // Helper method to get localized success message by code
  String getSuccessMessage(String? code) {
    if (code == null) return '';

    switch (code) {
      case 'verification-email-sent':
        return successVerificationEmailSent;
      case 'password-reset-sent':
        return successPasswordResetSent;
      case 'profile-updated':
        return successProfileUpdated;
      default:
        return '';
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'kk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
