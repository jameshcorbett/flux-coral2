#!/bin/sh

test_description='Test Watching Storages in K8s'

. $(dirname $0)/sharness.sh

FLUX_SIZE=2

test_under_flux ${FLUX_SIZE} job

flux setattr log-stderr-level 1

DATA_DIR=${SHARNESS_TEST_SRCDIR}/data/nnf-watch/
DWS_MODULE_PATH=${FLUX_SOURCE_DIR}/src/modules/coral2_dws.py
RPC=${FLUX_BUILD_DIR}/t/util/rpc

check_dmesg_for_pattern() {
	flux dmesg | grep -q "$1" || return 1
}

if test_have_prereq NO_DWS_K8S; then
    skip_all='skipping DWS workflow tests due to no DWS K8s'
    test_done
fi

test_expect_success 'job-manager: load alloc-bypass plugin' '
	flux jobtap load alloc-bypass.so
'

test_expect_success 'exec nnf watching script' '
	echo $PYTHONPATH >&2 &&
	R=$(flux R encode -r 0) &&
	jobid=$(flux submit \
	        --setattr=system.alloc-bypass.R="$R" \
	        -o per-resource.type=node flux python ${DWS_MODULE_PATH}) &&
	flux job wait-event -vt 15 -p guest.exec.eventlog ${jobid} shell.start
'

# This test used to close the race condition between the python process starting
# and the `dws` service being registered.  Once https://github.com/flux-framework/flux-core/issues/3821
# is implemented/closed, this can be replaced with that solution.
test_expect_success 'wait for service to register and send test RPC' '
	flux job wait-event -vt 15 -m "note=dws watchers setup" ${jobid} exception &&
	${RPC} "dws.watch_test" 
'

test_expect_failure 'updating the NNF status is caught by the watch' '
	flux dmesg -C &&
	kubectl patch storages flux-test-storage0 \
		--type merge --patch "$(cat ${DATA_DIR}/down.yaml)" &&
	${RPC} "dws.watch_test" &&
	check_dmesg_for_pattern "flux-test-storage0 status changed to NotReady" &&
	check_dmesg_for_pattern "flux-test-storage0 capacity changed to 100000"
'

test_expect_failure 'revert the changes to the NNF' '
	flux dmesg -C &&
	kubectl patch storages flux-test-storage0 \
		--type merge --patch "$(cat ${DATA_DIR}/up.yaml)" &&
	${RPC} "dws.watch_test" &&
	check_dmesg_for_pattern "flux-test-storage0 status changed to Ready" &&
	check_dmesg_for_pattern "flux-test-storage0 capacity changed to 50000"
'

test_done
