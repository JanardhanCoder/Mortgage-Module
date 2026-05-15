
page 60019 "US Loan Card"
{
    PageType = Card;
    SourceTable = "US Mortgage Agreement Header";
    ApplicationArea = All;
    Caption = 'Loan';
    PromotedActionCategories = 'Home,release,reports,Schedule,Pre-Settlement,Loan,Loan Ledger Entries';
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    trigger OnAssistEdit()
                    var
                        myInt: Integer;
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Commitment No."; Rec."Commitment No.") { }
                field("Loan Application No."; Rec."Loan Application No.") { }
                field("Borrower Customer No."; Rec."Borrower Customer No.") { }
                field("Customer Name"; Rec."Customer Name")
                {
                    Editable = false;
                }
                field("Agent Contact No."; Rec."Agent Contact No.") { }
                field(Status; Rec.Status) { }
            }
            group(Terms)
            {
                field("Product Code"; Rec."Product Code") { }
                field("Principal Amount"; Rec."Principal Amount") { }
                field("Rate Code"; Rec."Rate Code")
                {
                    trigger OnValidate()
                    var
                        RateMgmt: Codeunit "Interest Rate Management";
                    begin
                        Rec."Current Interest %" := RateMgmt.GetCurrentInterestRate(Rec."Rate Code", Rec."Spread %", WorkDate);
                    end;
                }
                field("Current Interest %"; Rec."Current Interest %") { }
                field("Spread %"; Rec."Spread %") { }
                field("Interest Rate %"; Rec."Interest Rate %") { Visible = true; }
                field("Tenor (Months)"; Rec."Tenor (Months)") { }
                field("Payment Frequency"; Rec."Payment Frequency") { }
                field("Accrual Basis"; Rec."Accrual Basis") { }
                field("Penalty Method"; Rec."Penalty Method") { }
                field("Penalty Rate %"; Rec."Penalty Rate %") { }
                field("Penalty Flat Amount"; Rec."Penalty Flat Amount") { }
                field("Agreement Date"; Rec."Agreement Date") { }
                field("Effective Date"; Rec."Effective Date") { }
                field("Maturity Date"; Rec."Maturity Date") { }
                field("EMI Amount"; Rec."EMI Amount")
                {

                }
                field("Remaining EMI Count"; Rec."Remaining EMI Count") { }

            }
            group("Pre&Settlement")
            {
                field("Pre-Settlement Allowed"; Rec."Allow Pre-Settlement") { }
                field("Pre-Settlement Type"; Rec."Pre-Settlement Type") { }
                field("Pre-Settlement Option"; Rec."Pre-Settlement Option") { }
                // field("Pre-Settlement Request Date"; Rec."Pre-Settlement Request Date") { }
                field("Pre-Settlement Date"; Rec."Pre-Settlement Date") { }
                field("Pre-Settlement Amount"; Rec."Pre-Settlement Amount") { }
                field("Pre-Settlement Penalty %"; Rec."Pre-Settlement Penalty %") { }
                field("Pre-Settlement Penalty Amount"; Rec."Pre-Settlement Penalty Amount") { }
                //field("Waiver Amount"; Rec."Waiver Amount") { }
                field("Pre-Settlement Doc No."; Rec."Pre-Settlement Doc No.") { }
                field("Pre-Settlement Posted Amount"; Rec."Pre-Settlement Posted Amount") { }
                field("Pre-Settlement Posted"; Rec."Pre-Settlement Posted") { }
                field("Keep Tenure Applied"; Rec."Keep Tenure Applied") { }

                group("Outstanding")
                {
                    field("Outstanding Principal"; Rec."Outstanding Principal") { Editable = true; }
                    field("Outstanding Interest"; Rec."Outstanding Interest") { Editable = true; }

                }
            }

            group("Charges & Waivers")
            {
                field("Pre-Settlement Charge %"; Rec."Pre-Settlement Charge %") { }
                field("Pre-Settlement Charge Amount"; Rec."Pre-Settlement Charge Amount") { Editable = false; }
                field("Waiver Amount"; Rec."Waiver Amount") { }
            }
            group(Posting)
            {
                field("Posting Group Code"; Rec."Posting Group Code") { }
                field("Bank Account No."; Rec."Bank Account No.") { }
                field("Escrow Required"; Rec."Escrow Required") { }
                field("Escrow Monthly Amount"; Rec."Escrow Monthly Amount") { }
                field("Deferred Fee Amount"; Rec."Deferred Fee Amount") { }
                field("Disbursed Amount"; Rec."Disbursed Amount") { Editable = false; }
                field("Agent Commission Amount"; Rec."Agent Commission Amount") { Editable = false; }
                field("Agent Commission Posted"; Rec."Agent Commission Posted") { Editable = false; }
                field("Last Accrual Date"; Rec."Last Accrual Date") { Editable = false; }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code") { }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code") { }
                field("Dimension set ID"; Rec."Dimension set ID") { }
            }
            group(LHFS)
            {
                field("Loan Strategy"; Rec."Loan Strategy") { ApplicationArea = All; }
                field("Accounting Classification"; Rec."Accounting Classification") { ApplicationArea = All; }
                field("Intended Investor Code"; Rec."Intended Investor Code") { ApplicationArea = All; }
                field("Investor Program"; Rec."Investor Program") { ApplicationArea = All; }
                field("Expected Sale Window"; Rec."Expected Sale Window") { ApplicationArea = All; }
                field("Sale Method"; Rec."Sale Method") { ApplicationArea = All; }
                field("Hedge Flag"; Rec."Hedge Flag") { ApplicationArea = All; }
            }

            //part(Collaterals; "GE Loan Collateral Subpage") { SubPageLink = "Loan No." = field("Loan No."); }
            part(Schedule; "US Loan Schedule Subpage")
            {
                SubPageLink = "Loan No." = field("Loan No.");
                SubPageView = WHERE(Status = FILTER("GE Schedule Status"::Pending | "GE Schedule Status"::Paid | "GE Schedule Status"::Settled | "GE Schedule Status"::Overdue));
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(GenerateSchedule)
            {
                Caption = 'Generate Schedule';
                ApplicationArea = ALL;
                Promoted = true;
                PromotedCategory = Category4;
                Image = Calculate;
                trigger OnAction()
                var
                    SchMgt: Codeunit "Mortgage Schedule Generator";
                begin
                    SchMgt.GenerateMonthlySchedule(Rec."Loan No.", Rec."Effective Date");
                    Message('Schedule generated.');
                end;
            }
            action(LoanScheduleList)
            {
                Caption = 'Schedule List';
                ApplicationArea = ALL;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = page "US Loan Schedule Subpage";
                RunPageLink = "Loan No." = field("Loan No.");
            }

            action(FullPreSettlement)
            {
                Caption = 'Full Payment';
                Image = Payment;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category5;

                trigger OnAction()
                var
                    PreSettlementCU: Codeunit "Loan Full Pre-Settlement";
                begin
                    Rec.TestField(Status, Rec.Status::Active);

                    PreSettlementCU.CreateJnlLines(
                        Rec,
                        WorkDate(),
                        Rec."Waiver Amount",
                        'GENERAL',
                        'DEFAULT');

                    Message('Pre-settlement journal lines created. Please review and post.');
                end;
            }

            action(ExecuteLoan)
            {
                Caption = 'Execute';
                ApplicationArea = All;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Executed;
                    Rec.Modify(true);
                    Message('Loan executed.');
                end;
            }


            action(ActivateLoan)
            {
                Caption = 'Activate';
                ApplicationArea = All;
                Image = ActivateDiscounts;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    if Rec.Status <> Rec.Status::Executed then
                        Error('Loan must be Executed before activation.');
                    Rec.Status := Rec.Status::Active;
                    Rec.Modify(true);
                    Message('Loan activated.');
                end;
            }
            action(PostDisbursement)
            {
                Caption = 'Post Disbursement';
                ApplicationArea = All;
                Image = Payment;

                trigger OnAction()
                var
                    // Post: Codeunit "US Schedule Mg";
                    Post: Codeunit 60023;
                begin
                    Post.PostDisbursement(Rec."Loan No.", Today, Rec."Bank Account No.", Rec."Principal Amount", 'Funding');
                    //Message('Disbursement posted.');
                    CurrPage.Update();
                end;
            }
            action("Partial Pre-Settlement")
            {
                Caption = 'Partial Pre-Settlement new';
                Image = Prepayment;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category5;
                trigger OnAction()
                var
                    PreSetMgt: Codeunit "Partial Pre-Settlement Mgt";
                begin
                    PreSetMgt.PrepareAndOpenJournal(Rec);

                    Message(
                      'Journal created. Review and post to apply Pre-Settlement.');
                end;
            }

            action(PostCommission)
            {
                Caption = 'Post Agent Commission';
                ApplicationArea = All;
                Image = GeneralLedger;
                Enabled = CommisssionEnabled;
                trigger OnAction()
                var
                    //  Post: Codeunit "US Schedule Mg";
                    post: Codeunit "GE Agent Commission Post";
                    Amt: Decimal;
                begin


                    Post.PostAgentCommission(Rec."Loan No.", Rec);
                    // Message('Accrual posted: %1', Amt);
                    CurrPage.Update();
                end;
            }
            action(PostAccrual)
            {
                Caption = 'Post Interest Accrual (Today)';
                ApplicationArea = All;
                Image = GeneralLedger;
                trigger OnAction()
                var
                    //  Post: Codeunit "US Schedule Mg";
                    post: Codeunit 60023;
                    Amt: Decimal;
                begin
                    Amt := Post.CalcMonthlyInterestEstimate(Rec."Loan No.", Today);
                    Message('Amount %1', Amt);
                    if Amt <= 0 then
                        Error('Calculated accrual is zero.');
                    Post.PostInterestAccrual(Rec."Loan No.", Today, Amt);
                    Message('Accrual posted: %1', Amt);
                    CurrPage.Update();
                end;
            }

            action(PostReceiptGuided)
            {
                Caption = 'Register Receipt';
                ApplicationArea = All;
                Image = CashReceiptJournal;
                RunObject = page "US Loan Receipt Wizard";
                // RunPageLink = LoanNo = field("Loan No.")
                // trigger OnAction()
                // var
                //     Wiz: Page "US Loan Receipt Wizard";
                // begin
                //     Wiz.SetLoan(Rec."Loan No.");
                //     Wiz.RunModal();
                //     CurrPage.Update();
                // end;
            }
            action(ViewLoanLedger)
            {
                Caption = 'Loan Ledger Entries';
                ApplicationArea = All;
                Image = Ledger;
                Promoted = true;
                PromotedCategory = Category7;
                trigger OnAction()
                var
                    LLE: Page "us Loan Ledger Entries";
                begin
                    LLE.SetLoan(Rec."Loan No.");
                    LLE.RunModal();
                end;
            }
            action(LoanArrangements)
            {
                Caption = 'Loan Arrangements';
                Image = Change;
                Promoted = true;
                PromotedCategory = Category6;

                trigger OnAction()
                var
                    ArrHdr: Record "GE Loan Arrangement Header";
                begin
                    ArrHdr.Reset();
                    ArrHdr.SetRange("Loan No.", Rec."Loan No.");
                    Page.Run(Page::"GE Loan Arrangement List", ArrHdr);
                end;
            }
            action(RecastSchedule)
            {
                Caption = 'Recast Schedule (After Prepayment)';
                ApplicationArea = All;
                Image = Recalculate;

                trigger OnAction()
                var
                    R: Codeunit "GE Loan Recast";
                begin
                    R.RecastFromNextPeriod(Rec."Loan No.");
                    Message('Schedule recast completed.');
                    CurrPage.Update();
                end;
            }
            action(ViewReceiptTxns)
            {
                Caption = 'Receipt Transactions';
                ApplicationArea = All;
                Image = Ledger;
                RunObject = page "GE Receipt Txns";
                RunPageLink = "Loan No." = field("Loan No.");
                // trigger OnAction()
                // var
                //     TxnList: Page "GE Receipt Txns";
                //     Txn: Record "GE Receipt Txn Header";
                // begin
                //     Txn.SetRange("Loan No.", Rec."Loan No.");
                //     TxnList.SetTableView(Txn);
                //     TxnList.RunModal();
                // end;
            }
            group(HeldForSale)
            {
                Caption = 'Held For Sale';
                action(Reclassification)
                {
                    trigger OnAction()
                    var
                        post: Codeunit "GE Loan Reclassification";
                    begin
                        post.PostReclassification(Rec."Loan No.", Rec."Outstanding Principal", Today);
                        Rec.Status := Rec.Status::ReClassification;
                        Rec.Modify();
                    end;
                }
                action(Sale)
                {
                    trigger OnAction()
                    var
                        post: Codeunit "GE Loan Reclassification";
                    begin
                        post.PostLoanSale(Rec."Loan No.", Rec."Outstanding Principal", Rec."Outstanding Principal", Today);
                        Rec.Status := Rec.Status::"Held For Sale";
                        Rec.Modify();
                    end;
                }
            }

        }
    }
    local procedure ConfirmPartialPreSettlement(
        Loan: Record "US Mortgage Agreement Header"): Boolean
    begin
        Loan.TestField("Pre-Settlement Amount");
        Loan.TestField("Pre-Settlement Date");

        if Loan."Pre-Settlement Amount" <= 0 then
            Error('Partial pre-settlement amount must be greater than zero.');

        if Loan."Pre-Settlement Amount" >= Loan."Outstanding Principal" then
            Error('Partial amount cannot be greater than or equal to outstanding principal.');

        exit(
            Confirm(
                'You are about to apply a partial pre-settlement of %1 on %2.\' +
                'This will cancel future EMI lines and regenerate the schedule.\' +
                'Do you want to continue?',
                false,
                Loan."Pre-Settlement Amount",
                Loan."Pre-Settlement Date"));
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Rec.RecalculateOutstandingAmounts();
    end;

    trigger OnAfterGetRecord()
    var
        Sched: Record "US Mortgage Schedule Line";
    begin
        CommissionPostingEnable();
        Rec.RecalculateOutstandingAmounts();
        Rec.CalcOutstandingInterest(Rec);
        Sched.SetRange("Loan No.", Rec."Loan No.");
        Sched.SetRange(Status, Sched.Status::paid);
        //Sched.SetRange(closed, false);
        // Sched.SetFilter(Status, '<>%1', Sched.Status::Paid);
        if Sched.findlast() then
            Rec."Last Accrual Date" := Sched."Paid Date";
        Rec.Modify();
    end;


    procedure CommissionPostingEnable()
    var
        myInt: Integer;
    begin
        Clear(CommisssionEnabled);
        if Rec."Disbursed Amount" > 0 then
            CommisssionEnabled := true
        else
            CommisssionEnabled := false;
    end;

    var
        bank: Record "Bank Account Ledger Entry";
        CommisssionEnabled: Boolean;
}
