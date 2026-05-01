class Media {
  final int id;
  final String? title;
  final String? name;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final String? firstAirDate;
  final double voteAverage;
  final String mediaType;

  Media({
    required this.id,
    this.title,
    this.name,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.firstAirDate,
    required this.voteAverage,
    required this.mediaType,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? 0,
      title: json['title'],
      name: json['name'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'],
      releaseDate: json['release_date'],
      firstAirDate: json['first_air_date'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      mediaType: json['media_type'] ?? (json['title'] != null ? 'movie' : 'tv'),
    );
  }

  String get displayName => title ?? name ?? 'Unknown';
  String get displayDate => releaseDate ?? firstAirDate ?? '';
  String get posterUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
  String get backdropUrl => 'https://image.tmdb.org/t/p/original$backdropPath';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'release_date': releaseDate,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'media_type': mediaType,
    };
  }
}
