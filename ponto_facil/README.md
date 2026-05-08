# Ponto Fácil 📱

Aplicativo Android para registro de ponto pessoal — 100% offline, sem backend, sem Firebase.

---

## ✅ Requisitos para compilação

| Ferramenta | Versão mínima |
|---|---|
| Flutter SDK | 3.16.x ou superior |
| Dart SDK | 3.0.0 ou superior |
| Android SDK | API 29 (Android 10) |
| Java / JDK | 17 |
| Gradle | 8.2 (via wrapper) |

---

## 🚀 Compilar e gerar o APK

### 1. Instalar o Flutter

```bash
# Linux/macOS
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

Ou baixe em: https://docs.flutter.dev/get-started/install

### 2. Entrar na pasta do projeto

```bash
cd ponto_facil
```

### 3. Instalar dependências

```bash
flutter pub get
```

### 4. Gerar APK de release (recomendado)

```bash
flutter build apk --release
```

O APK ficará em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 5. (Alternativa) APK de debug para testes

```bash
flutter build apk --debug
```

### 6. Instalar diretamente no dispositivo via USB

```bash
flutter install
```

---

## 📁 Estrutura do projeto

```
ponto_facil/
├── lib/
│   ├── main.dart                  # Entry point
│   ├── models/
│   │   ├── registro_ponto.dart    # Modelo de registro + enum TipoPonto
│   │   └── configuracao.dart      # Modelo de configurações
│   ├── database/
│   │   └── database_helper.dart   # SQLite — CRUD completo
│   ├── services/
│   │   ├── ponto_service.dart     # Lógica de negócio
│   │   ├── notification_service.dart  # Notificações locais
│   │   └── export_service.dart    # PDF + CSV
│   ├── providers/
│   │   └── app_provider.dart      # Estado global (Provider)
│   ├── screens/
│   │   ├── main_shell.dart        # Navegação principal
│   │   ├── home_screen.dart       # Tela inicial + botão de ponto
│   │   ├── historico_screen.dart  # Histórico com edição/exclusão
│   │   ├── relatorios_screen.dart # Gráficos e resumos
│   │   ├── configuracoes_screen.dart  # Configurações
│   │   └── pin_screen.dart        # Tela de PIN
│   ├── widgets/
│   │   ├── status_card.dart       # Indicador Trabalhando/Fora
│   │   └── registro_recente_card.dart
│   └── utils/
│       ├── app_theme.dart         # Tema claro/escuro Material 3
│       └── formatters.dart        # Formatadores de data/hora
├── android/                       # Configurações nativas Android
├── pubspec.yaml                   # Dependências
└── README.md
```

---

## 🔧 Dependências principais

| Pacote | Uso |
|---|---|
| `sqflite` | Banco de dados SQLite local |
| `provider` | Gerenciamento de estado |
| `google_fonts` | Fonte Inter |
| `fl_chart` | Gráficos de barras e linha |
| `flutter_local_notifications` | Notificações offline |
| `pdf` | Geração de PDF |
| `csv` | Exportação CSV |
| `share_plus` | Compartilhamento de arquivos |
| `pinput` | Campo de PIN visual |
| `permission_handler` | Permissões Android |

---

## ⚙️ Funcionalidades implementadas

- [x] Registro automático com detecção de tipo (Entrada / Saída / Extra)
- [x] Bloqueio de duplicatas no mesmo minuto
- [x] Relógio em tempo real na tela inicial
- [x] Status "Trabalhando" com animação pulsante
- [x] Histórico completo com edição e exclusão
- [x] Relatório semanal e mensal com gráficos
- [x] Cálculo automático de saldo de horas
- [x] Exportação PDF e CSV com compartilhamento
- [x] PIN de 4 dígitos opcional
- [x] Lembretes de entrada e saída configuráveis
- [x] Tema claro, escuro e automático (Material Design 3)
- [x] Nome de usuário personalizável
- [x] Carga horária diária configurável
- [x] 100% offline — zero dependência de internet

---

## 🔒 Compatibilidade

- Android 10 (API 29) ou superior
- Testado em Android 10, 12, 13 e 14

---

## 📦 Sobre o APK gerado

O arquivo `app-release.apk` é diretamente instalável via:
- Transferência USB → Gerenciador de arquivos → Instalar
- ADB: `adb install app-release.apk`
- Google Drive / e-mail (habilitar "Fontes desconhecidas" nas configurações do Android)

---

Desenvolvido com Flutter 💙
