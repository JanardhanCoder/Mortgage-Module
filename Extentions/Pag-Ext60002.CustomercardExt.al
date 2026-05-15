namespace MortgageForUS.MortgageForUS;

using Microsoft.Sales.Customer;

pageextension 60002 "Customer card Ext" extends "Customer Card"
{
    layout
    {
        addafter("Primary Contact No.")
        {
            field("GE Broker Contact No."; Rec."GE Broker Contact No.")
            {
                ApplicationArea = all;
            }
        }
    }
}
