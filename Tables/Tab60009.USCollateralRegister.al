table 60009 "US Collateral Register"
{
    DataClassification = CustomerContent;
    Caption = 'Collateral Register';

    fields
    {
        field(1; "Collateral No."; Code[20]) { }
        field(2; Description; Text[100]) { }
        field(3; "Collateral Type"; Enum "GE Collateral Type") { }
        field(4; "Property Category"; Option) { OptionMembers = Freehold,Leasehold,Other; }
        field(5; "Construction Status"; Option) { OptionMembers = Ready,"Under Construction"; }
        field(6; "Occupancy"; Enum "GE Occupancy") { }
        field(7; "Collateral Sub Type"; Enum "GE Collateral Sub Type") { }
        field(8; "Loan Application No."; Code[20]) { TableRelation = "US Loan Application Header"; }

        // Location
        field(10; "Country/Region Code"; Code[10]) { TableRelation = "Country/Region".Code; }
        field(11; "State/Province/Emirate"; Text[50]) { }
        field(12; City; Text[50]) { }
        field(13; "District/Area"; Text[50]) { }
        field(14; "Address Line 1"; Text[100]) { }
        field(15; "Address Line 2"; Text[100]) { }
        field(16; "Building Name"; Text[60]) { }
        field(17; Street; Text[60]) { }
        field(18; "Postal Code"; Code[20]) { }
        field(19; "PO Box"; Code[20]) { }
        field(20; Latitude; Decimal) { DecimalPlaces = 0 : 8; }
        field(21; Longitude; Decimal) { DecimalPlaces = 0 : 8; }

        // Unit
        field(30; "Tower/Block"; Text[30]) { }
        field(31; "Floor No."; Text[10]) { }
        field(32; "Unit No."; Text[20]) { }
        field(33; "Unit Type"; Enum "GE Unit Type") { }
        field(34; Bedrooms; Integer) { }
        field(35; Bathrooms; Integer) { }
        field(36; "Parking Spaces"; Integer) { }
        field(37; "Built-up Area (sqm)"; Decimal) { DecimalPlaces = 0 : 3; }
        field(38; "Net/Leasable Area (sqm)"; Decimal) { DecimalPlaces = 0 : 3; }
        field(39; "Land Area (sqm)"; Decimal) { DecimalPlaces = 0 : 3; }

        // Legal
        field(50; "Title Deed No."; Text[50]) { }
        field(51; "Parcel/Plot No."; Text[50]) { }
        field(52; "Lot No."; Text[50]) { }
        field(53; "Registry Authority"; Text[50]) { }
        field(54; "Registry Reference No."; Text[50]) { }
        field(55; "Zoning Code"; Text[30]) { }
        field(56; "Restrictions/Easements"; Text[250]) { }

        // Valuation
        field(70; "Valuation Currency"; Code[10]) { TableRelation = Currency.Code; }
        field(71; "Market Value"; Decimal) { }
        field(72; "Forced Sale Value"; Decimal) { }
        field(73; "Appraisal Date"; Date) { }
        field(74; "Appraiser Name"; Text[80]) { }
        field(75; "Valuation Report Link"; Text[250]) { }

        // Insurance
        field(80; "Insurance Required"; Boolean) { }
        field(81; "Insurer Name"; Text[80]) { }
        field(82; "Policy No."; Text[50]) { }
        field(83; "Policy Expiry Date"; Date) { }
        field(84; "Insured Value"; Decimal) { }
        field(85; "Annual Premium Estimate"; Decimal) { }

        // Existing Liens
        field(90; "Existing Lien"; Boolean) { }
        field(91; "Lien Position"; Enum "GE Lien Position") { }
        field(92; "Existing Lender"; Text[80]) { }
        field(93; "Existing Outstanding Balance"; Decimal) { }
    }

    keys
    {
        key(PK; "Collateral No.") { Clustered = true; }
        key(PK2; "Loan Application No.") { }
    }

}

