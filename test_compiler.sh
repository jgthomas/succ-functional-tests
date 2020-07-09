#!/bin/bash

BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

padding_dots=$(printf '%0.1s' "."{1..60})
padlength=50

# arguments
compiler=$1
shift
first_command=$1
test_cases=$@

# commands
list_tests="tests"

# paths
test_group_label="stage"
should_pass="valid"
should_fail="invalid"
should_pass_multi_file="valid_multifile"

success_total=0
failure_total=0


print_test_name () {
    test_name=$1
    printf '%s' "$test_name"
    printf '%*.*s' 0 $((padlength - ${#test_name})) "$padding_dots"
}


print_thick_line() {
        echo "===================================================="
}


print_thin_line() {
        echo "----------------------------------------------------"
}


print_star_line() {
        echo "****************************************************"
}


test_success () {
    printf '%s\n' "${GREEN}OK${NORMAL}"
    ((success++))
}


test_failure () {
    printf '%s\n' "${RED}FAIL${NORMAL}"
    ((fail++))
}


run_our_program () {
    actual_out=$(./$1 2>/dev/null)
    actual_exit_code=$?
    rm $1 2>/dev/null
}


run_correct_program () {
    expected_out=$(./a.out)
    expected_exit_code=$?
    rm a.out
}


compare_program_results () {
    if [[ "$expected_exit_code" -ne "$actual_exit_code" || "$expected_out" != "$actual_out" ]]; then
        test_failure
    else
        test_success
    fi
}


test_valid() {
        echo "======================================Valid Programs"
        valid_path="./${test_group_label}_${1}/${should_pass}/*"
        for src_path in $(find . -type f -name "*.c" -path "$valid_path" 2>/dev/null); do

            gcc -w $src_path
            run_correct_program

            exec_path="${src_path%.*}"         # source path minus *.c
            test_name="${exec_path##*valid/}"  # name of executable minus path

            $compiler $src_path 2>/dev/null
            run_our_program $exec_path

            print_test_name $test_name
            compare_program_results
        done
}


test_invalid() {
        echo "====================================Invalid Programs"
        invalid_path="./${test_group_label}_${1}/${should_fail}/*"
        for src_path in $(find . -type f -name "*.c" -path "$invalid_path" 2>/dev/null); do

            exec_path="${src_path%.*}"           # source path minus *.c
            test_name="${exec_path##*invalid/}"  # name of executable minus path

            $compiler $src_path >/dev/null 2>&1
            print_test_name $test_name

            # neither executable nor assembly should be produced
            if [[ -f $exec_path || -f $exec_path".s" ]]; then
                test_failure
                rm $exec_path 2>/dev/null
                rm $exec_path".s" 2>/dev/null
            else
                test_success
            fi
        done
}


test_valid_multifile() {
        echo "============================Valid Multifile Programs"
        valid_multi_path="./${test_group_label}_${1}/${should_pass_multi_file}/*"
        for dir in $(find -type d -path "$valid_multi_path" 2>/dev/null); do

            gcc -w $dir/*
            run_correct_program

            exec_path="${dir%.*}"                        # source path (directory w/out extension)
            test_name="${exec_path##*valid_multifile/}"  # name of executable minus path

            # need to explicitly specify output name
            $compiler -o "$test_name" $dir/* >/dev/null
            run_our_program $test_name

            print_test_name $test_name
            compare_program_results
        done
}


test_stage () {
    success=0
    fail=0
    printf "\n${1^^}\n"

    test_valid $1
    test_invalid $1
    #test_valid_multifile $1
    stage_summary $1

    ((success_total=success_total+success))
    ((failure_total=failure_total+fail))
}


stage_summary() {
        print_thick_line

        printf '%-12s' "${1^^}"

        if (($fail == 0)); then
                printf "${GREEN}%18d successes${NORMAL}, %d failures\n" $success $fail
        else
                printf "%18d successes, ${RED}%d failures${NORMAL}\n" $success $fail
        fi

        print_thick_line
}


total_summary () {
    printf '\n%-12s' "OVERALL"

    if (($failure_total == 0)); then
            printf "${GREEN}%18d successes${NORMAL}, %d failures\n" $success_total $failure_total
    else
            printf "%18d successes, ${RED}%d failures${NORMAL}\n" $success_total $failure_total
    fi

    print_thick_line
}


usage() {
    echo "USAGE: ./test_compiler.sh /path/to/compiler [stages]"
    echo "RUN NAMED TESTS: ./test_compiler.sh /path/to/compiler tests1 tests2 tests3"
    echo "RUN ALL STAGES: ./test_compiler.sh  /path/to/compiler"
}


if [[ -z $compiler ]]; then
        usage
        exit 1
fi


all_test_cases="literals \
                unary \
                binary_I \
                binary_II \
                locals \
                conditionals \
                compound \
                loops \
                functions \
                globals \
                ops \
                pointers \
                types \
                bitwise \
                array"


if [[ $first_command == $list_tests ]]; then
        printf "TEST GROUPS\n"
        printf "===========\n"
        for test_case in $all_test_cases; do
                echo $test_case
        done
        exit 0
fi


if [[ -z $test_cases ]]; then
        test_cases=$all_test_cases
fi


for test_case in $test_cases; do
        test_stage $test_case
done


total_summary
