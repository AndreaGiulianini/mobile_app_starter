# Comandi fondamentali per buildare il progetto

### Importare file

Il file config.dart contiene dati sensibili come chiavi e compagnia che non si vuole lasciare sotto git, importare a mano

### Compilare GoRouter/MobX/JsonSerializable

`dart run build_runner build --delete-conflicting-outputs`

### Format di tutti i file del progetto

`dart format ./ -l 120`

### Linting di tutti i file del progetto

`dart fix --apply`

### Se vogliamo verificare la presenza di aggiornamenti nelle dipendenze

`flutter pub upgrade --major-versions`

### Linee guida generali sul codice del progetto

1. Enum di un componente vanno 'part of' del componente stesso e dentro la stessa cartella
2. Rimozione di tutti i warings possibili
3. Solo named parameters nelle funzioni

### Comando per generare un apk

`flutter build apk`
