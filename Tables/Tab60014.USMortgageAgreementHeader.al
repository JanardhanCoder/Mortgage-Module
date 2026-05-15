table 60014 "US Mortgage Agreement Header"
{
    DataClassification = CustomerContent;
    Caption = 'Mortgage Agreement (Loan)';

    fields
    {
        field(1; "Loan No."; Code[20])
        {
            trigger OnValidate()
            begin
                if "Loan No." <> xRec."Loan No." then begin
                    Setup.Get();
                    NoSeriesMgt.TestManual(GetNoSeriesCode);
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Commitment No."; Code[20]) { TableRelation = "US Commitment Header"."Commitment No."; }
        field(3; "Borrower Customer No."; Code[20])
        {
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                cust: Record Customer;
            begin
                if "Borrower Customer No." <> '' then begin
                    cust.SetRange("No.", "Borrower Customer No.");
                    if cust.FindFirst() then
                        "Customer Name" := cust.Name;
                end;
            end;
        }
        field(4; "Agent Contact No."; Code[20])
        {
            TableRelation = Contact."No.";
        }
        field(5; "Loan End Date"; Date) { }
        field(6; "Loan Application No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "US Loan Application Header";
        }
        field(10; "Product Code"; Code[20]) { TableRelation = "US Mortgage Product".Code; }
        field(11; "Posting Group Code"; Code[20]) { TableRelation = "US Mortgage Posting Group".Code; }
        field(12; "Bank Account No."; Code[20]) { TableRelation = "Bank Account"."No."; }
        field(13; "Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(20; "Agreement Date"; Date) { }
        field(21; "Effective Date"; Date) { }
        field(22; "Maturity Date"; Date) { }

        field(30; "Principal Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                CalcEMI();
            end;
        }
        field(24; "EMI Amount"; Decimal) { }
        field(25; "Remaining EMI Count"; Integer) { }
        field(31; "Disbursed Amount"; Decimal) { }
        field(32; "Interest Rate %"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                CalcEMI();
            end;
        }
        field(23; "Last Interest Calc Date"; Date)
        {
            Caption = 'Last Interest Calc Date';
            DataClassification = CustomerContent;
        }
        field(33; "Tenor (Months)"; Integer)
        {
            trigger OnValidate()
            begin
                CalcEMI();
            end;
        }
        field(34; "Payment Frequency"; Option) { OptionMembers = Monthly,Quarterly,HalfYearly,Yearly; }
        field(35; "Accrual Basis"; Enum "GE Accrual Basis") { }

        field(40; "Escrow Required"; Boolean) { }
        field(41; "Escrow Monthly Amount"; Decimal) { }
        field(42; "Deferred Fee Amount"; Decimal) { }

        field(50; Status; Enum "GE Loan Status") { }
        field(51; "Last Accrual Date"; Date) { }
        field(52; "Rate Code"; Code[20])
        {
            TableRelation = "GE Interest Rate Setup"."Rate Code";
        }
        field(53; "Spread %"; Decimal)
        {
            Caption = 'Spread %';
        }
        field(54; "Current Interest %"; Decimal)
        {
            Editable = false;
        }
        field(55; "Penalty Method"; Option)
        {
            OptionMembers = None,"Flat","Rate Per Day";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                Setup.Get('SETUP');

                if "Penalty Method" = "Penalty Method"::"Rate Per Day" then begin
                    "Penalty Rate %" := Setup."Penalty Percent/Amount" / 30;
                    "Penalty Flat Amount" := 0;
                end
                else if "Penalty Method" = "Penalty Method"::None then begin
                    "Penalty Rate %" := 0;
                    "Penalty Flat Amount" := 0;
                end
                else begin
                    "Penalty Rate %" := 0;
                    "Penalty Flat Amount" := Setup."Penalty Percent/Amount";
                end;
            end;
        }
        field(56; "Penalty Rate %"; Decimal) { }
        field(57; "Penalty Flat Amount"; Decimal) { }
        field(58; "Outstanding Principal"; Decimal)
        {
            trigger OnValidate()
            begin
                CalcOutstandingInterest(Rec);
            end;
        }
        field(59; "Outstanding Interest"; Decimal) { }
        field(60; "Currency Code"; Code[20]) { }
        field(61; "Allow Pre-Settlement"; Boolean) { }
        field(62; "Pre-Settlement Date"; Date) { }
        field(63; "Pre-Settlement Penalty %"; Decimal) { }
        field(64; "Pre-Settlement Penalty Amount"; Decimal) { }
        field(65; "Pre-Settlement Amount"; Decimal) { }
        field(66; "Pre-Settlement Posted"; Boolean) { }
        field(67; "Pre-Settlement Doc No."; Code[20]) { }
        field(68; "Pre-Settlement Posted Amount"; Decimal) { }
        field(69; "Waiver Amount"; Decimal) { }
        field(70; "Pre-Settlement Charge %"; Decimal) { }
        field(71; "Pre-Settlement Charge Amount"; Decimal) { }
        field(72; "Pre-Settlement Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Full Payment","Partial Payment";
        }
        field(73; "Pre-Settlement Option"; Enum "Pre-Settlement Option")
        {
            DataClassification = ToBeClassified;
        }
        field(74; "Keep Tenure Applied"; Boolean) { }
        field(75; "Agent Commission Amount"; Decimal) { }
        field(76; "Agent Commission Posted"; Boolean) { }
        field(77; "Borrower IBAN"; Code[50]) { }
        field(78; "Loan Strategy"; Enum "US Loan Strategy")
        {
            Caption = 'Loan Strategy';
            DataClassification = CustomerContent;
        }

        field(79; "Accounting Classification"; Enum "US Accounting Classification")
        {
            Caption = 'Accounting Classification';
            DataClassification = CustomerContent;
        }

        field(80; "Intended Investor Code"; Code[20])
        {
            Caption = 'Intended Investor';
            TableRelation = "US Investor Master";
            DataClassification = CustomerContent;
        }

        field(81; "Investor Program"; Code[20])
        {
            Caption = 'Investor Program';
            DataClassification = CustomerContent;
        }

        field(82; "Expected Sale Window"; Date)
        {
            Caption = 'Expected Sale Window';
            DataClassification = CustomerContent;
        }

        field(83; "Sale Method"; Enum "US Loan Sale Method")
        {
            Caption = 'Sale Method';
            DataClassification = CustomerContent;
        }

        field(84; "Hedge Flag"; Boolean)
        {
            Caption = 'Pipeline Hedging';
            DataClassification = CustomerContent;
        }
        field(122; "Dimension Set Id"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            var
                myInt: Integer;
            begin
                Rec.ShowDocDim();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(123; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                Rec.ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(124; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                Rec.ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(125; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        //field(126; "Current Investor Sale No."; Code[20]) { Caption = 'Current Investor Sale No.'; }
        // field(74; "Principal Paid"; Decimal) { DataClassification = ToBeClassified; }
    }

    keys { key(PK; "Loan No.") { Clustered = true; } }

    trigger OnInsert()
    begin
        InitNo();
        if "Agreement Date" = 0D then
            "Agreement Date" := Today;
        if Status = Status::Draft then; // keep
    end;

    var
        loan: page "Loaner List";
        Setup: Record "US Mortgage Posting Setup";
        NoSeriesMgt: Codeunit "No. Series";

    procedure GetNoseriesCode(): Code[20]
    var
        myInt: Integer;
    begin
        Setup.Get('SETUP');
        Setup.TestField("Loan No. Series");
        exit(Setup."Loan No. Series");
    end;

    procedure InitNo()
    var
        myInt: Integer;
    begin
        if "Loan No." = '' then begin
            if NoSeriesMgt.AreRelated(GetNoSeriesCode(), xRec."No. Series") then
                "No. Series" := xRec."No. Series"
            else
                "No. Series" := GetNoSeriesCode();
            "Loan No." := NoSeriesMgt.GetNextNo("No. Series");

            "Penalty Method" := Setup."Penalty Method";
            if "Penalty Method" = "Penalty Method"::"Rate Per Day" then
                "Penalty Rate %" := Setup."Penalty Percent/Amount"
            else
                "Penalty Flat Amount" := Setup."Penalty Percent/Amount";
        end;
    end;

    procedure AssistEdit(OldAG: Record "US Mortgage Agreement Header"): Boolean
    begin
        if NoSeriesMgt.LookupRelatedNoSeries(GetNoSeriesCode(), OldAG."No. Series", "No. Series") then begin
            "Loan No." := NoSeriesMgt.GetNextNo("No. Series");
            exit(true);
        end;
    end;

    procedure RecalculateOutstandingAmounts()
    var
        Sched: Record "US Mortgage Schedule Line";
        "OutstandingPrincipalAmt": Decimal;
        "OutstandingInterestAmt": Decimal;
    begin
        "Outstanding Principal" := 0;
        "Outstanding Interest" := 0;
        Clear(OutstandingPrincipalAmt);
        Clear(OutstandingInterestAmt);
        Sched.Reset();
        Sched.SetRange("Loan No.", "Loan No.");
        Sched.SetRange(Status, Sched.Status::Pending);
        //Sched.SetRange(closed, false);
        // Sched.SetFilter(Status, '<>%1', Sched.Status::Paid);

        if Sched.FindSet() then
            repeat
                "Outstanding Principal" += Sched."Principal Amount";
                "Outstanding Interest" += Sched."Interest Amount";
            until Sched.Next() = 0;
    end;


    procedure CalcOutstandingInterest(var Loan: Record "US Mortgage Agreement Header")
    var
        FromDate: Date;
        Days: Integer;
        DailyRate: Decimal;
        Interest: Decimal;
    begin
        // Safety check
        if Loan."Effective Date" = 0D then
            exit;

        // Use Last Interest Calc Date if exists; else Loan Start Date
        if Loan."Last Interest Calc Date" = 0D then
            FromDate := Loan."Effective Date"
        else
            FromDate := Loan."Last Interest Calc Date";

        Days := Today - FromDate;

        if Days <= 0 then
            exit; // Nothing to calculate

        DailyRate := Loan."Interest Rate %" / 100 / 365;
        Interest := Loan."Outstanding Principal" * DailyRate * Days;

        // Update outstanding interest and last calc date
        Loan."Outstanding Interest" += Round(Interest, 0.01);
        Loan."Last Interest Calc Date" := Today;

        Loan.Modify();
    end;


    local procedure CalcEMI()
    var
        P: Decimal;
        r: Decimal;
        n: Integer;
        PowerValue: Decimal;
    begin
        // Validation
        if (Rec."Principal Amount" <= 0) or ("Interest Rate %" <= 0) or (Rec."Tenor (Months)" <= 0) then begin
            "EMI Amount" := 0;
            exit;
        end;

        P := "Principal Amount";
        n := "Tenor (Months)";
        r := ("Interest Rate %" / 12) / 100; // Monthly rate

        PowerValue := Power(1 + r, n);

        "EMI Amount" :=
            Round(
                (P * r * PowerValue) / (PowerValue - 1),
                0.01,
                '='
            );
    end;

    local procedure CalculatePreSettlementPenalty(PreSettlementAmount: Decimal; PenaltyPercent: Decimal; GSTPercent: Decimal;
    var PenaltyAmount: Decimal;
    var GSTAmount: Decimal;
    var TotalPenalty: Decimal)
    begin
        PenaltyAmount := Round(
            PreSettlementAmount * PenaltyPercent / 100, 0.01);

        GSTAmount := Round(
            PenaltyAmount * GSTPercent / 100, 0.01);

        TotalPenalty := PenaltyAmount + GSTAmount;
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        //OnBeforeShowDocDim(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            Rec, "Dimension Set ID", StrSubstNo('%1', "Loan No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        if OldDimSetID <> "Dimension Set ID" then begin

            Modify();
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
        IsHandled: Boolean;
    begin

        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "Loan No." <> '' then
            Modify();

        if OldDimSetID <> "Dimension Set ID" then begin
            if not IsNullGuid(Rec.SystemId) then
                Modify();

        end;
    end;

    var
        cust: Record Customer;
        DimMgt: Codeunit DimensionManagement;
}

