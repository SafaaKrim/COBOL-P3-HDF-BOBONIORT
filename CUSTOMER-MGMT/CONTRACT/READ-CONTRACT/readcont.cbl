      ****************************************************************** 
       IDENTIFICATION DIVISION.
       PROGRAM-ID. readcont.
       AUTHOR. Martial.

      ******************************************************************

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  SC-MENU-RETURN          PIC X(01).
       01  SC-MODIFY-CONTRACT      PIC X(01).

       01  WS-REIM-NUM             PIC X(10).  
       01  WS-CREATE-DATE.
           03 WS-CD-YEAR           PIC X(04).
           03 SEPARATOR1               PIC X(01).
           03 WS-CD-MONTH          PIC X(02).
           03 SEPARATOR2               PIC X(01).
           03 WS-CD-DAY            PIC X(02).
       01  WS-DOCTOR               PIC X(03). 
       01  WS-PARMEDICAL           PIC X(03).      
       01  WS-HOSPITAL             PIC X(03). 
       01  WS-S-GLASSES            PIC X(03). 
       01  WS-P-GLASSES            PIC X(03). 
       01  WS-MOLAR                PIC X(03). 
       01  WS-NON-MOLAR            PIC X(03). 
       01  WS-DESCALINGS           PIC X(03).

       01  WS-CUSTOMER-NAME        PIC X(45).

       01  WS-CUSTOMER.
           03 WS-CUS-UUID          PIC X(36).
           03 WS-CUS-GENDER        PIC X(10).
           03 WS-CUS-LASTNAME      PIC X(20).
           03 WS-CUS-FIRSTNAME     PIC X(20).
           03 WS-CUS-ADRESS1       PIC X(50).
           03 WS-CUS-ADRESS2       PIC X(50).
           03 WS-CUS-ZIPCODE       PIC X(15).
           03 WS-CUS-TOWN          PIC X(30).
           03 WS-CUS-COUNTRY       PIC X(20).
           03 WS-CUS-PHONE	       PIC X(10).
           03 WS-CUS-MAIL	       PIC X(50).
           03 WS-CUS-BIRTH-DATE    PIC X(10).           
           03 WS-CUS-DOCTOR	       PIC X(20).
           03 WS-CUS-CODE-SECU     PIC 9(15).
           03 WS-CUS-CODE-IBAN     PIC X(34).
           03 WS-CUS-NBCHILDREN    PIC X(03).
           03 WS-CUS-COUPLE        PIC X(05).
           03 WS-CUS-CREATE-DATE   PIC X(10).
           03 WS-CUS-UPDATE-DATE   PIC X(10).
           03 WS-CUS-CLOSE-DATE    PIC X(10).
           03 WS-CUS-ACTIVE	       PIC X(01).

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DBNAME   PIC  X(11) VALUE 'boboniortdb'.
       01  USERNAME PIC  X(05) VALUE 'cobol'.
       01  PASSWD   PIC  X(10) VALUE 'cbl85'.
       
       01  SQL-CUS-REIMBURSEMENT.
           03 SQL-REIM-NUM    PIC X(10).
           03 SQL-CREATE-DATE PIC X(10).
           03 SQL-DOCTOR      PIC 9(03).
           03 SQL-PARMEDICAL  PIC 9(03).
           03 SQL-HOSPITAL    PIC 9(03).
           03 SQL-S-GLASSES   PIC 9(03).
           03 SQL-P-GLASSES   PIC 9(03).
           03 SQL-MOLAR       PIC 9(03).   
           03 SQL-NON-MOLAR   PIC 9(03).
           03 SQL-DESCALINGS  PIC 9(03).
       EXEC SQL END DECLARE SECTION END-EXEC.
       EXEC SQL INCLUDE SQLCA END-EXEC. 

       LINKAGE SECTION.
       01  LK-CUSTOMER.
           03 LK-CUS-UUID          PIC X(36).
           03 LK-CUS-GENDER        PIC X(10).
           03 LK-CUS-LASTNAME      PIC X(20).
           03 LK-CUS-FIRSTNAME     PIC X(20).
           03 LK-CUS-ADRESS1       PIC X(50).
           03 LK-CUS-ADRESS2       PIC X(50).
           03 LK-CUS-ZIPCODE       PIC X(15).
           03 LK-CUS-TOWN          PIC X(30).
           03 LK-CUS-COUNTRY       PIC X(20).
           03 LK-CUS-PHONE	       PIC X(10).
           03 LK-CUS-MAIL	       PIC X(50).
           03 LK-CUS-BIRTH-DATE    PIC X(10).           
           03 LK-CUS-DOCTOR	       PIC X(20).
           03 LK-CUS-CODE-SECU     PIC 9(15).
           03 LK-CUS-CODE-IBAN     PIC X(34).
           03 LK-CUS-NBCHILDREN    PIC 9(03).
           03 LK-CUS-COUPLE        PIC X(05).
           03 LK-CUS-CREATE-DATE   PIC X(10).
           03 LK-CUS-UPDATE-DATE   PIC X(10).
           03 LK-CUS-CLOSE-DATE    PIC X(10).
           03 LK-CUS-ACTIVE	       PIC X(01).  
      
       SCREEN SECTION.
           COPY 'screen-read-contract.cpy'.
      
      ******************************************************************

       PROCEDURE DIVISION USING LK-CUSTOMER. 

       0000-START-MAIN.
           EXEC SQL
               CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME 
           END-EXEC.

           PERFORM 1000-PREPARE-SCREEN-START 
              THRU END-1000-PREPARE-SCREEN.

           PERFORM 2000-SELECT-CONTRACT 
              THRU END-2000-SELECT-CONTRACT.

           PERFORM 3000-START-FETCH 
              THRU END-3000-FETCH.

           ACCEPT SCREEN-READ-CONTRACT.
       0000-END-MAIN.  
           EXEC SQL COMMIT WORK END-EXEC.
           EXEC SQL DISCONNECT ALL END-EXEC.
           GOBACK.

      ******************************************************************    
      *    [RD] Déplace le Customer de la linkage vers celui de la WS  *
      *    et créer un STRIN Nom Prénom NumSécu pour SCREEN SECTION.   *
      ******************************************************************
       1000-PREPARE-SCREEN-START.
           MOVE LK-CUSTOMER TO WS-CUSTOMER.

           STRING FUNCTION TRIM (WS-CUS-FIRSTNAME)
                  SPACE 
                  FUNCTION TRIM (WS-CUS-LASTNAME)
                  SPACE 
                  WS-CUS-CODE-SECU 
           DELIMITED BY SIZE 
           INTO WS-CUSTOMER-NAME.  
       END-1000-PREPARE-SCREEN.
           EXIT.

      ******************************************************************
      ****************************************************************** 
       2000-SELECT-CONTRACT.
           EXEC SQL
               DECLARE CRSUUID CURSOR FOR
               SELECT REIMBURSEMENT_NUM,
                      REIMBURSEMENT_CREATE_DATE, 
                      REIMBURSEMENT_DOCTOR,
                      REIMBURSEMENT_PARMEDICAL,
                      REIMBURSEMENT_HOSPITAL,
                      REIMBURSEMENT_SINGLE_GLASSES,
                      REIMBURSEMENT_PROGRESSIVE_GLASSES,
                      REIMBURSEMENT_MOLAR_CROWNS,
                      REIMBURSEMENT_NON_MOLAR_CROWNS,
                      REIMBURSEMENT_DESCALINGS
               FROM CUSTOMER_REIMBURSEMENT
               WHERE UUID_CUSTOMER = :WS-CUS-UUID
           END-EXEC.
       END-2000-SELECT-CONTRACT.
           EXIT.

      ******************************************************************
      ******************************************************************     
       3000-START-FETCH.
           EXEC SQL  
               OPEN CRSUUID  
           END-EXEC.

           PERFORM UNTIL SQLCODE = 100
               EXEC SQL
                   FETCH CRSUUID
                   INTO :SQL-REIM-NUM, 
                        :SQL-CREATE-DATE, 
                        :SQL-DOCTOR, 
                        :SQL-PARMEDICAL, 
                        :SQL-HOSPITAL, 
                        :SQL-S-GLASSES, 
                        :SQL-P-GLASSES, 
                        :SQL-MOLAR, 
                        :SQL-NON-MOLAR, 
                        :SQL-DESCALINGS
               END-EXEC

               EVALUATE SQLCODE
                   WHEN ZERO
                       PERFORM 3100-START-HANDLE THRU END-3100-HANDLE
                   WHEN 100
                       DISPLAY 'NO MORE ROWS IN CURSOR RESULT SET'
                   WHEN OTHER
                       DISPLAY 'ERROR FETCHING CURSOR CRSUUID:'
                       SPACE SQLCODE
               END-EVALUATE
           END-PERFORM.

           EXEC SQL  
               CLOSE CRSUUID   
           END-EXEC.
       END-3000-FETCH.
           EXIT.

      ******************************************************************
      ****************************************************************** 
       3100-START-HANDLE.
           MOVE SQL-REIM-NUM    TO WS-REIM-NUM.
           MOVE SQL-CREATE-DATE TO WS-CREATE-DATE. 
           MOVE SQL-DOCTOR      TO WS-DOCTOR.     
           MOVE SQL-PARMEDICAL  TO WS-PARMEDICAL.
           MOVE SQL-HOSPITAL    TO WS-HOSPITAL.
           MOVE SQL-S-GLASSES   TO WS-S-GLASSES
           MOVE SQL-P-GLASSES   TO WS-P-GLASSES.
           MOVE SQL-MOLAR       TO WS-MOLAR.
           MOVE SQL-NON-MOLAR   TO WS-NON-MOLAR.
           MOVE SQL-DESCALINGS  TO WS-DESCALINGS.
       END-3100-HANDLE.
           EXIT.
