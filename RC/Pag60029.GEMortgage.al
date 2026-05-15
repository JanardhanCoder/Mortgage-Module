namespace MortgageForUS.MortgageForUS;
using System.Integration.PowerBI;
using Mortgage.Mortgage;
using Microsoft.Sales.Customer;
using Microsoft.Projects.Project.Job;
using System.Visualization;
using System.Email;
using System.Automation;
using System.Threading;
using Microsoft.EServices.EDocument;

page 60029 "GE Mortgage"
{
    ApplicationArea = All;
    Caption = 'GE Mortgage';
    PageType = RoleCenter;
    layout
    {
        area(RoleCenter)
        {

            part(Control139; "Headline RC Administrator")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Mrt; "GE Mortgage Cue Page")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Emails"; "Email Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part(ApprovalsActivities; "Approvals Activities")
            {
                ApplicationArea = Suite;
            }
            part(PowerBIEmbeddedReportPart; "Power BI Embedded Report Part")
            {
                AccessByPermission = TableData "Power BI Context Settings" = I;
                ApplicationArea = Basic, Suite;
            }
            part("My Job Queue"; "My Job Queue")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control96; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = IMD;
                ApplicationArea = Suite;
            }
            part(PowerBIEmbeddedReportPart2; "Power BI Embedded Report Part")
            {
                AccessByPermission = TableData "Power BI Context Settings" = I;
                ApplicationArea = Basic, Suite;
                SubPageView = where(Context = const('Power BI Part II'));
                Visible = false;
            }
            part(PowerBIEmbeddedReportPart3; "Power BI Embedded Report Part")
            {
                AccessByPermission = TableData "Power BI Context Settings" = I;
                ApplicationArea = Basic, Suite;
                SubPageView = where(Context = const('Power BI Part III'));
                Visible = false;
            }
            systempart(MyNotes; MyNotes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(embedding)
        {
            action(Jobs)
            {
                Caption = 'Projects';
                ApplicationArea = All;
                RunObject = page "Job List";
            }
            action(CustomerList)
            {
                ApplicationArea = all;
                Caption = 'Customers';
                RunObject = page "Customer List";
            }

        }
        area(sections)
        {
            group("Mortgage")
            {
                action("Loan Applications")
                {
                    Caption = 'Loan Applications';
                    ApplicationArea = all;
                    RunObject = page "US Loan Applications";
                }
                action("Loans")
                {
                    ApplicationArea = all;
                    RunObject = page "GE Loans";
                }
                action("Mortgage Products")
                {
                    ApplicationArea = all;
                    RunObject = page "US Mortgage Products";
                }
            }
        }
    }
}
profile "GE Mortgage"
{
    Caption = 'GE Mortgage';
    RoleCenter = "GE mortgage";
}
