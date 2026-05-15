namespace Mortgage.Mortgage;

page 60005 "US Mortgage Posting Groups"
{
    PageType = List;
    SourceTable = "US Mortgage Posting Group";
    ApplicationArea = All;
    Caption = 'Mortgage Posting Groups';
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code) { }
                field(Description; Rec.Description) { }
                field("Loan Principal Receivable"; Rec."Loan Principal Receivable") { }
                field("Interest Receivable"; Rec."Interest Receivable") { }
                field("Interest Income"; Rec."Interest Income") { }
                field("Escrow Liability"; Rec."Escrow Liability") { }
                field("Deferred Fee Liability"; Rec."Deferred Fee Liability") { }
                field("Fee Income"; Rec."Fee Income") { }
                field("Penalty Income"; Rec."Penalty Income") { }
                field("Penalty Waiver GL"; Rec."Penalty Waiver GL") { }
                field("Agent Vendor Posting Group"; Rec."Agent Vendor Posting Group")
                {
                    Caption = 'Commission Expenses Account';
                }
            }

        }
    }
}

