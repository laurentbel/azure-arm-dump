#!/bin/bash

# process a single subscriptions
# $1 : subscription id
function process_subscription() {
    # variables
    sub_id=$1
    batch_size=25

    # display basic info
    sub_name=$(az account show --subscription $sub_id --query name --output tsv)
    echo "processing subscription $sub_name ($sub_id)"

    # loop through the resource groups
    i=0
    j=0
    resource_group_names=$(az group list --subscription $sub_id --query [].name --output tsv)
    resource_group_count=$(echo "$resource_group_names" | wc -l)
    for resource_group_name in $resource_group_names
    do
        # counter increment
        i=$((i+1))
        j=$((j+1))

        # info
        echo "$i / $resource_group_count processing resource group $resource_group_name"

        # process the resource group async
        process_resource_group $sub_id "$sub_name" "$resource_group_name" &

        # batch by 25
        if [ $j -eq $batch_size ]
        then
            echo "Waiting for the threads..."
            wait
            j=0
        fi
    done
}

# process a single resource group
# $1 : subscription id
# $2 : subscription name
# $3 : resource groupe name
function process_resource_group() {
    # parameters
    sub_id=$1
    sub_name=$2
    resource_group_name=$3

    # prepare output
    mkdir -p "/output/$sub_name"

    # export arm template
    az group export --subscription $sub_id --name $resource_group_name --skip-resource-name-params --include-parameter-default-value > "/output/$sub_name/$resource_group_name.json" 2>&1
}

# main function
function main () {
    # starting...
    echo "-- Azure ARM Dump --"
    echo "Backup your entire Azure config in the form of ARM templates"

    # login to azure
    az login

    # loop through subscriptions
    sub_ids=$(az account list --query [].id --output tsv)
    for sub_id in $sub_ids
    do
    process_subscription $sub_id
    done
}

# call main entrypoint
main




