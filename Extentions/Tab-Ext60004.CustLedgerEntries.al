namespace MortgageForUS.MortgageForUS;

using Microsoft.Sales.Receivables;

tableextension 60004 "Cust Ledger Entries" extends "Cust. Ledger Entry"
{
    fields
    {
        field(60000; "US Loan No."; Code[20])
        {
            Caption = 'US Loan No.';
            DataClassification = CustomerContent;
        }
    }
}
