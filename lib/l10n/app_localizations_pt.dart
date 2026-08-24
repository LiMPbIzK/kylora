// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Kylora';

  @override
  String get loginTitle => 'Conectar ao IPTV';

  @override
  String get serverUrl => 'URL do servidor';

  @override
  String get username => 'Usuário';

  @override
  String get password => 'Senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginErrorInvalidCredentials => 'URL ou credenciais inválidas';

  @override
  String get loginErrorNetwork =>
      'Não foi possível conectar ao servidor. Verifique a URL e sua conexão.';

  @override
  String get loginErrorUnknown => 'Erro inesperado. Tente novamente.';

  @override
  String get loginSourceXtream => 'Xtream';

  @override
  String get loginSourceM3u => 'M3U/XMLTV';

  @override
  String get m3uDisplayName => 'Nome (opcional)';

  @override
  String get m3uPlaylistUrl => 'URL da lista M3U';

  @override
  String get m3uXmltvUrl => 'URL do EPG XMLTV (opcional)';

  @override
  String get loginErrorM3uParse =>
      'Não foi possível ler a lista M3U. Verifique a URL.';

  @override
  String get validationRequired => 'Este campo é obrigatório';

  @override
  String get validationInvalidUrl =>
      'Digite uma URL válida (ex. http://servidor:8080)';

  @override
  String get signOut => 'Sair';

  @override
  String get changeAccount => 'Trocar de conta';

  @override
  String get fullscreen => 'Tela cheia';

  @override
  String get exitFullscreen => 'Sair da tela cheia';

  @override
  String get accountStatus => 'Status da conta';

  @override
  String get accountActive => 'Ativa';

  @override
  String get accountExpired => 'Expirada';

  @override
  String accountExpiresOn(String date) {
    return 'Expira em $date';
  }

  @override
  String accountConnections(String active, String max) {
    return 'Conexões: $active/$max';
  }

  @override
  String get liveTv => 'TV ao Vivo';

  @override
  String get allCategories => 'Todas';

  @override
  String get addedToFavorites => 'Adicionado aos favoritos';

  @override
  String get removedFromFavorites => 'Removido dos favoritos';

  @override
  String get noChannels => 'Nenhum canal nesta categoria';

  @override
  String get liveLoadError =>
      'Não foi possível carregar o catálogo ao vivo. Verifique sua conexão e tente novamente.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get movies => 'Filmes';

  @override
  String get series => 'Séries';

  @override
  String get favorites => 'Favoritos';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsSectionAccount => 'Conta';

  @override
  String get settingsSectionCatalog => 'Catálogo';

  @override
  String get settingsSectionAppearance => 'Aparência';

  @override
  String get settingsSectionSecurity => 'Segurança';

  @override
  String get accountSource => 'Origem';

  @override
  String get accountExpiration => 'Expiração';

  @override
  String get accountConnectionsLabel => 'Conexões';

  @override
  String get accountXmltvPresent => 'Configurada';

  @override
  String get accountXmltvMissing => 'Não configurada';

  @override
  String get refreshCatalog => 'Atualizar catálogo';

  @override
  String get refreshCatalogDescription =>
      'Recarrega canais, filmes e séries do provedor.';

  @override
  String get refreshCatalogSuccess => 'Catálogo atualizado com sucesso';

  @override
  String get refreshCatalogFailure =>
      'Não foi possível atualizar o catálogo. Verifique sua conexão.';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get clearCacheConfirm =>
      'O cache local (canais salvos) será excluído. Eles serão baixados novamente na próxima vez.';

  @override
  String get clearCacheSuccess => 'Cache limpo';

  @override
  String get localeSystem => 'Idioma do sistema';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get themeNocturne => 'Nocturne';

  @override
  String get themeExpressive => 'Expressive';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeCanvas => 'Canvas';

  @override
  String get pinCode => 'Código PIN';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get epgNoProgram => 'Sem informações de programação';

  @override
  String get epgLoadError => 'Não foi possível carregar o guia de programação';

  @override
  String get epgGuide => 'Guia de programação';

  @override
  String get nowEpg => 'Agora';

  @override
  String get nextEpg => 'Próximo';

  @override
  String get close => 'Fechar';

  @override
  String get searchPlaceholder => 'Buscar canais, filmes...';

  @override
  String get audioTrack => 'Faixa de áudio';

  @override
  String get subtitles => 'Legendas';

  @override
  String get streamError => 'Erro de reprodução. Tentando novamente...';

  @override
  String get nowPlaying => 'Reproduzindo';

  @override
  String get play => 'Reproduzir';

  @override
  String get pause => 'Pausar';

  @override
  String get vodLoadError =>
      'Não foi possível carregar o catálogo de filmes. Verifique sua conexão e tente novamente.';

  @override
  String get noMovies => 'Nenhum filme nesta categoria';

  @override
  String get searchNoResults => 'Nenhum resultado para sua busca';

  @override
  String get rating => 'Avaliação';

  @override
  String get seriesLoadError =>
      'Não foi possível carregar o catálogo de séries. Verifique sua conexão e tente novamente.';

  @override
  String get noSeries => 'Nenhuma série nesta categoria';

  @override
  String get seriesDetailLoadError =>
      'Não foi possível carregar os episódios da série. Verifique sua conexão e tente novamente.';

  @override
  String get season => 'Temporada';

  @override
  String get language => 'Idioma';

  @override
  String get history => 'Histórico';

  @override
  String get noFavorites => 'Você ainda não tem favoritos';

  @override
  String get favoritesLoadError => 'Não foi possível carregar os favoritos';

  @override
  String get noHistory => 'Nenhum histórico de reprodução';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get clearHistoryConfirm =>
      'Tem certeza de que deseja apagar todo o histórico? Esta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get historyLoadError => 'Não foi possível carregar o histórico';

  @override
  String get justNow => 'Agora mesmo';

  @override
  String minutesAgo(int minutes) {
    return 'Há $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Há $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'Há $days dias';
  }
}
