<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->


## Description

API REST construite avec [NestJS](https://github.com/nestjs/nest) pour la gestion de projets immobiliers. Implémente un CRUD complet avec filtrage, pagination, validation et persistance SQLite via Prisma.

**Fonctionnalités principales :**
- Gestion de projets (CRUD complet)
- Filtrage par statut et recherche textuelle  
- Pagination avec métadonnées
- Validation stricte des données (DTOs)
- 5 projets d'exemple pré-chargés

## Configuration du projet

```bash
# Installation des dépendances
$ npm install

# Configuration de la base de données
$ npx prisma migrate dev --name init
$ npx prisma generate

# Injection des données d'exemple
$ npm run seed
```

## Compilation et lancement

```bash
# développement
$ npm run start

# mode watch
$ npm run start:dev

# mode production
$ npm run start:prod
```

➡️ **API disponible sur `http://localhost:3000`**

## Endpoints API

### GET /projects
Récupère les projets avec filtres optionnels :
- `status` : `DRAFT` | `PUBLISHED` | `ARCHIVED`
- `q` : recherche par nom
- `page` & `pageSize` : pagination

### POST /projects
Crée un nouveau projet
```json
{
  "name": "Villa Example",
  "status": "DRAFT",
  "amount": 150000
}
```

### PUT /projects/:id
Met à jour un projet existant

### DELETE /projects/:id
Supprime un projet

## Lancement des tests

```bash
# tests unitaires
$ npm run test

# tests e2e
$ npm run test:e2e

# couverture de code
$ npm run test:cov
```

## Technologies utilisées

- **NestJS** - Framework Node.js avec TypeScript
- **Prisma** - ORM moderne avec SQLite
- **Class-validator** - Validation des DTOs
- **Jest** - Framework de tests

## Structure des données

```typescript
enum Status {
  DRAFT
  PUBLISHED  
  ARCHIVED
}

interface Project {
  id: string        // UUID
  name: string      // Nom du projet
  status: Status    // Statut
  amount: number    // Montant
  createdAt: Date   // Date de création
}
```