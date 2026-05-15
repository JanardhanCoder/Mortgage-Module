namespace Mortgage.Mortgage;
using Microsoft.Bank.BankAccount;

page 60022 "US Loan Receipt Wizard"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Caption = 'Loan Receipt';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(LoanNo; LoanNo) {TableRelation="US Mortgage Agreement Header"; Caption = 'Loan No.'; Editable = true; }
                field(PostingDate; PostingDate) { Caption = 'Posting Date'; }
                field(BankAccountNo; BankAccountNo) { Caption = 'Bank Account No.'; TableRelation = "Bank Account"."No."; }
                field(ExternalRef; ExternalRef) { Caption = 'External Reference'; }
            }
            group(Amounts)
            {
                field(TotalAmount; TotalAmount) { Caption = 'Total Amount'; }
                field(PenaltyPortion; PenaltyPortion) { }
                field(InterestPortion; InterestPortion) { Caption = 'Interest Portion'; }
                field(PrincipalPortion; PrincipalPortion) { Caption = 'Principal Portion'; }
                field(EscrowPortion; EscrowPortion) { Caption = 'Escrow Portion'; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Post)
            {
                Caption = 'Post';
                ApplicationArea = All;
                Image = Post;

                trigger OnAction()
                var
                    //PostCU: Codeunit 60023;
                    postCU: Codeunit 60023;
                begin
                    PostCU.PostReceipt(LoanNo, PostingDate, BankAccountNo, TotalAmount, PenaltyPortion, InterestPortion, PrincipalPortion, EscrowPortion, ExternalRef);
                    Message('Receipt posted.');
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        LoanNo: Code[20];
        PostingDate: Date;
        BankAccountNo: Code[20];
        ExternalRef: Text[50];
        TotalAmount: Decimal;
        InterestPortion: Decimal;
        PenaltyPortion: Decimal;
        PrincipalPortion: Decimal;
        EscrowPortion: Decimal;

    procedure SetLoan(NewLoanNo: Code[20])
    var
        Loan: Record "US Mortgage Agreement Header";
        Setup: Record "US Mortgage Posting Setup";
    begin
        LoanNo := NewLoanNo;
        PostingDate := Today;

        if Loan.Get(LoanNo) then begin
            BankAccountNo := Loan."Bank Account No.";
            if BankAccountNo = '' then
                if Setup.Get('SETUP') then
                    BankAccountNo := Setup."Default Bank Account No.";
        end;
    end;
}

