namespace MortgageForUS.MortgageForUS;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 60001 "general journal Line Ext" extends "General Journal"
{
    layout
    {
        addafter("Document No.")
        {
            field("US Mortgage No."; Rec."US Mortgage No.")
            {
                ApplicationArea = All;
            }
            field("US Schedule Status"; Rec."US Schedule Status")
            {
                ApplicationArea = all;
                Visible = false;
            }
            field("US Sch. Line No."; Rec."US Sch. Line No.")
            {
                Visible = false;
                ApplicationArea = all;
            }
        }
    }
}
