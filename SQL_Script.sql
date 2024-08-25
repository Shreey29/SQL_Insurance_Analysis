/* Total Policy Revenue by Product Group for the Current Year:
Write a query to calculate the total revenue from policies for each Product Group for the current year, 
and list the Product Groups in descending order of total revenue. */

with currentyear as (
select year(policy_start_date) as yearS from brokerage 
group by year(policy_start_date)
order by yearS desc 
limit 1 )

select product_group , round(sum(b.amount),2) as TotalRevenue
from brokerage b
join currentyear cy 
on year(b.policy_start_date) = cy.yearS 
group by b.product_group 
order by sum(amount) desc; 


/*Commission and Fees Analysis by Account Executive:
Construct a query to compare the total commissions (from fees) and total policy amounts (from brokerage) for each Account Executive, 
and identify the Account Executive with the highest combined total*/

with TotalCommisions As (
select Account_Executive  , sum(Amount) as TotalCommission from fees group by Account_Executive) ,
TotalPolicyAmount AS
(
select Exe_Name as Account_Executive , sum(Amount) as  TotalPolicyAmt from brokerage group by Exe_Name
),
CombinedCommission AS(
Select coalesce(c.Account_Executive,p.Account_Executive) AS Account_Executive,
coalesce(TotalCommission,0) + coalesce(TotalPolicyAmt,0) AS CombinedTotal
From TotalCommisions C 
Left join TotalPolicyAmount p on c.Account_Executive = p.Account_Executive 
UNION 
Select coalesce(c.Account_Executive,p.Account_Executive) AS Account_Executive,
coalesce(TotalCommission,0) + coalesce(TotalPolicyAmt,0) AS CombinedTotal
From TotalCommisions C 
right join TotalPolicyAmount p on c.Account_Executive = p.Account_Executive )
Select Account_Executive, Round(CombinedTotal,2) from CombinedCommission  Order by CombinedTotal DESC Limit 1;



/* Budget Utilization vs. New Budget Allocation by Income Class:
Develop a query to compare the actual budget utilization (from the fees table) against the new budget allocations (from the individual_budgets table) 
based on the income_class for each Account_Executive.
 */

With ActualBudgetUtilization AS (
Select Account_Executive , Sum(Amount) AS ActualBudget, income_class from fees group by Account_Executive, income_class),
NewBudgetAllocation AS (
Select Employee_Name as Account_Executive , Sum(New_Budget) AS new_budget,
'New' as income_class 
from individual_budgets group by Employee_Name

UNION ALL

Select Employee_Name as Account_Executive , Sum(Cross_sell_bugdet) AS new_budget,
'Cross Sell' as income_class 
from individual_budgets group by Employee_Name

UNION ALL

Select Employee_Name as Account_Executive , Sum(Renewal_Budget) AS new_budget,
'Renewal' as income_class 
from individual_budgets group by Employee_Name
)

SELECT
    a.Account_Executive AS Account_Executive,
    a.income_class AS IncomeClass,
    COALESCE(a.ActualBudget, 0) AS ActualUtilized,
    COALESCE(b.new_budget, 0) AS BudgetAllocated
FROM ActualBudgetUtilization a
LEFT JOIN NewBudgetAllocation b
ON a.Account_Executive = b.Account_Executive
AND a.income_class = b.income_class
ORDER BY a.Account_Executive, a.income_class;

/* Impact of Meetings on Opportunity Closure:
Create a query to evaluate the impact of meetings on the closure of opportunities by comparing the number of opportunities closed before and after each meeting,
and identify meetings with the highest positive impact. */

WITH OpportunitiesBeforeAfter AS (
Select m.Account_Exe_Id As Account_Exe_Id ,  m.Account_Executive AS Account_Executive, m.meeting_date AS meeting_date ,
Count(CASE when o.closing_date <= m.meeting_date THEN o.opportunity_id END) AS OpportunityBefore,
Count(CASE when o.closing_date > m.meeting_date THEN o.opportunity_id END) AS OpportunityAfter
from meeting m 
left join opportunity o 
on m.Account_Exe_Id = o. Account_Exe_Id 
group by m.Account_Exe_Id ,  m.Account_Executive , m.meeting_date ),

ImpactAnalysis AS(
Select Account_Exe_Id, Account_Executive , meeting_date , OpportunityBefore, OpportunityAfter, (OpportunityAfter - OpportunityBefore) AS Impact 
from OpportunitiesBeforeAfter group by Account_Exe_Id, Account_Executive , meeting_date )

select Account_Exe_Id, Account_Executive , meeting_date , OpportunityBefore, OpportunityAfter, Impact from ImpactAnalysis 
Where Impact > 0 
order by Impact DESC LIMIT 1 ;

/*Quarterly Revenue and Transaction Summary by Solution Group:
Write a SQL query to summarize the total revenue and count of invoices for each solution_group for each quarter in a given year. 
Your analysis should include:
Total Revenue: Calculate the total revenue amount for each solution_group in each quarter of the specified year.
Count of Invoices: Determine the count of invoices for each solution_group in each quarter of the specified year. */

SELECT 
    solution_group,
    EXTRACT(QUARTER FROM invoice_date) AS quarter,
    SUM(Amount) AS total_revenue,
    COUNT(invoice_number) AS invoice_count
FROM invoice
WHERE 
    EXTRACT(YEAR FROM invoice_date) = 2019  
GROUP BY 
    solution_group,
    EXTRACT(QUARTER FROM invoice_date)
ORDER BY 
    solution_group, quarter desc;
    
    
    
    
 /* Top 5 Opportunities by Revenue Amount:
Construct a query to list the top 5 opportunities by their revenue amount, including the Account Executive responsible. */

SELECT 
    opportunity_name,
    opportunity_id,
    Account_Executive,
    revenue_amount
FROM 
    opportunity
ORDER BY 
    revenue_amount DESC
LIMIT 5;






/* Average Revenue per Policy by Solution Group
Write a SQL query to calculate the average revenue per policy for each solution_group using the brokerage and invoice tables. 
Ensure that you consider only those policies that appear in both tables. List the solution groups with their average revenue per policy 
in descending order. */

WITH PolicyRevenue AS (
    SELECT 
         b.solution_group,
        COUNT(DISTINCT b.policy_number) AS policy_count,
        SUM(i.Amount) AS total_revenue
    FROM brokerage b JOIN invoice i
    ON b.policy_number = i.policy_number GROUP BY b.solution_group )
SELECT 
    solution_group,
    round((total_revenue / NULLIF(policy_count, 0)),0) AS average_revenue_per_policy
FROM PolicyRevenue ORDER BY average_revenue_per_policy DESC;

/* Revenue Contribution by Product Sub-Group:
Question: What is the revenue contribution of each product sub-group as a percentage of total revenue? */

WITH TotalRevenue AS (
    SELECT
        SUM(revenue_amount) AS overall_revenue
    FROM opportunity
)
SELECT
    product_sub_group,
    SUM(revenue_amount) AS sub_group_revenue,
    round(((SUM(revenue_amount) * 1.0 / overall_revenue) * 100),2) AS revenue_percentage
FROM opportunity, TotalRevenue
GROUP BY product_sub_group, overall_revenue
ORDER BY revenue_percentage DESC;



/*Meeting Frequency Analysis
Question: How often do meetings occur per Account Executive, and how does this correlate with their revenue generation?*/
WITH MeetingFrequency AS (
    SELECT Account_Exe_ID, Account_Executive, COUNT(*) AS meeting_count
    FROM meeting
    GROUP BY Account_Exe_ID, Account_Executive
),
RevenueByExecutive AS (
    SELECT Account_Exe_ID, Account_Executive,SUM(Amount) AS total_revenue
    FROM
        (SELECT Account_Exe_ID, Exe_Name AS Account_Executive, Amount FROM brokerage
         UNION ALL
         SELECT Account_Exe_ID, Account_Executive, Amount FROM invoice
         UNION ALL
         SELECT Account_Exe_ID, Account_Executive, Amount FROM fees) AS combined_revenue
    GROUP BY Account_Exe_ID, Account_Executive )
SELECT m.Account_Exe_ID, m.Account_Executive, m.meeting_count,round(r.total_revenue,0)
FROM MeetingFrequency m
LEFT JOIN RevenueByExecutive r
ON m.Account_Exe_ID = r.Account_Exe_ID
ORDER BY m.Account_Executive;
















