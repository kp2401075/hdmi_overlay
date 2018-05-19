set_global_assignment -entity "fast_pll" -library "lib_fast_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "fast_pll" -library "lib_fast_pll" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "fast_pll" -library "lib_fast_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fast_pll" -name SPD_FILE [file join $::quartus(sip_path) "fast_pll.spd"]

set_global_assignment -library "lib_fast_pll" -name MISC_FILE [file join $::quartus(sip_path) "fast_pll_sim/fast_pll.vo"]
