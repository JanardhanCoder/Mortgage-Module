namespace MortgageForUS.MortgageForUS;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;

codeunit 60005 CreateJournals
{
    procedure CreateGenJournalFromSchedule(Sched: Record "US Mortgage Schedule Line")
    var
        Loan: Record "US Mortgage Agreement Header";
        Jnl: Record "Gen. Journal Line";
        Setup: Record "US Mortgage Posting Setup";
        Posting: Record "US Mortgage Posting Group";
        LineNo: Integer;
        PageJnl: Page "General Journal";
        PenaltyMgnt: Codeunit "US Mortgage Penalty Mgt.";
        template: Record "Gen. Journal Template";
        DocNo: Code[20];
        Noseries: Codeunit "No. Series";
    begin
        Clear(DocNo);
        if Sched.Status = Sched.Status::Paid then
            Error('This installment is already paid.');

        Loan.SetRange("Loan No.", Sched."Loan No.");
        if Loan.FindFirst() then begin
            Posting.SetRange(Code, Loan."Posting Group Code");
            if Posting.FindFirst() then begin
                Setup.Get('SETUP');
                Setup.TestField("Gen. Jnl. Template");
                Setup.TestField("Gen. Jnl. Batch");


                Jnl.SetRange("Journal Template Name", Setup."Gen. Jnl. Template");
                Jnl.SetRange("Journal Batch Name", Setup."Gen. Jnl. Batch");
                if Jnl.FindLast() then
                    LineNo := Jnl."Line No."
                else
                    LineNo := 0;

                template.Get(Setup."Gen. Jnl. Template");
                template.TestField("No. Series");
                DocNo := Noseries.PeekNextNo(template."No. Series");
                if (Sched."Interest Amount" <> 0) and (Sched."Paid Interest" = 0) then begin
                    LineNo += 10000;
                    Jnl.Init();
                    Jnl."Journal Template Name" := Setup."Gen. Jnl. Template";
                    Jnl."Journal Batch Name" := Setup."Gen. Jnl. Batch";
                    Jnl."Line No." := LineNo;
                    Jnl.Validate("Document No.", DocNo);
                    //Jnl."US Sch. Line No." := Sched."Line No.";
                    Jnl."Posting Date" := WorkDate();
                    Jnl."US Mortgage No." := Sched."Loan No.";
                    Jnl."US Sch. Line No." := Sched."Line No.";
                    Jnl."Account Type" := Jnl."Account Type"::"G/L Account";
                    Jnl.Validate("Account No.", Posting."Interest Income");
                    Jnl.Validate(Amount, -Sched."Interest Amount");
                    Jnl."Loan Entry Type" := Jnl."Loan Entry Type"::InterestAccrual;
                    Jnl.Description :=
                        StrSubstNo(
                            'Interest %1 - Loan %2',
                            Sched.Description,
                            Sched."Loan No.");
                    Jnl.Validate("Dimension Set ID", Loan."Dimension Set Id");
                    Jnl.Insert(true);
                end;
                if Sched."Principal Amount" <> 0 then begin
                    LineNo += 10000;
                    Jnl.Init();
                    Jnl."Journal Template Name" := Setup."Gen. Jnl. Template";
                    Jnl."Journal Batch Name" := Setup."Gen. Jnl. Batch";
                    Jnl."Line No." := LineNo;
                    Jnl.Validate("Document No.", DocNo);
                    Jnl."US Sch. Line No." := Sched."Line No.";
                    Jnl."Posting Date" := WorkDate();
                    Jnl."US Mortgage No." := Sched."Loan No.";
                    //Jnl."Document Type" := Jnl."Document Type"::Payment;
                    Jnl."Account Type" := Jnl."Account Type"::Customer;
                    Jnl.Validate("Account No.", Loan."Borrower Customer No.");
                    if Sched."Amount Paying" = Sched."EMI Amount" then
                        Jnl.Validate(Amount, -Sched."Principal Amount")
                    else
                        Jnl.Validate(Amount, -(Sched."Amount Paying" - Sched."Interest Amount" - Sched."Penalty Amount"));
                    Jnl.Description := Sched.Description;
                    Jnl.Validate("Dimension Set ID", Loan."Dimension Set Id");
                    Jnl."Loan Entry Type" := Jnl."Loan Entry Type"::Receipt;
                    Jnl.Insert(true);
                end;

                if Sched."Penalty Amount" <> 0 then begin
                    LineNo += 10000;
                    Jnl.Init();
                    Jnl."Journal Template Name" := Setup."Gen. Jnl. Template";
                    Jnl."Journal Batch Name" := Setup."Gen. Jnl. Batch";
                    Jnl."Line No." := LineNo;
                    Jnl.Validate("Document No.", DocNo);
                    //Jnl."US Sch. Line No." := Sched."Line No.";
                    Jnl."Posting Date" := WorkDate();
                    Jnl."US Mortgage No." := Sched."Loan No.";
                    Jnl."US Sch. Line No." := Sched."Line No.";
                    Jnl."Account Type" := Jnl."Account Type"::"G/L Account";
                    Jnl.Validate("Account No.", Posting."Penalty Income");
                    Jnl.Validate(Amount, -Sched."Penalty Amount");
                    Jnl.Validate("Dimension Set ID", Loan."Dimension Set Id");
                    Jnl."Loan Entry Type" := Jnl."Loan Entry Type"::Penalty;
                    Jnl.Description :=
                        StrSubstNo(
                            'Penalty %1 - Loan %2',
                            Sched.Description,
                            Sched."Loan No.");
                    Jnl.Insert(true);
                end;

                LineNo += 10000;
                Jnl.Init();
                Jnl."Journal Template Name" := Setup."Gen. Jnl. Template";
                Jnl."Journal Batch Name" := Setup."Gen. Jnl. Batch";
                Jnl."Line No." := LineNo;
                Jnl.Validate("Document No.", DocNo);
                Jnl."Posting Date" := WorkDate();
                Jnl."US Mortgage No." := Sched."Loan No.";
                //Jnl."US Sch. Line No." := Sched."Line No.";
                Jnl."Account Type" := Jnl."Account Type"::"Bank Account";
                Jnl.Validate("Account No.", Loan."Bank Account No.");
                Jnl.Description := Sched.Description;
                Jnl.Validate(Amount, Sched."Amount Paying");
                Jnl.Validate("Dimension Set ID", Loan."Dimension Set Id");
                Jnl.Insert(true);

                Page.Run(Page::"General Journal", Jnl);
            end;
        end;
    end;
}
