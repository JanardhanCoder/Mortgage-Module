namespace MortgageForUS.MortgageForUS;

using Microsoft.Finance.GeneralLedger.Journal;
using Mortgage.Mortgage;
tableextension 60001 "Gen. Journal Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(60003; "US Mortgage No."; Code[20])
        {
            Caption = 'US Mortgage No.';
            DataClassification = ToBeClassified;
            TableRelation = "US Mortgage Agreement Header";
        }
        field(60004; "US Schedule Status"; Enum "GE Schedule Status")
        {
            Caption = 'Schedule Status';
            DataClassification = ToBeClassified;
            TableRelation = "US Mortgage Schedule Line";
        }
        field(60005; "US Sch. Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(60006; "Loan Entry Type"; Enum "GE Loan Entry Type")
        {
            DataClassification = ToBeClassified;
        }
    }
}
