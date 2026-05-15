table 60013 "US Commitment Header"
{
    DataClassification = CustomerContent;
    Caption = 'Commitment';

    fields
    {
        field(1; "Commitment No."; Code[20]) { }
        field(2; "Application No."; Code[20]) { TableRelation = "US Loan Application Header"."No."; }
        field(3; "Borrower Customer No."; Code[20]) { TableRelation = Customer."No."; }
        field(4; "Agent Contact No."; Code[20]) { TableRelation = Contact."No."; }

        field(10; "Approved Amount"; Decimal) { }
        field(11; "Approved Tenor (Months)"; Integer) { }
        field(12; "Approved Rate %"; Decimal) { DecimalPlaces = 0 : 5; }

        field(20; "Commitment Date"; Date) { }
        field(21; "Expiry Date"; Date) { }
        field(22; Status; Enum "GE Commitment Status") { }

        field(30; "Conditions Summary"; Text[250]) { }
        field(31; "Accepted Date"; Date) { }
        // field(32; "Purchase Price"; Decimal)
        // {
        //     DataClassification = CustomerContent;
        // }
        // field(33; "Down Payment"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }
        // field(34; "Intrest Rate %"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }
        field(72357575; "Envelope ID"; Text[100])
        {
            Caption = 'Envelope ID';
            DataClassification = CustomerContent;
        }
        field(72357576; "Document ID"; Text[100])
        {
            Caption = 'DocuSign Document ID';
            DataClassification = CustomerContent;
        }
        field(72357577; "Enable DocuSign"; Boolean)
        {
            Caption = 'Enable DocuSign';
            DataClassification = CustomerContent;
        }
        field(72357578; "Envelope Status"; Enum "Envelope Status")
        {
            Caption = 'Envelop Status';
            DataClassification = CustomerContent;
            //Editable = false;
            trigger OnValidate()
            begin
                if Rec."Envelope Status" = xRec."Envelope Status" then
                    exit;
                if Rec."Envelope Status" = "Envelope Status"::sent then begin
                    Rec."Envelope Sent Date" := CurrentDateTime();
                    Rec."User Security ID" := UserSecurityId();
                    // if DocuSignUser.Get() then
                    //     Rec."DocuSign User ID" := DocuSignUser.UserID;
                end else
                    if Rec."Envelope Status" = "Envelope Status"::completed then
                        Rec."Envelope Completed Date" := CurrentDateTime();
            end;
        }
        field(72357579; "Envelope Sent Date"; DateTime)
        {
            Caption = 'Date Sent';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(72357580; "Envelope Completed Date"; DateTime)
        {
            Caption = 'Date Completed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(72357581; "Envelope Sent By"; Text[100])
        {
            Caption = 'Sent By';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(User."Full Name" where("User Security ID" = field("User Security ID")));

        }
        field(72357582; "Signature Sequence"; Option)
        {
            OptionMembers = "In Order",Parallel;
            Caption = 'Signature Sequence';
            DataClassification = CustomerContent;
        }
        field(72357583; "DocuSign User ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'DocuSign User ID';
            Editable = false;
            //TableRelation = "DocuSign User";
        }
        field(72357584; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = User;
        }

        field(72357585; "Enclosed Document"; Text[250])
        {
            Caption = 'Enclosed Document';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(72357586; "Document Downloaded"; Boolean)
        {
            Caption = 'Signed Document Downloaded';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Commitment No.")
        {
            Clustered = true;
        }
    }
}

