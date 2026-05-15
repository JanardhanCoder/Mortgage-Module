namespace MortgageForUS.MortgageForUS;

using Microsoft.Finance.GeneralLedger.Ledger;
using Mortgage.Mortgage;

tableextension 60002 GLEntryExt extends "G/L Entry"
{
    fields
    {
        field(60000; "US Mortgage No."; Code[20])
        {
            Caption = 'US Mortgage No.';
            DataClassification = ToBeClassified;
            TableRelation = "US Mortgage Agreement Header";
        }
        field(60001; "Loan Entry Type"; Enum "GE Loan Entry Type")
        {
            DataClassification = ToBeClassified;
        }
    }
}
