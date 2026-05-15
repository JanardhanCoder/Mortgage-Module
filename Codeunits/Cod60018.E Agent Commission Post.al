namespace MortgageForUS.MortgageForUS;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Purchases.Vendor;
using Mortgage.Mortgage;
using Microsoft.Foundation.NoSeries;
using Microsoft.CRM.BusinessRelation;
codeunit 60018 "GE Agent Commission Post"
{
    Subtype = Normal;
    procedure PostAgentCommission(LoanNo: Code[20]; var LoanHeader: Record "US Mortgage Agreement Header")
    var
        AgrHdr: Record "GE Agent Agreement Header";
        AgrLine: Record "GE Agent Agreement Line";
        VendorRec: Record Vendor;
        ContactBusRel: Record "Contact Business Relation";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        NoSeriesMgt: Codeunit "No. Series";
        CommissionAmount: Decimal;
        DocNo: Code[20];
        LineNo: Integer;
        PG: Record "US Mortgage Posting Group";
        Setup: Record "US Mortgage Posting Setup";
    begin
        // ---------------- VALIDATIONS ----------------
        LoanHeader.TestField("Agent Contact No.");
        LoanHeader.TestField("Principal Amount");

        Setup.Get('SETUP');

        if LoanHeader."Agent Commission Posted" then
            Error(
              'Agent commission already posted for Loan %1.',
              LoanHeader."Loan No.");

        // ---------------- CONTACT → VENDOR ----------------
        ContactBusRel.SetRange("Contact No.", LoanHeader."Agent Contact No.");
        ContactBusRel.SetRange(
            "Link to Table",
            ContactBusRel."Link to Table"::Vendor);

        if not ContactBusRel.FindFirst() then
            Error(
              'No Vendor linked to Contact %1.',
              LoanHeader."Agent Contact No.");

        VendorRec.SetRange("No.", ContactBusRel."No.");
        if VendorRec.FindFirst() then begin

            LoanHeader.Get(LoanNo);
            PG.SetRange(Code, LoanHeader."Posting Group Code");
            if pg.FindFirst() then begin
                // ---------------- FIND ACTIVE AGREEMENT ----------------
                AgrHdr.SetRange("Agent Vendor No.", VendorRec."No.");
                AgrHdr.SetRange(Status, AgrHdr.Status::Active);
                AgrHdr.SetFilter("Effective From Date", '<=%1', WorkDate());
                AgrHdr.SetFilter("Effective To date", '>=%1|=%2', WorkDate(), 0D);

                if not AgrHdr.FindFirst() then
                    Error(
                      'No active agent agreement found for Vendor %1.',
                      VendorRec."No.");

                // ---------------- CALCULATE COMMISSION ----------------
                AgrLine.Reset();
                AgrLine.SetRange("Agreement No.", AgrHdr."No.");

                if not AgrLine.FindFirst() then
                    Error(
                      'No commission lines defined for Agreement %1.',
                      AgrHdr."No.");

                case AgrLine."Commission Type" of
                    AgrLine."Commission Type"::Percentage:
                        CommissionAmount :=
                            LoanHeader."Principal Amount" *
                            AgrLine."Commission %" / 100;

                    AgrLine."Commission Type"::"Fixed Amount":
                        CommissionAmount :=
                            AgrLine."Commission Amount";

                    AgrLine."Commission Type"::Tiered:
                        begin
                            AgrLine.SetFilter(
                                "From Loan Amount",
                                '<=%1',
                                LoanHeader."Principal Amount");
                            AgrLine.SetFilter(
                                "To Loan Amount",
                                '>=%1|=%2',
                                LoanHeader."Principal Amount",
                                0);

                            if AgrLine.FindFirst() then
                                CommissionAmount :=
                                    LoanHeader."Principal Amount" *
                                    AgrLine."Commission %" / 100
                            else
                                Error(
                                  'No commission slab defined for loan amount %1.',
                                  LoanHeader."Principal Amount");
                        end;
                end;

                if CommissionAmount <= 0 then
                    exit;

                // ---------------- GET JOURNAL BATCH ----------------
                GenJnlBatch.Get(Setup."Accrual Jnl. Template", Setup."Accrual Jnl. Batch");

                DocNo :=
                    NoSeriesMgt.GetNextNo(
                        GenJnlBatch."No. Series",
                        WorkDate(),
                        true);

                // ---------------- CREATE JOURNAL LINES ----------------
                GenJnlLine.Reset();
                GenJnlLine.SetRange("Journal Template Name", Setup."Accrual Jnl. Template");
                GenJnlLine.SetRange("Journal Batch Name", Setup."Accrual Jnl. Batch");
                GenJnlLine.DeleteAll();

                LineNo := GetNextLineNo(GenJnlBatch);
                //GenJnlLine
                // Vendor line (Payable)
                InsertVendorLine(
                    GenJnlLine,
                    GenJnlBatch,
                    VendorRec."No.",
                    -CommissionAmount,
                    DocNo,
                    LoanHeader."Loan No.",
                    LineNo, "GE Loan Entry Type"::Commission);

                LineNo += 10000;

                // Expense line
                InsertGLLine(
                    GenJnlLine,
                    GenJnlBatch,
                    PG."Agent Vendor Posting Group",
                    CommissionAmount,
                    DocNo,
                    LoanHeader."Loan No.",
                    LineNo, "GE Loan Entry Type"::Commission);

                // ---------------- Creat JOURNAL ----------------
                Page.Run(Page::"General Journal", GenJnlLine);
            end;
        end;
    end;
    // ----------------------------------------------------

    local procedure InsertVendorLine(
        var GenJnlLine: Record "Gen. Journal Line";
        Batch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
        Amount: Decimal;
        DocNo: Code[20];
        LoanNo: Code[20];
        LineNo: Integer; LoanEntryType: Enum "GE Loan Entry Type")
    begin
        //GenJnlLine.DeleteAll();
        GenJnlLine.Init();
        GenJnlLine."US Mortgage No." := LoanNo;
        GenJnlLine."Loan Entry Type" := LoanEntryType;
        GenJnlLine."Journal Template Name" := Batch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := Batch.Name;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Document No." := DocNo;
        GenJnlLine."Posting Date" := WorkDate();
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
        GenJnlLine.Validate("Account No.", VendorNo);
        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine.Description :=
            'Agent Commission - Loan ' + LoanNo;
        GenJnlLine.Insert(true);
    end;

    local procedure InsertGLLine(
        var GenJnlLine: Record "Gen. Journal Line";
        Batch: Record "Gen. Journal Batch";
        GLAccount: Code[20];
        Amount: Decimal;
        DocNo: Code[20];
        LoanNo: Code[20];
        LineNo: Integer; LoanEntryType: Enum "GE Loan Entry Type")
    begin
        GenJnlLine.Init();
        GenJnlLine."US Mortgage No." := LoanNo;
        GenJnlLine."Loan Entry Type" := LoanEntryType;
        GenJnlLine."Journal Template Name" := Batch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := Batch.Name;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Document No." := DocNo;
        GenJnlLine."Posting Date" := today();
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine.Validate("Account No.", GLAccount);
        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine.Description :=
            'Agent Commission Expense - Loan ' + LoanNo;
        GenJnlLine.Insert(true);
    end;

    local procedure GetNextLineNo(
        Batch: Record "Gen. Journal Batch"): Integer
    var
        JnlLine: Record "Gen. Journal Line";
    begin
        JnlLine.SetRange(
            "Journal Template Name",
            Batch."Journal Template Name");
        JnlLine.SetRange(
            "Journal Batch Name",
            Batch.Name);

        if JnlLine.FindLast() then
            exit(JnlLine."Line No." + 10000)
        else
            exit(10000);
    end;
}
