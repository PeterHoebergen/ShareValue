pageextension 50006 JobPlanningLineExt extends "Job Planning Lines"
{
    layout
    {
        addafter(Overdue)
        {
            field("DateTime Exported to Exact";"DateTime Exported to Exact")
            {
                ApplicationArea = All;
            }
        }
    }
}