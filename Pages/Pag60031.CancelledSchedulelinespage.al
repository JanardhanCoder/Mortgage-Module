namespace MortgageForUS.MortgageForUS;
page 60031 "GE Cancelled EMI Lines"
{
    PageType = List;
    SourceTable = "US Mortgage Schedule Line";
    Caption = 'Cancelled EMI Schedule';
    ApplicationArea = all;
    SourceTableView = where(Status = const(Cancelled));
    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Due Date"; Rec."Due Date") { }
                field(Description; Rec.Description) { }
                field("EMI Amount"; Rec."EMI Amount") { }
                field("Principal Amount"; Rec."Principal Amount") { }
                field("Interest Rate %"; Rec."Interest Rate %") { }
                field("Interest Amount"; Rec."Interest Amount") { }
                field("Escrow Amount"; Rec."Escrow Amount") { }
                field("Penalty Amount"; Rec."Penalty Amount") { }
                field("Penalty Calculated Date"; Rec."Penalty Calculated Date") { Caption = 'Penalty date'; }
                field("Paid Date"; Rec."Paid Date") { }
                field("Paid Total Amount"; Rec."Paid Total Amount") { Visible = false; }
                field("Paid Principal"; Rec."Paid Principal") { }
                field(Status; Rec.Status) { }
                field(closed; Rec.closed) { }
            }
        }

    }
}

