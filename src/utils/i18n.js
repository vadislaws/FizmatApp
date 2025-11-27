// Multi-language support
const translations = {
  en: {
    // Auth
    welcomeBack: 'Welcome back',
    email: 'Email',
    password: 'Password',
    name: 'Full Name',
    forgotPassword: 'Forgot password?',
    signIn: 'Sign in',
    signUp: 'Sign up',
    or: 'or',
    continueWithGoogle: 'Continue with Google',
    dontHaveAccount: "Don't have an account?",
    alreadyHaveAccount: 'Already have an account?',
    createAccount: 'Create account',
    resetPassword: 'Reset password',
    sendResetLink: 'Send reset link',
    backToLogin: 'Back to login',
    
    // Placeholders
    emailPlaceholder: 'your.email@fizmat.kz',
    passwordPlaceholder: '••••••••',
    namePlaceholder: 'Your full name',
    
    // Errors
    invalidCredentials: 'Invalid email or password',
    userExists: 'User already exists',
    userNotFound: 'User not found',
    fillAllFields: 'Please fill in all fields',
    
    // Success
    resetLinkSent: 'Reset link sent to your email',
  },
  
  ru: {
    // Auth
    welcomeBack: 'С возвращением',
    email: 'Email',
    password: 'Пароль',
    name: 'Полное имя',
    forgotPassword: 'Забыли пароль?',
    signIn: 'Войти',
    signUp: 'Регистрация',
    or: 'или',
    continueWithGoogle: 'Продолжить через Google',
    dontHaveAccount: 'Нет аккаунта?',
    alreadyHaveAccount: 'Уже есть аккаунт?',
    createAccount: 'Создать аккаунт',
    resetPassword: 'Сброс пароля',
    sendResetLink: 'Отправить ссылку',
    backToLogin: 'Назад ко входу',
    
    // Placeholders
    emailPlaceholder: 'ваш.email@fizmat.kz',
    passwordPlaceholder: '••••••••',
    namePlaceholder: 'Ваше полное имя',
    
    // Errors
    invalidCredentials: 'Неверный email или пароль',
    userExists: 'Пользователь уже существует',
    userNotFound: 'Пользователь не найден',
    fillAllFields: 'Заполните все поля',
    
    // Success
    resetLinkSent: 'Ссылка отправлена на ваш email',
  },
  
  kk: {
    // Auth
    welcomeBack: 'Қош келдіңіз',
    email: 'Email',
    password: 'Құпия сөз',
    name: 'Толық аты',
    forgotPassword: 'Құпия сөзді ұмыттыңыз ба?',
    signIn: 'Кіру',
    signUp: 'Тіркелу',
    or: 'немесе',
    continueWithGoogle: 'Google арқылы жалғастыру',
    dontHaveAccount: 'Аккаунт жоқ па?',
    alreadyHaveAccount: 'Аккаунт бар ма?',
    createAccount: 'Аккаунт жасау',
    resetPassword: 'Құпия сөзді қалпына келтіру',
    sendResetLink: 'Сілтеме жіберу',
    backToLogin: 'Кіруге оралу',
    
    // Placeholders
    emailPlaceholder: 'сіздің.email@fizmat.kz',
    passwordPlaceholder: '••••••••',
    namePlaceholder: 'Сіздің толық атыңыз',
    
    // Errors
    invalidCredentials: 'Email немесе құпия сөз қате',
    userExists: 'Пайдаланушы бұрыннан бар',
    userNotFound: 'Пайдаланушы табылмады',
    fillAllFields: 'Барлық өрістерді толтырыңыз',
    
    // Success
    resetLinkSent: 'Сілтеме сіздің email-ға жіберілді',
  },
};

// i18n helper
const i18n = {
  currentLanguage: localStorage.getItem('language') || 'en',
  
  t: (key) => {
    return translations[i18n.currentLanguage][key] || key;
  },
  
  setLanguage: (lang) => {
    i18n.currentLanguage = lang;
    localStorage.setItem('language', lang);
  },
  
  getLanguage: () => {
    return i18n.currentLanguage;
  },
};

export default i18n;