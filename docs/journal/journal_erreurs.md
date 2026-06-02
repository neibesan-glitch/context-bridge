---
type: journal/erreurs
statut: actif
priorite: moyenne
tags: [journal/erreurs, immunite]
derniere_maj: 2026-06-02
---

# 🛑 Journal des Erreurs et Anti-Patterns

Ce fichier contient la mémoire collective des erreurs commises et résolues sur le projet. **L'IA doit le lire avant d'écrire du code pour ne pas répéter les mêmes fautes.** Retour à l'[[INDEX]].

## 📋 Modèle de fiche d'erreur (À copier-coller)

Copiez ce modèle pour chaque nouveau bug résolu :

```markdown
### 🛑 Erreur #[Numéro] : [Titre court de l'erreur]
* **Module concerné** : [ex: Base de données / Auth]
* **Problème** : [Description du comportement indésirable ou du crash]
* **Cause** : [Pourquoi le bug s'est produit]
* **Ce qu'il ne faut PAS faire** : [Anti-pattern identifié]
* **Solution / Règle de code** : [Comment l'écrire correctement et éviter le bug (lien vers [[regles_de_code]])]
```

---

## 🗃️ Liste des Erreurs Répertoriées

### 🛑 Erreur #001 : Plantage des chemins sous Windows (Exemple)
* **Module concerné** : Scripts de build et démarrage
* **Problème** : Les commandes échouent car les chemins de fichiers absolus contiennent des espaces dans le dossier utilisateur OneDrive (`OneDrive - Documents/...`).
* **Cause** : Concaténations de chaînes de caractères brutes utilisant `/` ou `\` au lieu du module système de chemins.
* **Ce qu'il ne faut PAS faire** : 
  ```javascript
  const myPath = __dirname + "/config/settings.json"; // Plante si le dossier parent contient des espaces
  ```
* **Solution / Règle de code** : Toujours utiliser le module natif de gestion de chemins (voir les [[regles_de_code|Règles de Code]]).
  ```javascript
  const path = require('path');
  const myPath = path.resolve(__dirname, 'config', 'settings.json'); // Géré proprement par l'OS
  ```

### 🛑 Erreur #002 : Fuite de connexion à la Base de Données (Exemple)
* **Module concerné** : `src/models/`
* **Problème** : Le serveur s'arrête de répondre après 15 minutes d'utilisation intensive.
* **Cause** : Les requêtes n'attendent pas la fermeture des connexions, saturant le pool de connexions SQL.
* **Ce qu'il ne faut PAS faire** : Ouvrir des connexions sans bloc `finally` pour garantir la fermeture.
* **Solution / Règle de code** : Utiliser systématiquement un pattern `try/catch/finally` (voir les [[regles_de_code|Règles de Code]]) :
  ```javascript
  let client;
  try {
    client = await pool.connect();
    // Votre requête...
  } catch (err) {
    console.error("Erreur de requête", err);
  } finally {
    if (client) client.release(); // Libère la connexion quoi qu'il arrive
  }
  ```
