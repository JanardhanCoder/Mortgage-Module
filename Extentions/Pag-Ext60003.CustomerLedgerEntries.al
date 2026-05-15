namespace MortgageForUS.MortgageForUS;

using Microsoft.Sales.Receivables;

pageextension 60003 "Customer Ledger Entries" extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("US Loan No."; Rec."US Loan No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}
