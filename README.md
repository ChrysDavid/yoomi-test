# Yoomi Test Technique - Écosystème Projects

## 📋 Vue d'ensemble

Mini écosystème de gestion de projets composé d'une API REST NestJS et d'une application mobile Flutter. Ce projet démontre une architecture moderne avec validation, persistance, cache local et interface utilisateur responsive.

## 🏗️ Architecture du Projet

```
yoomi-test/
├── backend (NestJS)/          # API NestJS (obligatoire)
│   ├── src/
│   ├── prisma/
│   ├── package.json
│   └── README.md
├── frontend (Flutter)/           # Application Flutter (Option B)
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│   └── README.md
├── .env.example
└── README.md
```

## 🚀 Démarrage Rapide

### Prérequis
- Node.js 16+ et npm
- Flutter SDK 3.0+
- Émulateur Android ou iOS Simulator

### 1. Backend (API NestJS)
```bash
cd backend (Next.js)
npm install
npm run seed
npm run start:dev
```
➡️ API disponible sur `http://localhost:3000`

### 2. Mobile (Application Flutter)
```bash
cd frontend (flutter)
flutter pub get
flutter packages pub run build_runner build
flutter run
```
➡️ App déployée sur émulateur/simulateur

## 🎯 Fonctionnalités Réalisées

### Backend (NestJS) ✅
- **API REST complète** : CRUD projects avec validation
- **Endpoints** : GET, POST, PUT, DELETE `/projects`
- **Filtrage** : par statut, recherche par nom, pagination
- **Persistance** : SQLite avec Prisma ORM
- **Validation** : DTOs avec class-validator
- **CORS** : configuré pour clients web/mobile
- **Seed** : 5 projets d'exemple injectés automatiquement

### Mobile (Flutter) ✅
- **Interface moderne** : Material Design 3 avec thème clair/sombre
- **CRUD complet** : création, lecture, modification, suppression
- **Recherche temps réel** : filtrage instantané par nom
- **Filtres dynamiques** : par statut (Draft/Published/Archived)
- **State management** : Provider pattern avec gestion d'erreurs
- **Cache local** : Hive pour persistance offline
- **UX optimisée** : pull-to-refresh, loading states, confirmations

## 📊 Ressource Project

### Modèle de données
```typescript
{
  id: string;          // UUID
  name: string;        // Nom du projet
  status: Status;      // DRAFT | PUBLISHED | ARCHIVED
  amount: number;      // Montant en euros
  createdAt: DateTime; // Date de création
}
```

### Données d'exemple
- Residence A (120 000€, Published)
- Loft B (85 000€, Draft)  
- Villa C (240 000€, Archived)
- Immeuble D (410 000€, Published)
- Studio E (60 000€, Draft)

## 🛠️ Choix Techniques

### Backend
- **NestJS** : Framework Enterprise avec TypeScript
- **Prisma** : ORM type-safe avec migrations
- **SQLite** : Base de données légère pour développement
- **Class-validator** : Validation robuste des DTOs
- **UUID** : Identifiants uniques sécurisés

### Mobile
- **Flutter** : Framework cross-platform performant
- **Provider** : State management simple et efficace
- **Hive** : Base de données NoSQL rapide
- **HTTP** : Client REST avec gestion d'erreurs
- **Material 3** : Design system moderne

## 🧪 Tests

### Backend
```bash
cd backend (Next.js)
npm run test        # Tests unitaires
npm run test:e2e    # Tests end-to-end
```

### Mobile
```bash
cd frontend (flutter)
flutter test        # Tests unitaires widgets
```

## 📱 Screenshots & Demo

L'application mobile propose :
- Liste des projets avec cartes colorées par statut
- Recherche instantanée et filtres par chips
- Formulaires de création/édition avec validation
- Bottom sheets pour détails complets
- Messages de confirmation et gestion d'erreurs

## 🔧 Configuration

### Variables d'environnement
Copiez `.env.example` vers `.env` et ajustez :
```bash
DATABASE_URL="file:./dev.db"
API_PORT=3000
```

### URLs API
- Développement : `http://localhost:3000`
- Android Emulator : `http://10.0.2.2:3000`
- iOS Simulator : `http://localhost:3000`

## 📈 Améliorations Possibles

### Court terme
- [ ] Tests unitaires étendus
- [ ] Authentification JWT
- [ ] Docker containerisation
- [ ] CI/CD pipeline

### Moyen terme
- [ ] Gestion complète offline avec sync
- [ ] Notifications push
- [ ] Export de données (PDF/CSV)
- [ ] Gestion d'images de projets
- [ ] Filtre par montant (amountMin/amountMax)

## 🤝 Contribution & Review

### Prêt pour revue technique (15 min)
- Code structuré et commenté
- Architecture scalable
- Bonnes pratiques respectées
- Gestion d'erreurs complète

### Micro-modification live demandée
Exemple d'ajout rapide : filtre `amountMin` sur l'API et exposition dans le mobile.

## 👤 Auteur

**Test technique Yoomi** - Démonstration d'un écosystème moderne NestJS + Flutter
- Durée de réalisation : ~4h
- Technologies : TypeScript, Dart, SQLite, REST API
- Focus : Architecture propre, UX moderne, code maintenable

---

⭐ **Merci pour votre attention !** N'hésitez pas à explorer le code et tester les fonctionnalités.