# Kylora

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Plataformas](https://img.shields.io/badge/Plataformas-Android%20%7C%20Android%20TV%20%7C%20Windows-blue)](https://github.com)
[![Linux](https://img.shields.io/badge/Linux-Em%20breve-lightgrey?logo=linux&logoColor=white)](https://github.com)
[![macOS](https://img.shields.io/badge/macOS-Em%20breve-lightgrey?logo=apple&logoColor=white)](https://github.com)
[![Motor](https://img.shields.io/badge/Motor%20de%20v%C3%ADdeo-media__kit%20(libmpv)-E040FB)](https://github.com/media-kit/media-kit)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen)](https://github.com)
[![Licença](https://img.shields.io/badge/Licen%C3%A7a-MIT-green.svg)](LICENSE)

> 🌐 [Español](README.md) · [English](README.en.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · **Português**

**Kylora** é um cliente IPTV local-first para Android móvel, Android TV/Google TV, Fire TV e Windows. Foi concebido para zapping rápido, navegação confortável com telecomando e reprodução fluida em HD, FHD e 4K, sem backend próprio, telemetria ou serviços na nuvem.

## Funcionalidades

- **Fontes Xtream Codes e M3U/XMLTV** com o mesmo contrato de repositório.
- **Android TV como alvo principal:** navegação D-Pad completa, Leanback, menus contextuais, desfile de títulos e guia TV utilizável com telecomando.
- **Reprodução 4K/UHD:** `media_kit`/libmpv com `mediacodec_embed` e `hwdec=mediacodec` no Android; faixas de áudio/legendas, seleção de faixa e OSD personalizado.
- **Multi-conta:** contas cifradas, mudança de conta ativa, configuração manual e adição a partir do telemóvel por QR.
- **Início de sessão pelo telemóvel:** o ecrã de login mostra um QR para entrar com uma conta guardada ou adicionar/editar credenciais na mesma Wi-Fi.
- **Gestão de contas sem sessão:** mesmo que todas as contas estejam caducadas, é possível editá-las, adicionar, remover, limpar e tentar novamente no gestor pré-login.
- **PIN opcional** para proteger a gestão de contas e o acesso remoto.
- **Categorias visíveis e ordenadas por conta**, com grupos de favoritos por categoria.
- **Secções TV, Filmes, Séries e Rádio separadas**, com pesquisa global e continuar a ver.
- **EPG:** agora/seguinte, grelha diária, guia multi-canal (até 30 canais por vista) e lembretes na aplicação.
- **Catch-up/timeshift** em canais Xtream compatíveis.
- **Cache VOD/séries por conta**. Catálogos grandes são mostrados assim que a API responde e a cache é completada em segundo plano.
- **100% local:** credenciais em `flutter_secure_storage` e catálogo em SQLite/Drift. Sem servidor próprio e sem telemetria.
- **Seis idiomas:** espanhol, inglês, francês, alemão, italiano e português, alteráveis a quente nas Definições.
- **Quatro temas:** Nocturne, Expressive, Pacotis e Canvas.

## Arquitetura

Clean Architecture em três camadas:

```text
presentation  →  ecrãs, blocs e widgets partilhados
domain        →  entidades e contratos de repositório
data          →  datasources remotos/locais, DTOs e repositórios
```

- Gestão de estado com `flutter_bloc`.
- Persistência com `drift`/SQLite e segredos com `flutter_secure_storage`.
- Repositório independente da fonte: Xtream e M3U implementam `IptvRepository`.
- Análise pesada de listas e XMLTV em isolates.

## Estrutura

```text
lib/
├── app.dart                 # MaterialApp.router, i18n e temas
├── main.dart                # Inicialização da aplicação
├── core/                    # Utilitários, tema, reprodução e lembretes
├── data/                    # Datasources, DTOs e repositórios
├── domain/                  # Entidades e contratos
├── l10n/                    # Traduções ARB
└── presentation/            # Ecrãs, blocs e widgets
```

## Primeiros passos

### Requisitos

- Flutter 3.x stable com Dart 3.x.
- **Windows:** Visual Studio 2022 com *Desktop development with C++*.
- **Android/TV:** Android SDK; `minSdk 23`, `compileSdk 37`.
- Linux/macOS está previsto para depois da v1.0.0.

### Compilação

```bash
# Windows
flutter build windows

# Android móvel
flutter build apk --release

# Android TV / Fire TV
flutter build apk --release --target-platform android-arm64
```

No Windows também está disponível o script de instalação para TV:

```powershell
.\scripts\build-install-tv-release.bat 192.168.0.42
```

### Execução

```bash
flutter run -d windows
flutter run -d <id-do-dispositivo-android>
```

## Configuração

1. **Xtream Codes:** URL do servidor, utilizador e palavra-passe.
2. **M3U/M3U8:** URL ou ficheiro local e, opcionalmente, XMLTV.

As contas são cifradas e isoladas por impressão digital da conta (favoritos, histórico, categorias e cache). A importação pelo telemóvel usa um servidor HTTP local temporário e um token de sessão; só funciona na mesma Wi-Fi. O QR nunca contém credenciais.

Para contas caducadas ou fornecedores indisponíveis:

1. Abrir **Gerir contas** a partir do login.
2. Editar as credenciais ou adicionar uma conta.
3. Guardar sem validar e tentar novamente quando o fornecedor responder.

## Internacionalização

A aplicação e a documentação estão disponíveis em:

| Idioma | README |
| :--- | :--- |
| Español | [README.md](README.md) |
| English | [README.en.md](README.en.md) |
| Français | [README.fr.md](README.fr.md) |
| Deutsch | [README.de.md](README.de.md) |
| Italiano | [README.it.md](README.it.md) |
| Português | [README.pt.md](README.pt.md) |

O idioma da aplicação pode ser fixado nas Definições ou deixado em automático conforme o sistema.

## Roteiro

- [x] **M0–M8:** fundação, Xtream, catálogo, leitor, VOD/séries, EPG, favoritos, M3U e Android TV.
- [x] **M9:** definições, temas, interface multilingue, multi-conta, importação web, catch-up, pesquisa global e v1.0.0 funcional.
- [x] **Post-M9:** categorias por conta, EPG multi-canal, rádio dedicada, login remoto por QR, gestão de contas sem sessão, PIN opcional e cache VOD/séries em segundo plano.
- [ ] **Assinatura de release real** e remoção definitiva das credenciais de desenvolvimento do histórico público.
- [ ] **Notificações EPG do sistema** com a aplicação fechada.
- [ ] **Guia multi-canal completa:** mais de 30 canais, paginação e seleção de categoria.
- [ ] **M10:** builds Linux (.deb/.AppImage) e macOS (.dmg), notarização e CI por sistema.

## Desenvolvimento

```bash
flutter analyze
flutter test
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Os commits seguem [Conventional Commits](https://www.conventionalcommits.org). A CI executa análise e testes em cada push.

## Aviso legal

Kylora é apenas um cliente multimédia. Não fornece, aloja nem distribui conteúdos, listas ou subscrições. O utilizador é responsável por usar conteúdos a que tenha direito e por cumprir a lei e as condições do seu fornecedor. Kylora não suporta conteúdos protegidos por DRM.

## Licença

Distribuído sob a [Licença MIT](LICENSE).
