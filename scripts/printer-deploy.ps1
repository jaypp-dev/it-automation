# ============================================================

# Printer Deployment Script

# USB Drive: D:\

# Run as: Local Administrator

# ============================================================

 

# ---- DRIVER INF PATHS --------------------------------------

 

$CanonInf  = "D:\PrinterDrivers\Canon ImageRunner Advance DX 4935i\x64\Driver\CNP60MA64.INF"

$E40040Inf = "D:\PrinterDrivers\HP_LJE40040\HP_LJE40040_V4\HPIPPStub.INF"

$E42540Inf = "D:\PrinterDrivers\HP_LJE42540\HP_LJE42540_V4\hpbud52a4_x64.inf"

$M402Inf   = "D:\PrinterDrivers\HP_LaserJet_Pro_M402-M403_n-dne\hpbuio160l.inf"

 

# ---- PRINTER LIST ------------------------------------------

 

$Printers = @(

 

    # --- Front Desk ---

    @{

        PrinterName = "Front Desk Reception"

        IPAddress   = "192.168.0.54"

        PortName    = "IP_192.168.0.54"

        DriverName  = "HP LaserJet Managed E40040"

        InfFile     = $E40040Inf

    },

    @{

        PrinterName = "Front Desk"

        IPAddress   = "192.168.0.55"

        PortName    = "IP_192.168.0.55"

        DriverName  = "Canon Generic Plus PCL6"

        InfFile     = $CanonInf

    },

 

    # --- HP LaserJet MFP E42540 ---

    @{

        PrinterName = "POD1"

        IPAddress   = "192.168.0.57"

        PortName    = "IP_192.168.0.57"

        DriverName  = "HP LaserJet MFP E42540"

        InfFile     = $E42540Inf

    },

    @{

        PrinterName = "POD2"

        IPAddress   = "192.168.0.58"

        PortName    = "IP_192.168.0.58"

        DriverName  = "HP LaserJet MFP E42540"

        InfFile     = $E42540Inf

    },

    @{

        PrinterName = "Lab"

        IPAddress   = "192.168.0.51"

        PortName    = "IP_192.168.0.51"

        DriverName  = "HP LaserJet MFP E42540"

        InfFile     = $E42540Inf

    },

    @{

        PrinterName = "Triage"

        IPAddress   = "192.168.0.53"

        PortName    = "IP_192.168.0.53"

        DriverName  = "HP LaserJet MFP E42540"

        InfFile     = $E42540Inf

    },

 

    # --- HP LaserJet Pro M402N ---

    @{

        PrinterName = "POD1 Script"

        IPAddress   = "192.168.0.60"

        PortName    = "IP_192.168.0.60"

        DriverName  = "HP LaserJet Pro M402n"

        InfFile     = $M402Inf

    },

    @{

        PrinterName = "POD2 Script"

        IPAddress   = "192.168.0.61"

        PortName    = "IP_192.168.0.61"

        DriverName  = "HP LaserJet Pro M402n"

        InfFile     = $M402Inf

    }

)

 

# ---- FUNCTIONS ----------------------------------------------

 

function Write-Status($msg)  { Write-Host "`n>> $msg" -ForegroundColor Cyan }

function Write-Success($msg) { Write-Host "   [OK] $msg" -ForegroundColor Green }

function Write-Fail($msg)    { Write-Host "   [FAIL] $msg" -ForegroundColor Red }

 

# ---- ADMIN CHECK --------------------------------------------

 

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "`n[ERROR] Please run this script as Administrator." -ForegroundColor Red

    exit 1

}

 

# ---- HELPER: Detect actual driver name from INF -------------

# If Add-PrinterDriver fails due to a name mismatch, this function

# reads the INF and prints what driver names are actually available.

 

function Get-DriverNamesFromInf($infPath) {

    Write-Host "`n   [INFO] Reading driver names from: $infPath" -ForegroundColor DarkYellow

    $content = Get-Content $infPath -ErrorAction SilentlyContinue

    $inModels = $false

    foreach ($line in $content) {

        if ($line -match '^\[Manufacturer\]') { $inModels = $true; continue }

        if ($inModels -and $line -match '^\[') { $inModels = $false }

        if ($inModels -and $line -match '=') {

            Write-Host "   Possible driver name: $($line.Split('=')[0].Trim())" -ForegroundColor DarkYellow

        }

    }

}

 

# ---- DRIVER INSTALL TRACKER ---------------------------------

$InstalledDrivers = @{}

 

# ---- MAIN DEPLOYMENT ----------------------------------------

 

foreach ($printer in $Printers) {

 

    Write-Host "`n============================================================" -ForegroundColor Yellow

    Write-Host " Deploying: $($printer.PrinterName)" -ForegroundColor Yellow

    Write-Host "============================================================" -ForegroundColor Yellow

 

    # --- STEP 1: Verify INF exists ---

    if (-not (Test-Path $printer.InfFile)) {

        Write-Fail "INF file not found: $($printer.InfFile)"

        Write-Host "   Check that the USB is drive D:\ and paths are correct." -ForegroundColor DarkYellow

        continue

    }

 

    # --- STEP 2: Install driver (once per unique driver) ---

    if (-not $InstalledDrivers.ContainsKey($printer.DriverName)) {

        Write-Status "Installing driver: $($printer.DriverName)"

        try {

            pnputil.exe /add-driver $printer.InfFile /install | Out-Null

            Add-PrinterDriver -Name $printer.DriverName -ErrorAction Stop

            Write-Success "Driver installed: $($printer.DriverName)"

            $InstalledDrivers[$printer.DriverName] = $true

        } catch {

            $existing = Get-PrinterDriver -Name $printer.DriverName -ErrorAction SilentlyContinue

            if ($existing) {

                Write-Success "Driver already present: $($printer.DriverName)"

                $InstalledDrivers[$printer.DriverName] = $true

            } else {

                Write-Fail "Driver install failed. The driver name in the script may not match the INF."

                Write-Host "   Expected name: $($printer.DriverName)" -ForegroundColor DarkYellow

                Get-DriverNamesFromInf $printer.InfFile

                Write-Host "   Update the DriverName in the script to match and re-run." -ForegroundColor DarkYellow

                continue

            }

        }

    } else {

        Write-Status "Driver already installed this session, skipping: $($printer.DriverName)"

    }

 

    # --- STEP 3: Create TCP/IP Port ---

    Write-Status "Creating port: $($printer.PortName) -> $($printer.IPAddress)"

    try {

        $existingPort = Get-PrinterPort -Name $printer.PortName -ErrorAction SilentlyContinue

        if (-not $existingPort) {

            Add-PrinterPort -Name $printer.PortName -PrinterHostAddress $printer.IPAddress -ErrorAction Stop

            Write-Success "Port created: $($printer.PortName)"

        } else {

            Write-Success "Port already exists: $($printer.PortName)"

        }

    } catch {

        Write-Fail "Port creation failed: $_"

        continue

    }

 

    # --- STEP 4: Add Printer ---

    Write-Status "Adding printer: $($printer.PrinterName)"

    try {

        $existingPrinter = Get-Printer -Name $printer.PrinterName -ErrorAction SilentlyContinue

        if ($existingPrinter) {

            Write-Host "   [INFO] Printer already exists. Removing and re-adding..." -ForegroundColor DarkYellow

            Remove-Printer -Name $printer.PrinterName -ErrorAction SilentlyContinue

        }

        Add-Printer -Name $printer.PrinterName -DriverName $printer.DriverName -PortName $printer.PortName -ErrorAction Stop

        Write-Success "Printer added: $($printer.PrinterName)"

    } catch {

        Write-Fail "Failed to add printer: $_"

        continue

    }

 

    Write-Host "`n   Deployment complete for: $($printer.PrinterName)" -ForegroundColor Green

}

 

# ---- SUMMARY ------------------------------------------------

 

Write-Host "`n============================================================" -ForegroundColor Yellow

Write-Host " Deployment Summary" -ForegroundColor Yellow

Write-Host "============================================================" -ForegroundColor Yellow

 

foreach ($printer in $Printers) {

    $check = Get-Printer -Name $printer.PrinterName -ErrorAction SilentlyContinue

    if ($check) {

        Write-Host " [INSTALLED] $($printer.PrinterName) ($($printer.IPAddress))" -ForegroundColor Green

    } else {

        Write-Host " [MISSING]   $($printer.PrinterName) ($($printer.IPAddress))" -ForegroundColor Red

    }

}

 

Write-Host "`nDone. Press any key to exit..."

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
