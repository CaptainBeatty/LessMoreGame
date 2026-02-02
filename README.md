# Challenge PowerShell - Jeu du Plus ou Moins

## Contexte professionnel

Vous travaillez chez **TechSecure** en tant qu'administrateur système junior. Dans le cadre de votre formation continue, votre manager souhaite que vous maîtrisiez PowerShell et les bonnes pratiques de développement, notamment l'utilisation de Git pour versionner votre code.

Votre mission : créer un jeu simple du "Plus ou Moins" en PowerShell, tout en appliquant les bonnes pratiques de gestion de versions avec Git et GitHub.

## Objectifs du challenge

À l'issue de ce challenge, vous serez capable de :
- Écrire un script PowerShell interactif
- Utiliser les structures de contrôle (conditions, boucles)
- Gérer les entrées utilisateur et la validation
- Versionner votre code avec Git
- Pousser régulièrement votre travail sur GitHub
- Documenter votre code

---

## Règles du jeu

Le jeu du "Plus ou Moins" fonctionne ainsi :
1. L'ordinateur choisit un nombre aléatoire entre 1 et 100
2. Le joueur doit deviner ce nombre
3. À chaque proposition, l'ordinateur indique si le nombre à trouver est plus grand ou plus petit
4. Le jeu compte le nombre de tentatives
5. Le jeu se termine quand le joueur trouve le bon nombre

---

## ÉTAPE 1 - Préparation de l'environnement

### Objectif
Récupérer le projet depuis GitHub et le préparer pour le développement.

### Travail à réaliser

**1.1** - Clonez le dépôt GitHub fourni par votre formateur :
- URL du dépôt : `[URL fournie par le formateur]`
- Dossier de destination : `C:\Scripts\`

**1.2** - Entrez dans le dossier du projet cloné

**1.3** - Vérifiez que vous êtes bien sur la branche principale

**1.4** - Configurez votre identité Git si ce n'est pas déjà fait

**1.5** - Ouvrez le fichier `README.md` existant et ajoutez votre nom dans la section "Auteur"

**1.6** - Faites votre premier commit et poussez sur GitHub :
- Ajoutez le fichier README modifié
- Commitez avec le message : `docs: ajout de mon nom dans le README`
- Poussez sur GitHub

---

## ÉTAPE 2 - Version 1.0 - Jeu basique

### Objectif
Créer une première version fonctionnelle du jeu.

### Travail à réaliser

**2.1** - Créez un fichier `PlusOuMoins.ps1` dans le dossier du projet

**2.2** - Écrivez le code permettant de :
- Générer un nombre aléatoire entre 1 et 100
- Demander au joueur de proposer un nombre
- Comparer la proposition avec le nombre à deviner
- Afficher "Plus grand" ou "Plus petit" selon le cas
- Continuer jusqu'à ce que le joueur trouve
- Afficher un message de victoire avec le nombre de tentatives

**2.3** - Testez votre script

**2.4** - **COMMIT OBLIGATOIRE** :
- Ajoutez votre fichier au dépôt Git
- Commitez avec le message : `feat: version 1.0 - jeu basique fonctionnel`
- Poussez sur GitHub

---

## ÉTAPE 3 - Version 1.1 - Améliorations visuelles

### Objectif
Améliorer l'expérience utilisateur avec des couleurs et un affichage plus clair.

### Travail à réaliser

**3.1** - Améliorez votre script en ajoutant :
- Un titre coloré au démarrage du jeu
- Des couleurs différentes selon les messages :
  - Vert pour "Plus petit"
  - Bleu pour "Plus grand"
  - Jaune pour les messages d'information
  - Cyan pour le message de victoire
- Un message d'accueil qui explique les règles
- Un affichage du nombre de tentatives à chaque essai

**3.2** - Testez les améliorations

**3.3** - **COMMIT OBLIGATOIRE** :
- Commitez avec le message : `feat: ajout des couleurs et messages améliorés`
- Poussez sur GitHub

---

## ÉTAPE 4 - Version 1.2 - Validation des entrées

### Objectif
Gérer les erreurs de saisie utilisateur.

### Travail à réaliser

**4.1** - Ajoutez des validations pour :
- Vérifier que l'utilisateur entre bien un nombre
- Vérifier que le nombre est entre 1 et 100
- Afficher un message d'erreur en rouge si la saisie est invalide
- Redemander une saisie en cas d'erreur (sans compter la tentative)

**4.2** - Testez avec des entrées invalides :
- Lettres
- Nombres négatifs
- Nombres supérieurs à 100
- Chaînes vides

**4.3** - **COMMIT OBLIGATOIRE** :
- Commitez avec le message : `feat: validation des entrées utilisateur`
- Poussez sur GitHub

---

## ÉTAPE 5 - Version 2.0 - Fonctionnalités avancées

### Objectif
Ajouter des fonctionnalités pour rendre le jeu plus intéressant.

### Travail à réaliser

**5.1** - Ajoutez les fonctionnalités suivantes :
- Afficher le nombre de tentatives restantes (limite : 10 tentatives)
- Si le joueur dépasse 10 tentatives, il perd et le jeu révèle le nombre
- Demander au joueur s'il veut rejouer à la fin d'une partie
- Garder un historique des scores (nombre de tentatives pour chaque partie gagnée)
- Afficher le meilleur score à la fin

**5.2** - Testez toutes les nouvelles fonctionnalités

**5.3** - **COMMIT OBLIGATOIRE** :
- Commitez avec le message : `feat: ajout limite tentatives et rejouer`
- Poussez sur GitHub

---

## ÉTAPE 6 - Version 2.1 - Niveaux de difficulté

### Objectif
Proposer différents niveaux de difficulté.

### Travail à réaliser

**6.1** - Au démarrage, demandez au joueur de choisir un niveau :
- **Facile** : nombre entre 1 et 50, 15 tentatives
- **Moyen** : nombre entre 1 et 100, 10 tentatives
- **Difficile** : nombre entre 1 et 200, 8 tentatives

**6.2** - Adaptez le jeu selon le niveau choisi

**6.3** - Affichez le niveau choisi pendant la partie

**6.4** - **COMMIT OBLIGATOIRE** :
- Commitez avec le message : `feat: ajout des niveaux de difficulté`
- Poussez sur GitHub

---

## ÉTAPE 7 - Version 3.0 - Mode deux joueurs

### Objectif
Ajouter un mode où deux joueurs peuvent s'affronter.

### Travail à réaliser

**7.1** - Au démarrage, proposez de choisir le mode :
- **1** : Un joueur contre l'ordinateur
- **2** : Deux joueurs

**7.2** - En mode deux joueurs :
- Le Joueur 1 choisit un nombre (saisie masquée ou écran effacé)
- Le Joueur 2 doit le deviner
- À la fin, les joueurs peuvent inverser les rôles

**7.3** - Testez le nouveau mode

**7.4** - **COMMIT OBLIGATOIRE** :
- Commitez avec le message : `feat: ajout du mode deux joueurs`
- Poussez sur GitHub

---

## ÉTAPE 8 - Version 3.1 - Sauvegarde des scores

### Objectif
Sauvegarder les scores dans un fichier pour les consulter entre les sessions.

### Travail à réaliser

**8.1** - Créez un système de sauvegarde :
- Sauvegarder les scores dans un fichier `scores.txt` ou `scores.csv`
- Enregistrer : nom du joueur, niveau, nombre de tentatives, date
- Charger les scores au démarrage
- Afficher le tableau des meilleurs scores

**8.2** - Ajoutez une option "Voir les scores" au menu principal

**8.3** - **COMMIT OBLIGATOIRE** :
- Commitez avec le message : `feat: sauvegarde des scores dans un fichier`
- Poussez sur GitHub

**8.4** - Ajoutez `scores.txt` ou `scores.csv` dans le `.gitignore` (les données utilisateur ne doivent pas être versionnées)

**8.5** - **COMMIT OBLIGATOIRE** :
- Commitez avec le message : `chore: ajout du gitignore pour les fichiers de données`
- Poussez sur GitHub

---

## ÉTAPE 9 - Documentation et finalisation

### Objectif
Documenter le code et finaliser le projet.

### Travail à réaliser

**9.1** - Ajoutez des commentaires dans votre code :
- En-tête du script avec synopsis, description, auteur, date
- Commentaires pour chaque section importante
- Commentaires pour les fonctions si vous en avez créé

**9.2** - Mettez à jour le `README.md` avec :
- Description complète du jeu
- Fonctionnalités implémentées
- Comment lancer le jeu
- Captures d'écran ou exemples (optionnel)
- Améliorations possibles pour le futur

**9.3** - **COMMIT OBLIGATOIRE** :
- Commitez avec le message : `docs: mise à jour de la documentation`
- Poussez sur GitHub

**9.4** - Consultez votre dépôt GitHub pour vérifier que tout est bien présent

---

## ÉTAPE 10 - Fonctionnalités bonus

### Objectif
Aller plus loin avec des fonctionnalités avancées.

### Idées d'améliorations (au choix)

**10.1** - Indice intelligent :
- Après 5 tentatives, proposer un indice (par exemple : "Le nombre est pair/impair")

**10.2** - Mode défi chronométré :
- Ajouter un chronomètre qui limite le temps total de jeu

**10.3** - Statistiques avancées :
- Moyenne des tentatives
- Taux de victoire
- Graphique des performances (difficile en PowerShell mais possible avec ASCII art)

**10.4** - Son ou animation :
- Jouer un bip différent selon plus/moins (avec `[console]::Beep()`)
- Animation ASCII lors de la victoire

**10.5** - Mode en ligne de commande avec paramètres :
- Permettre de lancer le jeu avec des paramètres : `.\PlusOuMoins.ps1 -Niveau Difficile -MaxTentatives 5`

**Pour chaque fonctionnalité ajoutée, faites un commit et poussez sur GitHub !**

---

## Exigences techniques

### Structure du code attendue

Votre script doit contenir au minimum :
- Un en-tête de documentation
- Des variables clairement nommées
- Des boucles (`while`, `do-while`, `for`)
- Des conditions (`if`, `elseif`, `else`, `switch`)
- De la gestion d'erreur (validation des entrées)
- Des commentaires explicatifs

### Bonnes pratiques PowerShell

- Utilisez `Write-Host` avec des couleurs pour l'affichage
- Utilisez `Read-Host` pour les saisies utilisateur
- Utilisez `Clear-Host` pour effacer l'écran quand nécessaire
- Nommez vos variables de manière explicite (ex: `$nombreSecret`, pas `$x`)
- Indentez correctement votre code

### Bonnes pratiques Git

- **Commits réguliers** : Au moins un commit par étape
- **Messages explicites** : Utilisez les préfixes `feat:`, `fix:`, `docs:`, `chore:`
- **Push fréquent** : Poussez après chaque commit ou au minimum après chaque étape
- **Pas de gros fichiers** : N'ajoutez pas de fichiers volumineux ou de données sensibles

---

## ⚠️ Points d'attention importants

### Versionnement obligatoire

**VOUS DEVEZ IMPÉRATIVEMENT** :
- ✅ Faire des commits réguliers (au moins 1 par étape)
- ✅ Pousser votre code sur GitHub même si l'exercice n'est pas terminé
- ✅ Avoir un historique Git propre et lisible

**Un projet sans commits réguliers ou sans push GitHub sera pénalisé, même si le code fonctionne parfaitement.**

### Gestion du temps

- Ne cherchez pas la perfection dès le début
- Avancez étape par étape
- **Commitez et poussez après chaque étape, même si ce n'est pas parfait**
- Si vous êtes bloqué sur une étape, passez à la suivante et revenez-y plus tard
- **L'important est d'avoir un historique Git montrant votre progression**

---

## Ressources utiles

- **Documentation PowerShell** : https://docs.microsoft.com/powershell/
- **Documentation Git** : https://git-scm.com/doc
- **Get-Help** : Utilisez `Get-Help` suivi du nom de la cmdlet pour obtenir de l'aide

---

**Difficulté** : ⭐⭐☆☆☆

🚀 **Bon courage !** N'oubliez pas : commitez et poussez régulièrement, c'est la clé ! Votre historique Git doit raconter l'histoire de votre développement.
