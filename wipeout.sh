#!/bin/bash

#Test Azure Script-based Authentication Methods

function login () {
	printf "logging into azure ...\n"
	login=$(az login)
	printf "> $login <\n"
	printf "============== DONE ================"
}

function listAccounts () {
	printf "listing subscriptions (account)\n"
	#accounts=$(az account list --all)
	accounts=$(az account list)
	printf "> $accounts <\n"
	printf "============== DONE ================"
}

function listManagementGroups () {
	printf "listing management-groups \n"
	mg=$(az account management-group list |jq -r '.[]|.name')

    for item in $mg
    do
    	printf "> $item <\n"
    	#inspectManagementGroup $item
    	listSubscriptionsUnderMG $item
    done

	printf "============== DONE ================"
}

function inspectManagementGroup () {
	groupName=$1
	printf "> inspecting management group: $groupName<\n"
	groupInfo=$(az account management-group show --name $groupName)
	printf "> $groupInfo <\n"
}

function listSubscriptionsUnderMG () {

	mg=$1
	subs=$(az account management-group subscription show-sub-under-mg --name $mg|jq -r '.[]|.name')
        printf "listing subscriptions under management-group $mg\n"
	
	for item in $subs
	do
		printf ">> $item <<\n"
		listResourceGroupsUnderSubscription $item
	done

}

function listResourceGroupsUnderSubscription () {

	subs=$1
	printf "listing resource groups in subscription $subs\n"
	rgs=$(az group list --subscription $subs | jq -r '.[].name')
	#printf "> $rgs <\n"

	for rg in $rgs
    do
    	printf "will delete resource group: $rg\n"
 	    printf "destroyResourceGroup $rg $subs\n"

    	destroyResourceGroup $rg $subs

    done
}

function destroyResourceGroup () {

	rg=$1
	subs=$2
	printf "deleting resource group $rg\n"
	out=$(az group delete --name $rg --yes --subscription $subs)

}


#1) login using the browser
login

#2) list accounts
listAccounts

#3) list management groups
#and destroy everything
listManagementGroups

