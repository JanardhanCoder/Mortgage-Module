namespace MortgageForUS.MortgageForUS;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;

codeunit 60012 "Partial Pre-Settlement Mgt"
{
    procedure PrepareAndOpenJournal(var Loan: Record "US Mortgage Agreement Header")
    var
        GenJnlLine: Record "Gen. Journal Line";
        Batch: Record "Gen. Journal Batch";

    begin

        // ---------------- VALIDATIONS ----------------
        if Loan."Pre-Settlement Amount" <= 0 then
            Error('Pre-Settlement Amount must be greater than zero.');

        if Loan."Pre-Settlement Date" = 0D then
            Error('Pre-Settlement Date must be specified.');

        if Loan."Pre-Settlement Option" = Loan."Pre-Settlement Option"::Select then
            Error('Pre-Settlement Option must be selected.');

        if Loan."Pre-Settlement Amount" > Loan."Outstanding Principal" then
            Error('Amount cannot exceed outstanding principal.');

        if Loan."Pre-Settlement Posted" then
            Error('Pre-Settlement already posted.');


        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');
        GenJnlLine.DeleteAll();
        // Store intent only (no EMI logic here)
        Loan.Modify(true);

        // Create journal and open for review
        CreateJournalAndOpen(Loan);
    end;

    local procedure CreateJournalAndOpen(Loan: Record "US Mortgage Agreement Header")
    var
        GenJnlLine: Record "Gen. Journal Line";
        NoSeriesMgt: Codeunit "No. Series";
        GenJnlBatch: Record "Gen. Journal Batch";
        Posting: Record "US Mortgage Posting Group";
        NewDocNo: Code[20];
        InterestAmount: Decimal;
        PrincipalAmount: Decimal;
        LineNo: Integer;
    begin
        // Get Document No
        GenJnlBatch.Get('GENERAL', 'DEFAULT');
        NewDocNo := NoSeriesMgt.PeekNextNo(GenJnlBatch."No. Series");

        Posting.Get('MG');

        // ---------------- CALCULATE SPLIT ----------------
        InterestAmount := CalculatePreSettlementInterest(Loan);
        PrincipalAmount := Loan."Pre-Settlement Amount" - InterestAmount;

        Message('interest amount %1', InterestAmount);
        if InterestAmount > Loan."Pre-Settlement Amount" then
            Error('Pre-settlement amount is less than interest due.');

        LineNo := 10000;

        // ================= INTEREST LINE =================
        Message('interest amount %1', InterestAmount);
        if InterestAmount > 0 then begin
            GenJnlLine.Init();
            GenJnlLine.Validate("Journal Template Name", 'GENERAL');
            GenJnlLine.Validate("Journal Batch Name", 'DEFAULT');
            GenJnlLine."Line No." := LineNo;

            GenJnlLine."Document No." := NewDocNo;
            GenJnlLine."Posting Date" := Loan."Pre-Settlement Date";
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;

            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
            GenJnlLine."Account No." := Loan."Borrower Customer No.";
            GenJnlLine.Amount := -InterestAmount;

            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            GenJnlLine."Bal. Account No." := Posting."Interest Receivable";

            GenJnlLine.Description := 'Pre-Settlement Interest';
            GenJnlLine."US Mortgage No." := Loan."Loan No.";

            GenJnlLine.Insert(true);
        end;

        // ================= PRINCIPAL LINE =================
        if PrincipalAmount > 0 then begin
            LineNo += 10000;

            GenJnlLine.Init();
            GenJnlLine.Validate("Journal Template Name", 'GENERAL');
            GenJnlLine.Validate("Journal Batch Name", 'DEFAULT');
            GenJnlLine."Line No." := LineNo;

            GenJnlLine."Document No." := NewDocNo;
            GenJnlLine."Posting Date" := Loan."Pre-Settlement Date";
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;

            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
            GenJnlLine."Account No." := Loan."Borrower Customer No.";
            GenJnlLine.Amount := -PrincipalAmount;

            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            GenJnlLine."Bal. Account No." := Posting."Loan Principal Receivable";

            GenJnlLine.Description := 'Pre-Settlement Principal';
            GenJnlLine."US Mortgage No." := Loan."Loan No.";

            GenJnlLine.Insert(true);
        end;

        // ---------------- OPEN JOURNAL ----------------
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');

        Page.Run(Page::"General Journal", GenJnlLine);
    end;


    local procedure CalculatePreSettlementInterest(Loan: Record "US Mortgage Agreement Header"): Decimal
    var
        Schedule: Record "US Mortgage Schedule Line";
        Interest: Decimal;
    begin
        Interest := 0;

        Schedule.SetRange("Loan No.", Loan."Loan No.");
        Schedule.SetRange(Status, Schedule.Status::Pending);
        Schedule.SetRange(closed, false);
        Schedule.SetFilter("Due Date", '..%1', Loan."Pre-Settlement Date");
        if Schedule.FindSet() then
            repeat
                Interest += Schedule."Interest Amount";
            until Schedule.Next() = 0;

        exit(Interest);
    end;

}

// it's also working and bellow code better
// namespace MortgageForUS.MortgageForUS;
// using Microsoft.Finance.GeneralLedger.Journal;

// codeunit 60012 "Partial Pre-Settlement Mgt"
// {
//     procedure PrepareAndOpenJournal(
//         var Loan: Record "US Mortgage Agreement Header")
//     begin
//         // ---------------- VALIDATIONS ----------------
//         if Loan."Pre-Settlement Amount" <= 0 then
//             Error('Pre-Settlement Amount must be greater than zero.');

//         if Loan."Pre-Settlement Date" = 0D then
//             Error('Pre-Settlement Date must be specified.');

//         if Loan."Pre-Settlement Option" = Loan."Pre-Settlement Option"::Select then
//             Error('Pre-Settlement Option must be selected.');

//         if Loan."Pre-Settlement Amount" > Loan."Outstanding Principal" then
//             Error('Amount cannot exceed outstanding principal.');

//         if Loan."Pre-Settlement Posted" then
//             Error('Pre-Settlement already posted.');

//         // ---------------- STORE INTENT ONLY ----------------
//         Loan.Modify(true);

//         // ---------------- CREATE & OPEN JOURNAL ----------------
//         CreateJournalAndOpen(Loan);
//     end;

//     local procedure CreateJournalAndOpen(
//         Loan: Record "US Mortgage Agreement Header")
//     var
//         GenJnlLine: Record "Gen. Journal Line";
//     begin
//         GenJnlLine.Init();
//         GenJnlLine.Validate("Journal Template Name", 'GENERAL');
//         GenJnlLine.Validate("Journal Batch Name", 'DEFAULT');

//         GenJnlLine."Posting Date" := Loan."Pre-Settlement Date";
//         GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;

//         GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
//         GenJnlLine."Account No." := Loan."Borrower Customer No.";

//         GenJnlLine.Amount := -Loan."Pre-Settlement Amount";

//         GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
//         GenJnlLine."Bal. Account No." := GetPreSettlementGL();

//         // Tracking
//         GenJnlLine."US Mortgage No." := Loan."Loan No.";

//         GenJnlLine.Insert(true);

//         // Open journal for review
//         GenJnlLine.Reset();
//         GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
//         GenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');

//         Page.Run(Page::"General Journal", GenJnlLine);
//     end;

//     local procedure GetPreSettlementGL(): Code[20]
//     begin
//         // Replace with valid GL Account
//         exit('10100');
//     end;
// }





//It's Working
// {
//     procedure PartialPreSettlementWithJournal(
//         var LoanHeader: Record "US Mortgage Agreement Header";
//         PartialAmount: Decimal;
//         SettlementDate: Date;
//         Option: Enum "Pre-Settlement Option")
//     var
//         Schedule: Record "US Mortgage Schedule Line";
//         RemainingPrincipal: Decimal;
//     begin
//         // ---------------- VALIDATIONS ----------------
//         if PartialAmount <= 0 then
//             Error('Partial settlement amount must be greater than zero.');

//         if SettlementDate = 0D then
//             Error('Settlement Date must be specified.');

//         LoanHeader.TestField("Outstanding Principal");

//         if PartialAmount > LoanHeader."Outstanding Principal" then
//             Error(
//               'Partial amount (%1) cannot exceed outstanding principal (%2).',
//               PartialAmount, LoanHeader."Outstanding Principal");

//         // ======================================================
//         // 🔹 CREATE JOURNAL (ONLY CREATION – NO POSTING)
//         // ======================================================
//         CreatePartialSettlementJournal(
//             LoanHeader,
//             PartialAmount,
//             SettlementDate);

//         // ---------------- APPLY PAYMENT ----------------
//         RemainingPrincipal :=
//             LoanHeader."Outstanding Principal" - PartialAmount;

//         LoanHeader."Outstanding Principal" := RemainingPrincipal;
//         LoanHeader.Modify(true);

//         // ---------------- CANCEL FUTURE EMIs ----------------
//         Schedule.Reset();
//         Schedule.SetRange("Loan No.", LoanHeader."Loan No.");
//         Schedule.SetFilter("Due Date", '>%1', SettlementDate);
//         Schedule.SetRange(Status, Schedule.Status::Pending);

//         if Schedule.FindSet() then
//             repeat
//                 Schedule.Status := Schedule.Status::Cancelled;
//                 Schedule.Modify(true);
//             until Schedule.Next() = 0;

//         // ---------------- REGENERATE SCHEDULE ----------------
//         case Option of
//             Option::ReduceTenure:
//                 CreateReducedTenureSchedule(
//                     LoanHeader,
//                     SettlementDate,
//                     RemainingPrincipal);

//             Option::KeepTenure:
//                 CreateReducedEMISchedule(
//                     LoanHeader,
//                     SettlementDate,
//                     RemainingPrincipal);
//         end;
//     end;


//     // 🔹 CREATE JOURNAL LINE (NO POSTING)
//     // ======================================================
//     local procedure CreatePartialSettlementJournal(
//         LoanHeader: Record "US Mortgage Agreement Header";
//         PartialAmount: Decimal;
//         SettlementDate: Date)
//     var
//         GenJnlLine: Record "Gen. Journal Line";
//     begin
//         GenJnlLine.Init();
//         GenJnlLine.Validate("Journal Template Name", 'GENERAL');
//         GenJnlLine.Validate("Journal Batch Name", 'DEFAULT');

//         GenJnlLine."Line No." :=
//             GetNextJnlLineNo('GENERAL', 'DEFAULT');

//         GenJnlLine.Validate("Posting Date", SettlementDate);
//         GenJnlLine.Validate("Document Date", SettlementDate);
//         GenJnlLine.Validate(
//             "Document Type",
//             GenJnlLine."Document Type"::Payment);

//         GenJnlLine.Validate("Document No.", LoanHeader."Loan No.");
//         GenJnlLine.Description := 'Partial Pre-Settlement';

//         // Debit Bank
//         GenJnlLine.Validate(
//             "Account Type",
//             GenJnlLine."Account Type"::"Bank Account");
//         GenJnlLine.Validate(
//             "Account No.",
//             LoanHeader."Bank Account No.");

//         GenJnlLine.Validate(Amount, PartialAmount);

//         // Credit Customer / Loan Control
//         GenJnlLine.Validate(
//             "Bal. Account Type",
//             GenJnlLine."Bal. Account Type"::Customer);
//         GenJnlLine.Validate(
//             "Bal. Account No.",
//             LoanHeader."Borrower Customer No.");

//         // Loan reference
//         GenJnlLine."US Mortgage No." := LoanHeader."Loan No.";

//         GenJnlLine.Insert(true);
//     end;

//     // ======================================================
//     // REDUCE TENURE (EMI SAME, TENURE SHORTER)
//     // ======================================================
//     local procedure CreateReducedTenureSchedule(
//      LoanHeader: Record "US Mortgage Agreement Header";
//      SettlementDate: Date;
//      RemainingPrincipal: Decimal)
//     var
//         NewLine: Record "US Mortgage Schedule Line";
//         EMI: Decimal;
//         InterestRate: Decimal;
//         InterestAmount: Decimal;
//         PrincipalAmount: Decimal;
//         DueDate: Date;
//         LineNo: Integer;
//     begin
//         EMI := LoanHeader."EMI Amount";
//         InterestRate := LoanHeader."Interest Rate %";

//         if EMI <= 0 then
//             Error('EMI Amount must be greater than zero.');

//         if InterestRate <= 0 then
//             Error('Interest Rate must be greater than zero.');

//         DueDate := CalcDate('<1M>', SettlementDate);
//         LineNo := GetLastLineNo(LoanHeader."Loan No.");

//         while RemainingPrincipal > 0 do begin
//             LineNo += 10000;

//             // 1️⃣ Calculate monthly interest
//             InterestAmount :=
//                 Round(RemainingPrincipal * (InterestRate / 100) / 12, 0.01);

//             // 2️⃣ Calculate principal portion
//             if RemainingPrincipal >= (EMI - InterestAmount) then
//                 PrincipalAmount := EMI - InterestAmount
//             else
//                 PrincipalAmount := RemainingPrincipal;

//             NewLine.Init();
//             NewLine."Loan No." := LoanHeader."Loan No.";
//             NewLine."Line No." := LineNo;
//             NewLine."Due Date" := DueDate;

//             NewLine."Interest Rate %" := InterestRate;
//             NewLine."Interest Amount" := InterestAmount;
//             NewLine."Principal Amount" := PrincipalAmount;

//             // 3️⃣ EMI = Principal + Interest
//             NewLine."EMI Amount" := PrincipalAmount + InterestAmount;

//             NewLine."Paid Principal" := 0;
//             NewLine.Status := NewLine.Status::Pending;
//             NewLine.Insert(true);

//             // 4️⃣ Reduce balance
//             RemainingPrincipal -= PrincipalAmount;

//             DueDate := CalcDate('<1M>', DueDate);
//         end;
//     end;

//     // ======================================================
//     // REDUCE EMI (TENURE SAME, EMI REDUCED)
//     // ======================================================
//     local procedure CreateReducedEMISchedule(
//         LoanHeader: Record "US Mortgage Agreement Header";
//         SettlementDate: Date;
//         RemainingPrincipal: Decimal)
//     var
//         OldLine: Record "US Mortgage Schedule Line";
//         NewLine: Record "US Mortgage Schedule Line";
//         EMIcount: Integer;
//         NewEMI: Decimal;
//         LineNo: Integer;
//     begin
//         OldLine.Reset();
//         OldLine.SetRange("Loan No.", LoanHeader."Loan No.");
//         OldLine.SetFilter("Due Date", '>%1', SettlementDate);
//         OldLine.SetRange(Status, OldLine.Status::Cancelled);

//         EMIcount := OldLine.Count();
//         if EMIcount = 0 then
//             Error('No EMIs available to recalculate.');

//         NewEMI := RemainingPrincipal / EMIcount;
//         LineNo := GetLastLineNo(LoanHeader."Loan No.");

//         if OldLine.FindSet() then
//             repeat
//                 LineNo += 10000;

//                 NewLine.Init();
//                 NewLine."Loan No." := LoanHeader."Loan No.";
//                 NewLine."Line No." := LineNo;
//                 NewLine."Due Date" := OldLine."Due Date";
//                 NewLine."Principal Amount" := NewEMI;
//                 NewLine."Paid Principal" := 0;
//                 NewLine.Status := NewLine.Status::Pending;
//                 NewLine.Insert(true);
//             until OldLine.Next() = 0;
//     end;

//     // ======================================================
//     // GET LAST LINE NO
//     // ======================================================
//     local procedure GetLastLineNo(LoanNo: Code[20]): Integer
//     var
//         Sched: Record "US Mortgage Schedule Line";
//     begin
//         Sched.SetRange("Loan No.", LoanNo);
//         if Sched.FindLast() then
//             exit(Sched."Line No.");
//         exit(0);
//     end;
//     // GET NEXT JOURNAL LINE NO
//     // ======================================================
//     local procedure GetNextJnlLineNo(
//         TemplateName: Code[10];
//         BatchName: Code[10]): Integer
//     var
//         GenJnlLine: Record "Gen. Journal Line";
//     begin
//         GenJnlLine.SetRange("Journal Template Name", TemplateName);
//         GenJnlLine.SetRange("Journal Batch Name", BatchName);

//         if GenJnlLine.FindLast() then
//             exit(GenJnlLine."Line No." + 10000);

//         exit(10000);
//     end;
// }


// codeunit 60012 "Partial Pre-Settlement Mgt"
// {
//     procedure PartialPreSettlementWithJournal(
//         var LoanHeader: Record "US Mortgage Agreement Header";
//         PartialAmount: Decimal;
//         SettlementDate: Date;
//         SettlementOption: Enum "Pre-Settlement Option";
//         JournalTemplateName: Code[10];
//         JournalBatchName: Code[10])
//     var
//         LoanSchedule: Record "US Mortgage Schedule Line";
//         GenJnlLine: Record "Gen. Journal Line";
//         Posting: Record "US Mortgage Posting Group";
//         OutstandingPrincipal: Decimal;
//         RemainingPrincipal: Decimal;
//         AccruedInterest: Decimal;
//         DailyInterestRate: Decimal;
//     begin
//         //---------------- VALIDATIONS ----------------
//         LoanHeader.TestField("Loan No.");
//         LoanHeader.TestField("Interest Rate %");
//         LoanHeader.TestField("Posting Group Code");

//         if PartialAmount <= 0 then
//             Error('Partial settlement amount must be greater than zero.');

//         Posting.Get(LoanHeader."Posting Group Code");

//         //---------------- CALCULATE OUTSTANDING ----------------
//         OutstandingPrincipal := 0;
//         AccruedInterest := 0;
//         DailyInterestRate := LoanHeader."Interest Rate %" / 100 / 360;

//         LoanSchedule.Reset();
//         LoanSchedule.SetRange("Loan No.", LoanHeader."Loan No.");
//         LoanSchedule.SetFilter("Due Date", '>%1', SettlementDate);

//         if LoanSchedule.FindSet() then
//             repeat
//                 OutstandingPrincipal +=
//                     LoanSchedule."Principal Amount" - LoanSchedule."Paid Principal";

//                 AccruedInterest +=
//                     (LoanSchedule."Principal Amount" - LoanSchedule."Paid Principal")
//                     * DailyInterestRate
//                     * (SettlementDate - CalcDate('<-1M>', LoanSchedule."Due Date"));
//             until LoanSchedule.Next() = 0;

//         if PartialAmount > OutstandingPrincipal then
//             Error('Partial settlement amount cannot exceed outstanding principal.');

//         RemainingPrincipal := OutstandingPrincipal - PartialAmount;

//         //---------------- CLOSE OLD FUTURE SCHEDULE ----------------
//         CloseFutureSchedules(LoanHeader, SettlementDate);

//         //---------------- CREATE NEW SCHEDULE ----------------
//         case SettlementOption of
//             SettlementOption::KeepTenure:
//                 CreateReducedEMISchedule(LoanHeader, SettlementDate, RemainingPrincipal);

//             SettlementOption::ReduceTenure:
//                 CreateReducedTenureSchedule(LoanHeader, SettlementDate, RemainingPrincipal);
//         end;

//         //---------------- JOURNAL ENTRY ----------------
//         CreateJournal(
//             LoanHeader,
//             Posting,
//             PartialAmount,
//             AccruedInterest,
//             SettlementDate,
//             JournalTemplateName,
//             JournalBatchName);
//     end;

//     //============================================================
//     local procedure CloseFutureSchedules(
//         LoanHeader: Record "US Mortgage Agreement Header";
//         SettlementDate: Date)
//     var
//         LoanSchedule: Record "US Mortgage Schedule Line";
//     begin
//         LoanSchedule.Reset();
//         LoanSchedule.SetRange("Loan No.", LoanHeader."Loan No.");
//         LoanSchedule.SetFilter("Due Date", '>%1', SettlementDate);

//         if LoanSchedule.FindSet() then
//             repeat
//                 LoanSchedule.Status := LoanSchedule.Status::Cancelled;
//                 LoanSchedule.Modify(true);
//             until LoanSchedule.Next() = 0;
//     end;

//     //============================================================
//     local procedure CreateReducedTenureSchedule(
//         LoanHeader: Record "US Mortgage Agreement Header";
//         SettlementDate: Date;
//         RemainingPrincipal: Decimal)
//     var
//         NewSchedule: Record "US Mortgage Schedule Line";
//         EMI: Decimal;
//         DueDate: Date;
//         LineNo: Integer;
//     begin
//         EMI := LoanHeader."EMI Amount";
//         DueDate := CalcDate('<1M>', SettlementDate);
//         LineNo := GetLastLineNo(LoanHeader."Loan No.");

//         while RemainingPrincipal > 0 do begin
//             LineNo += 10000;

//             NewSchedule.Init();
//             NewSchedule."Loan No." := LoanHeader."Loan No.";
//             NewSchedule."Line No." := LineNo;
//             NewSchedule."Due Date" := DueDate;

//             if RemainingPrincipal >= EMI then
//                 NewSchedule."Principal Amount" := EMI
//             else
//                 NewSchedule."Principal Amount" := RemainingPrincipal;

//             NewSchedule.Status := NewSchedule.Status::Pending;
//             NewSchedule.Insert(true);

//             RemainingPrincipal -= NewSchedule."Principal Amount";
//             DueDate := CalcDate('<1M>', DueDate);
//         end;
//     end;

//     //============================================================
//     local procedure CreateReducedEMISchedule(
//         LoanHeader: Record "US Mortgage Agreement Header";
//         SettlementDate: Date;
//         RemainingPrincipal: Decimal)
//     var
//         NewSchedule: Record "US Mortgage Schedule Line";
//         CountEMI: Integer;
//         EMIAmount: Decimal;
//         DueDate: Date;
//         LineNo: Integer;
//     begin
//         CountEMI := LoanHeader."Remaining EMI Count";
//         EMIAmount := RemainingPrincipal / CountEMI;

//         DueDate := CalcDate('<1M>', SettlementDate);
//         LineNo := GetLastLineNo(LoanHeader."Loan No.");

//         for CountEMI := CountEMI downto 1 do begin
//             LineNo += 10000;

//             NewSchedule.Init();
//             NewSchedule."Loan No." := LoanHeader."Loan No.";
//             NewSchedule."Line No." := LineNo;
//             NewSchedule."Due Date" := DueDate;
//             NewSchedule."Principal Amount" := EMIAmount;
//             NewSchedule.Status := NewSchedule.Status::Pending;
//             NewSchedule.Insert(true);

//             DueDate := CalcDate('<1M>', DueDate);
//         end;
//     end;

//     //============================================================
//     local procedure CreateJournal(
//         LoanHeader: Record "US Mortgage Agreement Header";
//         Posting: Record "US Mortgage Posting Group";
//         PrincipalAmount: Decimal;
//         InterestAmount: Decimal;
//         PostingDate: Date;
//         JournalTemplateName: Code[10];
//         JournalBatchName: Code[10])
//     var
//         GenJnlLine: Record "Gen. Journal Line";
//         LineNo: Integer;
//     begin
//         LineNo := 10000;

//         // PRINCIPAL
//         GenJnlLine.Init();
//         GenJnlLine."Journal Template Name" := JournalTemplateName;
//         GenJnlLine."Journal Batch Name" := JournalBatchName;
//         GenJnlLine."Line No." := LineNo;
//         GenJnlLine."Posting Date" := PostingDate;
//         GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
//         GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
//         GenJnlLine."Account No." := LoanHeader."Borrower Customer No.";
//         GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
//         GenJnlLine."Bal. Account No." := Posting."Loan Principal Receivable";
//         GenJnlLine.Description := 'Partial Pre-Settlement - Principal';
//         GenJnlLine.Amount := PrincipalAmount;
//         GenJnlLine.Insert(true);

//         // INTEREST
//         if InterestAmount <> 0 then begin
//             LineNo += 10000;

//             GenJnlLine.Init();
//             GenJnlLine."Journal Template Name" := JournalTemplateName;
//             GenJnlLine."Journal Batch Name" := JournalBatchName;
//             GenJnlLine."Line No." := LineNo;
//             GenJnlLine."Posting Date" := PostingDate;
//             GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
//             GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
//             GenJnlLine."Account No." := LoanHeader."Borrower Customer No.";
//             GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
//             GenJnlLine."Bal. Account No." := Posting."Interest Income";
//             GenJnlLine.Description := 'Partial Pre-Settlement - Interest';
//             GenJnlLine.Amount := InterestAmount;
//             GenJnlLine.Insert(true);
//         end;
//     end;

//     //============================================================
//     local procedure GetLastLineNo(LoanNo: Code[20]): Integer
//     var
//         LoanSchedule: Record "US Mortgage Schedule Line";
//     begin
//         LoanSchedule.Reset();
//         LoanSchedule.SetRange("Loan No.", LoanNo);

//         if LoanSchedule.FindLast() then
//             exit(LoanSchedule."Line No.");

//         exit(0);
//     end;
// }
