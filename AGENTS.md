# Context Bridge — Protocole de continuité inter-agents

<!-- context-bridge:version 1.1.0 -->
<!-- Fichier canonique. Les autres fichiers de directives (CLAUDE.md, .cursor/rules/,
     .windsurf/rules/, .github/copilot-instructions.md) pointent vers celui-ci.
     Ne dupliquez jamais ce protocole : modifiez uniquement ce fichier. -->

Ce projet utilise Context Bridge. La mémoire du projet vit dans `docs/` et elle est versionnée avec Git. Chaque agent reprend le travail exactement là où le précédent s'est arrêté.

Ce protocole est obligatoire. Il s'applique à chaque session, quel que soit l'agent ou l'humain aux commandes.

## 1. Démarrage de session — lecture obligatoire

Avant toute action (avant même de répondre à la première demande), lisez dans cet ordre :

1. `docs/state.md` — état courant du projet, en 5 lignes
2. `docs/roadmap.md` — objectifs et tâches en cours
3. `docs/journal/journal_bord.md` — dernière session : qui a fait quoi
4. `docs/journal/journal_erreurs.md` — bugs déjà résolus, à ne pas reproduire
5. `docs/CODE_MAP.md` — architecture du projet

Si `docs/state.md` est encore rempli de texte entre crochets, c'est la première session réelle : remplissez-le avant de coder.

## 2. Pendant la session

- Nouveau module, nouveau dossier, responsabilité déplacée → mettez à jour `docs/CODE_MAP.md`
- Décision technique structurante (framework, schéma de données, protocole) → ajoutez un ADR dans `docs/permanent/choix_techniques.md`
- Bug non trivial résolu → ajoutez une fiche dans `docs/journal/journal_erreurs.md`
- Nouvelle convention adoptée → ajoutez-la à `docs/permanent/regles_projet.md`

Écrivez ces mises à jour au moment où l'information est fraîche, pas à la fin.

## 3. Fin de session — écriture obligatoire

Déclencheurs : l'utilisateur clôt la session, la fenêtre de contexte approche de sa limite, ou vous vous apprêtez à livrer un travail terminé.

1. Mettez à jour `docs/state.md` : ce qui fonctionne, ce qui est en cours, ce qui bloque
2. Ajoutez une entrée datée dans `docs/journal/journal_bord.md` : agent, travail réalisé, décisions, prochaines étapes
3. Mettez à jour `docs/roadmap.md` : cochez le terminé, ajoutez le découvert
4. Commit et push

Une session sans entrée de journal est une session perdue pour le suivant.

## 4. Format des entrées

Journal de bord :

```markdown
### Session du AAAA-MM-JJ — [Objectif]
- **Agent** : [Humain / Claude Code / Cursor / Codex / Copilot / Windsurf]
- **Réalisé** :
  - [x] [Tâche terminée]
  - [ ] [Tâche entamée non terminée]
- **Décisions** : [Décisions prises, ou "Aucune"]
- **Prochaines étapes** : [Ce qui attend le suivant]
```

Journal des erreurs :

```markdown
### Erreur #NNN : [Titre court]
- **Module** : [Module ou fichier concerné]
- **Problème** : [Comportement indésirable observé]
- **Cause** : [Pourquoi le bug s'est produit]
- **Anti-pattern** : [Ce qu'il ne faut PAS refaire]
- **Solution** : [La façon correcte]
```

## 5. Règles de projet

Les conventions de code, les règles de sécurité et les règles Git de ce projet sont dans `docs/permanent/regles_projet.md`. Elles font partie de ce protocole.
