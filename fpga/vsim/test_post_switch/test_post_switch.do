onerror {quit -f}
onbreak {quit -f}

set vlog_opts {-incr}

vlib work

vlog $vlog_opts ../../src/test_post_switch.v
vlog $vlog_opts ../../src/post_switch.v
vlog $vlog_opts ../../src/CRC_gen.v

vopt +acc test_post_switch -o test_post_switch_opt 

vsim test_post_switch_opt

run -a
