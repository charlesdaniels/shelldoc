#!/bin/sh

# .SCRIPTDOC

# This script runs the ShellDoc end-to-end smoke tests.

# .DESCRIPTION

# This script consumes tab-separated-values with the following fields, in
# order:

# * test description (human readable)
# * input file to use with shelldoc
# * file containing the expected output (not including stderr)
# * expected return code from shelldoc
# * (optional) arguments to pass to shelldoc (should not include ``--input`` or
# ``--output``)

# This script will display human-readable output relating to the status of each
# test case on standard out, and will use the number of failed test cases as
# its exit code.

# This script needs to be run from the ``smoketest`` folder.

# .SYNTAX

# /dev/stdin . . . test cases in the noted format
#
# EXAMPLE:
#
# ./do_test.sh < testcases.tsv

# .AUTHOR

# Charles Daniels

# .ENDOC

SHELLDOC="../shelldoc"
FAILED_COUNT=0

while read -r testcase ; do
	if [ "$(echo "$testcase" | tr -d ' ' | tr -d '\t' | tr -d '\r' | tr -d '\n')" = "" ] ; then
		# this line is blank, skip it
		continue
	fi

	TEST_DESC="$(echo "$testcase" | cut -f 1)"
	TEST_INPUT="$(echo "$testcase" | cut -f 2)"
	TEST_EXPECTED="$(echo "$testcase" | cut -f 3)"
	TEST_EXPECTED_RETCODE="$(echo "$testcase" | cut -f 4)"
	TEST_ARGS="$(echo "$testcase" | cut -f 5)"
	TEST_OUTPUT="/tmp/$(uuidgen)"

	printf "Running test '$TEST_DESC'... "

	# make sure the expected input and output files actually exist
	if [ ! -f "$TEST_INPUT" ] ; then
		echo "FAIL"
		echo "\tNo such input file '$TEST_INPUT'"
		FAILED_COUNT=$(echo "$FAILED_COUNT + 1" | bc)
		continue
	fi

	if [ ! -f "$TEST_EXPECTED" ] ; then
		echo "FAIL"
		echo "\tNo such input file '$TEST_EXPECTED'"
		FAILED_COUNT=$(echo "$FAILED_COUNT + 1" | bc)
		continue
	fi

	# run the test
	TEST_STDERR="$($SHELLDOC --input "$TEST_INPUT" --output "$TEST_OUTPUT" $TEST_ARGS 2>&1)"
	RETCODE=$?
	TEST_DIFF="$(diff "$TEST_OUTPUT" "$TEST_EXPECTED" 2>&1)"

	if [ "$RETCODE" -ne "$TEST_EXPECTED_RETCODE" ] ; then
		echo "FAIL"
		echo "\tShellDoc return code '$RETCODE' did not match the expected '$TEST_EXPECTED_RETCODE'\n"
		echo "\tStandard error from shelldoc:\n\n"
		echo "$TEST_STDERR" | while read -r ln ; do echo "\t\t$ln" ; done
		echo ""
		FAILED_COUNT=$(echo "$FAILED_COUNT + 1" | bc)

	elif [ "$( echo "$(echo "$TEST_DIFF" | wc -l) - 1" | bc)" -ne 0 ] ; then
		echo "FAIL"
		echo "\tTest output did not match expected output\n"
		echo "\tExpected output was: \n"
		while read -r ln ; do echo "\t\t$ln" ; done < "$TEST_EXPECTED"
		echo "\n\n\tActual output was: \n"
		while read -r ln ; do echo "\t\t$ln" ; done < "$TEST_OUTPUT"
		echo "\n\n\tDifference between actual and expected output was: \n\n"
		echo "$TEST_DIFF" | while read -r ln ; do echo "\t\t$ln" ; done
		echo "\n\tStandard error from shelldoc:\n\n"
		echo "$TEST_STDERR" | while read -r ln ; do echo "\t\t$ln" ; done
		echo ""
		FAILED_COUNT=$(echo "$FAILED_COUNT + 1" | bc)

	else
		echo "PASS"
	fi

	rm -f "$TEST_OUTPUT"

done < /dev/stdin

echo ""
echo "$FAILED_COUNT test cases failed"
exit $FAILED_COUNT
