namespace MortgageForUS.MortgageForUS;

page 60035 "GE Agent Agreement Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "GE Agent Agreement Header";
    Caption = 'Agent Agreement';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; rec."No.") {}
                field("Agent Vendor No."; rec."Agent Vendor No.") {}
                field("Agent Contact No."; Rec."Agent Contact No.") {}
                field("Commission Basis"; Rec."Commission Basis") {}
                field("Effective From Date"; rec."Effective From Date") {}
                field("Effective To Date"; Rec."Effective To Date") {}
                field(Status; rec.Status) {}
            }

            part(Lines; "GE Agent Agreement Subpage")
            {
                SubPageLink = "Agreement No." = field("No.");
            }
        }
    }
}

