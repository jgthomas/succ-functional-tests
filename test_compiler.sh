#!/bin/bash

BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

padding_dots=$(printf '%0.1s' "."{1..60})
padlength=50
compiler=$1
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


test_not_implemented () {
    echo "NOT IMPLEMENTED"
}


run_our_program () {
    actual_out=`./$1 2>/dev/null`
    actual_exit_code=$?
    rm $1 2>/dev/null
}


run_correct_program () {
    expected_out=`./a.out`
    expected_exit_code=$?
    rm a.out
}


compare_program_results () {
    # make sure exit code is correct
    if [ "$expected_exit_code" -ne "$actual_exit_code" ] || [ "$expected_out" != "$actual_out" ]
    then
        test_failure
    else
        test_success
    fi
}


test_valid() {
        echo "======================================Valid Programs"
        for src_path in $(find . -type f -name "*.c" -path "./stage_$1/valid/*" 2>/dev/null); do

            gcc -w $src_path
            run_correct_program

            exec_path="${src_path%.*}"           # src_path minus *.c
            test_name="${exec_path##*valid/}"    # name of executable minus path

            $compiler $src_path 2>/dev/null
            run_our_program $exec_path

            print_test_name $test_name
            compare_program_results
        done
}


test_valid_multifile() {
        for dir in `ls -d stage_$1/valid_multifile/* 2>/dev/null` ; do
            gcc -w $dir/*

            run_correct_program

            base="${dir%.*}" #name of executable (directory w/out extension)
            test_name="${base##*valid_multifile/}"

            # need to explicitly specify output name
            $compiler -o "$test_name" $dir/* >/dev/null

            print_test_name $test_name

            # check output/exit codes
            run_our_program $test_name
            compare_program_results
        done
}


test_invalid() {
        echo "====================================Invalid Programs"
        for prog in `ls stage_$1/invalid/{,**/}*.c 2>/dev/null`; do

            base="${prog%.*}" #name of executable (filename w/out extension)
            test_name="${base##*invalid/}"

            $compiler $prog >/dev/null 2>&1
            status=$? #failed, as we expect, if exit code != 0
            print_test_name $test_name

            # make sure neither executable nor assembly was produced
            if [[ -f $base || -f $base".s" ]]; then
                test_failure
                rm $base 2>/dev/null
                rm $base".s" 2>/dev/null
            else
                test_success
            fi
        done
}


test_stage () {
    success=0
    fail=0
    printf "\n${1^^}\n"

    test_valid $1
    test_valid_multifile $1
    test_invalid $1
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


if [ "$1" == "" ]; then
    echo "USAGE: ./test_compiler.sh /path/to/compiler [stages(optional)]"
    echo "EXAMPLE(test specific stages): ./test_compiler.sh ./mycompiler 1 2 4"
    echo "EXAMPLE(test all): ./test_compiler.sh ./mycompiler"
    exit 1
fi


if test 1 -lt $#; then
   testcases=("$@") # [1..-1] is testcases
   for i in `seq 2 $#`; do
       test_stage ${testcases[$i-1]}
   done
   total_summary
   exit 0
fi


num_stages=10


for i in `seq 1 $num_stages`; do
    test_stage $i
done


total_summary
