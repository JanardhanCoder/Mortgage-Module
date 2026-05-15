table 60025 "GE Mortgage Agent"
{
    DataClassification = CustomerContent;
    Caption = 'Mortgage Agent';

    fields
    {
        field(1; "Agent Code"; Code[20]) { }
        field(2; "CRM Agent Contact No."; Code[20]) { TableRelation = Contact."No."; }
        field(3; "Payee Contact No."; Code[20])
        {
            TableRelation = Contact."No.";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if ("CRM Agent Contact No." <> '') and ("Payee Contact No." <> '') and ("CRM Agent Contact No." = "Payee Contact No.") then
                    Error('CRM Agent Contact and Payee Contact should be different.');
            end;
        }
        field(4; "Agent Vendor No."; Code[20]) { TableRelation = Vendor."No."; }
        field(5; "Default Agreement No."; Code[20]) { }
        field(6; Active; Boolean) { InitValue = true; }
    }

    keys { key(PK; "Agent Code") { Clustered = true; } }



    procedure GetAgentByCRMContact(CRMContactNo: Code[20]): Code[20]
    var
        Agent: Record "GE Mortgage Agent";
    begin
        Agent.SetRange("CRM Agent Contact No.", CRMContactNo);
        if Agent.FindFirst() then
            exit(Agent."Agent Code");
        exit('');
    end;

    procedure RequirePayeeSetup(AgentCode: Code[20])
    var
        Agent: Record "GE Mortgage Agent";
        Setup: Record "US Mortgage Posting Setup";
    begin
        Agent.Get(AgentCode);
        Setup.Get();

        if Setup."Lender Pays Agent Commission" then begin
            if Agent."Payee Contact No." = '' then
                Error('Payee Contact is required for Agent %1.', AgentCode);
            if Agent."Agent Vendor No." = '' then
                Error('Agent Vendor is required for Agent %1 because lender pays commission.', AgentCode);
        end;
    end;
}

