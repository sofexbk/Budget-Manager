# 💰 Budget Manager - Application de Gestion de Budget

Une application mobile Flutter élégante et intuitive pour gérer votre budget mensuel et suivre vos dépenses.

## 📱 Captures d'écran

L'application propose une interface moderne avec :
- Tableau de bord coloré avec indicateurs visuels
- Suivi en temps réel de votre budget
- Historique détaillé par mois
- Gestion complète des dépenses

## ✨ Fonctionnalités

### 🎯 Gestion du Budget
- **Définir un salaire mensuel** : Entrez votre revenu pour commencer
- **Modifier le salaire** : Bouton d'édition dans l'app bar pour ajuster votre salaire
- **Indicateurs visuels** : Statut du budget avec code couleur
    - 🟢 Vert : Plus de 50% restant (Excellente gestion)
    - 🟠 Orange : 20-50% restant (Attention)
    - 🔴 Rouge : Moins de 20% restant (Budget critique)

### 💸 Gestion des Dépenses
- **Ajouter une dépense** : Bouton flottant pour ajouter rapidement
- **Modifier une dépense** : Cliquez sur une dépense pour la modifier
- **Supprimer une dépense** : Glissez vers la gauche pour supprimer
- **Vue détaillée** : Titre, montant, et date de chaque dépense

### 📊 Tableau de Bord
- **Carte de statut** : Vue d'ensemble colorée du budget restant
- **Statistiques** : Cartes affichant le salaire et les dépenses totales
- **Barre de progression** : Visualisation du pourcentage utilisé
- **Liste des dépenses récentes** : Scroll vertical pour voir toutes les dépenses
- **Interaction tactile** : Cliquez pour modifier, glissez pour supprimer

### 📅 Historique
- **Vue par mois** : Historique complet de tous les mois
- **Résumé mensuel** : Total des dépenses et montant restant par mois
- **Navigation facile** : Menu latéral pour switcher entre vues

### 🔄 Gestion des Mois
- **Nouveau mois intelligent** : Création automatique uniquement pour les nouveaux mois
- **Conservation du salaire** : Votre salaire est préservé d'un mois à l'autre
- **Protection des données** : Confirmation avant la création d'un nouveau mois

## 🏗️ Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── models/
│   └── expense.dart            # Modèle de données pour les dépenses
├── screens/
│   └── budget_home_page.dart   # Page principale avec toute la logique
└── widgets/
    ├── dashboard.dart          # Widget du tableau de bord
    ├── history_page.dart       # Widget de l'historique
    └── stat_card.dart          # Widget de carte statistique
```

## 🚀 Installation

### Prérequis
- Flutter SDK (version 3.0 ou supérieure)
- Dart SDK
- Android Studio / VS Code
- Émulateur Android/iOS ou appareil physique

### Étapes d'installation

1. **Cloner le repository**
```bash
git clone <url-du-repo>
cd budget_manager
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Vérifier l'installation Flutter**
```bash
flutter doctor
```

4. **Lancer l'application**
```bash
flutter run
```

## 📦 Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

## 🎨 Design

### Palette de Couleurs
- **Primaire** : Indigo (`Colors.indigo`)
- **Succès** : Vert (`Colors.green`)
- **Avertissement** : Orange (`Colors.orange`)
- **Danger** : Rouge (`Colors.red`)
- **Fond** : Gris clair (`#F5F7FA`)

### Composants UI
- **Material Design 3** activé
- **Cartes avec ombres** pour la profondeur
- **Dégradés de couleurs** pour les indicateurs
- **Animations fluides** pour les transitions
- **Dismissible** pour les gestes de suppression

## 💡 Utilisation

### Premier lancement
1. Entrez votre salaire mensuel
2. Cliquez sur "Commencer"

### Ajouter une dépense
1. Cliquez sur le bouton flottant "Dépense"
2. Entrez le titre et le montant
3. Cliquez sur "Ajouter"

### Modifier une dépense
1. Cliquez sur la dépense à modifier
2. Modifiez les informations
3. Cliquez sur "Modifier"

### Supprimer une dépense
1. Glissez la dépense vers la gauche
2. Confirmez la suppression

### Modifier le salaire
1. Cliquez sur l'icône d'édition (✏️) dans l'app bar
2. Entrez le nouveau montant
3. Confirmez

### Nouveau mois
1. Ouvrez le menu latéral
2. Cliquez sur "Nouveau mois"
3. Confirmez (disponible uniquement si un nouveau mois calendaire est arrivé)

## 🔧 Personnalisation

### Modifier la devise
Dans les fichiers, remplacez `DH` par votre devise :
```dart
"${amount.toStringAsFixed(2)} DH"
// Devient par exemple :
"${amount.toStringAsFixed(2)} €"
```

### Ajuster les seuils de couleur
Dans `_getBudgetStatusColor()` :
```dart
if (percentageLeft > 50) return Colors.green;  // Modifier 50
if (percentageLeft > 20) return Colors.orange; // Modifier 20
return Colors.red;
```

### Messages personnalisés
Modifiez `_getBudgetStatusMessage()` pour personnaliser les messages d'état.

## 🐛 Débogage

### Problèmes courants

**Les dépenses ne s'affichent pas**
- Vérifiez que le salaire est défini
- Vérifiez que vous êtes sur le bon mois

**L'application crash au démarrage**
```bash
flutter clean
flutter pub get
flutter run
```

**Problèmes d'affichage**
- Vérifiez la version de Flutter : `flutter --version`
- Mettez à jour Flutter : `flutter upgrade`

## 🚦 État du Projet

- ✅ Gestion du budget mensuel
- ✅ Ajout/Modification/Suppression de dépenses
- ✅ Historique multi-mois
- ✅ Indicateurs visuels
- ✅ Gestion intelligente des mois
- ✅ Interface responsive
- ✅ Persistance des données
- ⏳ Catégories de dépenses (à venir)
- ⏳ Graphiques statistiques (à venir)
- ⏳ Export des données (à venir)

## 📈 Améliorations Futures

- [ ] **Persistance locale** : Sauvegarde avec SharedPreferences ou SQLite
- [ ] **Catégories** : Organiser les dépenses par catégorie
- [ ] **Graphiques** : Visualisation avec charts
- [ ] **Export** : PDF ou Excel des rapports mensuels
- [ ] **Multi-devises** : Support de plusieurs devises
- [ ] **Notifications** : Alertes pour budget critique
- [ ] **Mode sombre** : Thème dark
- [ ] **Authentification** : Login utilisateur
- [ ] **Cloud sync** : Synchronisation cloud

## 👨‍💻 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👤 Auteur

Développé avec ❤️ en Flutter

## 🙏 Remerciements

- Flutter Team pour le framework
- Material Design pour les guidelines UI
- La communauté Flutter pour les ressources

---

**Note** : Cette application est actuellement en version de développement. Les données ne sont pas persistées et seront perdues à la fermeture de l'application. Une version avec sauvegarde locale est en cours de développement.

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter via email (soufianbouktaib1@gmail.com)

**Bonne gestion de votre budget ! 💪💰**
