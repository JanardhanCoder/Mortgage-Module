namespace MortgageForUS.MortgageForUS;

using Microsoft.Sales.Customer;
using Microsoft.CRM.Contact;

tableextension 60003 "Customer Ext" extends Customer
{
    fields
    {
        field(60000; "GE Broker Contact No."; Code[20])
        {
            Caption = 'Broker Contact No.';
            TableRelation = Contact."No.";
        }
    }
}
