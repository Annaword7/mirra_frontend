import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'ru', 'es'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? ruText = '',
    String? esText = '',
  }) =>
      [enText, ruText, esText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // CreateAccountPage
  {
    'v4ogufdc': {
      'en': 'Create your profile',
      'es': 'Crea tu perfil',
      'ru': 'Создайте профиль',
    },
    'fzz6pquo': {
      'en': 'Email address',
      'es': 'Correo electrónico',
      'ru': 'Электронная почта',
    },
    'jl6rrleg': {
      'en': 'Password',
      'es': 'Contraseña',
      'ru': 'Пароль',
    },
    'yktrgba2': {
      'en': 'Enter valid email',
      'es': 'Introduzca un correo electrónico válido',
      'ru': 'Введите действительный адрес электронной почты',
    },
    '2rx0s31e': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'pw6ghio3': {
      'en': 'Enter valid password',
      'es': 'Introduzca una contraseña válida',
      'ru': 'Введите действительный пароль',
    },
    'eeqs1ag8': {
      'en': 'The password must be at least 5 characters long',
      'es': 'La contraseña debe tener al menos 5 caracteres.',
      'ru': 'Пароль должен состоять как минимум из 5 символов.',
    },
    '9458n6fk': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'o5q6qmi9': {
      'en': 'Create account',
      'es': 'Crear cuenta',
      'ru': 'Создать аккаунт',
    },
    'wvkbomvg': {
      'en': 'Continue with Apple',
      'es': 'Continuar con Apple',
      'ru': 'Продолжить с Apple',
    },
    'gxuca5l4': {
      'en': 'By continuing, you agree to our ',
      'es': 'Al continuar, aceptas nuestros ',
      'ru': 'Продолжая, вы принимаете наши ',
    },
    'np61e9wt': {
      'en': 'Terms and Privacy Policy',
      'es': 'Términos y Política de privacidad',
      'ru': 'Условия и Политику конфиденциальности',
    },
    'f4ohc693': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // LogInPage
  {
    's2sex1cq': {
      'en': 'Welcome back',
      'es': 'Bienvenido de nuevo',
      'ru': 'С возвращением',
    },
    'i7sno6fc': {
      'en': 'Enter your details to continue',
      'es': 'Ingresa tus datos para continuar',
      'ru': 'Введите данные для входа',
    },
    'v6o9xcii': {
      'en': 'Email address',
      'es': 'Correo electrónico',
      'ru': 'Электронная почта',
    },
    '8o8sm32x': {
      'en': 'Password',
      'es': 'Contraseña',
      'ru': 'Пароль',
    },
    'jvlhc56j': {
      'en': 'Log in',
      'es': 'Iniciar sesión',
      'ru': 'Войти',
    },
    'gbhzkxej': {
      'en': 'Continue with Apple',
      'es': 'Continuar con Apple',
      'ru': 'Продолжить с Apple',
    },
    'k1r81ycx': {
      'en': 'Forgot password? ',
      'es': '¿Olvidaste tu contraseña?',
      'ru': 'Забыли пароль? ',
    },
    'f4zg2rq8': {
      'en': 'Reset',
      'es': 'Restablecer',
      'ru': 'Сбросить',
    },
    '9jzxfvzw': {
      'en': 'By continuing, you agree to our',
      'es': 'Al continuar, aceptas nuestros',
      'ru': 'Продолжая, вы принимаете наши',
    },
    'oksxunlm': {
      'en': 'Terms and Privacy Policy',
      'es': 'Términos y Política de privacidad',
      'ru': 'Условия и Политику конфиденциальности',
    },
    'x1jameup': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // Onboarding_Profile
  {
    'zte082q6': {
      'en': 'Customize your profile',
      'es': 'Personaliza tu perfil',
      'ru': 'Настройте профиль',
    },
    'lf9tgr4o': {
      'en': 'Add your profile details below',
      'es': 'Añade los detalles de tu perfil',
      'ru': 'Добавьте информацию о себе',
    },
    '7s3y7mvj': {
      'en': 'Profile photo ideas',
      'es': 'Ideas para foto de perfil',
      'ru': 'Идеи для фото профиля',
    },
    '806chf8j': {
      'en': 'First name',
      'es': 'Nombre de pila',
      'ru': 'Имя',
    },
    '3s25dejy': {
      'en': 'Last name',
      'es': 'Apellido',
      'ru': 'Фамилия',
    },
    'r07lmjc9': {
      'en': 'Username',
      'es': 'Nombre de usuario',
      'ru': 'Имя пользователя',
    },
    'razzzfb3': {
      'en': 'Username ideas',
      'es': 'Ideas para nombres de usuario',
      'ru': 'Идеи для имени пользователя',
    },
    'otyd40i2': {
      'en': 'Interface language',
      'es': 'Idioma de la interfaz',
      'ru': 'Язык интерфейса',
    },
    'z80dp9kp': {
      'en': 'First name is required.',
      'es': 'El nombre es obligatorio.',
      'ru': 'Имя обязательно.',
    },
    'lwk5zvwl': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'kpzghah7': {
      'en': 'Last name is required.',
      'es': 'El apellido es obligatorio.',
      'ru': 'Фамилия обязательна.',
    },
    'szaw5qld': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'pkkj80zk': {
      'en': 'Nickname is required.',
      'es': 'Se requiere apodo.',
      'ru': 'Требуется указать псевдоним.',
    },
    'mg6kozzr': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'spc42q3x': {
      'en': 'Continue',
      'es': 'Continuar',
      'ru': 'Продолжить',
    },
    'jyisdhjp': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // Onboarding_Instructions
  {
    '4h3142h8': {
      'en': 'Take a photo or upload a product',
      'es': 'Toma una foto o sube un producto',
      'ru': 'Сделайте фото или загрузите продукт',
    },
    'iq5uwmkr': {
      'en':
          'Simply snap or upload a photo of any cosmetic product—we\'ll instantly recognize and analyze it.',
      'es':
          'Simplemente toma o sube una foto de cualquier producto cosmético: lo reconoceremos y analizaremos al instante.',
      'ru':
          'Просто сделайте или загрузите фото косметического средства — мы мгновенно распознаем и проанализируем его.',
    },
    't15aa351': {
      'en': 'Save favorites your way',
      'es': 'Guarda tus favoritos a tu manera',
      'ru': 'Сохраняйте избранное',
    },
    'pwl68ete': {
      'en':
          'Organize your favorite products by category and add personal notes—your perfect routine, always at hand.',
      'es':
          'Organiza tus productos favoritos por categoría y añade notas personales: tu rutina perfecta, siempre a mano.',
      'ru':
          'Организуйте любимые продукты по категориям и добавляйте заметки — идеальный уход всегда под рукой.',
    },
    '15gvq4lh': {
      'en': 'Share your finds',
      'es': 'Comparte tus hallazgos',
      'ru': 'Делитесь находками',
    },
    's7tdc3jt': {
      'en':
          'Share favorite products with friends or save their recommendations—only carefully analyzed products in your collection.',
      'es':
          'Comparte productos favoritos con amigos o guarda sus recomendaciones: solo productos cuidadosamente analizados en tu colección.',
      'ru':
          'Делитесь любимыми продуктами с друзьями или сохраняйте их рекомендации — только тщательно проанализированные средства в коллекции.',
    },
    '17ibyu4t': {
      'en': 'Back',
      'es': 'Atrás',
      'ru': 'Назад',
    },
    'y5wcyxmx': {
      'en': 'Get started',
      'es': 'Comenzar',
      'ru': 'Начать',
    },
    'u52b0vlk': {
      'en': 'Next',
      'es': 'Siguiente',
      'ru': 'Далее',
    },
    't6xvo2bj': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // Boards
  {
    'g9plkvs3': {
      'en': 'Collections',
      'es': 'Colecciones',
      'ru': 'Подборки',
    },
    'lkfbdixo': {
      'en': 'New collection',
      'es': 'Nueva colección',
      'ru': 'Новая подборка',
    },
    'ftrzd6sh': {
      'en': 'Collections',
      'es': 'Colecciones',
      'ru': 'Подборки',
    },
  },
  // Home
  {
    'fjrdil62': {
      'en': 'Update to PRO',
      'es': 'Pasar a PRO',
      'ru': 'Перейти на PRO',
    },
    'pmne5rlo': {
      'en': 'Hello, ',
      'es': '¡Hola, ',
      'ru': 'Привет, ',
    },
    'cs6ibthq': {
      'en': 'AI Cosmetic Analysis',
      'es': 'Análisis de IA (INCI)',
      'ru': 'AI Анализ Косметики',
    },
    '5tol65io': {
      'en': 'Instantly analyze ingredients and get safety ratings',
      'es':
          'Analice instantáneamente los ingredientes y obtenga calificaciones de seguridad',
      'ru':
          'Мгновенно анализируйте ингредиенты и получайте оценки безопасности.',
    },
    'ie8y2531': {
      'en': '/',
      'es': '/',
      'ru': '/',
    },
    'mbf7bgat': {
      'en': ' analyses used',
      'es': '  análisis utilizados',
      'ru': '  использовано анализов',
    },
    'sgp5e6y4': {
      'en': 'Start Analysis',
      'es': 'Iniciar análisis',
      'ru': 'Начать анализ',
    },
    'cnejp0mk': {
      'en': 'My Products',
      'es': 'Mis productos',
      'ru': 'Мои Продукты',
    },
    '1fq5s0h9': {
      'en': 'Explore',
      'es': 'Explorar',
      'ru': 'Исследовать',
    },
  },
  // Profile
  {
    '1g4dikoz': {
      'en': 'Try premium',
      'es': 'Prueba premium',
      'ru': 'Попробуйте премиум-версию',
    },
    '45rliy0n': {
      'en': 'Edit Profile',
      'es': 'Editar perfil',
      'ru': 'Редактировать профиль',
    },
    '0nawsp0z': {
      'en': 'Share',
      'es': 'Compartir',
      'ru': 'Поделиться',
    },
    'yyo7sp77': {
      'en': 'Leave a Review',
      'es': 'Deja una reseña',
      'ru': 'Оставить отзыв',
    },
    'su4nz9dy': {
      'en': 'App language',
      'es': 'Idioma de la app',
      'ru': 'Язык приложения',
    },
    'gcl2zbxg': {
      'en': 'Your Region',
      'es': 'Tu región',
      'ru': 'Ваш регион',
    },
    '01vkpjw3': {
      'en': 'Log out',
      'es': 'Finalizar la sesión',
      'ru': 'Выйти',
    },
    'hm5mygux': {
      'en': 'Delete account',
      'es': 'Eliminar cuenta',
      'ru': 'Удалить аккаунт',
    },
    'b5etn619': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // imagedetails
  {
    'qrwru10w': {
      'en': 'Print',
      'es': '',
      'ru': '',
    },
    'fpabsgw2': {
      'en': 'Mark as spam',
      'es': 'Marcar como spam',
      'ru': 'Отметить как спам',
    },
    '2zwuat2o': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // imagesbyAlbum
  {
    '9irpcdv0': {
      'en': 'Collections',
      'es': 'Colecciones',
      'ru': 'Подборки',
    },
  },
  // ForgotPassword
  {
    'n5l6rjok': {
      'en': 'Reset Password',
      'es': 'Restablecer contraseña',
      'ru': 'Сбросить пароль',
    },
    '7m4wdroo': {
      'en':
          'You’ll receive a link to reset your password after entering your email address below.',
      'es':
          'Recibirás un enlace para restablecer tu contraseña después de ingresar tu correo electrónico a continuación.',
      'ru':
          'Введите адрес электронной почты — мы отправим вам ссылку для сброса пароля.',
    },
    '6rbowge6': {
      'en': 'Email address',
      'es': 'Dirección de correo electrónico',
      'ru': 'Адрес электронной почты',
    },
    'g9lwam7j': {
      'en': 'Email address is required.',
      'es': 'Se requiere dirección de correo electrónico.',
      'ru': 'Адрес электронной почты обязателен.',
    },
    'ppwv5em7': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'ba5totab': {
      'en': 'Send Reset Password Link',
      'es': 'Enviar enlace para restablecer contraseña',
      'ru': 'Отправить ссылку для сброса пароля',
    },
    'ivgt0bnk': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // EditProfile
  {
    'naz9ync6': {
      'en': 'Avatar ideas',
      'es': 'Ideas para avatares',
      'ru': 'Идеи аватарок',
    },
    '5qv9fjet': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'zh29g2pb': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'ty7b3kkv': {
      'en': '',
      'es': '',
      'ru': '',
    },
    's504ftt3': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'tvz6ivhn': {
      'en': 'First name is required.',
      'es': 'El nombre es obligatorio.',
      'ru': 'Имя обязательно.',
    },
    'epo4g4if': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    '33bi6x4z': {
      'en': 'Last name is required.',
      'es': 'El apellido es obligatorio.',
      'ru': 'Фамилия обязательна.',
    },
    'sz56qo2e': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'n0kk243i': {
      'en': 'Nickname is required.',
      'es': 'Se requiere apodo.',
      'ru': 'Требуется указать псевдоним.',
    },
    'fczkxxb8': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'bwi4v4ib': {
      'en': 'Save Changes',
      'es': 'Guardar cambios',
      'ru': 'Сохранить изменения',
    },
    '6nakj5p3': {
      'en': 'Edit Profile',
      'es': 'Editar perfil',
      'ru': 'Редактировать профиль',
    },
    '88aeu6x5': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // Toprated
  {
    's0iman0p': {
      'en': 'Explore',
      'es': 'Explorar',
      'ru': 'Обзор',
    },
    'lhz5s19w': {
      'en': 'Top-rated by the community',
      'es': 'Mejor valorados por la comunidad',
      'ru': 'Лучшее от сообщества',
    },
    'fy9oe58n': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // Paywallpage
  {
    '7n2kv1iq': {
      'en': 'UPGRADE TO PRO',
      'es': 'Actualizar a PRO',
      'ru': 'Перейти на PRO',
    },
    '2rjs2u6d': {
      'en': 'See what your skincare really does',
      'es': 'Descubre qué hace realmente tu skincare',
      'ru': 'Узнай, что на самом деле делает твоя косметика',
    },
    '8u51n3um': {
      'en': ' ≈ ',
      'es': ' ≈ ',
      'ru': ' ≈ ',
    },
    '9w0g4j4t': {
      'en': '/ month',
      'es': '/ mes',
      'ru': '/ месяц',
    },
    '1g94zlat': {
      'en': 'Continue',
      'es': 'Continuar',
      'ru': 'Продолжить',
    },
    'x8c6hh46': {
      'en': 'TWO MONTHS FREE',
      'es': 'DOS MESES GRATIS',
      'ru': 'Экономия 42%',
    },
    '88jhwjj4': {
      'en': ' ≈ ',
      'es': ' ≈ ',
      'ru': ' ≈ ',
    },
    'yzzh1a7x': {
      'en': '/ month',
      'es': '/ mes',
      'ru': '/ месяц',
    },
    'ps8msu6e': {
      'en': 'Continue',
      'es': 'Continuar',
      'ru': 'Продолжить',
    },
    'ebqccf7f': {
      'en': 'Restore Purchases',
      'es': 'Restaurar compras',
      'ru': 'Восстановить покупки',
    },
    'whubf4jp': {
      'en':
          'Subscription price:It is a symbolic price through which the continuity of the application and the costs of its operation, updates and deployment can be supported.Subscribe and support the continuity of the application.paying off: \nPayment will be made via your Apple ID after subscription confirmation, and subscription will automatically renew unless auto-renew is turned off at least 24-hours before the end of the subscription period with the then-current subscription fee.Subscription management:You can manage your subscriptions and turn off auto-renewal by going to your account settings in the App Store after purchase.',
      'es':
          'Precio de la suscripción: Es un precio simbólico que permite cubrir la continuidad de la aplicación y los costes de su funcionamiento, actualizaciones e implementación. Suscríbete y apoya la continuidad de la aplicación. Beneficios: El pago se realizará a través de tu ID de Apple tras confirmar la suscripción y se renovará automáticamente a menos que desactives la renovación automática al menos 24 horas antes del final del periodo de suscripción con la tarifa vigente en ese momento. Gestión de suscripciones: Puedes gestionar tus suscripciones y desactivar la renovación automática accediendo a la configuración de tu cuenta en la App Store tras la compra.',
      'ru':
          'Стоимость подписки: это символическая цена, за счет которой обеспечивается непрерывность работы приложения и покрытие расходов на его эксплуатацию, обновления и развертывание. Подпишитесь и поддержите непрерывность работы приложения. Оплата:\nОплата будет произведена через ваш Apple ID после подтверждения подписки, и подписка будет автоматически продлеваться, если автоматическое продление не будет отключено как минимум за 24 часа до окончания периода подписки с использованием текущей абонентской платы. Управление подписками: Вы можете управлять своими подписками и отключать автоматическое продление, перейдя в настройки своей учетной записи в App Store после покупки.',
    },
    'j321mb3y': {
      'en': 'Privacy Policy',
      'es': 'Política de privacidad',
      'ru': 'Политика конфиденциальности',
    },
    'r6swa5sg': {
      'en': 'Terms of use',
      'es': 'Condiciones de uso',
      'ru': 'Условия использования',
    },
    'cv7r6leq': {
      'en': 'Home',
      'es': 'Hogar',
      'ru': 'Дом',
    },
  },
  // Langs
  {
    'kgd7sdul': {
      'en': '🇺🇸 English',
      'es': '🇺🇸 Inglés',
      'ru': '🇺🇸 Английский',
    },
    'gp7z3wuj': {
      'en': ' 🇷🇺 Русский',
      'es': '🇷🇺 Ruso',
      'ru': '🇷🇺 Русский',
    },
    'lfacw4vw': {
      'en': ' 🇪🇸 Español',
      'es': '🇪🇸 Español',
      'ru': '🇪🇸 Español',
    },
    'c7dzaokw': {
      'en': 'App language',
      'es': 'Idioma de la aplicación',
      'ru': 'Язык приложения',
    },
  },
  // TakeorUploadPage
  {
    'rstxqopn': {
      'en': 'Free plan',
      'es': 'Plan Gratuito',
      'ru': 'Бесплатный план',
    },
    'efo6pk07': {
      'en': 'PRO plan',
      'es': 'Plan PRO',
      'ru': 'PRO-план',
    },
    '8q04ptlr': {
      'en': '/',
      'es': '/',
      'ru': '/',
    },
    'u9352mom': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'jjy5neq6': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'qb4ojhyz': {
      'en': ' analyses remaining this month',
      'es': ' análisis restantes este mes',
      'ru': ' анализов осталось в этом месяце',
    },
    'e431pan7': {
      'en': ' analyses remaining this month',
      'es': ' análisis restantes este mes',
      'ru': ' анализов осталось в этом месяце',
    },
    's07ldcer': {
      'en': 'Analyze your product',
      'es': 'Analiza tu producto',
      'ru': 'Анализ вашего продукта',
    },
    'h67zdlkd': {
      'en':
          'Choose how you\'d like to upload your cosmeticproduct photo for ingredient analysis.',
      'es':
          'Elige cómo subir la foto de tu producto cosmético para analizar sus ingredientes',
      'ru':
          'Выберите, как загрузить фото косметического продукта для анализа ингредиентов',
    },
    'qp1hi0rq': {
      'en': 'Analysis started\nUsually takes up to 1 minute',
      'es': 'Análisis iniciado\nNormalmente tarda hasta 1 minuto',
      'ru': 'Анализ запущен\nОбычно занимает до 1 минуты',
    },
    '6785p5nl': {
      'en': 'Recognizing product....',
      'es': 'Reconociendo producto....',
      'ru': 'Распознавание продукта....',
    },
    'f0iwc245': {
      'en': 'Analyzing ingredients...',
      'es': 'Analizando ingredientes...',
      'ru': 'Анализ ингредиентов...',
    },
    'jfb7hpl8': {
      'en': 'Preparing your report...',
      'es': 'Preparando tu informe...',
      'ru': 'Подготовка отчёта...',
    },
    'xirptk6c': {
      'en': 'Take a photo',
      'es': 'Tomar una foto',
      'ru': 'Сделать фото',
    },
    'pznd0mgm': {
      'en': 'Choose from gallery',
      'es': 'Elegir de la galería',
      'ru': 'Выбрать из галереи',
    },
    'c793vezr': {
      'en': 'Photo tips',
      'es': 'Tips para fotos',
      'ru': 'Подсказки для фото',
    },
    'byujsu2p': {
      'en': 'Make sure the brand name and product name are clearly visible',
      'es': 'Que se vea bien claro el nombre de la marca y del producto',
      'ru': 'Бренд и название продукта должны быть чётко видны',
    },
    'dcho9j17': {
      'en': 'Use good lighting for betteraccuracy',
      'es': 'Usa buena iluminación para mayor precisión',
      'ru': 'Используйте хорошее освещение — будет точнее',
    },
    'be3z130n': {
      'en': 'Keep text in focus and readable',
      'es': 'El texto tiene que estar enfocado y leerse fácil',
      'ru': 'Держи текст в фокусе, чтобы он был читаемым',
    },
    'eb9qmbpi': {
      'en': 'Example photo',
      'es': 'Foto de ejemplo',
      'ru': 'Пример фотографии',
    },
    'fxe2m9tp': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // Favorites
  {
    'slaql1vn': {
      'en': 'Favorite products',
      'es': 'Productos favoritos',
      'ru': 'Избранные продукты',
    },
    '5dhl2hvp': {
      'en': 'Favourites',
      'es': 'Favoritos',
      'ru': 'Избранное',
    },
    'yaqevjgo': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // Countries
  {
    'ldro9gp9': {
      'en': 'We\'ll show local retailers and products available in your area',
      'es':
          'Te mostraremos tiendas locales y productos disponibles en tu región',
      'ru':
          'Мы покажем локальные магазины и продукты, доступные в вашем регионе',
    },
    '8pwht5ld': {
      'en': 'Your Region',
      'es': 'Tu región',
      'ru': 'Ваш регион',
    },
  },
  // newblank
  {
    'da2agqnn': {
      'en': 'INCI Decode AI',
      'es': 'INCI Decode AI',
      'ru': 'INCI Decode AI',
    },
    '2d4q59e7': {
      'en': 'Your skincare expert',
      'es': 'Tu experto en productos de belleza',
      'ru': 'Ваш эксперт по косметике',
    },
    '5t7iunbg': {
      'en':
          'Get complete insights on formula effectiveness and ingredient safety—just snap a photo.',
      'es':
          'Obtén información completa sobre la efectividad de la fórmula y la seguridad de los ingredientes: solo toma una foto.',
      'ru':
          'Получите полную информацию об эффективности формулы и безопасности ингредиентов — просто сделайте фото.',
    },
    '7ujfcyzd': {
      'en': 'Get Started',
      'es': 'Comenzar',
      'ru': 'Начать',
    },
    'k2s5anzx': {
      'en': 'Already have an account? ',
      'es': '¿Ya tienes cuenta? ',
      'ru': 'Уже есть аккаунт? ',
    },
    'b3n2vltd': {
      'en': 'Log in',
      'es': 'Iniciar sesión',
      'ru': 'Войти',
    },
    'g8q5xvh6': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // itemcard2
  {
    's8zqazfv': {
      'en': 'Overall Score',
      'es': 'Puntuación total',
      'ru': 'Общая оценка',
    },
    '0gp4aqqw': {
      'en': '/',
      'es': '/',
      'ru': '/',
    },
    '4m42sem0': {
      'en': '100',
      'es': '100',
      'ru': '100',
    },
    'cox122eb': {
      'en': 'Expert Analysis',
      'es': 'Análisis experto',
      'ru': 'Экспертный анализ',
    },
    'sdd57mig': {
      'en': 'How to use',
      'es': 'Cómo usar ',
      'ru': 'Как использовать ',
    },
    'pt08joyi': {
      'en': 'Skin Type Compatibility',
      'es': 'Compatibilidad con el tipo de piel',
      'ru': 'Совместимость с типом кожи',
    },
    'wgu62t65': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'gs46omyo': {
      'en': 'Top Active Ingredients',
      'es': 'Principales ingredientes activos',
      'ru': 'Основные активные ингредиенты',
    },
    'sgfwkpt4': {
      'en': 'Position',
      'es': 'Posición',
      'ru': 'Позиция',
    },
    '92xu2duz': {
      'en': 'Efficacy Contribution',
      'es': 'Contribución a la eficacia',
      'ru': 'Вклад в эффективность',
    },
    'ijod64a2': {
      'en': 'Your feedback',
      'es': 'Tu opinión',
      'ru': 'Ваше мнение',
    },
    'e2fxci9s': {
      'en': 'Was this analysis helpful? ',
      'es': '¿Te ha resultado útil este análisis? ',
      'ru': 'Был ли этот анализ полезен? ',
    },
    'on05z6xe': {
      'en': 'Helpful',
      'es': 'Útil',
      'ru': 'Полезно',
    },
    '330wbi7z': {
      'en': 'Not Helpful',
      'es': 'No es útil',
      'ru': 'Бесполезно',
    },
    '5a7j03ug': {
      'en': 'Personal Notes',
      'es': 'Notas personales',
      'ru': 'Персональные заметки',
    },
    'abj9484s': {
      'en':
          'There is nothing here at the moment. Add your personal notes for this product.',
      'es':
          'Por ahora no hay nada aquí. Añade tus notas personales para este producto.',
      'ru':
          'Пока что здесь пусто. Добавьте ваши персональные заметки для этого продукта.',
    },
    'd7zoo4qj': {
      'en': 'Add to favourite',
      'es': 'Añadir a favoritos',
      'ru': 'Добавить в избранное',
    },
    '8fxs3m5r': {
      'en': 'Remove from favorite',
      'es': 'Eliminar de favoritos',
      'ru': 'Удалить из избранного',
    },
    '7um3crv1': {
      'en': 'Hide form public',
      'es': 'Hacer privado',
      'ru': 'Скрыть из общего доступа',
    },
    'ves7p6f3': {
      'en': 'Make product public',
      'es': 'Hacer público',
      'ru': 'Сделать продукт общедоступным',
    },
    'xkz8m3p1': {
      'en': 'Share link',
      'es': 'Compartir enlace',
      'ru': 'Поделиться ссылкой',
    },
    'q2xjnp4k': {
      'en': 'Add to board',
      'es': 'Añadir al tablero',
      'ru': 'Добавить на доску',
    },
    'bpwivw1d': {
      'en': 'Mark as spam',
      'es': 'Marcar como spam',
      'ru': 'Пометить как спам',
    },
    '8v1j4q7h': {
      'en': 'Copy product',
      'es': 'Copiar producto',
      'ru': 'Копировать продукт',
    },
    'alhd09eg': {
      'en': 'Delete',
      'es': 'Eliminar',
      'ru': 'Удалить',
    },
    'a8n7a8qx': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
  },
  // Shareproduct
  {
    'zgq2b7dh': {
      'en': 'Choose a card format to save',
      'es': 'Elige el formato de tarjeta para guardar',
      'ru': 'Выберите формат карточки для сохранения',
    },
    'c72tq9qs': {
      'en': 'Story',
      'es': 'Historia',
      'ru': 'Сториз',
    },
    '731ycgiu': {
      'en': 'Square',
      'es': 'Cuadrado',
      'ru': 'Квадрат',
    },
    'sronrotm': {
      'en': 'Home',
      'es': '',
      'ru': '',
    },
  },
  // PaywallConfirmation
  {
    '0t5sc45u': {
      'en': 'PRO',
      'es': 'PRO',
      'ru': 'PRO',
    },
    'mcrnylah': {
      'en': 'Welcome to M!RRA Pro',
      'es': 'Bienvenido a M!RRA Pro',
      'ru': 'Добро пожаловать в M!RRA Pro',
    },
    'l13naqtt': {
      'en': '200 analytics requests per month',
      'es': '200 solicitudes de análisis al mes',
      'ru': '200 запросов на аналитику продуктов в месяц',
    },
    '8slgbpit': {
      'en': 'Save to collections',
      'es': 'Guardar en colecciones',
      'ru': 'Сохраняйте в подборки',
    },
    'nyi1gh42': {
      'en': 'Share your finds',
      'es': 'Comparte tus hallazgos',
      'ru': 'Делитесь своими находками',
    },
    'nzvzb6kk': {
      'en': 'High-rated formulas',
      'es': 'Fórmulas mejor valoradas',
      'ru': 'Подборки составов с высоким рейтингом',
    },
    'ccikm8kx': {
      'en': 'Let\'s go!',
      'es': '¡Vamos!',
      'ru': 'Поехали!',
    },
  },
  // navbar
  {
    'kndykt66': {
      'en': 'Home',
      'es': 'Inicio',
      'ru': 'Главная',
    },
    'f0lv5sbb': {
      'en': 'Explore',
      'es': 'Explorar',
      'ru': 'Обзор',
    },
    '5lvcbe4s': {
      'en': 'Collections',
      'es': 'Colecciones',
      'ru': 'Подборки',
    },
    'i0bb253q': {
      'en': 'Profile',
      'es': 'Perfil',
      'ru': 'Профиль',
    },
  },
  // DeleteConfirmation
  {
    '4latue44': {
      'en': 'Are you sure you want to delete your account?',
      'es': '¿Estás seguro que deseas eliminar tu cuenta?',
      'ru': 'Вы уверены, что хотите удалить свой аккаунт?',
    },
    '9fm4u5g5': {
      'en': 'Any products you’ve added will be deleted.',
      'es': 'Todos los productos que hayas añadido se eliminarán.',
      'ru': 'Все добавленные вами продукты будут удалены.',
    },
    'qh4oraql': {
      'en': 'Delete account',
      'es': 'Eliminar cuenta',
      'ru': 'Удалить аккаунт',
    },
    '9lehmzbk': {
      'en': 'Cancel',
      'es': 'Cancelar',
      'ru': 'Отмена',
    },
  },
  // newAlbum
  {
    '3k3xtikh': {
      'en': 'Create new board',
      'es': 'Crear nuevo tablero',
      'ru': 'Создать новую доску',
    },
    'l4d5m49x': {
      'en': 'Add board details below',
      'es': 'Agrega detalles del tablero a continuación',
      'ru': 'Добавьте информацию ниже',
    },
    'azcd4b5c': {
      'en': 'New board name',
      'es': 'Nombre del nuevo tablero',
      'ru': 'Название новой доски',
    },
    '5t47wlr7': {
      'en': 'Title is required.',
      'es': 'Se requiere título.',
      'ru': 'Требуется указать заголовок.',
    },
    '5ylzoaso': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'h68noqox': {
      'en': 'Create',
      'es': 'Crear',
      'ru': 'Создать',
    },
    'sw4zsxbk': {
      'en': 'Cancel',
      'es': 'Cancelar',
      'ru': 'Отменить',
    },
  },
  // editAlbum
  {
    'fr6pjcbf': {
      'en': 'Edit board details',
      'es': 'Editar tablero',
      'ru': 'Редактировать доску',
    },
    'cfmx4p6n': {
      'en': 'Title',
      'es': 'Título',
      'ru': 'Заголовок',
    },
    'czl8suqe': {
      'en': 'Title is required.',
      'es': 'Se requiere título.',
      'ru': 'Требуется указать заголовок.',
    },
    'zvzfz7u0': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'mkoyjpvu': {
      'en': 'Field is required',
      'es': 'El campo es obligatorio',
      'ru': 'Поле обязательно для заполнения.',
    },
    'u3eh8pby': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    'ifhesf3b': {
      'en': 'Save Changes',
      'es': 'Guardar cambios',
      'ru': 'Сохранить изменения',
    },
    'aqmuxxl3': {
      'en': 'Delete',
      'es': 'Eliminar',
      'ru': 'Удалить',
    },
  },
  // blankAlbum
  {
    '1s4tdpvq': {
      'en': 'Empty album...',
      'es': 'Álbum vacío...',
      'ru': 'Пустой альбом...',
    },
  },
  // premiumFeaturesList
  {
    '8xm0tarf': {
      'en': 'Full scientific analysis — safety, efficacy & skin compatibility',
      'es': 'Análisis científico completo — seguridad, eficacia y compatibilidad',
      'ru': 'Полный научный анализ — безопасность, эффективность и совместимость',
    },
    'y0rimd99': {
      'en': 'Personalized verdict based on your skin type',
      'es': 'Veredicto personalizado según tu tipo de piel',
      'ru': 'Персональный вердикт на основе твоего типа кожи',
    },
    'o1zj0116': {
      'en': 'Top-rated products ranking',
      'es': 'Ranking de productos mejor valorados',
      'ru': 'Рейтинг лучших продуктов сообщества',
    },
    'pm4r9x2w': {
      'en': 'Keep your scans private',
      'es': 'Mantén tus análisis en privado',
      'ru': 'Скрывай свои сканы от других',
    },
  },
  // OutOfGenerations
  {
    '1zkc5y9j': {
      'en': 'Limit reached',
      'es': 'Límite alcanzado',
      'ru': 'Вы достигли лимита',
    },
    '1egcc9to': {
      'en':
          'You’ve reached the maximum number of analyses.\nUpgrade to Pro or contact support for help.',
      'es':
          'Has alcanzado el número máximo de análisis.\nMejora a Pro o contacta con el soporte para obtener ayuda.',
      'ru':
          'Вы использовали установленное количество анализов.\nПерейдите на Pro-версию или обратитесь в службу поддержки.',
    },
    'enziwu64': {
      'en': 'Got it',
      'es': 'Entendido',
      'ru': 'Понятно',
    },
  },
  // leaveReview
  {
    '9g2qcen7': {
      'en': 'Leave your review here',
      'es': 'Deja tu reseña aquí',
      'ru': 'Оставьте свой отзыв здесь',
    },
    'is69hoea': {
      'en': 'Feedback helps us develop our product faster',
      'es':
          'Los comentarios nos ayudan a desarrollar nuestro producto más rápido',
      'ru': 'Обратная связь помогает нам быстрее разрабатывать наш продукт.',
    },
    'l1p9g6sy': {
      'en': 'Short Description',
      'es': 'Descripción breve',
      'ru': 'Краткое описание',
    },
    'etqk72qg': {
      'en': 'Type a message here',
      'es': 'Escribe un mensaje aquí',
      'ru': 'Введите сообщение здесь',
    },
    '6nbvew2p': {
      'en': 'Title is required.',
      'es': 'Se requiere título.',
      'ru': 'Требуется указать заголовок.',
    },
    'kmqitvxn': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    '35sexy68': {
      'en': 'Field is required',
      'es': 'El campo es obligatorio',
      'ru': 'Поле обязательно для заполнения.',
    },
    '36k4g97w': {
      'en': 'Please choose an option from the dropdown',
      'es': 'Por favor, elija una opción del menú desplegable.',
      'ru': 'Пожалуйста, выберите вариант из выпадающего списка.',
    },
    '0n0273ug': {
      'en': 'Send',
      'es': 'Enviar',
      'ru': 'Отправить',
    },
  },
  // nounsorteditems
  {
    'gzohwfxg': {
      'en': 'There are no products yet',
      'es': 'No hay productos todavía',
      'ru': 'Товаров пока нет',
    },
  },
  // upgrade
  {
    'rl28xdip': {
      'en': 'Update a Pro',
      'es': 'Mejorar a Pro',
      'ru': 'Перейти на Pro',
    },
  },
  // imagecart
  {
    'zbl2b3bx': {
      'en': 'Hello World',
      'es': 'Hola mundo!',
      'ru': 'Привет, мир!',
    },
  },
  // deleteitem
  {
    'ww2bynjy': {
      'en': 'Delete Item',
      'es': 'Eliminar elemento',
      'ru': 'Удалить элемент',
    },
    'ejy0zcsp': {
      'en':
          'Are you sure you want to delete this item? \nThis action cannot be undone.',
      'es':
          '¿Estás seguro de que deseas eliminar este elemento?\nEsta acción no se puede deshacer.',
      'ru':
          'Вы уверены, что хотите удалить этот элемент?\nЭто действие необратимо.',
    },
    'ood20cri': {
      'en': 'Cancel',
      'es': 'Cancelar',
      'ru': 'Отмена',
    },
    'y814btsy': {
      'en': 'Delete',
      'es': 'Borrar',
      'ru': 'Удалить',
    },
  },
  // Emptyfavourite
  {
    'f9tt3hzn': {
      'en': 'Your favorite products will appear here.',
      'es': 'Aquí aparecerán tus productos favoritos.',
      'ru': 'Здесь будут отображаться ваши избранные продукты',
    },
  },
  // Emptytopfindings
  {
    'dupyww6s': {
      'en':
          'Here you’ll see products with high ratings based on ingredient analysis.',
      'es':
          'Aquí verás productos con alta puntuación según el análisis de ingredientes.',
      'ru':
          'Здесь будут отображаться продукты с высоким рейтингом по результатам анализа состава.',
    },
  },
  // limitOut
  {
    'fvjg2ei8': {
      'en': 'Limit reached',
      'es': 'Límite alcanzado',
      'ru': 'Превышен лимит',
    },
    '5vf31bag': {
      'en': 'You’ve used ',
      'es': 'Has utilizado ',
      'ru': 'Вы использовали ',
    },
    '9iwfkse3': {
      'en': ' product analysis requests.\nYour limit will reset on ',
      'es':
          ' solicitudes de análisis de productos.\nEl límite se restablecerá el ',
      'ru': ' запросов на анализ продукта.\nЛимит будет обновлён ',
    },
    'e12wjrgi': {
      'en': 'Got it',
      'es': 'Entendido',
      'ru': 'Понятно',
    },
    'cscoyn8e': {
      'en': 'Upgrade to Pro',
      'es': 'Mejorar a Pro',
      'ru': 'Перейти на Pro',
    },
  },
  // countryselector
  {
    'ocz602t7': {
      'en': 'Your region',
      'es': 'Tu región',
      'ru': 'Ваш регион',
    },
    'qsbnew6g': {
      'en': 'Search...',
      'es': 'Buscar...',
      'ru': 'Поиск...',
    },
  },
  // Startanalys
  {
    '16f5sjb6': {
      'en': 'AI Analysis',
      'es': 'Análisis de IA',
      'ru': 'Анализ ИИ',
    },
    'bk3jxz77': {
      'en': 'Scan a Product',
      'es': 'Escanear un producto',
      'ru': 'Отсканируйте товар',
    },
    'a8lx03m5': {
      'en': 'Instantly analyze ingredients and get safety ratings',
      'es':
          'Analice instantáneamente los ingredientes y obtenga calificaciones de seguridad',
      'ru':
          'Мгновенно анализируйте ингредиенты и получайте оценки безопасности.',
    },
    'zyx01ncu': {
      'en': 'Start',
      'es': 'Iniciar',
      'ru': 'Начать',
    },
  },
  // ratingdetailed
  {
    'bijscz1a': {
      'en': 'Safety Score',
      'es': 'Puntuación de seguridad',
      'ru': 'Оценка безопасности',
    },
    '2x9pgdry': {
      'en': 'Suitable for:',
      'es': 'Adecuado para:',
      'ru': 'Подходит для:',
    },
  },
  // yourrating
  {
    'yr352ijv': {
      'en': 'Your rating of the product',
      'es': 'Tu valoración del producto',
      'ru': 'Ваша оценка продукта',
    },
  },
  // personalnotes
  {
    'yxsdvb47': {
      'en': 'Your personal notes about the product',
      'es': 'Tus notas personales sobre el producto',
      'ru': 'Ваши персональные заметки о продукте',
    },
    'hg03d4pn': {
      'en':
          'There is nothing here at the moment. Add your personal notes for this product.',
      'es':
          'Por ahora no hay nada aquí. Añade tus notas personales para este producto.',
      'ru':
          'Пока что здесь пусто. Добавьте ваши персональные заметки для этого продукта.',
    },
  },
  // sammary
  {
    '6qffgpwn': {
      'en': 'Summary',
      'es': 'Resumen',
      'ru': 'Резюме',
    },
  },
  // Parametrs
  {
    'og3ip7y9': {
      'en': 'Product Details',
      'es': 'Detalles del producto',
      'ru': 'Сведения о продукте',
    },
    'mbtcecb5': {
      'en': 'Skin type recomendations',
      'es': 'Recomendaciones según el tipo de piel',
      'ru': 'Рекомендации по типу кожи',
    },
    't011iras': {
      'en': '✓ Pros',
      'es': '✓ Pros',
      'ru': '✓ Плюсы',
    },
    'unv28agb': {
      'en': '✘ Cons',
      'es': '✘ Cons',
      'ru': '✘ Минусы',
    },
    'wjg934yf': {
      'en': 'Warnings',
      'es': 'Advertencias',
      'ru': 'Предупреждения',
    },
  },
  // ingridients
  {
    '11yiut5a': {
      'en': 'Ingredients (INCI)',
      'es': 'Ingredientes (INCI)',
      'ru': 'Состав (INCI)',
    },
  },
  // copyitem
  {
    'yj35oi8u': {
      'en': 'Copy Item',
      'es': 'Copiar artículo',
      'ru': 'Копировать элемент',
    },
    'p2cdk61c': {
      'en': 'Are you sure you want to copy this item to your products? ',
      'es': '¿Estás seguro de que deseas copiar este artículo a tus productos?',
      'ru': 'Вы уверены, что хотите скопировать этот элемент в свои товары?',
    },
    '5gas3j6n': {
      'en': 'Cancel',
      'es': 'Cancelar',
      'ru': 'Отмена',
    },
    'noj51h6l': {
      'en': 'Copy',
      'es': 'Copiar',
      'ru': 'Копировать',
    },
  },
  // newboardempty
  {
    '95giorwg': {
      'en': 'Your collections',
      'es': 'Tus colecciones',
      'ru': 'Ваши подборки',
    },
    'd37etdgk': {
      'en': 'Save favourites, build routines, share your picks',
      'es': 'Guarda favoritos, crea rutinas, comparte tus hallazgos',
      'ru': 'Сохраняйте любимое, собирайте рутины, делитесь находками',
    },
    'o1bipgy8': {
      'en': 'Create collection',
      'es': 'Crear colección',
      'ru': 'Создать подборку',
    },
  },
  // topratedproductspage
  {
    'bw4n521q': {
      'en': 'Highest Safety Ratings',
      'es': 'Calificaciones de seguridad más altas',
      'ru': 'Высочайший рейтинг безопасности',
    },
    'a09tawz3': {
      'en': 'Products with the best ingredient scores',
      'es': 'Productos con las mejores puntuaciones de ingredientes',
      'ru': 'Продукты с лучшими показателями качества ингредиентов',
    },
  },
  // emptyfavourite_new
  {
    'vstpx0tw': {
      'en': 'No favourites yet',
      'es': 'Aún no hay ningún favorito',
      'ru': 'Пока нет избранного',
    },
    'bea7pc3c': {
      'en': 'Scan a product',
      'es': 'Escanear un producto',
      'ru': 'Сканировать продукт',
    },
  },
  // albumslist
  {
    '2swgqgrb': {
      'en': 'Add to board',
      'es': 'Añadir al tablero',
      'ru': 'Добавить на доску',
    },
    'n2ylozbe': {
      'en': 'Apply',
      'es': 'Aplicar',
      'ru': 'Применить',
    },
  },
  // Makeprivate
  {
    'lfd7kbh4': {
      'en': 'Product hidden',
      'es': 'Producto oculto',
      'ru': 'Продукт скрыт',
    },
    'wpxs96fj': {
      'en':
          'Your product is currently hidden from other users.\nOnly you can see it.',
      'es':
          'Tu producto está oculto para otros usuarios en este momento.\nSolo tú puedes verlo.',
      'ru':
          'Ваш продукт сейчас скрыт от других пользователей.\nТолько вы можете его видеть.',
    },
    'k0o8li8u': {
      'en': 'Ok',
      'es': 'Vale!',
      'ru': 'Хорошо',
    },
  },
  // Makepubluc
  {
    '553khwzz': {
      'en': 'Product visible to other users',
      'es': 'Producto visible para otros usuarios',
      'ru': 'Продукт виден другим пользователям',
    },
    'g7bez9em': {
      'en': 'Other users can view your product.',
      'es': 'Otros usuarios pueden ver tu producto.',
      'ru': 'Другие пользователи могут просматривать ваш продукт.',
    },
    'dv0imp11': {
      'en': 'Ok',
      'es': 'Aceptar',
      'ru': 'Хорошо',
    },
  },
  // Hidenavailability
  {
    'bgtz3rm2': {
      'en': 'This feature is available only for PRO users.',
      'es': 'Esta función está disponible solo para usuarios PRO.',
      'ru': 'Эта функция доступна только для PRO-пользователей.',
    },
    '0bcivvmz': {
      'en': 'Upgrade to the PRO plan to hide your product from other users.',
      'es': 'Cambia al plan PRO para ocultar tu producto a otros usuarios.',
      'ru':
          'Перейдите на PRO-тариф, чтобы скрывать продукт от других пользователей.',
    },
    '02k9xvmr': {
      'en': 'Go PRO',
      'es': 'Pasar a PRO',
      'ru': 'Перейти на PRO',
    },
  },
  // markasspam
  {
    'tost89il': {
      'en': 'Mark as spam',
      'es': 'Marcar como spam',
      'ru': 'Отметить как спам',
    },
    '0whnywol': {
      'en': 'This product will be hidden from top ratings',
      'es': 'Este producto se ocultará de las clasificaciones principales',
      'ru': 'Этот продукт будет скрыт из топ-рейтинга',
    },
    'h4qorptg': {
      'en': 'Cancel',
      'es': 'Cancelar',
      'ru': 'Отмена',
    },
    '899uf23u': {
      'en': 'Hide',
      'es': 'Ocultar',
      'ru': 'Скрыть',
    },
  },
  // ShareCardSheet
  {
    'a1bpjvs8': {
      'en': 'Выберите формат карточки продукта для сохранения',
      'es': '',
      'ru': '',
    },
    'himmmtup': {
      'en': 'Сториз',
      'es': '',
      'ru': '',
    },
    'k2ruyzeg': {
      'en': 'Квадрат',
      'es': '',
      'ru': '',
    },
  },
  // Miscellaneous
  {
    'zkh3z8tp': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'ohwc49bu': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'hmrxa2qi': {
      'en':
          'In order to send you important reminders, this app requires permission to send notifications.',
      'es':
          'Para poder enviarte recordatorios importantes, esta aplicación requiere permiso para enviar notificaciones.',
      'ru':
          'Для отправки важных напоминаний этому приложению требуется разрешение на отправку уведомлений.',
    },
    'tymv0tkj': {
      'en': 'MiRRA сохраняет карточки продуктов в фотогалерею',
      'es': '',
      'ru': '',
    },
    '2uqazfud': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'w3n7104a': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'o46xe637': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'vby7356o': {
      'en': '',
      'es': '',
      'ru': '',
    },
    '3x5mazn9': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'krsty4il': {
      'en': '',
      'es': '',
      'ru': '',
    },
    '90810fqy': {
      'en': '',
      'es': '',
      'ru': '',
    },
    '5xdek5v0': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'ub2pnrcr': {
      'en': '',
      'es': '',
      'ru': '',
    },
    '446nmqfw': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'lvpepwip': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'yz9u5qgu': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'sgc51xow': {
      'en': '',
      'es': '',
      'ru': '',
    },
    '0rfgqu6r': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'nnsq0kj5': {
      'en': '',
      'es': '',
      'ru': '',
    },
    '48je50c9': {
      'en': '',
      'es': '',
      'ru': '',
    },
    't5l3cspz': {
      'en': '',
      'es': '',
      'ru': '',
    },
    '4eemae24': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'ty7a9smo': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'mubk0pfy': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'b652wlj0': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'pvpxd2wv': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'oocbcr3w': {
      'en': '',
      'es': '',
      'ru': '',
    },
    '3dfv6cmb': {
      'en': '',
      'es': '',
      'ru': '',
    },
    'pt749ga9': {
      'en': '',
      'es': '',
      'ru': '',
    },
  },
].reduce((a, b) => a..addAll(b));
