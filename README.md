# Context Bridge

Protocole de memoire partagee et de continuite entre agents IA et developpeurs humains.

---

## Le probleme

Quand plusieurs outils IA travaillent sur un meme projet (Claude Code, Cursor, Windsurf, Codex, Copilot...), chacun perd le contexte a chaque nouvelle session. Les bugs reviennent, les decisions se contredisent, le travail se repete.

## La solution

Context Bridge impose un **protocole de handoff** : chaque agent lit l'etat du projet au demarrage et documente son travail en fin de session. La memoire est stockee dans Git, accessible a tous.

---

## Structure

```text
/
├── CLAUDE.md               # Directives pour Claude Code
├── CODEX.md                # Directives pour Codex (OpenAI)
├── .cursorrules            # Directives pour Cursor / Windsurf
├── .github/copilot.md      # Directives pour GitHub Copilot
│
└── docs/
    ├── INDEX.md            # Point d'entree et navigation
    ├── CODE_MAP.md         # Carte de l'architecture du projet
    ├── state.md            # Etat courant du projet (resume rapide)
    ├── roadmap.md          # Objectifs et taches a accomplir
    │
    ├── permanent/          # Connaissances stables
    │   ├── choix_techniques.md   # Decisions d'architecture (ADR)
    │   └── regles_projet.md      # Conventions et regles du projet
    │
    └── journal/            # Flux d'activite
        ├── journal_erreurs.md    # Memoire immunitaire (bugs resolus)
        └── journal_bord.md       # Historique des sessions
```

---

## Agents supportes

| Agent | Fichier de directives | Detection |
|-------|----------------------|-----------|
| Claude Code | `CLAUDE.md` | Automatique |
| Codex (OpenAI) | `CODEX.md` | Automatique |
| Cursor / Windsurf | `.cursorrules` | Automatique |
| GitHub Copilot | `.github/copilot.md` | Automatique |

Chaque fichier contient le meme protocole adapte au format de l'agent.

---

## Protocole de Handoff

### Demarrage de session (Lecture obligatoire)

1. Lire `docs/state.md` pour l'etat courant
2. Lire `docs/roadmap.md` pour les objectifs en cours
3. Lire `docs/journal/journal_bord.md` pour la derniere session
4. Lire `docs/journal/journal_erreurs.md` pour eviter les regressions

### Fin de session (Ecriture obligatoire)

1. Mettre a jour `docs/state.md` avec le nouvel etat
2. Mettre a jour `docs/journal/journal_bord.md` avec le travail effectue
3. Si bug resolu : ajouter la fiche dans `docs/journal/journal_erreurs.md`
4. Si decision d'architecture : mettre a jour `docs/permanent/choix_techniques.md`
5. Commit et push

---

## Installation

### Methode 1 : Une seule commande (recommande)

Ouvrez un terminal a la racine de votre projet et collez :

```bash
curl -fsSL https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.sh | bash
```

**Windows (PowerShell)** :

```powershell
irm https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.ps1 | iex
```

C'est tout. Le protocole est actif immediatement.

### Methode 2 : Template GitHub

1. Cliquez sur **"Use this template"** sur la page GitHub du depot
2. Clonez votre nouveau depot
3. Le protocole est immediatement actif

### Methode 3 : Installation manuelle

1. Copiez les fichiers de directives (`CLAUDE.md`, `CODEX.md`, `.cursorrules`, `.github/copilot.md`) a la racine de votre projet
2. Copiez le dossier `docs/` dans votre projet
3. Adaptez `docs/CODE_MAP.md` a votre architecture

### Methode 4 : npx (pour les projets Node.js)

```bash
npx context-bridge init
```

---

## Integration Obsidian (optionnel)

1. Ouvrez le dossier `docs/` dans Obsidian comme coffre
2. Les fichiers sont interconnectes par des Wiki-links `[[NomDuFichier]]`
3. La Vue Graphe affiche les relations entre documents

---

## Licence

MIT
