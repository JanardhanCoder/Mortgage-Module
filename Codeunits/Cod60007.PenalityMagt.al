namespace MortgageForUS.MortgageForUS;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 60007 "US Mortgage Penalty Mgt."
{
    procedure CalculatePenalty(MortgageNo: Code[20])
    var
        Mort: Record "US Mortgage Agreement Header";
        Sch: Record "US Mortgage Schedule Line";
        DaysLate: Integer;
        Penalty: Decimal;
    begin
        Mort.SetRange("Loan No.", MortgageNo);
        if Mort.FindFirst() then begin

            if Mort."Penalty Method" = Mort."Penalty Method"::None then
                exit;

            Sch.Reset();
            Sch.SetRange("Loan No.", MortgageNo);
            Sch.SetRange(Sch.Status, Sch.Status::Pending);
            Sch.SetFilter("Due Date", '<%1', WorkDate());

            if Sch.FindSet() then
                repeat
                    DaysLate := Today() - Sch."Due Date";
                    Penalty := 0;

                    case Mort."Penalty Method" of
                        Mort."Penalty Method"::Flat:
                            Penalty := Mort."Penalty Flat Amount";

                        Mort."Penalty Method"::"Rate Per Day":
                            Penalty :=
                                Round(
                                    Sch."Principal Amount" *
                                    (Mort."Penalty Rate %" / 100) *
                                    DaysLate,
                                    0.01
                                );
                    end;

                    Sch."Penalty Amount" := Penalty;
                    Sch."Penalty Calculated Date" := WorkDate();
                    Sch.Modify(true);
                until Sch.Next() = 0;
        end;
    end;





    //Job Queue
    trigger OnRun()
    var
        Mort: Record "US Mortgage Agreement Header";
    //PenCU: Codeunit "US Mortgage Penalty Mgt.";
    begin
        Mort.SetRange(Status, Mort.Status::Active);
        if Mort.FindSet() then
            repeat
                CalculatePenalty(Mort."Loan No.");
            until Mort.Next() = 0;
    end;


    // procedure PostPenalty(var Sch: Record "US Mortgage Schedule Line")
    // var
    //     GenJnlLine: Record "Gen. Journal Line";
    //     GenJnlPost: Codeunit "Gen. Jnl.-Post";
    //     Setup: Record "US Mortgage Posting Setup";
    //     PostingGroup: Record "US Mortgage Posting Group";
    //     Loan: Record "US Mortgage Agreement Header";
    // begin
    //     if Sch."Penalty Amount" = 0 then
    //         Error('No penalty amount to post.');

    //     if not Setup.Get() then
    //         Error('Setup is missing.');
    //     PostingGroup.Get('MG');

    //     GenJnlLine.Reset();
    //     GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
    //     GenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');
    //     GenJnlLine.DeleteAll();

    //     // -----------------------------
    //     // 1️⃣ Debit Bank
    //     // -----------------------------
    //     GenJnlLine.Init();
    //     GenJnlLine."Journal Template Name" := 'GENERAL';
    //     GenJnlLine."Journal Batch Name" := 'DEFAULT';
    //     GenJnlLine."Line No." := 10000;
    //     GenJnlLine."Posting Date" := WorkDate();
    //     GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
    //     GenJnlLine."Account No." := Setup."Default Bank Account No.";
    //     GenJnlLine.Amount := Sch."Penalty Amount";
    //     GenJnlLine.Description := 'Penalty Received';

    //     GenJnlLine.Insert(true);

    //     // -----------------------------
    //     // 2️⃣ Credit Penalty Income
    //     // -----------------------------
    //     GenJnlLine.Init();
    //     GenJnlLine."Journal Template Name" := 'GENERAL';
    //     GenJnlLine."Journal Batch Name" := 'DEFAULT';
    //     GenJnlLine."Line No." := 20000;
    //     GenJnlLine."Posting Date" := WorkDate();
    //     GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
    //     GenJnlLine."Account No." := PostingGroup."Penalty Income";
    //     GenJnlLine.Amount := -Sch."Penalty Amount";
    //     GenJnlLine.Description := 'Late Payment Penalty';
    //     Loan.SetRange("Loan No.", Sch."Loan No.");
    //     if Loan.FindFirst() then begin
    //         GenJnlLine."Dimension Set ID" := Loan."Dimension Set Id";
    //     end;
    //     GenJnlLine.Insert(true);

    //     // -----------------------------
    //     // 3️⃣ Post Journal
    //     // -----------------------------
    //     Page.Run(Page::"General Journal", GenJnlLine);
    //     //  GenJnlPost.Run(GenJnlLine);

    //     // -----------------------------
    //     // 4️⃣ Clear Penalty
    //     // -----------------------------
    //     // Sch."Penalty Amount" := 0;
    //     // Sch.Modify(true);
    // end;

}
