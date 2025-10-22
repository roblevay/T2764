# Backupstrategier för SQL Server och Veeam

## 🧭 Grundprinciper (viktigt)

- **Blanda aldrig två system som tar transaktionslogg-backuper samtidigt.**  
  Endast *ett* system ska ta löpande LOG-backuper – annars får du luckor i LSN-kedjan och tappar möjligheten till point-in-time-återställning (PITR).

- **Om Veeam tar FULL-backuper för SQL**, se till att de är `COPY_ONLY`  
  (så rubbar de inte differentialbasen för dina inbyggda `DIFFERENTIAL`-backuper).

- **Välj “ägare” av backupstrategin:**  
  - Alternativ 1: SQL Server (SQL Agent / underhållsplan) är primär.  
    Veeam är sekundär (image + copy-only).  
  - Alternativ 2: Veeam är primär för full/diff/log.  
    SQL Agent-jobb för LOG stängs då av.

---

## ⚙️ Två beprövade upplägg

### A) SQL-ledd strategi *(rekommenderas för klassisk .bak-kedja)*

**Princip:**  
SQL Server sköter FULL / DIFF / LOG.  
Veeam tar image-backup (VM/OS) och COPY_ONLY FULL för extra skydd.

#### SQL Agent-jobb
| Typ | Frekvens | Kommentar |
|------|-----------|-----------|
| FULL | 1 gång/vecka (t.ex. söndag natt) | Basen för differ |
| DIFFERENTIAL | Dagligen (mån–lör) | Förkortar återställning |
| LOG | Var 5–15:e minut | Beroende på RPO |

#### Veeam-jobb (Application-Aware Processing **på**)
- Slå på
