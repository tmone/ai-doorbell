#!/bin/bash
# Git Submodule Auto-Sync Script
# This script helps manage submodules by:
# 1. Pulling latest changes from all submodules
# 2. Detecting and pushing changes in submodules if any exist

# Define colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to show script header
show_header() {
    echo -e "\n${CYAN}====================================================="
    echo -e "         GIT SUBMODULE AUTO-SYNC SCRIPT"
    echo -e "=====================================================${NC}"
}

# Function to pull latest changes for all submodules
update_all_submodules() {
    echo -e "\n${GREEN}[1] Updating all submodules...${NC}"
    
    # Initialize submodules if needed
    git submodule init
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error initializing submodules!${NC}"
        return 1
    fi
    
    # Update all submodules to latest remote version
    git submodule update --remote --recursive
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error updating submodules from remote!${NC}"
        return 1
    fi
    
    # For each submodule, checkout main branch and pull latest changes
    git submodule foreach "git checkout main && git pull"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error checking out main branch or pulling in one or more submodules!${NC}"
        return 1
    fi
    
    echo -e "${GREEN}All submodules updated successfully!${NC}"
    return 0
}

# Function to check if a submodule has changes
test_submodule_has_changes() {
    local submodule_path=$1
    
    pushd $submodule_path > /dev/null
    
    # Check for uncommitted changes
    local status=$(git status -s)
    local has_changes=0
    if [ -n "$status" ]; then
        has_changes=1
    fi
    
    # Check for unpushed commits
    local unpushed_commits=$(git log --branches --not --remotes --oneline)
    local has_unpushed_commits=0
    if [ -n "$unpushed_commits" ]; then
        has_unpushed_commits=1
    fi
    
    popd > /dev/null
    
    if [ $has_changes -eq 1 ] || [ $has_unpushed_commits -eq 1 ]; then
        return 0  # true in shell script (success)
    else
        return 1  # false in shell script (failure)
    fi
}

# Function to commit and push changes in a submodule
push_submodule_changes() {
    local submodule_path=$1
    
    pushd $submodule_path > /dev/null
    
    # Get current branch name
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Check for uncommitted changes
    local status=$(git status -s)
    if [ -n "$status" ]; then
        echo -e "\n${YELLOW}Uncommitted changes found in $submodule_path${NC}"
        git status
        
        echo -n "Enter commit message (leave empty to abort): "
        read commit_msg
        if [ -z "$commit_msg" ]; then
            echo -e "${YELLOW}Commit aborted. No changes were pushed.${NC}"
            popd > /dev/null
            return 1
        fi
        
        # Add all changes and commit
        git add -A
        git commit -m "$commit_msg"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error committing changes!${NC}"
            popd > /dev/null
            return 1
        fi
    fi
    
    # Push changes to remote
    echo -e "${GREEN}Pushing changes in $submodule_path to origin/$current_branch...${NC}"
    git push origin $current_branch
    local push_success=$?
    
    popd > /dev/null
    
    if [ $push_success -eq 0 ]; then
        echo -e "${GREEN}Successfully pushed changes in $submodule_path!${NC}"
        return 0
    else
        echo -e "${RED}Failed to push changes in $submodule_path!${NC}"
        return 1
    fi
}

# Function to update the main repository to track new submodule commits
update_main_repository() {
    echo -e "\n${GREEN}[3] Updating main repository to track new submodule commits...${NC}"
    
    local status=$(git status -s)
    if echo "$status" | grep -E "server|ui" > /dev/null; then
        echo -n "Enter commit message for main repository update (leave empty to abort): "
        read commit_msg
        if [ -z "$commit_msg" ]; then
            echo -e "${YELLOW}Update aborted. Submodule references in main repository not updated.${NC}"
            return 1
        fi
        
        # Add changed submodule references and commit
        git add server ui
        git commit -m "$commit_msg"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error committing submodule reference updates!${NC}"
            return 1
        fi
        
        # Ask if changes should be pushed to remote
        echo -n "Push these changes to remote? (y/n): "
        read push_choice
        if [ "$push_choice" = "y" ]; then
            # Get current branch name
            local current_branch=$(git rev-parse --abbrev-ref HEAD)
            
            git push origin $current_branch
            if [ $? -ne 0 ]; then
                echo -e "${RED}Error pushing changes to remote!${NC}"
                return 1
            fi
            
            echo -e "${GREEN}Successfully pushed changes to remote!${NC}"
        fi
        
        return 0
    else
        echo -e "${GREEN}No submodule reference changes to commit in the main repository.${NC}"
        return 0
    fi
}

# Main execution
show_header

# Step 1: Update all submodules
update_all_submodules
if [ $? -ne 0 ]; then
    echo -e "${RED}Submodule update failed. Exiting script.${NC}"
    exit 1
fi

# Step 2: Check for changes in submodules and push if needed
echo -e "\n${GREEN}[2] Checking for changes in submodules...${NC}"
submodules=("server" "ui")
submodules_changed=0

for submodule in "${submodules[@]}"; do
    if test_submodule_has_changes "$submodule"; then
        echo -e "${YELLOW}Changes detected in $submodule submodule${NC}"
        echo -n "Do you want to commit and push changes in the $submodule submodule? (y/n): "
        read push_choice
        
        if [ "$push_choice" = "y" ]; then
            push_submodule_changes "$submodule"
            if [ $? -eq 0 ]; then
                submodules_changed=1
            fi
        else
            echo -e "${YELLOW}Skipping push for $submodule${NC}"
        fi
    else
        echo -e "${GREEN}No changes detected in $submodule submodule${NC}"
    fi
done

# Step 3: If submodules were changed, update the main repository
if [ $submodules_changed -eq 1 ]; then
    update_main_repository
fi

echo -e "\n${CYAN}====================================================="
echo -e "              SCRIPT COMPLETED"
echo -e "=====================================================${NC}"