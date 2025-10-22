Grundprinciper (viktigt)





Blanda aldrig två system som tar transaktionslogg-backuper samtidigt. Endast ett system ska ta löpande LOG-backuper, annars får du luckor i LSN-kedjan och tappar möjligheten till point-in-time-återställning.
Om Veeam tar FULL-backuper för SQL, se till att de är COPY_ONLY (så rubbar de inte differentialbasen för dina inbyggda DIFFERENTIAL-backuper).
Välj "ägare" av backupstrategin: antingen låter du SQL Server (SQL Agent/onderhållsplan) vara primär och Veeam sekundär (image + copy-only), eller så låter du Veeam vara primär för full/diff/log – och du stänger då av dina SQL Agent-jobb för LOG.










Två beprövade upplägg







A) SQL-ledd strategi (rekommenderas när du vill ha klassisk .bak-kedja)





SQL Server sköter FULL/DIFF/LOG. Veeam tar image-backup (VM/OS) och COPY_ONLY FULL för extra skydd.



SQL Agent-jobb
FULL: 1 gång/vecka (t.ex. söndag natt).
DIFFERENTIAL: dagligen (mån–lör).
LOG: var 5–15:e minut (beroende på RPO).

Veeam-jobb (Application-Aware Processing på)
Slå på Application-Aware (VSS) för konsistens.
Slå av "Process/Backup SQL transaction logs" (ingen logghantering i Veeam).
Ställ in att FULL blir COPY_ONLY (Veeam gör detta vid AAP om du aktiverar "Copy only"). Då påverkas inte differentialbasen.

Återställning
För databaspunkt-i-tid: använd SQL-kedjan (.bak: FULL → DIFF → LOG).
För hel maskin/volym: återställ Veeam-imagen, starta SQL, och lägg därefter på SQL-kedjan vid behov.





Fördelar: Klassisk, förutsägbar SQL-kedja, lätt att verifiera med RESTORE VERIFYONLY och DBCC.

Nackdelar: Två system att övervaka (men rollerna är väl avgränsade).









B) Veeam-ledd strategi (enkelt när allt ska ligga i Veeam)





Veeam sköter FULL/Diff (om du använder det) och LOG-backuper via AAP. SQL Agent-jobb för LOG stängs av.



Veeam-jobb
Application-Aware Processing på.
Aktivera transaktionslogg-backup i Veeam och sätt intervall (ex. var 15:e minut).
Eventuella "syntetiska" fulla samt retention enligt dina mål.

SQL Agent-jobb
Inga LOG-jobb (stäng av/ta bort).
Du kan ha ad hoc COPY_ONLY FULL ibland för t.ex. test/verifiering – men undvik regelbundna "vanliga" FULL/DIFF så du inte krockar.

Återställning
Använd Veeam Explorer for Microsoft SQL för databaspunkt-i-tid (den syr ihop Veeam-full och Veeam-loggar).





Fördelar: En enda pane of glass, Veeam sköter kedjan och punkt-i-tid.

Nackdelar: Du förlitar dig på Veeam även för finmaskig SQL-återställning.









Viktiga detaljer och fallgropar





COPY_ONLY gäller framför allt FULL. Använd COPY_ONLY på fulla som tas av det "sekundära" systemet (ofta Veeam) så att dina DIFFERENTIAL fortsätter bygga på senaste icke-copy-only FULL från SQL.
Transaktionsloggar: Låt endast ett system ta "riktiga" LOG-backuper (de som trimmar/trunkerar loggen). "Ad hoc" COPY_ONLY-LOG bör du undvika i drift; det kan förvirra övervakning och loggtillväxt.
Recovery model: För punkt-i-tid krävs FULL (eller BULK_LOGGED) recovery model. I SIMPLE finns inga LOG-backuper – då är diffs + täta fulla den väg du har.
Always On Availability Groups:
Låt ett system ta LOG-backuper enligt AG-preferenser.
I Veeam: "Backup from preferred replica" och respektera AG-prioritet.
Ta inte parallella LOG-backuper från olika repliker/system.

Underhåll: Kör helst DBCC CHECKDB i SQL-jobb (Veeam ersätter inte detta).
Kompression & kryptering: SQL-komprimering och Veeam-komprimering kan båda ge CPU-last. Välj var du vill komprimera. Kryptering bör vara konsekvent.
Testa återställning regelbundet (både fil-/imagenivå och databaspunkt-i-tid). Sätt gärna upp en rutin (t.ex. kvartalsvis).










Exempel på schema (SQL-ledd)





SQL Agent jobb (T-SQL-kommandon, förenklat):

-- FULL (söndag 02:00)

BACKUP DATABASE MyDb TO DISK = 'X:\Backups\MyDb_full_YYYYMMDD.bak'

  WITH INIT, COMPRESSION, STATS = 5;



-- DIFFERENTIAL (mån–lör 02:00)

BACKUP DATABASE MyDb TO DISK = 'X:\Backups\MyDb_diff_YYYYMMDD.bak'

  WITH DIFFERENTIAL, INIT, COMPRESSION, STATS = 5;



-- LOG (var 15:e minut)

BACKUP LOG MyDb TO DISK = 'X:\Backups\MyDb_log_YYYYMMDD_HHMM.trn'

  WITH INIT, COMPRESSION, STATS = 5;

Veeam-jobb:



Application-Aware: On
Backup SQL transaction logs: Off
Copy-only full: On










Snabb checklista





Bestäm "ägare": SQL eller Veeam för LOG-backuper.
Om Veeam är sekundär: Copy-only FULL i Veeam, ingen Veeam-LOG.
Om Veeam är primär: Avaktivera SQL-LOG-jobb.
Säkerställ FULL recovery model där du behöver PITR.
Dokumentera kedjor och återställningssteg.
Testa återställning regelbundet.
