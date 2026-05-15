namespace MortgageForUS.MortgageForUS;

page 60050 "US Mortgage Schedule List"
{
    ApplicationArea = All;
    Caption = 'US Mortgage Schedule List';
    PageType = List;
    SourceTable = "US Mortgage Schedule Line";
    UsageCategory = Lists;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Line No."; Rec."Line No.")
                { Visible = false; }
                field("Due Date"; Rec."Due Date") { }
                field("Loan No."; Rec."Loan No.") { }
                field(Description; Rec.Description) { }
                field("Opening Principal"; Rec."Opening Principal") { Editable = false; }
                field("EMI Amount"; Rec."EMI Amount") { }
                field("Principal Amount"; Rec."Principal Amount") { }
                field("Interest Rate %"; Rec."Interest Rate %") { }
                field("Interest Amount"; Rec."Interest Amount") { }
                field("Escrow Amount"; Rec."Escrow Amount") { Visible = false; }
                field("Penalty Amount"; Rec."Penalty Amount") { }
                field("Penalty Calculated Date"; Rec."Penalty Calculated Date") { Caption = 'Penalty date'; }
                field("Paid Date"; Rec."Paid Date") { }
                field("Paid Total Amount"; Rec."Paid Total Amount") { }
                field("Paid Principal"; Rec."Paid Principal") { }
                field("Paid Interest"; Rec."Paid Interest") { }
                field("Closing Principal"; Rec."Closing Principal") { Editable = false; }
                field(Status; Rec.Status) { }
                field(closed; Rec.closed) { }
            }
        }
    }
}
