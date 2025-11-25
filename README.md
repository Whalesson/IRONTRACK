# 🏋️ IRONTRACK

**Gamified Pixel Art Hardcore Workout Progression App**  
*Focused on Load Progression | Inspired by Heavy Duty*

![Status](https://img.shields.io/badge/status-MVP-green)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![License](https://img.shields.io/badge/license-MIT-orange)

## 🎯 Sobre o IRONTRACK

IRONTRACK é um aplicativo móvel gamificado para progressão de treinos de musculação, inspirado na filosofia **Heavy Duty** de Mike Mentzer e Dorian Yates. Com uma estética **pixel art hardcore** e sistema de gamificação profundo, transforma cada treino em uma batalha épica contra "bosses" (exercícios).

### 🔥 Filosofia Heavy Duty

A metodologia Heavy Duty foca em:
- **Intensidade sobre volume**: Menos séries, mais intensidade
- **Progressão de carga**: Aumentar peso consistentemente
- **Descanso adequado**: Recuperação completa entre treinos
- **Séries até a falha**: Top sets levados ao limite

IRONTRACK implementa essa filosofia com:
- Cálculo automático de carga sugerida
- Detecção inteligente de platôs
- Sugestões de deload quando necessário
- Foco em séries principais (top sets)

## ✨ Funcionalidades Principais

### 💪 Gerenciamento de Exercícios
- Cadastro personalizado de exercícios
- Definição de faixas de repetições alvo
- Escolha entre progressão fixa ou percentual
- Sistema de níveis e XP por exercício

### 🎮 Treino Gamificado (Boss Fight)
- Exercícios como "bosses" a serem derrotados
- Cálculo automático de carga sugerida
- Registro rápido de séries
- Sistema de aquecimento e top sets

### 📊 Sistema de Progressão
- **Cálculo inteligente de próxima carga**
  - Progressão fixa: adiciona valor fixo (ex: +2.5kg)
  - Progressão percentual: adiciona percentual (ex: +5%)
- **Detecção de platô**: 3 falhas consecutivas
- **Sugestão de deload**: -10% quando necessário

### 🏆 Gamificação Profunda
- **Sistema de XP**: Ganhe experiência a cada série
  - XP Base: `peso * reps * 0.1`
  - Bônus Top Set: +50 XP
  - Bônus Aumento Reps: +75 XP
  - Bônus Aumento Carga: +100 XP
  - Bônus PR: +200 XP
- **Sistema de Níveis**: Progressão exponencial
- **Personal Records (PRs)**: Detectados automaticamente

## 🛠️ Stack Tecnológico

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Banco de Dados**: SQLite (sqflite / sqflite_common_ffi)
- **Gráficos**: fl_chart
- **Plataformas**: Android, iOS, Linux, Windows, macOS

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK 3.0 ou superior
- Dart SDK 3.0 ou superior
- Para Linux: `sudo apt install libsqlite3-dev sqlite3`

### Instalação

```bash
# Clone o repositório
git clone https://github.com/Whalesson/IRONTRACK.git
cd IRONTRACK

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

### Build para Produção

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Linux
flutter build linux --release
```

## 📦 Estrutura do Projeto

```
lib/
├── core/                 # Configurações e constantes
│   └── app_colors.dart   # Paleta de cores neon
├── data/                 # Camada de dados
│   ├── database_helper.dart
│   ├── exercise_repository.dart
│   ├── workout_repository.dart
│   └── workout_set_repository.dart
├── domain/               # Lógica de negócio
│   ├── progression_service.dart
│   └── gamification_service.dart
├── models/               # Modelos de dados
│   ├── exercise.dart
│   ├── workout.dart
│   └── workout_set.dart
└── presentation/         # Interface do usuário
    ├── screens/
    └── widgets/
```

## 🎨 Design System

### Paleta de Cores Neon

- **Neon Primary**: `#00FF41` (Verde neon)
- **Neon Secondary**: `#00D9FF` (Ciano neon)
- **Neon Accent**: `#FF006E` (Magenta neon)
- **Background**: `#0A0A0A` (Preto profundo)
- **XP Yellow**: `#FFD700` (Ouro)
- **PR Gold**: `#FFA500` (Laranja ouro)

## 📝 Roadmap

### ✅ MVP (Completo)
- [x] Models e banco de dados
- [x] Repositórios CRUD
- [x] Serviços de progressão e gamificação
- [x] UI Kit pixel art
- [x] Telas principais
- [x] Registro de séries com XP e PR

### 🚧 v1.0 (Próximos Passos)
- [ ] Histórico com gráficos detalhados
- [ ] Sistema de conquistas completo
- [ ] Animações de PR e Level Up
- [ ] Onboarding para novos usuários

## 📄 Licença

Este projeto está licenciado sob a Licença MIT.

## 👤 Autor

**Whalesson**

- GitHub: [@Whalesson](https://github.com/Whalesson)

---

**Que a progressão esteja sempre ao nosso favor. Bem-vindo ao IRONTRACK!** 🏋️‍♂️💀🎮
