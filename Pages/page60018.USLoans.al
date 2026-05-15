
page 60018 "GE Loans"
{
    PageType = List;
    SourceTable = "US Mortgage Agreement Header";
    ApplicationArea = All;
    Caption = 'Loans';
    CardPageId = "US Loan Card";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Loan No."; Rec."Loan No.") { }
                field("Commitment No."; Rec."Commitment No.")
                { }
                field("Loan Application No."; Rec."Loan Application No.") { }
                field("Borrower Customer No."; Rec."Borrower Customer No.") { }
                field("Agent Contact No."; Rec."Agent Contact No.") { }
                field("Product Code"; Rec."Product Code") { }
                field("Principal Amount"; Rec."Principal Amount") { }
                field("Disbursed Amount"; Rec."Disbursed Amount") { }
                field("Interest Rate %"; Rec."Interest Rate %") { }
                field(Status; Rec.Status) { }
                field("Last Accrual Date"; Rec."Last Accrual Date") { }
            }
        }
    }
}
