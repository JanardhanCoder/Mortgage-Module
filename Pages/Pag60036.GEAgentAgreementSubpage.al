namespace MortgageForUS.MortgageForUS;

page 60036 "GE Agent Agreement Subpage"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "GE Agent Agreement Line";
    Caption = 'Agreement Lines';
    AutoSplitKey = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Agreement No."; Rec."Agreement No.") { }
                field("Line No."; Rec."Line No.") { }
                field("Commission Type"; Rec."Commission Type") { }
                field("From Loan Amount"; Rec."From Loan Amount") { }
                field("To Loan Amount"; rec."To Loan Amount") { }
                field("Commission %"; Rec."Commission %") { }
                field("Commission Amount"; Rec."Commission Amount") { }
                field("Minimum Commission"; Rec."Minimum Commission") { }
                field("Maximum Commission"; Rec."Maximum Commission") { }
            }
        }
    }
}
