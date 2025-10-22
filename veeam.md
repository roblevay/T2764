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
- Slå på **Application-Aware (VSS)** för konsistens.  
- Slå av **Process/Backup SQL transaction logs** (ingen logghantering i Veeam).  
- Aktivera **Copy-only** för FULL – påverkar inte differentialbasen.

#### Återställning
- **Databas-PITR:** använd SQL-kedjan  
  (`FULL → DIFF → LOG`).
- **Hel maskin/volym:** återställ Veeam-imagen, starta SQL och lägg därefter på SQL-kedjan.

**Fördelar:**  
✅ Klassisk, förutsägbar SQL-kedja  
✅ Lätt att verifiera med `RESTORE VERIFYONLY` och `DBCC`

**Nackdelar:**  
⚠️ Två system att övervaka (men tydligt avgränsade roller)

---

### B) Veeam-ledd strategi *(enkelt när allt ska ligga i Veeam)*

**Princip:**  
Veeam sköter FULL/Diff (om du använder det) och LOG-backuper via Application-Aware Processing.  
SQL Agent-jobb för LOG stängs av.

#### Veeam-jobb
- **Application-Aware Processing:** På  
- **Transaktionslogg-backup:** Aktiverad, välj intervall (t.ex. var 15:e minut)  
- **Retention:** Enligt policy (t.ex. syntetiska fulla)

#### SQL Agent-jobb
- Inga LOG-jobb – stäng av eller ta bort.
- Ad hoc `COPY_ONLY FULL` kan användas vid test/verifiering (inte regelbundet).

#### Återställning
- Använd **Veeam Explorer for Microsoft SQL**  
  → punkt-i-tid-återställning direkt från Veeam.

**Fördelar:**  
✅ En enda “pane of glass”  
✅ Enkel hantering av hela kedjan  

**Nackdelar:**  
⚠️ Du förlitar dig helt på Veeam för finmaskig SQL-återställning

---

## ⚠️ Viktiga detaljer och fallgropar

- **`COPY_ONLY` gäller främst FULL.**  
  Det “sekundära” systemet (oftast Veeam) ska använda `COPY_ONLY FULL`.

- **Transaktionsloggar:**  
  Endast *ett* system ska ta “riktiga” LOG-backuper (som trunkerar loggen).  
  Undvik ad hoc `COPY_ONLY LOG` i drift.

- **Recovery model:**  
  För punkt-i-tid krävs `FULL` eller `BULK_LOGGED`.  
  `SIMPLE` → inga LOG-backuper (använd då diff + täta fulla).

- **Always On Availability Groups:**  
  - Låt ett system ta LOG-backuper enligt AG-preferenser.  
  - I Veeam: välj “Backup from preferred replica”.  
  - Ta inte parallella LOG-backuper från olika repliker/system.

- **Underhåll:**  
  Kör `DBCC CHECKDB` i SQL-jobb – Veeam ersätter inte detta.

- **Kompression & kryptering:**  
  SQL- och Veeam-komprimering ger CPU-last → välj ett av dem.  
  Kryptering bör vara konsekvent.

- **Testa återställning regelbundet:**  
  Fil-/imagenivå och PITR, t.ex. kvartalsvis.

---

## 🧩 Exempel på schema (SQL-ledd)

**SQL Agent-jobb (förenklat):**

```sql
-- FULL (söndag 02:00)
BACKUP DATABASE MyDb 
TO DISK = 'X:\Backups\MyDb_full_YYYYMMDD.bak'
WITH INIT, COMPRESSION, STATS = 5;

-- DIFFERENTIAL (mån–lör 02:00)
BACKUP DATABASE MyDb 
TO DISK = 'X:\Backups\MyDb_diff_YYYYMMDD.bak'
WITH DIFFERENTIAL, INIT, COMPRESSION, STATS = 5;

-- LOG (var 15:e minut)
BACKUP LOG MyDb 
TO DISK = 'X:\Backups\MyDb_log_YYYYMMDD_HHMM.trn'
WITH INIT, COMPRESSION, STATS = 5;
