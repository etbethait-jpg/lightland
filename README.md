# 🌟 LIGHTLAND - Smart Money Expert Advisor

**LIGHTLAND** est un Expert Advisor (EA) MQL4 avancé basé sur les principes du **Smart Money Concept**. Cet EA automatise une stratégie de trading sophistiquée qui identifie et exploite les mouvements des acteurs majeurs du marché (smart money).

## 📊 Caractéristiques principales

- 🎯 **Analyse Smart Money** : Détection des zones d'accumulation et de distribution
- 📈 **Gestion automatisée** : Entrées, sorties et stops loss basés sur la logique Smart Money
- 🛡️ **Gestion du risque** : Position sizing dynamique et protection du capital
- 🔄 **Flexible** : Adaptable à différents timeframes et paires de devises
- 📊 **Backtesting** : Résultats et statistiques de performance inclus
- ⚡ **Performance** : Optimisé pour un trading rapide et fiable

## 🎯 Objectif

Fournir une solution de trading automatisée fiable et transparente pour les traders qui souhaitent appliquer les concepts de Smart Money sans intervention manuelle.

## 🚀 Démarrage rapide

### Installation

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/etbethait-jpg/lightland.git
   cd lightland
   ```

2. **Copier les fichiers vers MetaTrader 4** :
   - Expert Advisors : `ea/` → `MQL4/Experts/`
   - Indicateurs : `indicators/` → `MQL4/Indicators/`
   - Utilitaires : `utils/` → `MQL4/Include/`

3. **Redémarrer MetaTrader 4**

4. **Attacher l'EA** à un graphique et configurer les paramètres

Pour plus de détails → [Guide d'installation](docs/installation.md)

## 📚 Documentation

- 📖 [Stratégie Smart Money détaillée](docs/strategy.md) - Explication complète de la logique
- 🔧 [Guide d'installation](docs/installation.md) - Installation pas à pas
- ⚙️ [Paramètres recommandés](docs/installation.md#paramètres-recommandés)

## 📁 Structure du projet

```
lightland/
├── README.md                      # Ce fichier
├── .gitignore                     # Fichiers à ignorer
├── ea/
│   └── LightlandEA.mq4           # Expert Advisor principal
├── indicators/
│   └── SmartMoneyLevel.mq4       # Indicateur Smart Money
├── utils/
│   └── helpers.mq4               # Fonctions utilitaires
├── docs/
│   ├── strategy.md               # Stratégie détaillée
│   └── installation.md           # Guide d'installation
└── backtest/
    └── results.txt               # Résultats des backtests
```

## ⚙️ Paramètres de l'EA

| Paramètre | Défaut | Description |
|-----------|--------|-------------|
| `Risk` | 2.0 | Pourcentage du capital à risquer par trade |
| `StopLossPips` | 50 | Stop loss en pips |
| `TakeProfitPips` | 100 | Take profit en pips |
| `MagicNumber` | 123456 | Numéro unique pour identifier les trades |
| `UseSmartMoneyLevels` | true | Activer l'indicateur Smart Money |
| `MaxTrades` | 5 | Nombre maximum de trades ouverts |

## 🧪 Testing

**IMPORTANT** : Toujours tester en mode démo avant le trading réel!

1. Utilisez un compte démo MetaTrader
2. Attachez l'EA au graphique
3. Laissez tourner pendant 1-2 semaines
4. Analysez les résultats

Voir les [résultats de backtest](backtest/results.txt)

## 📊 Performances attendues

- **Win Rate** : 55-65%
- **Profit Factor** : 1.5-2.0
- **Max Drawdown** : 15-20%
- **Trades par mois** : 10-20 (dépend du marché)

## ⚠️ Disclaimer

⚠️ **AVERTISSEMENT** :
- Le trading comporte des risques de perte
- Les performances passées ne garantissent pas les résultats futurs
- Testez toujours en démo d'abord
- Utilisez uniquement ce que vous pouvez vous permettre de perdre
- Pas de conseil financier - À vos risques et périls

## 🤝 Contribution

Vous trouvez un bug? Des suggestions?

1. Créez une **Issue** pour signaler un problème
2. Créez une **Pull Request** pour soumettre des améliorations
3. Partagez vos résultats de backtest!

## 📞 Support & Contact

- 🐛 Signalez les bugs via les [Issues](https://github.com/etbethait-jpg/lightland/issues)
- 💡 Suggestions d'améliorations bienvenues
- 📊 Partagez vos résultats de backtest

## 📝 License

MIT License - Voir le fichier LICENSE pour plus de détails

## 🎓 Ressources utiles

- [Documentation MQL4 officielle](https://docs.mql4.com/)
- [Smart Money Concept - Trading](https://www.investopedia.com/)
- [MetaTrader 4 - Guide complet](https://www.metatrader4.com/)

---

**Créé avec ❤️ par etbethait-jpg**

**Dernière mise à jour** : Mai 2026

**Version** : 1.0.0 (Beta)
