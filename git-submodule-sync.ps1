# Git Submodule Auto-Sync Script
# This script helps manage submodules by:
# 1. Pulling latest changes from all submodules
# 2. Detecting and pushing changes in submodules if any exist

# Define colors for console output
$Green = @{ForegroundColor = "Green"}
$Yellow = @{ForegroundColor = "Yellow"}
$Red = @{ForegroundColor = "Red"}
$Cyan = @{ForegroundColor = "Cyan"}

# Function to show script header
function Show-Header {
    Write-Host "`n=====================================================" @Cyan
    Write-Host "         GIT SUBMODULE AUTO-SYNC SCRIPT" @Cyan
    Write-Host "=====================================================" @Cyan
}

# Function to pull latest changes for all submodules
function Update-AllSubmodules {
    Write-Host "`n[1] Updating all submodules..." @Green
    
    # Initialize submodules if needed
    git submodule init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error initializing submodules!" @Red
        return $false
    }
    
    # Update all submodules to latest remote version
    git submodule update --remote --recursive
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error updating submodules from remote!" @Red
        return $false
    }
    
    # For each submodule, checkout main branch and pull latest changes
    git submodule foreach "git checkout main && git pull"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error checking out main branch or pulling in one or more submodules!" @Red
        return $false
    }
    
    Write-Host "All submodules updated successfully!" @Green
    return $true
}

# Function to check if a submodule has changes
function Test-SubmoduleHasChanges {
    param (
        [string]$submodulePath
    )
    
    Push-Location $submodulePath
    
    # Check for uncommitted changes
    $status = git status -s
    $hasChanges = $status.Length -gt 0
    
    # Check for unpushed commits
    $unpushedCommits = git log --branches --not --remotes --oneline
    $hasUnpushedCommits = $unpushedCommits.Length -gt 0
    
    Pop-Location
    
    return $hasChanges -or $hasUnpushedCommits
}

# Function to commit and push changes in a submodule
function Push-SubmoduleChanges {
    param (
        [string]$submodulePath
    )
    
    Push-Location $submodulePath
    
    # Get current branch name
    $currentBranch = git rev-parse --abbrev-ref HEAD
    
    # Check for uncommitted changes
    $status = git status -s
    if ($status.Length -gt 0) {
        Write-Host "`nUncommitted changes found in $submodulePath" @Yellow
        git status
        
        $commitMsg = Read-Host "Enter commit message (leave empty to abort)"
        if ([string]::IsNullOrWhiteSpace($commitMsg)) {
            Write-Host "Commit aborted. No changes were pushed." @Yellow
            Pop-Location
            return $false
        }
        
        # Add all changes and commit
        git add -A
        git commit -m "$commitMsg"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error committing changes!" @Red
            Pop-Location
            return $false
        }
    }
    
    # Push changes to remote
    Write-Host "Pushing changes in $submodulePath to origin/$currentBranch..." @Green
    git push origin $currentBranch
    $pushSuccess = $LASTEXITCODE -eq 0
    
    Pop-Location
    
    if ($pushSuccess) {
        Write-Host "Successfully pushed changes in $submodulePath!" @Green
        return $true
    }
    else {
        Write-Host "Failed to push changes in $submodulePath!" @Red
        return $false
    }
}

# Function to update the main repository to track new submodule commits
function Update-MainRepository {
    Write-Host "`n[3] Updating main repository to track new submodule commits..." @Green
    
    $status = git status -s
    if ($status -match "server|ui") {
        $commitMsg = Read-Host "Enter commit message for main repository update (leave empty to abort)"
        if ([string]::IsNullOrWhiteSpace($commitMsg)) {
            Write-Host "Update aborted. Submodule references in main repository not updated." @Yellow
            return $false
        }
        
        # Add changed submodule references and commit
        git add server ui
        git commit -m "$commitMsg"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error committing submodule reference updates!" @Red
            return $false
        }
        
        # Ask if changes should be pushed to remote
        $pushChoice = Read-Host "Push these changes to remote? (y/n)"
        if ($pushChoice -eq "y") {
            # Get current branch name
            $currentBranch = git rev-parse --abbrev-ref HEAD
            
            git push origin $currentBranch
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error pushing changes to remote!" @Red
                return $false
            }
            
            Write-Host "Successfully pushed changes to remote!" @Green
        }
        
        return $true
    }
    else {
        Write-Host "No submodule reference changes to commit in the main repository." @Green
        return $true
    }
}

# Main execution
Show-Header

# Step 1: Update all submodules
$updateResult = Update-AllSubmodules
if (-not $updateResult) {
    Write-Host "Submodule update failed. Exiting script." @Red
    exit 1
}

# Step 2: Check for changes in submodules and push if needed
Write-Host "`n[2] Checking for changes in submodules..." @Green
$submodules = @("server", "ui")
$submodulesChanged = $false

foreach ($submodule in $submodules) {
    if (Test-SubmoduleHasChanges -submodulePath $submodule) {
        Write-Host "Changes detected in $submodule submodule" @Yellow
        $pushChoice = Read-Host "Do you want to commit and push changes in the $submodule submodule? (y/n)"
        
        if ($pushChoice -eq "y") {
            $pushResult = Push-SubmoduleChanges -submodulePath $submodule
            if ($pushResult) {
                $submodulesChanged = $true
            }
        }
        else {
            Write-Host "Skipping push for $submodule" @Yellow
        }
    }
    else {
        Write-Host "No changes detected in $submodule submodule" @Green
    }
}

# Step 3: If submodules were changed, update the main repository
if ($submodulesChanged) {
    Update-MainRepository
}

Write-Host "`n=====================================================" @Cyan
Write-Host "              SCRIPT COMPLETED" @Cyan
Write-Host "=====================================================" @Cyan