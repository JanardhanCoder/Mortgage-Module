namespace Mortgage.Mortgage;
using MortgageForUS.MortgageForUS;

page 60017 "US Commitments"
{
    PageType = List;
    SourceTable = "US Commitment Header";
    ApplicationArea = All;
    Caption = 'Commitments';
    UsageCategory = Lists;
    CardPageId = "Commitment Aggrement Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Commitment No."; Rec."Commitment No.") { }
                field("Application No."; Rec."Application No.") { }
                field("Borrower Customer No."; Rec."Borrower Customer No.") { }
                field("Agent Contact No."; Rec."Agent Contact No.") { }
                field("Approved Amount"; Rec."Approved Amount") { }
                field("Approved Rate %"; Rec."Approved Rate %") { }
                field("Approved Tenor (Months)"; Rec."Approved Tenor (Months)") { }
                field(Status; Rec.Status) { }
                field("Expiry Date"; Rec."Expiry Date") { }
            }
        }
    }
}

page 60020 "GE Loan Collateral Subpage"
{
    PageType = ListPart;
    SourceTable = "USLoan Collateral";
    ApplicationArea = All;
    Caption = 'Loan Collaterals';

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Collateral No."; Rec."Collateral No.") { }
                field("Lien Position"; Rec."Lien Position") { }
                field("Registration Ref."; Rec."Registration Ref.") { }
                field("Registered Date"; Rec."Registered Date") { }
                field(Notes; Rec.Notes) { }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        L: Record "USLoan Collateral";
    begin
        if Rec."Line No." = 0 then begin
            L.SetRange("Loan No.", Rec."Loan No.");
            if L.FindLast() then
                Rec."Line No." := L."Line No." + 10000
            else
                Rec."Line No." := 10000;
        end;
    end;
}
