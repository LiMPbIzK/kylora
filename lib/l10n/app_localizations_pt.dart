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
  String get addAccount => 'Adicionar conta';

  @override
  String get addAccountFromPhone => 'Adicionar pelo telemóvel';

  @override
  String get webImportInstructions =>
      'Leia o QR com um telemóvel ligado ao mesmo Wi-Fi. Também pode abrir o endereço no navegador.';

  @override
  String get webImportStarting => 'A iniciar o servidor local…';

  @override
  String get webImportError =>
      'Não foi possível iniciar o servidor local. Verifique se a TV e o telemóvel estão no mesmo Wi-Fi.';

  @override
  String get webImportLocalOnly =>
      'Apenas rede local: sem Internet nem HTTPS. O host, utilizador e palavra-passe não podem ser alterados pela web; apenas a etiqueta ou apagar a conta.';

  @override
  String get playFromStart => 'Reproduzir desde o início';

  @override
  String get catchupUnavailable =>
      'Este programa não está disponível em catch-up.';

  @override
  String get selectAccount => 'Selecionar conta';

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
  String get radio => 'Rádio';

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
  String get manageCategories => 'Gerir categorias';

  @override
  String get multiChannelGuide => 'Guia multi-canal';

  @override
  String get save => 'Guardar';

  @override
  String get saveError => 'Não foi possível guardar as alterações';

  @override
  String get moveUp => 'Mover para cima';

  @override
  String get moveDown => 'Mover para baixo';

  @override
  String get manageAccounts => 'Gerir contas';

  @override
  String get accountManagerDescription =>
      'Gerir as suas contas sem uma sessão ativa.';

  @override
  String get noSavedAccounts => 'Não há contas guardadas.';

  @override
  String get accountNotValidated => 'Não validada';

  @override
  String get accountEdit => 'Editar conta';

  @override
  String get accountDelete => 'Eliminar conta';

  @override
  String get deleteAccountConfirm => 'Eliminar esta conta?';

  @override
  String get loginErrorAccountExpired => 'A conta está caducada ou inativa.';

  @override
  String get accountLabel => 'Etiqueta';

  @override
  String get passwordKeepHint => 'Deixe em branco para manter a atual';

  @override
  String get accountSavePendingHint =>
      'A conta é guardada sem validação. Poderá tentar entrar a partir da lista.';

  @override
  String get loginWithPhone => 'Entrar com o telemóvel';

  @override
  String get remoteLoginTitle => 'Entrar com o telemóvel';

  @override
  String get remoteLoginInstructions =>
      'Digitalize o QR com um telemóvel na mesma Wi-Fi. Aí pode usar uma conta guardada ou adicionar/editar os dados.';

  @override
  String get pinProtectAccounts => 'Proteger gestão de contas';

  @override
  String get pinDescription =>
      'Será pedido um PIN para gerir contas sem sessão.';

  @override
  String get pinSetTitle => 'Configurar PIN';

  @override
  String get pinSet => 'PIN ativado';

  @override
  String get pinRemoved => 'PIN desativado';

  @override
  String get pinEnter => 'Introduza o PIN';

  @override
  String get pinWrong => 'PIN incorreto';

  @override
  String get pinTooShort => 'O PIN deve ter entre 4 e 8 dígitos';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get cleanExpiredAccounts => 'Limpar caducadas';

  @override
  String get cleanExpiredConfirm =>
      'Eliminar as contas caducadas que não estão ativas?';

  @override
  String get expiredAccountsRemoved => 'Contas caducadas eliminadas';

  @override
  String get settings => 'Ajustes';

  @override
  String get clock => 'Relógio';

  @override
  String get clockFormat24h => '24 horas';

  @override
  String get clockFormat12h => '12 horas';

  @override
  String endsAt(String time) {
    return 'Termina às $time';
  }

  @override
  String get viewDetails => 'Ver detalhes';

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
  String get themePacotis => 'Pacotis';

  @override
  String get themeCanvas => 'Canvas';

  @override
  String get pinCode => 'Código PIN';

  @override
  String get settingsSectionSupport => 'Suporte';

  @override
  String get donation => 'Doar via PayPal';

  @override
  String get donationDescription =>
      'Ajude no desenvolvimento do Kylora com uma doação voluntária.';

  @override
  String get donationOpenError => 'Não foi possível abrir o link de doação';

  @override
  String get contact => 'Contatar por e-mail';

  @override
  String get contactDescription =>
      'Envie uma mensagem para contact@fmartinezgarcia.com.';

  @override
  String get contactOpenError => 'Não foi possível abrir o cliente de e-mail';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get epgNoProgram => 'Sem informações de programação';

  @override
  String get epgLoadError => 'Não foi possível carregar o guia de programação';

  @override
  String get epgGuide => 'Guia de programação';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Seguinte';

  @override
  String get today => 'Hoje';

  @override
  String get reminderSet => 'Lembrete ativado';

  @override
  String get reminderRemoved => 'Lembrete removido';

  @override
  String get reminderDueTitle => 'Lembrete';

  @override
  String get watchNow => 'Ver agora';

  @override
  String get nowEpg => 'Agora';

  @override
  String get nextEpg => 'Próximo';

  @override
  String get close => 'Fechar';

  @override
  String get exitAppTitle => 'Sair do Kylora?';

  @override
  String get exitAppConfirm => 'Tem certeza de que deseja sair do Kylora?';

  @override
  String get exitApp => 'Sair';

  @override
  String get searchPlaceholder => 'Buscar canais, filmes...';

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get recentlyAdded => 'Adicionado recentemente';

  @override
  String get continueWatchingSection => 'Continuar a assistir';

  @override
  String get removeResumeTitle => 'Remover visualização';

  @override
  String get removeResumeConfirm =>
      'Deseja remover esta visualização recente? Você não poderá retomá-la daqui.';

  @override
  String get removeResumeConfirmButton => 'Remover';

  @override
  String get audioTrack => 'Faixa de áudio';

  @override
  String get settingsSectionPlayback => 'Reprodução';

  @override
  String get audioLanguage => 'Idioma do áudio';

  @override
  String get audioLanguageAuto => 'Idioma da aplicação';

  @override
  String get subtitlesOff => 'Desativadas';

  @override
  String get subtitlesAutomatic => 'Automáticas (idioma da app)';

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
  String get searchLoadError =>
      'Não foi possível carregar a busca. Verifique a ligação.';

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
  String get favoriteGroups => 'Grupos favoritos';

  @override
  String get addGroupToFavorites => 'Adicionar grupo aos favoritos';

  @override
  String get removeGroupFromFavorites => 'Remover grupo dos favoritos';

  @override
  String get groupFavoriteAdded => 'Grupo adicionado aos favoritos';

  @override
  String get groupFavoriteRemoved => 'Grupo removido dos favoritos';

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
