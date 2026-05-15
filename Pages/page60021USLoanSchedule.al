namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;
using Microsoft.Finance.GeneralLedger.Journal;
page 60021 "US Loan Schedule Subpage"
{
    PageType = ListPart;
    SourceTable = "US Mortgage Schedule Line";
    ApplicationArea = All;
    Caption = 'Schedule';
    // SourceTableView=WHERE(Status = FILTER("GE Schedule Status"::Pending | "GE Schedule Status"::Paid));
    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                { Visible = false; }
                field("Due Date"; Rec."Due Date") { }
                field("Loan No."; Rec."Loan No.") { }
                field(Description; Rec.Description) { }
                field("Opening Principal"; Rec."Opening Principal") { Editable = false; }
                field("EMI Amount"; Rec."EMI Amount") { Editable = false; }
                field("Principal Amount"; Rec."Principal Amount") { Editable = false; }
                field("Interest Rate %"; Rec."Interest Rate %") { Editable = false; }
                field("Interest Amount"; Rec."Interest Amount") { Editable = false; }
                field("Escrow Amount"; Rec."Escrow Amount") { Visible = false; }
                field("Penalty Amount"; Rec."Penalty Amount") { Editable = false; }
                field("Penalty Calculated Date"; Rec."Penalty Calculated Date") { Editable = false; Caption = 'Penalty date'; }
                field("Amount Paying"; Rec."Amount Paying")
                { Editable = false; }
                field("Paid Date"; Rec."Paid Date") { Editable = false; }
                field("Paid Total Amount"; Rec."Paid Total Amount") { Editable = false; }
                field("Paid Principal"; Rec."Paid Principal") { Editable = false; }
                field("Paid Interest"; Rec."Paid Interest") { Editable = false; }
                field("Closing Principal"; Rec."Closing Principal") { Editable = false; }
                field(Status; Rec.Status) { Editable = false; }
                field(closed; Rec.closed) { Editable = false; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(PostEMI)
            {
                Caption = 'Post EMI Payment';
                Image = Payment;
                trigger OnAction()
                var
                    Sch: Record "US Mortgage Schedule Line";
                    SelLines: Record "US Mortgage Schedule Line";
                    MGMgt: Codeunit CreateJournals;
                    Jnl: Record "Gen. Journal Line";
                    Setup: Record "US Mortgage Posting Setup";
                begin
                    if Rec."Amount Paying" = 0 then
                        Error('Amount Paying is 0, cannot post payment.');

                    Setup.Get('SETUP');
                    Jnl.Reset();
                    Jnl.SetRange("Journal Template Name", Setup."Gen. Jnl. Template");
                    Jnl.SetRange("Journal Batch Name", Setup."Gen. Jnl. Batch");
                    Jnl.DeleteAll();
                    CurrPage.SetSelectionFilter(SelLines);
                    if SelLines.IsEmpty() then
                        Error('Please select at least one PDC.');
                    if SelLines.FindSet() then
                        repeat
                            MGMgt.CreateGenJournalFromSchedule(Rec);
                        until SelLines.Next() = 0;
                    //Rec.Status := rec.Status::Paid;
                end;
            }

            action(PostEMIPayment)
            {
                Caption = 'Post Multiple EMI Payments';
                ApplicationArea = All;
                Image = Post;

                trigger OnAction()
                var
                    SelSched: Record "US Mortgage Schedule Line";
                    Jnl: Record "Gen. Journal Line";
                    LineNo: Integer;
                begin
                    // 🔑 Get ALL selected lines
                    CurrPage.SetSelectionFilter(SelSched);

                    if SelSched.IsEmpty() then
                        Error('Please select at least one schedule line.');

                    LineNo := 0;

                    if SelSched.FindSet() then
                        repeat
                            // Create journal lines PER selected schedule
                            CreateJournalLines(SelSched, LineNo);
                        until SelSched.Next() = 0;
                end;
            }
            action(ShowActive)
            {
                Caption = 'Active EMIs';
                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Pending);
                end;
            }
            action(ShowOverDue)
            {
                Caption = 'OverDue EMIs';
                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Overdue);
                end;
            }
            action(ShowPaid)
            {
                Caption = 'Paid EMIs';
                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Paid);
                end;
            }

            action(ShowSettled)
            {
                Caption = 'Settled EMIs';
                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Settled);
                end;
            }
            action(Cancelled)
            {
                Caption = 'Cancelled EMI';
                ApplicationArea = all;
                RunObject = page "GE Cancelled EMI Lines";
                RunPageLink = "Loan No." = field("Loan No.");
            }
            action("Make OverDue")
            {
                Caption = 'Make OverDue';
                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Overdue;
                    CurrPage.Update();
                end;
            }

            // action(PostPenalty)
            // {
            //     Caption = 'Post Penalty';
            //     Image = Payment;
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     var
            //         PenaltyMgt: Codeunit "GE Mortgage Penalty Mgt.";
            //     begin
            //         PenaltyMgt.PostPenalty(Rec);
            //     end;


            // }
        }
    }
    local procedure CreateJournalLines(Sched: Record "US Mortgage Schedule Line"; var LineNo: Integer)
    var
        Jnl: Record "Gen. Journal Line";
        Loan: Record "US Mortgage Agreement Header";
        Posting: Record "US Mortgage Posting Group";
        PageJnl: Page "General Journal";
        SelSched: Record "US Mortgage Schedule Line";
    begin
        Jnl.Reset();
        Jnl.SetRange("Journal Template Name", 'GENERAL');
        Jnl.SetRange("Journal Batch Name", 'DEFAULT');
        Jnl.DeleteAll(true); // use TRUE for safety
        if Sched.Status = Sched.Status::Paid then
            Error('This installment is already paid.');

        // if not Setup.Get() then
        //     Error('Setup is missing.');
        //   Setup.Get();
        Posting.Get('MG');
        Loan.Get(Sched."Loan No.");
        CurrPage.SetSelectionFilter(SelSched);
        if SelSched.IsEmpty() then
            Error('Please select at least one schedule line.');
        if SelSched.FindSet() then
            repeat
                // PRINCIPAL
                if Sched."Principal Amount" <> 0 then begin
                    LineNo += 10000;
                    Jnl.Init();
                    Jnl."Journal Template Name" := 'GENERAL';
                    Jnl."Journal Batch Name" := 'DEFAULT';
                    Jnl."Line No." := LineNo;
                    Jnl."Posting Date" := WorkDate();
                    Jnl."US Mortgage No." := Sched."Loan No.";
                    Jnl."US Sch. Line No." := Sched."Line No."; // 🔑 UNIQUE PER SCHEDULE
                    Jnl."Document Type" := Jnl."Document Type"::Payment;
                    Jnl."Account Type" := Jnl."Account Type"::Customer;
                    Jnl."Account No." := Loan."Borrower Customer No.";
                    Jnl.Amount := -Sched."Principal Amount";
                    Jnl.Validate("Dimension Set ID", Loan."Dimension Set Id");
                    Jnl.Insert(true);
                end;

                // INTEREST
                if Sched."Interest Amount" <> 0 then begin
                    LineNo += 10000;
                    Jnl.Init();
                    Jnl."Journal Template Name" := 'GENERAL';
                    Jnl."Journal Batch Name" := 'DEFAULT';
                    Jnl."Line No." := LineNo;
                    Jnl."Posting Date" := WorkDate();
                    Jnl."US Mortgage No." := Sched."Loan No.";
                    Jnl."US Sch. Line No." := Sched."Line No.";
                    //Jnl."Document Type" := Jnl."Document Type"::Payment;
                    Jnl."Account Type" := Jnl."Account Type"::"G/L Account";
                    Jnl."Account No." := Posting."Interest Income";
                    Jnl.Amount := -Sched."Interest Amount";
                    Jnl.Validate("Dimension Set ID", Loan."Dimension Set Id");
                    //Jnl."Bal. Account Type" := Jnl."Bal. Account Type"::"Bank Account";
                    //Jnl."Bal. Account No." := Loan."Bank Account No.";
                    Jnl.Insert(true);
                end;

                LineNo += 10000;
                Jnl.Init();
                Jnl."Journal Template Name" := 'GENERAL';
                Jnl."Journal Batch Name" := 'DEFAULT';
                Jnl."Line No." := LineNo;
                Jnl."Posting Date" := WorkDate();
                Jnl."US Mortgage No." := Sched."Loan No.";
                Jnl."US Sch. Line No." := Sched."Line No.";
                //Jnl."Document Type" := Jnl."Document Type"::Payment;
                Jnl."Account Type" := Jnl."Account Type"::"Bank Account";
                Jnl."Account No." := Loan."Bank Account No.";
                Jnl.Amount := Sched."Interest Amount";
                Jnl.Validate("Dimension Set ID", Loan."Dimension Set Id");
                //Jnl."Bal. Account Type" := Jnl."Bal. Account Type"::"Bank Account";
                //Jnl."Bal. Account No." := Loan."Bank Account No.";
                Jnl.Insert(true);

            Until SelSched.Next() = 0;

        Page.Run(Page::"General Journal", Jnl);
    end;
}


