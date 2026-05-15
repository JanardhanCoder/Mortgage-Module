namespace Mortgage.Mortgage;
using Microsoft.Foundation.Reporting;

enum 60000 "US Application Source"
{
    Extensible = true;
    value(0; Direct) { Caption = 'Direct'; }
    value(1; Broker) { Caption = 'Broker'; }
}
enum 60001 "US Application Status"
{
    Extensible = true;
    value(0; Open) { Caption = 'Open'; }
    value(1; Submitted) { Caption = 'Submitted'; }
    value(2; "Docs Pending") { Caption = 'Docs Pending'; }
    value(3; "Docs Verified") { Caption = 'Docs Verified'; }
    //value(4; "Credit Check") { Caption = 'Credit Check'; }
    //value(5; "Valuation Pending") { Caption = 'Valuation Pending'; }
    value(6; Underwriting) { Caption = 'Underwriting'; }
    //value(7; "Conditional Approval") { Caption = 'Conditional Approval'; }
    value(8; Approved) { Caption = 'Approved'; }
    value(9; Rejected) { Caption = 'Rejected'; }
    //value(10; "Commitment Issued") { Caption = 'Commitment Issued'; }
    //value(11; "Commitment Accepted") { Caption = 'Commitment Accepted'; }
    //value(12; "Ready for Agreement") { Caption = 'Ready for Agreement'; }
    value(13; "Agreement Created") { Caption = 'Agreement Created'; }
    value(14; Cancelled) { Caption = 'Cancelled'; }
    value(15; Released) { }
    value(16; "Pending Approval") { }
}

enum 60002 "GE Collateral Type"
{
    Extensible = true;
    value(0; Residential) { Caption = 'Residential'; }
    value(1; Commercial) { Caption = 'Commercial'; }
    // value(2; Land) { Caption = 'Land'; }
    value(3; Industrial) { Caption = 'Industrial'; }
    value(4; MixedUse) { Caption = 'Mixed Use'; }
    value(5; Other) { Caption = 'Other'; }
}

enum 60003 "GE Unit Type"
{
    Extensible = true;
    value(0; Apartment) { Caption = 'Apartment'; }
    value(1; Villa) { Caption = 'Villa'; }
    value(2; Townhouse) { Caption = 'Townhouse'; }
    value(3; Office) { Caption = 'Office'; }
    value(4; Shop) { Caption = 'Shop'; }
    value(5; Warehouse) { Caption = 'Warehouse'; }
    value(6; Plot) { Caption = 'Plot (Land)'; }
    value(7; Other) { Caption = 'Other'; }
}
enum 60004 "GE Occupancy"
{
    Extensible = true;
    value(0; OwnerOccupied) { Caption = 'Owner Occupied'; }
    value(1; Tenanted) { Caption = 'Tenanted'; }
    value(2; Vacant) { Caption = 'Vacant'; }
}
enum 60005 "GE Lien Position"
{
    Extensible = true;
    value(0; First) { Caption = '1st'; }
    value(1; Second) { Caption = '2nd'; }
    value(2; Third) { Caption = '3rd'; }
    value(3; Other) { Caption = 'Other'; }
}

enum 60006 "GE Commitment Status"
{
    Extensible = true;
    value(0; Draft) { Caption = 'Draft'; }
    value(1; Issued) { Caption = 'Issued'; }
    value(2; Accepted) { Caption = 'Accepted'; }
    value(3; Expired) { Caption = 'Expired'; }
    value(4; Withdrawn) { Caption = 'Withdrawn'; }
}
enum 60007 "GE Loan Status"
{
    Extensible = true;
    value(0; Draft) { Caption = 'Draft'; }
    value(1; Executed) { Caption = 'Executed'; }
    value(2; Active) { Caption = 'Active'; }
    value(3; Delinquent) { Caption = 'Delinquent'; }
    value(4; Restructured) { Caption = 'Restructured'; }
    value(5; "Pre-Settled") { }
    value(6; "Pre-Settlement Pending") { }
    value(7; Closed) { Caption = 'Closed'; }
    value(8; "ReClassification")
    {
    }
    value(9; "Held For Sale")
    {
    }
}
enum 60008 "GE Schedule Status"
{
    Extensible = true;
    value(0; Pending) { Caption = 'Pending'; }
    value(1; Paid) { Caption = 'Paid'; }
    value(2; Overdue) { Caption = 'Overdue'; }
    value(3; Restructured) { Caption = 'Restructured'; }
    value(4; Settled) { Caption = 'Settled'; }
    value(5; Cancelled) { }
}

enum 60009 "GE Loan Entry Type"
{
    Extensible = true;
    value(0; " ") { }
    value(1; Disbursement) { Caption = 'Disbursement'; }
    value(2; InterestAccrual) { Caption = 'Interest Accrual'; }
    value(3; FeeRecognition) { Caption = 'Fee Recognition'; }
    value(4; Receipt) { Caption = 'Receipt'; }
    value(5; Penalty) { Caption = 'Penalty'; }
    value(6; Adjustment) { Caption = 'Adjustment'; }
    value(7; WriteOff) { Caption = 'Write-off'; }
    value(8; "Commission") { }
    value(9; Reclassification)
    {
    }
    value(10; FairValueAdjustment)
    {
    }
    value(11; LoanSale)
    {
    }
}

enum 60010 "GE Fee Recognition Method"
{
    Extensible = true;
    value(0; Upfront) { Caption = 'Upfront'; }
    value(1; DeferredStraightLine) { Caption = 'Deferred - Straight Line'; }
}
enum 60011 "GE Accrual Basis"
{
    Extensible = true;
    value(0; Monthly) { Caption = 'Monthly'; }
    value(1; "Daily_ACT365") { Caption = 'Daily (ACT/365)'; }
    value(2; "Daily_30_360") { Caption = 'Daily (30/360)'; }
}
enum 60012 "Pre-Settlement Option"
{
    Extensible = false;
    value(0; Select) { }
    value(1; KeepTenure)
    {
        Caption = 'Keep Tenure';
    }

    value(2; ReduceTenure)
    {
        Caption = 'Reduce Tenure';
    }
}
enum 60013 "GE Commission Type"
{
    Extensible = true;
    value(0; Select) { }
    value(1; Percentage)
    {
        Caption = 'Percentage';
    }

    value(2; "Fixed Amount")
    {
        Caption = 'Fixed Amount';
    }
    value(3; Tiered) { }
}
enum 60014 "GE Commission Basis"
{
    Extensible = true;
    value(0; Select) { }
    value(1; "Loan Amount")
    {
        Caption = 'Loan Amount';
    }

    value(2; "Disbursed Amount")
    {
        Caption = 'Disbursed Amount';
    }
}

enum 60015 "GE Agreement Status"
{
    Extensible = true;

    value(0; Draft)
    {
        Caption = 'Draft';
    }

    value(1; Active)
    {
        Caption = 'Active';
    }

    value(2; Closed)
    {
        Caption = 'Closed';
    }
}
enum 60016 "GE Commission Status"
{
    Extensible = true;

    value(0; Draft) { Caption = 'Draft'; }
    value(1; Submitted) { Caption = 'Submitted'; }
    value(2; Approved) { Caption = 'Approved'; }
    value(3; Accrued) { Caption = 'Accrued'; }
    value(4; Paid) { Caption = 'Paid'; }
    value(5; Cancelled) { Caption = 'Cancelled'; }
}
enum 60017 "GE Loan Arrangement Type"
{
    Extensible = true;

    value(0; " ") { Caption = 'Select'; }
    value(1; PTP)
    {
        Caption = 'Promise To Pay';
    }
    value(2; Waiver)
    {
        Caption = 'Waiver';
    }
    value(3; Restructure)
    {
        Caption = 'Restructure';
    }
}



enum 60018 "GE Loan Arrangement Status"
{
    Extensible = false;
    AssignmentCompatibility = true;

    value(0; Open)
    {
        Caption = 'Open';
    }

    value(1; Submitted)
    {
        Caption = 'Submitted';
    }

    value(2; Approved)
    {
        Caption = 'Approved';
    }

    value(3; InProcess)
    {
        Caption = 'In Process';
    }

    value(4; Completed)
    {
        Caption = 'Completed';
    }

    value(5; Cancelled)
    {
        Caption = 'Cancelled';
    }

}
enum 60032 "GE Arrangement Line Type"
{
    Extensible = true;
    value(0; " ") { Caption = 'Select'; }
    value(1; Penalty)
    {
        Caption = 'Penalty';
    }
    value(2; Interest)
    {
        Caption = 'Interest';
    }
    value(3; Principal)
    {
        Caption = 'Principal';
    }
    value(4; Escrow)
    {
        Caption = 'Escrow';
    }
}

enum 60033 "GE Restructure Type"
{
    Extensible = true;
    value(0; " ") { Caption = 'Select'; }

    value(1; TenureExtension)
    {
        Caption = 'Tenure Extension';
    }
    value(2; EMIReduction)
    {
        Caption = 'EMI Reduction';
    }
    value(3; EMITenureChange)
    {
        Caption = 'EMI and Tenure Change';
    }
    value(4; InterestRateChange)
    {
        Caption = 'Interest Rate Change';
    }
    value(5; PrincipalMoratorium)
    {
        Caption = 'Principal Moratorium';
    }
    value(6; InterestMoratorium)
    {
        Caption = 'Interest Moratorium';
    }
    value(7; FullMoratorium)
    {
        Caption = 'Full Moratorium (Principal + Interest)';
    }
}

enum 60034 "GE Collateral Sub Type"
{
    Extensible = true;
    value(0; "") { }
    value(1; Land) { Caption = 'Land'; }

    value(2; Unit) { Caption = 'Unit'; }
    value(3; "Building") { }
}
enum 60035 "US Mortgage Type"
{
    Extensible = true;

    value(0; " ") { }
    value(1; "Purchase Price") { }
    value(2; "Market Value") { }
}

enum 60036 "Risk Level"
{
    Extensible = true;
    value(0; " ") { }
    value(1; Low) { Caption = 'Low'; }
    value(2; Medium) { Caption = 'Medium'; }
    value(3; High) { Caption = 'High'; }
}

enum 60037 "Assessment Type"
{
    Extensible = true;

    value(0; Initial) { Caption = 'Initial Assessment'; }
    value(1; CreditUpdate) { Caption = 'Credit Bureau Update'; }
    value(2; Revaluation) { Caption = 'Property Revaluation'; }
    value(3; Final) { Caption = 'Final Underwriting'; }
}
enum 60038 "Risk Rule Type"
{
    Extensible = true;
    value(0; " ")
    {
    }
    value(1; LTV) { Caption = 'Loan To Value'; }
    value(2; FOIR) { Caption = 'Fixed Obligation to Income Ratio'; }
    value(3; DTI)
    {
        Caption = 'Debt-to-Income Ratio';
    }
    value(4; "Credit Score")
    {
    }

}
enumextension 60001 "RSU" extends "Report Selection Usage"
{
    value(60001; "US Mortgage Aggreement")
    {
    }
}
// enumextension 60002 "Docusign Doc Type" extends "DocuSign Document Type"
// {
//     value(100; "Commitment")
//     {
//     }
// }
enum 60039 "Envelope Status"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; created)
    {
        Caption = 'Created';
    }
    value(2; delivered)
    {
        Caption = 'Delivered';
    }
    value(3; sent)
    {
        Caption = 'Sent';
    }
    value(4; completed)
    {
        Caption = 'Completed';
    }
    value(5; correct)
    {
        Caption = 'Correct';
    }
    value(6; declined)
    {
        Caption = 'Declined';
    }
    value(7; deleted)
    {
        Caption = 'Deleted';
    }
    value(8; signed)
    {
        Caption = 'Signed';
    }
    value(9; transfercompleted)
    {
        Caption = 'Transfer Completed';
    }
    value(10; timedout)
    {
        Caption = 'Timed Out';
    }

    value(11; voided)
    {
        Caption = 'Voided';
    }
}
enum 60040 "US Loan Strategy"
{
    Extensible = true;

    value(0; "Hold to Collect")
    {
        Caption = 'Hold to Collect';
    }
    value(1; "Held for Sale")
    {
        Caption = 'Held for Sale';
    }
}
enum 60041 "US Accounting Classification"
{
    Extensible = true;

    value(0; "Amortized Cost")
    {
        Caption = 'Amortized Cost';
    }
    value(1; FVTPL)
    {
        Caption = 'Fair Value Through P&L';
    }
    value(2; LHFS)
    {
        Caption = 'Loan Held for Sale';
    }
}
enum 60042 "US Loan Sale Method"
{
    Extensible = true;

    value(0; "Whole Loan Sale")
    {
        Caption = 'Whole Loan Sale';
    }
    value(1; "Securitization Pool")
    {
        Caption = 'Securitization Pool';
    }
    value(2; Assignment)
    {
        Caption = 'Assignment';
    }
}
enum 60043 "US Investor Settlement Method"
{
    Extensible = true;

    value(0; Wire)
    {
        Caption = 'Wire Transfer';
    }

    value(1; ACH)
    {
        Caption = 'ACH';
    }

    value(2; Internal)
    {
        Caption = 'Internal Settlement';
    }
}
enum 60044 "US Purchase Advice Format"
{
    Extensible = true;

    value(0; CSV)
    {
        Caption = 'CSV';
    }

    value(1; Pain001)
    {
        Caption = 'ISO 20022 pain.001';
    }

    value(2; CustomXML)
    {
        Caption = 'Custom XML';
    }
}
enum 60045 "US Price Method"
{
    Extensible = true;

    value(0; ParPrice)
    {
        Caption = 'Par Price';
    }

    value(1; SRP)
    {
        Caption = 'Service Release Premium';
    }

    value(2; FeeBased)
    {
        Caption = 'Fee Based';
    }

    value(3; Spread)
    {
        Caption = 'Spread Based';
    }
}
enum 60046 "GE LHFS Sale Status"
{
    Extensible = true;
    value(0; Pipeline) { Caption = 'Pipeline'; }
    value(1; Committed) { Caption = 'Committed'; }
    value(2; Settled) { Caption = 'Settled'; }
    value(3; Cancelled) { Caption = 'Cancelled'; }
}
enum 60047 "GE LHFS Sale Type"
{
    Extensible = true;
    value(0; "WholeLoan") { Caption = 'Whole Loan'; }
    value(1; "Pool") { Caption = 'Pool'; }
    value(2; "Assignment") { Caption = 'Assignment'; }
    value(3; "Securitization") { Caption = 'Securitization'; }
}