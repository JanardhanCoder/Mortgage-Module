namespace MortgageForUS.MortgageForUS;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Mortgage.Mortgage;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Reporting;
using System.Reflection;
using Microsoft.Sales.Customer;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.Receivables;
codeunit 60008 "PreSettlement Posting Events"
{
    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure ApplyAfterPosting(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        Loan: Record "US Mortgage Agreement Header";
        OldSched: Record "US Mortgage Schedule Line";
        NewSched: Record "US Mortgage Schedule Line";
        postmang: Codeunit "US Loan GL Posting";

        RemainingPrincipal: Decimal;
        EMI: Decimal;
        Interest: Decimal;
        Principal: Decimal;
        DueDate: Date;

        Outstanding: Decimal;
        MonthlyRate: Decimal;
        PowerValue: Decimal;
        RemainingCount: Integer;
        LineNo: Integer;
        LineNoToCancel: Integer;
        CancelList: List of [Integer];
        DueDateMap: Dictionary of [Integer, Date];
        line: Page "General Journal";
    begin
        GLEntry."US Mortgage No." := GenJournalLine."US Mortgage No.";
        GLEntry."Loan Entry Type" := GenJournalLine."Loan Entry Type";
        If GenJournalLine."US Mortgage No." <> '' then begin
            Loan.SetRange("Loan No.", GenJournalLine."US Mortgage No.");
            if not Loan.FindFirst() then
                Error('Loan not found.');

            MarkScheduleLineAsPaid(GLEntry, GenJournalLine, Loan."Loan No.");

            // postmang.InsertLedger(Loan."Loan No.", GenJournalLine."Posting Date", GenJournalLine."Loan Entry Type",
            // GenJournalLine.Amount,
            //     0, 0, 0,
            //     GenJournalLine."Bal. Account No.",
            //     '',
            //     GenJournalLine."Document No.",
            //     GenJournalLine."Shortcut Dimension 1 Code",
            //     GenJournalLine."Shortcut Dimension 2 Code",
            //     GenJournalLine."Dimension Set ID");
            if GenJournalLine."Loan Entry Type" = GenJournalLine."Loan Entry Type"::Disbursement then begin
                Loan.SetRange("Loan No.", GenJournalLine."US Mortgage No.");
                if Loan.FindFirst() then begin
                    Loan."Disbursed Amount" := GenJournalLine.Amount;
                    Loan.Modify(false);
                end
                else
                    Message('Loan not found');
            end
            else
                if GenJournalLine."Loan Entry Type" = GenJournalLine."Loan Entry Type"::Commission then begin
                    Loan.SetRange("Loan No.", GenJournalLine."US Mortgage No.");
                    if Loan.FindFirst() then begin
                        Loan."Agent Commission Amount" := GenJournalLine.Amount;
                        Loan."Agent Commission Posted" := true;
                        Loan.Modify(false);
                    end;
                end;
            // ------------------------------------------------
            // BASIC GUARDS
            // ------------------------------------------------
            if GenJournalLine."US Mortgage No." = '' then
                exit;

            if not Loan.Get(GenJournalLine."US Mortgage No.") then
                exit;

            // 🔒 VERY IMPORTANT: prevent multiple executions
            if Loan."Pre-Settlement Posted" then
                exit;

            // ------------------------------------------------
            // REDUCE PRINCIPAL
            // ------------------------------------------------
            RemainingPrincipal :=
                Loan."Outstanding Principal" - Abs(GenJournalLine.Amount);

            Loan."Outstanding Principal" := RemainingPrincipal;

            // ------------------------------------------------
            // GET CURRENT EMI (from next pending line)
            // ------------------------------------------------
            OldSched.Reset();
            OldSched.SetRange("Loan No.", Loan."Loan No.");
            OldSched.SetRange(Status, OldSched.Status::Pending);
            OldSched.SetFilter("Due Date", '>%1', GenJournalLine."Posting Date");

            if not OldSched.FindFirst() then
                exit;

            EMI := OldSched."EMI Amount";

            DueDate := CalcDate('<1M>', GenJournalLine."Posting Date");

            // ------------------------------------------------
            // PRE-SETTLEMENT OPTION
            // ------------------------------------------------
            case Loan."Pre-Settlement Option" of

                // =================================================
                // REDUCE TENURE (CANCEL + REBUILD)
                // =================================================
                Loan."Pre-Settlement Option"::ReduceTenure:
                    begin
                        Clear(CancelList);

                        // 1️⃣ Collect all future unpaid EMI
                        OldSched.Reset();
                        OldSched.SetRange("Loan No.", Loan."Loan No.");
                        OldSched.SetRange(Closed, false);
                        OldSched.SetRange("Paid Date", 0D);

                        if OldSched.FindSet() then
                            repeat
                                CancelList.Add(OldSched."Line No.");
                            until OldSched.Next() = 0;

                        // 2️⃣ Cancel them ONCE
                        foreach LineNoToCancel in CancelList do begin
                            OldSched.Get(Loan."Loan No.", LineNoToCancel);
                            OldSched.Status := OldSched.Status::Cancelled;
                            OldSched.Closed := true;
                            OldSched.Modify(true);
                        end;

                        // 3️⃣ Rebuild EMI until principal becomes zero
                        LineNo := GetLastLineNo(Loan."Loan No.");

                        while RemainingPrincipal > 0 do begin
                            LineNo += 10000;

                            Interest :=
                                Round(
                                    RemainingPrincipal *
                                    Loan."Interest Rate %" / 100 / 12,
                                    0.01);

                            if (EMI - Interest) <= RemainingPrincipal then
                                Principal := EMI - Interest
                            else
                                Principal := RemainingPrincipal;

                            NewSched.Init();
                            NewSched."Loan No." := Loan."Loan No.";
                            NewSched."Line No." := LineNo;
                            NewSched."Due Date" := DueDate;
                            NewSched.Description := 'EMI - ' + Format(NewSched."Due Date", 0, '<Month Text> <Year4>');
                            NewSched."Interest Rate %" := Loan."Interest Rate %";
                            NewSched."Interest Amount" := Interest;
                            NewSched."Principal Amount" := Principal;
                            NewSched."EMI Amount" := Interest + Principal;
                            NewSched.Status := NewSched.Status::Pending;
                            NewSched.Closed := false;
                            NewSched.Insert(true);
                            NewSched.Description := 'EMI - ' + Format(NewSched."Due Date", 0, '<Month Text> <Year>');

                            RemainingPrincipal :=
                                Round(RemainingPrincipal - Principal, 0.01);

                            DueDate := CalcDate('<1M>', DueDate);
                        end;

                        Loan."Pre-Settlement Posted" := true;
                        Loan.Modify(true);
                    end;

                // =================================================
                // KEEP TENURE
                // =================================================
                Loan."Pre-Settlement Option"::KeepTenure:
                    begin
                        if Loan."Keep Tenure Applied" then
                            exit;

                        Clear(CancelList);
                        Clear(DueDateMap);

                        // 1️⃣ Collect EMI count & dates
                        OldSched.Reset();
                        OldSched.SetRange("Loan No.", Loan."Loan No.");
                        OldSched.SetRange(Closed, false);
                        OldSched.SetRange("Paid Date", 0D);

                        if not OldSched.FindSet() then
                            exit;

                        repeat
                            CancelList.Add(OldSched."Line No.");
                            DueDateMap.Add(
                                OldSched."Line No.",
                                OldSched."Due Date");
                        until OldSched.Next() = 0;

                        RemainingCount := CancelList.Count();
                        if RemainingCount = 0 then
                            exit;

                        // 2️⃣ Calculate new EMI
                        Outstanding := RemainingPrincipal;
                        MonthlyRate := Loan."Interest Rate %" / 100 / 12;

                        PowerValue := Power(1 + MonthlyRate, RemainingCount);
                        EMI :=
                            Round(
                                Outstanding * MonthlyRate * PowerValue /
                                (PowerValue - 1),
                                0.01);

                        // 3️⃣ Cancel old EMI
                        foreach LineNoToCancel in CancelList do begin
                            OldSched.Get(Loan."Loan No.", LineNoToCancel);
                            OldSched.Status := OldSched.Status::Cancelled;
                            OldSched.Closed := true;
                            OldSched.Modify(true);
                        end;

                        // 4️⃣ Rebuild EMI with same count
                        LineNo := GetLastLineNo(Loan."Loan No.");

                        foreach LineNoToCancel in CancelList do begin
                            LineNo += 10000;

                            Interest := Round(Outstanding * MonthlyRate, 0.01);
                            Principal := Round(EMI - Interest, 0.01);

                            if Principal > Outstanding then begin
                                Principal := Outstanding;
                                EMI := Principal + Interest;
                            end;

                            Outstanding := Round(Outstanding - Principal, 0.01);

                            NewSched.Init();
                            NewSched."Loan No." := Loan."Loan No.";
                            NewSched."Line No." := LineNo;
                            NewSched."Due Date" := DueDateMap.Get(LineNoToCancel);
                            NewSched."Interest Rate %" := Loan."Interest Rate %";
                            NewSched."Interest Amount" := Interest;
                            NewSched."Principal Amount" := Principal;
                            NewSched."EMI Amount" := Principal + Interest;
                            NewSched.Status := NewSched.Status::Pending;
                            NewSched.Closed := false;
                            NewSched.Insert(true);
                            NewSched.Description := 'EMI - ' + Format(NewSched."Due Date", 0, '<Month Text> <Year>');
                            NewSched.Modify();
                        end;

                        Loan."Keep Tenure Applied" := true;
                        Loan."Pre-Settlement Posted" := true;
                        //Loan."Outstanding Principal" := RemainingPrincipal;
                        Loan.Modify(true);
                    end;
            end;
        end;
    end;

    local procedure GetLastLineNo(LoanNo: Code[20]): Integer
    var
        S: Record "US Mortgage Schedule Line";
    begin
        S.SetRange("Loan No.", LoanNo);
        if S.FindLast() then
            exit(S."Line No.");
        exit(0);
    end;
    //===================================================================
    local procedure MarkScheduleLineAsPaid(
     GLEntry: Record "G/L Entry";
     GenJournalLine: Record "Gen. Journal Line"; LoanNo: Code[20])
    var
        LoanSch: Record "US Mortgage Schedule Line";
        PaidAmt: Decimal;
    begin
        if GenJournalLine."US Mortgage No." = '' then
            exit;

        if GenJournalLine."US Sch. Line No." = 0 then
            exit;

        GenJournalLine.SetRange("US Mortgage No.", loanNo);
        //PaidAmt := Abs(GenJournalLine.Amount);

        LoanSch.Reset();
        LoanSch.LockTable();
        LoanSch.SetRange("Loan No.", GenJournalLine."US Mortgage No.");
        LoanSch.SetRange("Line No.", GenJournalLine."US Sch. Line No.");

        if LoanSch.FindFirst() then begin
            //LoanSch."Paid Total Amount" ;
            case GenJournalLine."Loan Entry Type" of
                GenJournalLine."Loan Entry Type"::Receipt:
                    LoanSch."Paid Principal" := LoanSch."Paid Principal" - GenJournalLine.Amount;
                GenJournalLine."Loan Entry Type"::InterestAccrual:
                    LoanSch."Paid Interest" := LoanSch."Paid Interest" - GenJournalLine.Amount;
                GenJournalLine."Loan Entry Type"::Penalty:
                    LoanSch."Paid Penalty" := LoanSch."Paid Penalty" - GenJournalLine.Amount;
            end;
            LoanSch."Paid Total Amount" := LoanSch."Paid Principal" + LoanSch."Paid Interest" + LoanSch."Paid Penalty";
            LoanSch."Paid Date" := GLEntry."Posting Date";

            if LoanSch."Paid Total Amount" >= LoanSch."EMI Amount" then begin
                LoanSch.Status := LoanSch.Status::Paid;
                LoanSch.Closed := true;
            end;
            LoanSch.Modify(true);
        end;
    end;



    // ================================================================
    // [EventSubscriber(
    //     ObjectType::Table,
    //     Database::"G/L Entry",
    //     'OnAfterInsertEvent',
    //     '',
    //     false,
    //     false)]
    // local procedure OnAfterInsertGLEntry(
    //     var Rec: Record "G/L Entry";
    //     RunTrigger: Boolean)
    // var
    //     AgentCommission: Codeunit "GE Agent Commission Post";
    //     Loan: Record "US Mortgage Agreement Header";
    // begin
    //     if Rec."US Mortgage No." = '' then
    //         exit;


    //     if not Loan.Get(Rec."US Mortgage No.") then
    //         exit;


    //     postmang.InsertLedger(
    //         Loan."Loan No.",
    //         Rec."Posting Date",
    //         "GE Loan Entry Type"::Disbursement,
    //         Rec.Amount,
    //         0, 0, 0,
    //         Rec."Bal. Account No.",
    //         '',
    //         Rec."Document No.",
    //         Rec."Global Dimension 1 Code",
    //         Rec."Global Dimension 2 Code"
    //     );

    //     Loan."Disbursed Amount" += Rec.Amount;
    //     Loan.Modify(false);
    //     AgentCommission.PostAgentCommission(Loan);
    // end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeCustLedgEntryInsert', '', false, false)]

    procedure UpdateCustEntry(var GenJournalLine: Record "Gen. Journal Line"; var CustLedgerEntry: Record "Cust. Ledger Entry"; GLRegister: Record "G/L Register"; sender: Codeunit "Gen. Jnl.-Post Line"; var TempDtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; var NextEntryNo: Integer)
    var
        postmang: Codeunit "US Loan GL Posting";
    begin
        postmang.InsertLedger(GenJournalLine."US Mortgage No.", GenJournalLine."Posting Date", GenJournalLine."Loan Entry Type",
                    GenJournalLine.Amount,
                        0, 0, 0,
                        GenJournalLine."Account No.",
                        '',
                        GenJournalLine."Document No.",
                        GenJournalLine."Shortcut Dimension 1 Code",
                        GenJournalLine."Shortcut Dimension 2 Code",
                        GenJournalLine."Dimension Set ID");

        if GenJournalLine."US Mortgage No." <> '' then
            CustLedgerEntry."US Loan No." := GenJournalLine."US Mortgage No.";
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Process Mgt.", 'OnSetSourceRecordRefFieldEnvelopeStatus', '', false, false)]
    // procedure EnvelopStatus(var SourceRecordRef: RecordRef; SourceFieldRef: FieldRef)
    // begin
    //     case SourceRecordRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 DataTypeManagement.FindFieldByName(SourceRecordRef, SourceFieldRef, 'Envelope Status');
    //                 if SourceFieldRef.Number <= 0 then
    //                     Error(NotFoundErrTxt, 'Field "Envelope Status"');
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Process Mgt.", 'OnSetSourceRecordRefFieldNo', '', false, false)]
    // procedure SetSourceRecordRefFieldNo(var SourceRecordRef: RecordRef; SourceFieldRef: FieldRef)
    // begin
    //     case SourceRecordRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 DataTypeManagement.FindFieldByName(SourceRecordRef, SourceFieldRef, 'Commitment No.');
    //                 if SourceFieldRef.Number <= 0 then
    //                     Error(NotFoundErrTxt, 'Field "Application No."');
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Process Mgt.", 'OnSetSourceRecordRefFieldClientNo', '', false, false)]
    // procedure SetSourceRecordRefFieldClientNo(var SourceRecordRef: RecordRef; SourceFieldRef: FieldRef)
    // begin
    //     case SourceRecordRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 DataTypeManagement.FindFieldByName(SourceRecordRef, SourceFieldRef, 'Borrower Customer No.');
    //                 if SourceFieldRef.Number <= 0 then
    //                     Error(NotFoundErrTxt, 'Field "Borrower Customer No."');
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Process Mgt.", 'OnSetSourceRecordRefFieldDocumentType', '', false, false)]
    // procedure SetSourceRecordRefFieldDocumentType(var RecRef: RecordRef; DcoumentType: Enum "DocuSign Document Type"; DocumentTypeName: Text)
    // begin
    //     case RecRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 DcoumentType := DcoumentType::Commitment;
    //                 DocumentTypeName := RecRef.Field(1).Value;
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Process Mgt.", 'OnGetMessageForEnvelopeSent', '', false, false)]
    // procedure GetMessageForEnvelopeSent(var SourceRecordRef: RecordRef; var NotificationMsgTxt: Text)
    // var
    //     TempMessageTxt: Label '%1 %2 %3 has been successfully sent to DocuSign for signing.', Comment = '%1 - Document Name, %2 - Document Type, %3 - Document No.';
    // begin
    //     case SourceRecordRef.Number() of
    //         Database::"US Commitment Header":
    //             NotificationMsgTxt := StrSubstNo(TempMessageTxt, 'Aggreement', 'Commitment', SourceRecordRef.Field(1).Value);
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Recipient Mgt.", 'OnbeforeResetEnvelopRecipttStatus', '', false, false)]
    // procedure ResetEnvelopRecipttStatus(var RecRef: RecordRef; DocumentNo: Code[20]; DocumentType: Enum "DocuSign Document Type")

    // begin
    //     case RecRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 Header.Get(RecRef.RecordId);
    //                 DocumentNo := Header."Commitment No.";
    //                 DocumentType := DocumentType::Commitment;
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Recipient Mgt.", 'OnBeforeEnvelopReceipt', '', false, false)]
    // procedure FillEnvelopReceipt(var RecRef: RecordRef; DocumentNo: Code[20]; DocumentType: Enum "DocuSign Document Type"; ClientNo: Code[20]; EnvelopeRecipient: Record "Envelope Recipient")
    // var
    //     customer: Record Customer;
    //     ClientNotFoundErrTxt: Label '%1 No. Record Found.', Comment = '%1 No. Record Found.';
    //     Header: Record "US Commitment Header";
    // begin
    //     case RecRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 Header.Get(RecRef.RecordId);
    //                 ClientNo := Header."Borrower Customer No.";
    //                 if ClientNo = '' then
    //                     Error(ClientNotFoundErrTxt, 'Customer');

    //                 DocumentNo := Header."Commitment No.";
    //                 EnvelopeRecipient.SetRange("Document Type", DocumentType);
    //                 EnvelopeRecipient.SetRange("Document No.", Header."Commitment No.");

    //                 Customer.Reset();
    //                 if Customer.Get(ClientNo) then;

    //                 Header."Enable DocuSign" := true;
    //                 Header."Signature Sequence" := Header."Signature Sequence";
    //                 Header.Modify();
    //             end;
    //     end;
    // end;

    // internal procedure FillEnvelopeRecipient(var SourceRecordRef: RecordRef)
    // var
    //     EnvelopeRecipient01: Record "Envelope Recipient";
    //     EnvelopeRecipent02: Record "Envelope Recipient";
    //     Customer: Record Customer;
    //     ClientNumber: Text;
    //     DocumentNo: Text;
    //     ClientNotFoundErrTxt: Label '%1 No. Record Found.', Comment = '%1 No. Record Found.';
    //     DocumentType: enum "Docusign Document Type";
    //     DocumentTypeName: text;
    // begin
    //     DocuSignProcessManagement.SetSourceRecordRefFieldDocumentType(SourceRecordRef, DocumentType, DocumentTypeName);
    //     case SourceRecordRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 Header.Get(SourceRecordRef.RecordId);
    //                 clientNumber := Header."Borrower Customer No.";
    //                 if clientNumber = '' then
    //                     Error(ClientNotFoundErrTxt, 'Customer');

    //                 DocumentNo := Header."Commitment No.";
    //                 EnvelopeRecipient01.SetRange("Document Type", DocumentType);
    //                 EnvelopeRecipient01.SetRange("Document No.", Header."Commitment No.");

    //                 Customer.Reset();
    //                 if Customer.Get(clientNumber) then;

    //                 Header."Enable DocuSign" := true;
    //                 Header."Signature Sequence" := Header."Signature Sequence";
    //                 Header.Modify();
    //             end;
    //     end;

    //     if not EnvelopeRecipient01.IsEmpty then
    //         EnvelopeRecipient01.DeleteAll(true);

    //     EnvelopeRecipient01.Reset();
    //     EnvelopeRecipient01.SetRange("Client No.", ClientNumber);
    //     EnvelopeRecipient01.SetRange("Document No.", '');

    //     if EnvelopeRecipient01.FindSet() then
    //         repeat
    //             EnvelopeRecipent02.Init();
    //             EnvelopeRecipent02.Validate("Document Type", DocumentType);
    //             EnvelopeRecipent02.Validate("Document No.", DocumentNo);
    //             EnvelopeRecipent02.Validate("Client No.", ClientNumber);
    //             EnvelopeRecipent02.Validate("Recipient Line No.", EnvelopeRecipient01."Recipient Line No.");
    //             EnvelopeRecipent02.Insert();
    //             EnvelopeRecipent02.TransferFields(EnvelopeRecipient01, false);
    //             EnvelopeRecipent02.Modify(true);
    //         until EnvelopeRecipient01.Next() = 0;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Recipient Mgt.", 'OnSetReceipt', '', false, false)]
    // procedure SetReceipt(var RecRef: RecordRef; EnvelopeRecipient: Record "Envelope Recipient")
    // begin
    //     case RecRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 header.Get(RecRef.RecordId);
    //                 EnvelopeRecipient.SetRange("Document No.", header."Commitment No.");
    //                 EnvelopeRecipient.SetRange("Client No.", header."Borrower Customer No.");
    //                 EnvelopeRecipient.SetRange("Document Type", EnvelopeRecipient."Document Type"::Commitment);
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Recipient Mgt.", 'OnBeforeValidateRecipientInfo', '', false, false)]
    // procedure ValidateRecipientInfo(var RecRef: RecordRef; EnvelopeRecipient: Record "Envelope Recipient")
    // var
    //     clientNumber: Code[20];
    // begin
    //     case RecRef.Number() of
    // Database::"US Commitment Header":
    //     begin
    //         Header.Get(RecRef.RecordId);
    //         clientNumber := Header."Borrower Customer No.";
    //         if clientNumber = '' then
    //             Error(NotFoundErrTxt, 'Customer');
    //         EnvelopeRecipient.SetRange("Document No.", Header."Commitment No.");
    //         EnvelopeRecipient.SetRange("Recipient Code", Header."Borrower Customer No.");
    //         EnvelopeRecipient.SetRange("Document Type", EnvelopeRecipient."Document Type"::Commitment);
    //         //Message('%1 %2', Header."Commitment No.", Header."Borrower Customer No.");
    //     end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    // procedure OpenRecRefUS(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var FlowFieldsEditable: Boolean)
    // var
    //     fieldRef: FieldRef;
    //     recNum: Code[20];
    // begin
    //     case RecRef.Number of
    //         DATABASE::"US Commitment Header":
    //             begin
    //                 fieldRef := RecRef.Field(1);
    //                 recNum := fieldRef.Value();
    //                 DocumentAttachment.SetRange("No.", recNum);
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Table, DataBase::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    // procedure InsertDocumentsUS(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    // var
    //     fieldRef: FieldRef;
    //     recNum: Code[20];
    // begin
    //     if RecRef.Number = DATABASE::"US Commitment Header" then begin
    //         fieldRef := RecRef.Field(1);
    //         recNum := fieldRef.Value();
    //         DocumentAttachment.Validate("No.", recNum);
    //     end;
    // end;

    // var
    //     NotFoundErrTxt: Label '%1 Not Found.', Comment = '%1 Not Found.';
    //     DataTypeManagement: Codeunit "Data Type Management";
    //     DocuSignProcessManagement: Codeunit "DocuSign Process Mgt.";
    //     Header: Record "US Commitment Header";

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Document Mgt.", 'OnGetReportId', '', false, false)]
    // procedure GetReportId(var ReportID: Integer; SourceRecordRef: RecordRef; var ReportUsage: Enum "Report Selection Usage"; var TempReportSelections: Record "Report Selections" temporary)
    // var
    //     clientNumber: Code[20];
    //     ReportSelections: Record "Report Selections";
    // begin
    //     case SourceRecordRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 Header.Get(SourceRecordRef.RecordId);
    //                 clientNumber := Header."Borrower Customer No.";
    //                 if clientNumber = '' then
    //                     Error(NotFoundErrTxt, 'Customer');
    //                 ReportUsage := ReportUsage::"US Mortgage Aggreement";
    //                 ReportSelections.FindReportUsageForCust(ReportUsage, clientNumber, TempReportSelections);
    //                 ReportID := TempReportSelections."Report ID";
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"DocuSign Document Mgt.", 'OnAppendDocumentToEnvelope', '', false, false)]
    // procedure AppendDocumentToEnvelope(var SourceRecordRef: RecordRef; DocumentName: Text)
    // var
    //     clientNumber: Code[20];
    // begin
    //     case SourceRecordRef.Number() of
    //         Database::"US Commitment Header":
    //             begin
    //                 Header.Get(SourceRecordRef.RecordId);
    //                 clientNumber := Header."Borrower Customer No.";
    //                 if clientNumber = '' then
    //                     Error(NotFoundErrTxt, 'Customer');
    //                 DocumentName := StrSubstNo('%1 %2', 'Aggrement', Header."Commitment No.");
    //             end;
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Mgt.", 'OnGetEnvelopStatus', '', false, false)]
    // procedure GetEnvelopStatus()
    // var
    //     status: enum "Envelope Status";
    //     SourceRecordRef: RecordRef;
    // begin
    //     Header.SetFilter("Envelope ID", '<>%1', '');
    //     Header.SetFilter("Envelope Status", '<>%1&<>%2&<>%3&<>%4', status::completed, status::voided, status::deleted, status::declined);
    //     if Header.FindSet() then
    //         repeat
    //             Header.GetEnvelopeStatus(SourceRecordRef);
    //             Commit();
    //         until Header.Next() = 0;
    // end;

}
