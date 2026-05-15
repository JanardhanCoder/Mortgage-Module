namespace MortgageForUS.MortgageForUS;

page 60034 "GE Agent Agreement List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "GE Agent Agreement Header";
    Caption = 'Agent Agreements';
    CardPageId="GE Agent Agreement Card";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { }
                field("Agent Vendor No."; Rec."Agent Vendor No.") { }
                field("Effective From Date"; Rec."Effective From Date") { }
                field("Effective To Date"; Rec."Effective To Date") { }
                field(Status; Rec.Status) { }
            }
        }
    }
}

