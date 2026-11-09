# NovaBank - Banking Dashboard (Flutter Web)

A banking dashboard UI with sample data. No backend: transactions are saved in the browser (shared_preferences).
All names, banks and amounts are fictional.

## Features
- **Home:** balance card with show/hide, quick actions (Send, Add money, Pay bills), income and spending summary, 7-day spending bar chart, recent transactions
- **Send money:** choose a payee, enter an amount (quick-amount chips), note, validation (invalid amount, insufficient balance), confirm and success dialogs
- **Transactions:** search, All / Income / Expense filters, grouped by day, tap for details
- **Analytics:** donut chart of this month's spending by category, income vs expenses, savings, biggest category
- Balance = opening balance + income - expenses, always calculated from the transactions
- Menu (top right on Home) has **Reset demo data**

## Run locally
```bash
flutter create . --platforms web      # adds the web/ folder (does not overwrite lib/ or pubspec.yaml)
flutter pub get
flutter run -d chrome
```

## Deploy to GitHub Pages
1. Run `flutter create . --platforms web`, commit everything (including `web/`) and push to `main`.
2. Repository -> Settings -> Pages -> Source -> **GitHub Actions**.
3. `.github/workflows/deploy.yml` builds and publishes automatically.
4. Live URL: `https://<your-username>.github.io/<repo-name>/`

## Deploy to Vercel
```bash
flutter build web --release
cd build/web
vercel --prod
```
