import 'package:flutter_test/flutter_test.dart';

import 'package:kylora/data/models/xtream_series_info_dto.dart';

void main() {
  test('parsea get_series_info con temporadas y episodios (bloque episodes)', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'info': <String, dynamic>{
        'name': 'House of Cards',
        'plot': 'Politdrama sobre el poder.',
        'genre': <String>['Drama', 'Thriller'],
        'rating': 8,
        'releaseDate': '2013-02-01',
      },
      'seasons': <dynamic>[
        // Solo metadatos; los episodios van en `episodes`.
        <String, dynamic>{
          'id': 3768,
          'name': 'Season 1',
          'season_number': 1,
          'episode_count': 2,
        },
      ],
      'episodes': <String, dynamic>{
        '1': <dynamic>[
          <String, dynamic>{
            'id': 557658,
            'episode_num': 1,
            'title': 'S01E01',
            'container_extension': 'mp4',
            'season': 1,
            'info': <String, dynamic>{
              'movie_image': 'http://x/img1.jpg',
              'plot': 'Sinopsis del capítulo 1',
              'releasedate': '2013-02-01',
              'duration': '00:57:00',
              'season': '01',
            },
          },
          <String, dynamic>{
            'id': 557659,
            'episode_num': 2,
            'title': 'S01E02',
            'container_extension': 'mp4',
            'season': 1,
            'info': <String, dynamic>{
              'movie_image': 'http://x/img2.jpg',
              'plot': 'Sinopsis del capítulo 2',
            },
          },
        ],
        '2': <dynamic>[
          <String, dynamic>{
            'id': 557671,
            'episode_num': 1,
            'title': 'S02E01',
            'container_extension': 'mp4',
          },
        ],
      },
    };

    final XtreamSeriesInfoDto dto = XtreamSeriesInfoDto.fromJson(json);

    expect(dto.seasons, hasLength(2));
    expect(dto.genre, 'Drama, Thriller');
    expect(dto.rating, '8');

    final t1 = dto.seasons.firstWhere((s) => s.number == 1);
    expect(t1.episodes, hasLength(2));
    final ep1 = t1.episodes.first;
    expect(ep1.name, 'S01E01');
    expect(ep1.episodeNumber, 1);
    expect(ep1.containerExtension, 'mp4');
    expect(ep1.cover, 'http://x/img1.jpg');
    expect(ep1.duration, '00:57:00');
    expect(ep1.plot, 'Sinopsis del capítulo 1');
    expect(ep1.releaseDate, '2013-02-01');
    expect(ep1.seasonNumber, 1);
  });
}
