# Guide d'installation - LIGHTLAND EA

## 📋 Prérequis

- MetaTrader 4 installé
- Compte de trading (démo ou réel)
- Git installé (pour cloner le dépôt)

## 🚀 Étapes d'installation

### 1. Cloner le dépôt

```bash
git clone https://github.com/etbethait-jpg/lightland.git
cd lightland
```

### 2. Localiser le dossier MQL4

Sous Windows :
```
C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL4\
```

### 3. Copier les fichiers

#### Expert Advisor
Copiez le fichier `ea/LightlandEA.mq4` vers :
```
MQL4/Experts/
```

#### Indicateurs
Copiez les fichiers du dossier `indicators/` vers :
```
MQL4/Indicators/
```

#### Fonctions utilitaires
Copiez les fichiers du dossier `utils/` vers :
```
MQL4/Include/
```

### 4. Redémarrer MetaTrader 4

Fermez et relancez MetaTrader 4 pour que les nouveaux fichiers soient reconnus.

## ⚙️ Configuration de l'EA

### Attacher l'EA à un graphique

1. Ouvrez un graphique (paire EURUSD en H1 recommandé)
2. Dans le navigateur, allez à **Experts** → **LightlandEA**
3. Double-cliquez sur **LightlandEA** ou glissez-le sur le graphique
4. La fenêtre des paramètres s'ouvrira

### Paramètres recommandés

```
Risk = 2.0                    // 2% du capital par trade
StopLossPips = 50             // Stop loss de 50 pips
TakeProfitPips = 100          // Take profit de 100 pips
MagicNumber = 123456          // Numéro unique
UseSmartMoneyLevels = true    // Utiliser l'indicateur
```

### Autres options MetaTrader

Dans la fenêtre de paramètres :

1. **Onglet "Common"** :
   - ✓ Allow live trading (si trading réel)
   - ✓ Allow DLL imports (si nécessaire)

2. **Onglet "Inputs"** :
   - Ajustez les paramètres selon votre profil de risque

3. **Onglet "Alerts"** :
   - Configurez les alertes (optionnel)

## 🧪 Tester en mode démo

**IMPORTANT** : Toujours tester en démo avant le trading réel!

### Étapes

1. Utilisez un compte démo MetaTrader
2. Attachez l'EA au graphique
3. Laissez tourner pendant 1-2 semaines
4. Analysez les résultats dans l'onglet "Terminal" → "Experts"

## 📊 Vérifier les performances

Les résultats des trades apparaîtront dans :
- Onglet **Terminal** → **Experts** (logs)
- Onglet **Terminal** → **Trade** (historique)

## ❓ Dépannage

### L'EA n'apparaît pas dans le navigateur

1. Vérifiez que le fichier est dans le bon dossier
2. Redémarrez MetaTrader 4
3. Vérifiez la syntaxe MQL4

### Erreur de compilation

1. Ouvrez l'Éditeur MQL (F4)
2. Compilez le fichier (F5)
3. Vérifiez les erreurs dans la fenêtre des résultats

### Pas de trades ouverts

1. Vérifiez que le système de signaux est configuré correctement
2. Testez en mode backtest d'abord
3. Vérifiez les logs pour des erreurs

## 📞 Support

Pour toute question ou problème :
- Consultez le dépôt GitHub
- Vérifiez la documentation
- Testez d'abord en mode démo

---

**Prochaine étape** : Lire la [Stratégie détaillée](strategy.md)
