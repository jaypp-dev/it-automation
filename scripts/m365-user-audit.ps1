# m365-user-audit.ps1
# Sanitized baseline script reflecting M365/Active Directory user account auditing.
# Used to track active licenses and enforce identity governance.

# Simulated user database object (No real corporate/MSP data included)
$SimulatedUsers = @(
    [PSCustomObject]@{ UPN = "j.smith@company.com"; Active = $true; Department = "Engineering" },
    [PSCustomObject]@{ UPN = "a.jones@company.com"; Active = $false; Department = "Finance" },
    [PSCustomObject]@{ UPN = "t.stark@company.com"; Active = $true; Department = "Operations" },
    [PSCustomObject]@{ UPN = "b.banner@company.com"; Active = $true; Department = "Healthcare" }
)

Write-Output "=================================================="
Write-Output "   MICROSOFT 365 / AD IDENTITY AUDIT PROCESS"
Write-Output "=================================================="
Write-Output "Querying directory for active user environments..."
Write-Output ""

# Filter for active accounts
$ActiveAccounts = $SimulatedUsers | Where-Object { $_.Active -eq $true }

# Output results to console
foreach ($Account in $ActiveAccounts) {
    Write-Output "SUCCESS: Verified active account for $($Account.UPN) [$($Account.Department)]"
}

Write-Output "--------------------------------------------------"
Write-Output "Audit Complete. $(($ActiveAccounts).Count) active accounts verified."
Write-Output "=================================================="
