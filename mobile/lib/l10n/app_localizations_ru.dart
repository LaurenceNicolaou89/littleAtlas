// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Маленький Атлас';

  @override
  String get explore => 'Обзор';

  @override
  String get search => 'Поиск';

  @override
  String get events => 'События';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get nearbyPlaces => 'Места поблизости';

  @override
  String get upcomingEvents => 'Ближайшие события';

  @override
  String get noResults => 'Ничего не найдено';

  @override
  String get loading => 'Загрузка...';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get filters => 'Фильтры';

  @override
  String get category => 'Категория';

  @override
  String get indoor => 'В помещении';

  @override
  String get outdoor => 'На улице';

  @override
  String get ageRange => 'Возраст';

  @override
  String get distance => 'Расстояние';

  @override
  String get weatherOutdoor => 'Отличный день для прогулки!';

  @override
  String get weatherIndoor => 'Лучше остаться в помещении';

  @override
  String get weatherCaution => 'Будьте осторожны на улице';

  @override
  String get allCategories => 'Все категории';

  @override
  String get viewOnMap => 'Показать на карте';

  @override
  String get directions => 'Маршрут';

  @override
  String get call => 'Позвонить';

  @override
  String get website => 'Сайт';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get dataSources => 'Источники данных';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get dataSourcesDescription =>
      'Приложение использует данные из следующих источников:';

  @override
  String get openStreetMap => 'OpenStreetMap';

  @override
  String get googlePlaces => 'Google Places';

  @override
  String get openWeatherMap => 'OpenWeatherMap';

  @override
  String get communityContributions => 'Вклад сообщества';

  @override
  String get close => 'Закрыть';

  @override
  String get getDirections => 'Построить маршрут';

  @override
  String get amenities => 'Удобства';

  @override
  String get details => 'Подробности';

  @override
  String get openNow => 'Открыто сейчас';

  @override
  String get closed => 'Закрыто';

  @override
  String get noUpcomingEvents => 'Нет предстоящих событий поблизости.';

  @override
  String get thisWeek => 'На этой неделе';

  @override
  String get thisMonth => 'В этом месяце';

  @override
  String get all => 'Все';

  @override
  String get happeningNow => 'Происходит сейчас';

  @override
  String get today => 'СЕГОДНЯ';

  @override
  String get tomorrow => 'ЗАВТРА';

  @override
  String get viewSource => 'Посмотреть источник';

  @override
  String get event => 'Событие';

  @override
  String get pullUpForNearby => 'Потяните вверх для мест поблизости';

  @override
  String get noPlacesNearby => 'Нет мест поблизости';

  @override
  String get searchPlaces => 'Поиск мест...';

  @override
  String get addFilter => 'Добавить фильтр';

  @override
  String get clearAll => 'Очистить все';

  @override
  String placesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'мест',
      few: 'места',
      one: 'место',
    );
    return '$count $_temp0 найдено';
  }

  @override
  String get noPlacesFound => 'Места не найдены';

  @override
  String get tryAdjustingFilters => 'Попробуйте изменить фильтры.';

  @override
  String get reset => 'Сброс';

  @override
  String get apply => 'Применить';

  @override
  String get ageGroup => 'Возрастная Группа';

  @override
  String get type => 'Тип';

  @override
  String get both => 'Оба';

  @override
  String get categoryPlaygrounds => 'Детские Площадки';

  @override
  String get categoryParks => 'Парки и Природа';

  @override
  String get categoryRestaurants => 'Рестораны';

  @override
  String get categoryEntertainment => 'Развлечения';

  @override
  String get categoryCulture => 'Культура и Образование';

  @override
  String get categorySports => 'Спорт и Активности';

  @override
  String get categoryShopping => 'Покупки';

  @override
  String get categoryBeaches => 'Пляжи';

  @override
  String get ageInfant => 'Младенец (0-1)';

  @override
  String get ageToddler => 'Малыш (1-3)';

  @override
  String get agePreschool => 'Дошкольник (3-5)';

  @override
  String get ageSchoolAge => 'Школьник (6-12)';

  @override
  String get amenityChangingTable => 'Пеленальный столик';

  @override
  String get amenityHighChair => 'Детский стульчик';

  @override
  String get amenityKidsMenu => 'Детское меню';

  @override
  String get amenityStrollerAccess => 'Доступ для колясок';

  @override
  String get amenityFencedArea => 'Огороженная зона';

  @override
  String get amenityParking => 'Парковка';

  @override
  String get amenityWheelchairAccess => 'Доступ для инвалидных колясок';

  @override
  String get amenityToilets => 'Туалеты';

  @override
  String get amenityNursingRoom => 'Комната для кормления';

  @override
  String get amenityShade => 'Тень';

  @override
  String get amenityWaterFountain => 'Питьевой фонтанчик';

  @override
  String get amenityWifi => 'WiFi';
}
