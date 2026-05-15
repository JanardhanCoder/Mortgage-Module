table 60024 "Loan Applicant Financials"
{
    Caption = 'Loan Applicant Financials';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Application No."; Code[20]) { TableRelation = "US Loan Application Header";}
        field(2; "Monthly Income"; Decimal) { }
        field(3; "Existing EMI"; Decimal) { }
        field(4; "Credit Score"; Integer) { }
        field(5; "Employment Type"; Option)
        {
            OptionMembers = " ",Salaried,SelfEmployed;
        }
    }
    keys
    {
        key(pk; "Application No.")
        {

        }
    }

}

