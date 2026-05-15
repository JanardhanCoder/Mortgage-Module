namespace Mortgage.Mortgage;

page 60023 "US Loan Ledger Entries"
{
    PageType = List;
    SourceTable = "us Loan Ledger Entry";
    ApplicationArea = All;
    Caption = 'Loan Ledger Entries';
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Loan No."; Rec."Loan No.") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("Entry Type"; Rec."Entry Type") { }
                field("Amount Principal"; Rec."Amount Principal") { }
                field("Amount Interest"; Rec."Amount Interest") { }
                field("Amount Escrow"; Rec."Amount Escrow") { }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    Caption = 'No.';
                }
                field("External Reference"; Rec."External Reference") { }
                field("Document No."; Rec."Document No.") { }
                field(Posted; Rec.Posted) { }
            }
        }
    }

    procedure SetLoan(LoanNo: Code[20])
    begin
        Rec.SetRange("Loan No.", LoanNo);
    end;
}

