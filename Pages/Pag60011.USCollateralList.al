namespace Mortgage.Mortgage;

page 60011 "US Collateral List"
{
    PageType = List;
    SourceTable = "US Collateral Register";
    ApplicationArea = All;
    Caption = 'Collaterals';
    UsageCategory = Lists;
    CardPageId = "GE Collateral Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Collateral No."; Rec."Collateral No.") { }
                field("Loan Application No."; Rec."Loan Application No.") { }
                field(Description; Rec.Description) { }
                field("Collateral Type"; Rec."Collateral Type") { }
                field(City; Rec.City) { }
                field("District/Area"; Rec."District/Area") { }
                field("Market Value"; Rec."Market Value") { }
                field("Title Deed No."; Rec."Title Deed No.") { }
            }
        }
    }
}

page 60012 "GE Collateral Card"
{
    PageType = Card;
    SourceTable = "US Collateral Register";
    ApplicationArea = All;
    Caption = 'Collateral';
    layout
    {
        area(content)
        {
            group(Classification)
            {
                field("Collateral No."; Rec."Collateral No.") { }
                field("Loan Application No."; Rec."Loan Application No.")
                { }
                field(Description; Rec.Description) { }
                field("Collateral Type"; Rec."Collateral Type") { }
                field("Collateral Sub Type"; Rec."Collateral Sub Type") { }
                field("Property Category"; Rec."Property Category") { }
                field("Construction Status"; Rec."Construction Status") { }
                field("Occupancy"; Rec."Occupancy") { }
            }
            group(Location)
            {
                field("Country/Region Code"; Rec."Country/Region Code") { }
                field("State/Province/Emirate"; Rec."State/Province/Emirate") { }
                field(City; Rec.City) { }
                field("District/Area"; Rec."District/Area") { }
                field("Address Line 1"; Rec."Address Line 1") { }
                field("Address Line 2"; Rec."Address Line 2") { }
                field("Building Name"; Rec."Building Name")
                {
                    Visible = Rec."Collateral Sub Type" = Rec."Collateral Sub Type"::Building;
                }
                field(Street; Rec.Street) { }
                field("Postal Code"; Rec."Postal Code") { }
                field("PO Box"; Rec."PO Box") { }
                field(Latitude; Rec.Latitude) { }
                field(Longitude; Rec.Longitude) { }
            }
            group(Unit)
            {
                Visible = Rec."Collateral Sub Type" = Rec."Collateral Sub Type"::Unit;
                field("Tower/Block"; Rec."Tower/Block") { }
                field("Floor No."; Rec."Floor No.") { }
                field("Unit No."; Rec."Unit No.") { }
                field("Unit Type"; Rec."Unit Type") { }
                field(Bedrooms; Rec.Bedrooms) { }
                field(Bathrooms; Rec.Bathrooms) { }
                field("Parking Spaces"; Rec."Parking Spaces") { }
                field("Built-up Area (sqm)"; Rec."Built-up Area (sqm)") { }
                field("Net/Leasable Area (sqm)"; Rec."Net/Leasable Area (sqm)") { }
                field("Land Area (sqm)"; Rec."Land Area (sqm)") { }
            }
            group(Legal)
            {
                field("Title Deed No."; Rec."Title Deed No.") { }
                field("Parcel/Plot No."; Rec."Parcel/Plot No.") { }
                field("Lot No."; Rec."Lot No.") { }
                field("Registry Authority"; Rec."Registry Authority") { }
                field("Registry Reference No."; Rec."Registry Reference No.") { }
                field("Zoning Code"; Rec."Zoning Code") { }
                field("Restrictions/Easements"; Rec."Restrictions/Easements") { }
            }
            group(Valuation)
            {
                field("Valuation Currency"; Rec."Valuation Currency") { }
                field("Market Value"; Rec."Market Value") { }
                field("Forced Sale Value"; Rec."Forced Sale Value") { }
                field("Appraisal Date"; Rec."Appraisal Date") { }
                field("Appraiser Name"; Rec."Appraiser Name") { }
                field("Valuation Report Link"; Rec."Valuation Report Link") { }
            }
            group(Insurance)
            {
                field("Insurance Required"; Rec."Insurance Required") { }
                field("Insurer Name"; Rec."Insurer Name") { }
                field("Policy No."; Rec."Policy No.") { }
                field("Policy Expiry Date"; Rec."Policy Expiry Date") { }
                field("Insured Value"; Rec."Insured Value") { }
                field("Annual Premium Estimate"; Rec."Annual Premium Estimate") { }
            }
            group("Existing Liens")
            {
                field("Existing Lien"; Rec."Existing Lien") { }
                field("Lien Position"; Rec."Lien Position") { }
                field("Existing Lender"; Rec."Existing Lender") { }
                field("Existing Outstanding Balance"; Rec."Existing Outstanding Balance") { }
            }
        }
    }
}
