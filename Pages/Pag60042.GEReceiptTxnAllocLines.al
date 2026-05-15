namespace MortgageForUS.MortgageForUS;
page 60042 "GE Receipt Txn Alloc Lines"
{
    PageType = ListPart;
    SourceTable = "GE Receipt Txn Alloc Line";
    ApplicationArea = All;
    Caption = 'Allocation Lines';
    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { }
                field("Schedule Line No."; Rec."Schedule Line No.") { }
                field("Due Date"; Rec."Due Date") { }
                field("Penalty Amount"; Rec."Penalty Amount") { }
                field("Interest Amount"; Rec."Interest Amount") { }
                field("Principal Amount"; Rec."Principal Amount") { }
                field("Escrow Amount"; Rec."Escrow Amount") { }
                field(Applied; Rec.Applied) { }
                field("Applied At"; Rec."Applied At") { }
            }
        }
    }
}

