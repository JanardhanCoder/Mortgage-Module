namespace MortgageForUS.MortgageForUS;

using Microsoft.CRM.Contact;

page 60025 "Customer Related Contacts"
{
    PageType = List;
    SourceTable = Contact;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Phone No."; Rec."Phone No.") { ApplicationArea = All; }
                field("E-Mail"; Rec."E-Mail") { ApplicationArea = All; }
            }
        }
    }
}

