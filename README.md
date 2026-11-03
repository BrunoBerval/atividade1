# 📍 Localizações

![Flutter](https://img.shields.io/badge/Flutter-aplicativo-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-%5E3.13.5-0175C2?logo=dart)
![Plataforma](https://img.shields.io/badge/plataforma-Android-3DDC84?logo=android&logoColor=white)
![Mapa](https://img.shields.io/badge/mapa-OpenStreetMap-7EBC6F?logo=openstreetmap&logoColor=white)

Aplicativo Flutter para coletar, armazenar e consultar localizações do aparelho. Os registros são salvos localmente em SQLite e podem ser visualizados em uma lista ou em um mapa com tiles do OpenStreetMap.

## 👥 Autores

> **Bruno Berval Moreira de Godoi**  
> **________________________________________**

## ✨ Recursos

- 📡 Coleta de posição usando GPS e alta precisão.
- ⏱️ Atualizações configuradas em intervalos de 20 segundos no Android.
- 🔔 Notificação persistente durante a coleta em primeiro plano.
- 💾 Gravação local da latitude, longitude, precisão e instante da leitura em UTC.
- 🕘 Histórico das 100 localizações mais recentes, com atualização por gesto.
- 🧹 Opção para apagar o histórico, com confirmação.
- 🗺️ Mapa interativo com marcadores, enquadramento dos registros e detalhes ao tocar em um ponto.
- 📦 Cache de tiles do mapa no armazenamento privado do aplicativo.
- 🌑 Interface escura com destaque verde.

## 🧰 Tecnologias

| Tecnologia | Uso |
| --- | --- |
| Flutter e Dart | Interface e lógica do aplicativo |
| `geolocator` | Serviço de localização e stream de posições |
| `permission_handler` | Solicitação de permissão de notificações no Android |
| `sqflite` | Banco de dados local |
| `flutter_map` e `latlong2` | Mapa, tiles e coordenadas geográficas |
| OpenStreetMap | Mapa base e dados cartográficos |
| `path_provider` e `path` | Caminhos do banco e do cache privado |
| `intl` | Formatação de data e hora no histórico |
| `url_launcher` | Abertura do link de atribuição do OpenStreetMap |

## 🚀 Começar

### Requisitos

- Flutter instalado e configurado no `PATH`.
- Android SDK e ferramentas de build disponíveis para compilar o APK.
- Aparelho Android ou emulador com serviços de localização para testar a coleta.

### Preparar e executar

Na pasta raiz do projeto:

```bash
flutter pub get
flutter run
```

Para verificar o código antes de executar:

```bash
dart format lib
flutter analyze
```

Ao iniciar a coleta pela primeira vez, permita o acesso à localização e, no Android 13 ou superior, às notificações. Para testar no emulador, defina uma localização simulada nos controles do emulador.

### Gerar APK

Para gerar a versão de release:

```bash
flutter build apk --release
```

O arquivo será criado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Para um APK de depuração, use `flutter build apk --debug`.

## 📱 Permissões Android

O manifesto declara as permissões necessárias para internet, localização e serviço em primeiro plano:

- `INTERNET` — carregar os tiles do mapa.
- `ACCESS_COARSE_LOCATION` e `ACCESS_FINE_LOCATION` — obter a localização aproximada ou precisa.
- `FOREGROUND_SERVICE` e `FOREGROUND_SERVICE_LOCATION` — manter a coleta ativa com uma notificação visível.
- `POST_NOTIFICATIONS` — exibir a notificação em versões Android que exigem essa permissão.

As permissões de localização e notificação também precisam ser concedidas pelo usuário durante a execução do aplicativo.

## 🗂️ Organização do código

```text
lib/
├── app.dart
├── main.dart
├── tema_app.dart
└── features/localizacoes/
    ├── data/
    │   ├── database/       # Abertura e criação do banco SQLite
    │   └── repositories/   # Consultas e gravações de localizações
    ├── models/             # Modelo Localizacao e conversão para SQLite
    ├── services/           # Coleta GPS e preparação do cache do mapa
    └── presentation/
        ├── screens/        # Coleta, histórico e mapa
        └── widgets/        # Item de histórico e mapa com marcadores
```

O banco `localizacoes.db` é criado no armazenamento privado do aplicativo. Cada registro guarda latitude, longitude, precisão em metros e instante UTC. O histórico exibe os registros mais recentes primeiro; o limite da consulta não apaga registros antigos.

Os ícones usados pelo aplicativo ficam em `assets/icons/` e nos recursos Android em `android/app/src/main/res/`.

## 🗺️ Atribuição cartográfica

Os tiles são carregados de `tile.openstreetmap.org`. O mapa exibe a atribuição **© OpenStreetMap contributors**, com link para as informações de copyright. O aplicativo envia seu identificador Android (`com.example.atividade1`) como nome de pacote do cliente de tiles.

## 📄 Licença

Este repositório não declara uma licença de distribuição. Os dados cartográficos do OpenStreetMap são disponibilizados sob a licença ODbL; consulte a [página de copyright do OpenStreetMap](https://www.openstreetmap.org/copyright).
