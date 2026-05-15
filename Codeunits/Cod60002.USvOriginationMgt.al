namespace Mortgage.Mortgage;
using Microsoft.Foundation.NoSeries;

codeunit 60002 "US Origination Mgt"
{
    procedure EnsureSetup()
    var
        Setup: Record "US Mortgage Posting Setup";
    begin
        if not Setup.Get('SETUP') then
            Error('Mortgage Setup is missing. Open "Mortgage Setup" and configure it.');
    end;

    procedure GetNextNo(NoSeriesCode: Code[20]): Code[20]
    var
        NoSeriesMgt: Codeunit "No. Series";
    begin
        exit(NoSeriesMgt.GetNextNo(NoSeriesCode, Today, true));
    end;

    procedure IssueCommitmentFromApplication(AppNo: Code[20]): Code[20]
    var
        Setup: Record "US Mortgage Posting Setup";
        App: Record "US Loan Application Header";
        Com: Record "US Commitment Header";
        No: Code[20];
    begin
        EnsureSetup();
        Setup.Get('SETUP');

        App.Get(AppNo);
        if App.Status <> App.Status::Approved then
            Error('Application must be Approved to issue a commitment.');

        No := GetNextNo(Setup."Commitment No. Series");

        Com.Init();
        Com."Commitment No." := No;
        Com."Application No." := App."No.";
        Com."Borrower Customer No." := App."Borrower Customer No.";
        Com."Agent Contact No." := App."Agent Contact No.";
        Com."Approved Amount" := App."Approved Amount";
        Com."Approved Tenor (Months)" := App."Approved Tenor (Months)";
        Com."Approved Rate %" := App."Current Interest %";
        Com."Commitment Date" := Today;
        Com.Status := Com.Status::Draft;
        Com.Insert(true);

        App."Created Commitment No." := No;
        App.Status := App.Status::"Agreement Created";
        App.Modify(true);

        exit(No);
    end;

    procedure UpdateLoanApplicationApproved(var commitment: Record "US Commitment Header")
    var
        App: Record "US Loan Application Header";
    begin
        App.SetRange("Created Commitment No.", commitment."Commitment No.");
        if App.FindFirst() then begin
            App.Decision := App.Decision::Approved;
            App."Approved Amount" := commitment."Approved Amount";
            App."Current Interest %" := commitment."Approved Rate %";
            App."Approved Rate %" := commitment."Approved Rate %";
            App."Approved Tenor (Months)" := commitment."Approved Tenor (Months)";
            App.Modify(true);
            Message('Loan Application approved successfully based on the commitment.');
        end;
    end;

    procedure CreateLoanFromCommitment(CommitmentNo: Code[20]): Code[20]
    var
        Setup: Record "US Mortgage Posting Setup";
        Com: Record "US Commitment Header";
        App: Record "US Loan Application Header";
        Product: Record "US Mortgage Product";
        Loan: Record "US Mortgage Agreement Header";
        AppCol: Record "US Loan App Collateral Line";
        LoanCol: Record "USLoan Collateral";
        LoanNo: Code[20];
        LineNo: Integer;
    begin
        EnsureSetup();
        Setup.Get('SETUP');

        if CommitmentNo = '' then
            Error('Commitment No. is blank.');

        Com.Get(CommitmentNo);
        App.Get(Com."Application No.");

        if Com.Status <> Com.Status::Accepted then
            Error('Commitment must be Accepted to create the loan.');

        Product.Get(App."Product Code");

        //LoanNo := GetNextNo(Setup."Loan No. Series");

        Loan.Init();
        Loan.InitNo();
        Loan.Insert();
        //Loan."Loan No." := LoanNo;
        Loan."Commitment No." := Com."Commitment No.";
        Loan."Loan Application No." := App."No.";
        Loan.Validate("Borrower Customer No.", Com."Borrower Customer No.");
        Loan."Agent Contact No." := Com."Agent Contact No.";
        Loan."Product Code" := App."Product Code";
        Loan."Principal Amount" := Com."Approved Amount";
        // Loan."Interest Rate %" := Com."Approved Rate %";
        Loan.Validate("Rate Code", App."Rate Code");
        Loan."Current Interest %" := App."Current Interest %";
        Loan.Validate("Interest Rate %", App."Current Interest %");
        Loan."Spread %" := App."Spread %";
        Loan."Tenor (Months)" := Com."Approved Tenor (Months)";
        Loan."Payment Frequency" := Product."Payment Frequency";
        Loan."Accrual Basis" := Product."Accrual Basis";
        Loan."Escrow Required" := Product."Default Escrow Required";
        Loan."Posting Group Code" := Product."Posting Group Code";
        Loan."Bank Account No." := Setup."Default Bank Account No.";
        Loan.Status := Loan.Status::Draft;

        Loan."Agreement Date" := Today;
        Loan."Effective Date" := Today;
        Loan."Maturity Date" := CalcDate(StrSubstNo('%1M', Loan."Tenor (Months)"), Loan."Effective Date");

        Loan.Modify();

        // Copy collaterals from application to loan
        LineNo := 0;
        AppCol.SetRange("Application No.", App."No.");
        if AppCol.FindSet() then
            repeat
                LineNo += 10000;
                LoanCol.Init();
                LoanCol."Loan No." := LoanNo;
                LoanCol."Line No." := LineNo;
                LoanCol."Collateral No." := AppCol."Collateral No.";
                LoanCol."Lien Position" := AppCol."Lien Position Requested";
                LoanCol.Insert(true);
            until AppCol.Next() = 0;

        // Update status links
        App."Created Loan No." := Loan."Loan No.";
        App.Status := App.Status::"Agreement Created";
        App.Modify(true);

        Com.Status := Com.Status::Accepted; // lender can change to Accepted upon borrower acceptance; simplified here
        Com."Accepted Date" := Today;
        Com.Modify(true);

        exit(LoanNo);
    end;
}
