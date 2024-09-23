#!/usr/bin/env bash

config=$1

echo "Analysing $config"
#head -n 1 $config

## Check not extras we will have to do manually
detected_memory=$(grep -c 'max_memory' $config)
detected_cpus=$(grep -c 'max_cpus' $config)
detected_time=$(grep -c 'max_time' $config)

detected_process=$(grep -c 'process {' $config)

cont="true"

if [[ "$detected_memory" -gt 1 ]]; then
    echo "ERROR: More than one max_memory detected in $config with $detected_memory"
    cont=false
fi

if [[ $detected_cpus -gt 1 ]]; then
    echo "ERROR: More than one max_cpus detected in $config"
    cont=false
fi

if [[ $detected_time -gt 1 ]]; then
    echo "ERROR: More than one max_time detected in $config"
    cont=false
fi

if [[ $detected_process -gt 1 ]]; then
    echo "ERROR: More than one process detected in $config"
    cont=false
fi

if [[ $detected_processalt -gt 1 ]]; then
    echo "ERROR: More than one process detected in $config"
    cont=false
fi

if [[ "$cont" = true ]]; then
    echo "Grabbing defaults for $config"
    mem_limit=$(grep 'max_memory' "$config" | xargs | cut -d ' ' -f 3)
    cpus_limit=$(grep 'max_cpus' "$config" | xargs | cut -d ' ' -f 3)
    time_limit=$(grep 'max_time' "$config" | xargs | cut -d ' ' -f 3)

    echo "Final value for $config"
    echo "$mem_limit"
    echo "$cpus_limit"
    echo "$time_limit"

    echo "Preparing for injection"
    indent_size=$(grep 'max_memory' "$config" | cut -f 1 -d 'm' | wc -c)
    actual_index_size=$(($indent_size - 1))
    the_indent=$(seq 1 $actual_index_size | sed 's/.*/ /' | tr -d '\n')

    echo "Indent size: $actual_index_size"
    echo "Indent is from here${the_indent}to here"

    resource_mem="${the_indent}memory: ${mem_limit}"
    resource_cpu="${the_indent}cpus: ${cpus_limit}"
    resource_time="${the_indent}time: ${time_limit}"

    sed -i "/process {/a jamon${the_indent}resourceLimits = [\n    $resource_mem,\n    $resource_cpu,\n    $resource_time\n${the_indent}]" $config
    sed -i 's/jamon//g' $config
else
    echo "ERROR: cannot complete the operation for $config, do manually"
fi

## How many configs have more than one process ?
