import 'package:fizmat_app/models/club_models.dart';

/// School clubs data provider
class ClubData {
  /// Get all clubs
  static List<Club> getAllClubs() {
    return [
      // ACADEMIC CLUBS
      Club(
        name: 'Матклуб',
        instagramHandle: '@mathclub248',
        leader: ClubLeader(
          firstName: 'Анвар',
          lastName: 'Камалеев',
          phone: '87081135790',
          classGrade: '10E',
        ),
        category: ClubCategory.academic,
      ),
      Club(
        name: 'Physics Horizon',
        instagramHandle: '@physics_horiz0n',
        leader: ClubLeader(
          firstName: 'Тимур',
          lastName: 'Мурат',
          phone: '87773750001',
          classGrade: '10C',
        ),
        category: ClubCategory.academic,
      ),
      Club(
        name: 'Astronomad',
        instagramHandle: '@astronomad.fizmat',
        leader: ClubLeader(
          firstName: 'Дінмұхаммед',
          lastName: 'Төрехан',
          phone: '87054761645',
          classGrade: '9B',
        ),
        category: ClubCategory.academic,
      ),
      Club(
        name: 'SAT Club',
        instagramHandle: '@satclub.nspm',
        leader: ClubLeader(
          firstName: 'Парасат',
          lastName: 'Тәңіберген',
          phone: '87780102765',
          classGrade: '11G',
        ),
        category: ClubCategory.academic,
      ),
      Club(
        name: 'Finance Club',
        instagramHandle: '@finance_club.fizmat',
        leader: ClubLeader(
          firstName: 'Азима',
          lastName: 'Бегалиева',
          phone: '87085702927',
          classGrade: '10H',
        ),
        category: ClubCategory.academic,
      ),

      // SPORTS & FITNESS
      Club(
        name: 'Fitness and Yoga Club',
        instagramHandle: '@fizmat_fitnessclub',
        leader: ClubLeader(
          firstName: 'Альбина',
          lastName: 'Саматова',
          phone: '87051623529',
          classGrade: '11G',
        ),
        category: ClubCategory.sports,
      ),
      Club(
        name: 'tennis club',
        instagramHandle: '@tennis_nspm',
        leader: ClubLeader(
          firstName: 'Влад',
          lastName: 'Ткаченко',
          phone: '87079354165',
          classGrade: '11E',
        ),
        category: ClubCategory.sports,
      ),
      Club(
        name: 'Fizmat Cycling Club',
        instagramHandle: '@fizmatcyclingclub',
        leader: ClubLeader(
          firstName: 'Әлібек',
          lastName: 'Қадырәлі',
          phone: '87714453460',
          classGrade: '11B',
        ),
        category: ClubCategory.sports,
      ),
      Club(
        name: 'Fizmat Armwrestling Club',
        instagramHandle: '@fizmat.arm',
        leader: ClubLeader(
          firstName: 'Искандер',
          lastName: 'Нурмагамбетов',
          phone: '87473553989',
          classGrade: '10F',
        ),
        category: ClubCategory.sports,
      ),
      Club(
        name: 'Fizmat Mountain Kings',
        instagramHandle: '@fizmat_mountain_kings_',
        leader: ClubLeader(
          firstName: 'Даулет',
          lastName: 'Асылханулы',
          phone: '87086903165',
          classGrade: '10G',
        ),
        category: ClubCategory.sports,
      ),
      Club(
        name: 'Jastar Club',
        description: 'Тренировки',
        instagramHandle: '@jastar_fizmat_club',
        leader: ClubLeader(
          firstName: 'Мирас',
          lastName: 'Жалғасбай',
          phone: '87771482010',
          classGrade: '10C',
        ),
        category: ClubCategory.sports,
      ),

      // ARTS & CULTURE
      Club(
        name: 'Dance Club',
        instagramHandle: '@danceclub.fizmat',
        leader: ClubLeader(
          firstName: 'Дарья',
          lastName: 'Заплавнова',
          phone: '87475257608',
          classGrade: '11K',
        ),
        category: ClubCategory.artsAndCulture,
      ),
      Club(
        name: 'Gemba',
        description: 'Ораторское искусство',
        instagramHandle: '@gemba.fizmat',
        leader: ClubLeader(
          firstName: 'Ажар',
          lastName: 'Әбілбай',
          phone: '87757907208',
          classGrade: '9H',
        ),
        category: ClubCategory.artsAndCulture,
      ),
      Club(
        name: 'Teddy Talks',
        instagramHandle: '@_teddytalks.nspm',
        leader: ClubLeader(
          firstName: 'Әкежан',
          lastName: 'Әліпбай',
          phone: '87784723242',
          classGrade: '9C',
        ),
        category: ClubCategory.artsAndCulture,
      ),
      Club(
        name: 'DIY Club',
        instagramHandle: '@diyclub_fizmat',
        leader: ClubLeader(
          firstName: 'Жадыра',
          lastName: 'Жарқын',
          phone: '87079044306',
          classGrade: '11G',
        ),
        category: ClubCategory.artsAndCulture,
      ),
      Club(
        name: 'Собиратели историй',
        instagramHandle: '@talekeepers',
        leader: ClubLeader(
          firstName: 'Биназир',
          lastName: 'Зиманова',
          phone: '87071091311',
          classGrade: '10K',
        ),
        category: ClubCategory.artsAndCulture,
      ),

      // TECHNOLOGY
      Club(
        name: 'CodeHub',
        instagramHandle: '@codehub.fizmatkz',
        leader: ClubLeader(
          firstName: 'Габиден',
          lastName: 'Амиржанов',
          phone: '87017449604',
          classGrade: '10H',
        ),
        category: ClubCategory.technology,
      ),
      Club(
        name: 'NERV',
        instagramHandle: '@nerv.ftc',
        leader: ClubLeader(
          firstName: 'Жангир',
          lastName: 'Ержанулы',
          phone: '87777000077',
          classGrade: '11K',
        ),
        category: ClubCategory.technology,
      ),
      Club(
        name: 'Aero Fizmat',
        instagramHandle: '@aero.fizmat',
        leader: ClubLeader(
          firstName: 'Райымбек',
          lastName: 'Адилбек',
          phone: '87002312008',
          classGrade: '11H',
        ),
        category: ClubCategory.technology,
      ),
      Club(
        name: 'International Young Researchers',
        instagramHandle: '@iyrc_club',
        leader: ClubLeader(
          firstName: 'Диас',
          lastName: 'Алишер',
          phone: '87071547509',
          classGrade: '10K',
        ),
        category: ClubCategory.technology,
      ),

      // SOCIAL & LEADERSHIP
      Club(
        name: 'Debate Club',
        instagramHandle: '@debate_club_fizmat',
        leader: ClubLeader(
          firstName: 'Айша',
          lastName: 'Женис',
          phone: '87477084126',
          classGrade: '10E',
        ),
        category: ClubCategory.social,
      ),
      Club(
        name: 'RSPM MUN Club',
        instagramHandle: '@rspm.mun',
        leader: ClubLeader(
          firstName: 'Амир',
          lastName: 'Ыбырай',
          phone: '87771218960',
          classGrade: '10D',
        ),
        category: ClubCategory.social,
      ),
      Club(
        name: 'Исторический клуб',
        instagramHandle: '@historyclub_nspm',
        leader: ClubLeader(
          firstName: 'Арлан',
          lastName: 'Аканаев',
          phone: '87777222268',
          classGrade: '10E',
        ),
        category: ClubCategory.social,
      ),
      Club(
        name: 'We united',
        instagramHandle: '@weunited.fizmat',
        leader: ClubLeader(
          firstName: 'Зере',
          lastName: 'Айтбай',
          phone: '87075995013',
          classGrade: '10C',
        ),
        category: ClubCategory.social,
      ),
      Club(
        name: 'Волонтерский клуб',
        instagramHandle: '@rspm.volunteering',
        leader: ClubLeader(
          firstName: 'Алем',
          lastName: 'Магзум',
          phone: '87010165544',
          classGrade: '10G',
        ),
        category: ClubCategory.social,
      ),

      // HOBBIES & GAMES
      Club(
        name: 'Fizmat Chess Club',
        instagramHandle: '@64_square_fizmat',
        leader: ClubLeader(
          firstName: 'Әкімжан',
          lastName: 'Әбдімәлік',
          phone: '87057732135',
          classGrade: '10A',
        ),
        category: ClubCategory.hobbies,
      ),
      Club(
        name: 'Fizmat SpeedCubing Club',
        instagramHandle: '@fizmat_cubers',
        leader: ClubLeader(
          firstName: 'Нұрислам',
          lastName: 'Дүйсенғали',
          phone: '87474618594',
          classGrade: '10C',
        ),
        category: ClubCategory.hobbies,
      ),
      Club(
        name: 'Клуб настольных игр',
        instagramHandle: '@board_games_club_fizmat',
        leader: ClubLeader(
          firstName: 'Жангир',
          lastName: 'Корганбаев',
          phone: '87086368148',
          classGrade: '9E',
        ),
        category: ClubCategory.hobbies,
      ),
      Club(
        name: 'Baking Club',
        instagramHandle: '@fizmat.baking_club',
        leader: ClubLeader(
          firstName: 'Аянат',
          lastName: 'Доспалинова',
          phone: '87058786355',
          classGrade: '9F',
        ),
        category: ClubCategory.hobbies,
      ),

      // LANGUAGES
      Club(
        name: 'Guten Morgen',
        instagramHandle: '@mg.fizmat.club',
        leader: ClubLeader(
          firstName: 'София',
          lastName: 'Альмукамбетова',
          phone: '87775896781',
          classGrade: '9F',
        ),
        category: ClubCategory.language,
      ),
      Club(
        name: 'China Talks',
        instagramHandle: '@chinatalks_fizmatclub',
        leader: ClubLeader(
          firstName: 'Айсулу',
          lastName: 'Мырзабаева',
          phone: '87751500096',
          classGrade: '11E',
        ),
        category: ClubCategory.language,
      ),
    ];
  }

  /// Get clubs by category
  static List<Club> getClubsByCategory(ClubCategory category) {
    return getAllClubs().where((club) => club.category == category).toList();
  }

  /// Get all categories with clubs
  static Map<ClubCategory, List<Club>> getClubsByCategories() {
    final Map<ClubCategory, List<Club>> categorized = {};
    for (final category in ClubCategory.values) {
      final clubs = getClubsByCategory(category);
      if (clubs.isNotEmpty) {
        categorized[category] = clubs;
      }
    }
    return categorized;
  }

  /// Search clubs by name or leader name
  static List<Club> searchClubs(String query) {
    if (query.isEmpty) return getAllClubs();

    final lowerQuery = query.toLowerCase();
    return getAllClubs().where((club) {
      final clubName = club.name.toLowerCase();
      final leaderName = club.leader.fullName.toLowerCase();
      return clubName.contains(lowerQuery) || leaderName.contains(lowerQuery);
    }).toList();
  }
}
