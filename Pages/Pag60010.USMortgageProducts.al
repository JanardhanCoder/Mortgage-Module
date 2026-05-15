namespace Mortgage.Mortgage;

page 60010 "US Mortgage Products"
{
    PageType = List;
    SourceTable = "US Mortgage Product";
    ApplicationArea = All;
    Caption = 'Mortgage Products';
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code) { }
                field(Description; Rec.Description) { }
                field("Rate Type"; Rec."Rate Type") { }
                field("Default Rate %"; Rec."Default Rate %") { }
                field("Payment Frequency"; Rec."Payment Frequency") { }
                field("Posting Group Code"; Rec."Posting Group Code") { }
                field("Fee Recognition Method"; Rec."Fee Recognition Method") { }
                field("Accrual Basis"; Rec."Accrual Basis") { }
                field("Default Escrow Required"; Rec."Default Escrow Required") { }
            }
        }
    }
}

