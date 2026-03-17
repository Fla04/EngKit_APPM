# Engkit
## 1. Obiettivi

### 1.1 Descrizione
L’applicazione nasce come strumento “per ingegneri, da ingegneri”, progettato per offrire un supporto completo a studenti di ingegneria (e non), con particolare attenzione all’ambito informatico.

La piattaforma integra:
1. **Strumenti di calcolo** per attività matematiche e analitiche (integrali, derivate, matrici, vettori) e per ambiti affini (statistica, probabilità, finanza).
2. **Gestione degli appunti** mediante un editor LaTeX dedicato alla redazione tecnica e una libreria personale per l’archiviazione ordinata di testi e dispense.
3. **Condivisione delle risorse** tramite cloud con geolocalizzazione integrata, per semplificare collaborazione e consultazione tra studenti.

Completano il quadro funzioni di digitalizzazione (image-to-PDF) e sezioni opzionali (aggiornamenti futuri) su elettronica, reti logiche e indirizzamento IP.

### 1.2 Scopo
Lo scopo principale del progetto è creare un ambiente digitale unico e centralizzato in grado di riunire gli strumenti più utili per la formazione e l’attività quotidiana di uno studente o di un giovane ingegnere. La soluzione intende:
* Ridurre la frammentazione tra applicazioni (calcolo, scrittura, condivisione, consultazione);
* Offrire un’esperienza integrata, accessibile e personalizzabile;
* Favorire la collaborazione tra studenti attraverso la condivisione geolocalizzata.

### 1.3 Obiettivi di progetto
1. Fornire strumenti di calcolo e analisi intuitivi a supporto delle discipline scientifiche e ingegneristiche.
2. Offrire un ambiente di scrittura tramite editor LaTeX e funzioni di gestione/archiviazione degli appunti.
3. Integrare un cloud con geotag per facilitare la condivisione di risorse tra studenti della stessa area geografica o corso di studi.
4. Semplificare la digitalizzazione del materiale cartaceo mediante conversione di immagini in documenti PDF.
5. Ampliare progressivamente il ventaglio di funzionalità (finanza, statistica, elettronica, reti, etc.) per coprire le esigenze degli studenti.

### 1.4 Target
Il target principale comprende studenti di ingegneria, ma è più in generale rivolto agli indirizzi del settore STEM. La piattaforma è anche rivolta a giovani professionisti che necessitano di uno strumento pratico, flessibile e orientato sia al lavoro tecnico sia alla collaborazione accademica.

La filosofia ispiratrice è quella del *peer-to-peer*: un prodotto ideato e costruito da studenti per studenti, capace di interpretare in modo autentico esigenze reali e quotidiane.

---

## 2. Funzionalità

### 2.1 Implementazioni
* **Funzionalità di registrazione e login:** Sistema di autenticazione, mediante il quale è possibile accedere e condividere i propri dati personali, quali appunti e documenti vari.
* **Cloud integrato:** Meccanismo di salvataggio e condivisione dei progetti/appunti tramite chiave univoca, per collaborare con colleghi e studenti. Le risorse condivise possono essere ricercate e filtrate.
* **Blocchi di calcolo:** Modulo per operazioni automatiche su matrici, integrali e derivate, calcoli di probabilità, strumenti di finanza di base, ecc.
* **Integrazione con API esterne:** Supporto a servizi terzi per la generazione automatica di grafici (es. integrazione con motori tipo Wolfram Alpha), al fine di potenziare le capacità di visualizzazione e analisi senza appesantire l’applicazione.
* **Blocco note:** Spazio dedicato ad annotazioni, schizzi, formule rapide e appunti durante studio o lavoro.
  > *Nota bene:* non si prevede l’implementazione di un sistema completo di annotazioni grafiche (penna, gomma, lazo, etc.) per evitare di introdurre un sotto-sistema complesso.
* **Editor LaTeX (incorporato nel blocco note):** Editor orientato alla scrittura tecnica, nel quale il rendering di LaTeX è gestito in modo nativo in Dart, garantendo una visualizzazione rapida tramite package `flutter_tex`. In una possibile configurazione freemium, la versione base offre la visualizzazione e la gestione dei sorgenti.

### 2.2 Estensioni (fattibilità in analisi)
* **Supporto IA:** Funzioni di assistenza basate su IA per ottenere riassunti, spiegazioni mirate o domande generate automaticamente a partire da un testo fornito dall’utente, con l’intento di velocizzare lo studio.
* **Sezione libreria:** Caricamento e consultazione rapida di libri, appunti e dispense in formato digitale. I contenuti sono accessibili in locale (offline) e/o via cloud, a seconda delle preferenze e dei vincoli del contesto d’uso.
* **Visualizzazione su mappa:** Il materiale caricato su cloud è geotaggato e reso disponibile su mappa mediante un’interfaccia dedicata. La visualizzazione real-time e l’analisi per area favoriscono una migliore condivisione del materiale tra gli studenti/colleghi.
* **Convertitore di formato (JPG/PNG to PDF):** Strumento interno per convertire immagini in documenti PDF, utile per digitalizzare appunti, scannerizzare esercizi e consolidare in un unico file stampabile o condivisibile.