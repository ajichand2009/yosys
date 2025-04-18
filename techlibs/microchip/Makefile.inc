# ISC License
# 
# Copyright (C) 2024 Microchip Technology Inc. and its subsidiaries
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.  
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.



OBJS += techlibs/microchip/synth_microchip.o
OBJS += techlibs/microchip/microchip_dffopt.o

$(eval $(call add_share_file,share/microchip,techlibs/microchip/arith_map.v))
$(eval $(call add_share_file,share/microchip,techlibs/microchip/cells_map.v))
$(eval $(call add_share_file,share/microchip,techlibs/microchip/cells_sim.v))
$(eval $(call add_share_file,share/microchip,techlibs/microchip/polarfire_dsp_map.v))

$(eval $(call add_share_file,share/microchip,techlibs/microchip/brams_defs.vh))
$(eval $(call add_share_file,share/microchip,techlibs/microchip/LSRAM_map.v))
$(eval $(call add_share_file,share/microchip,techlibs/microchip/LSRAM.txt))
$(eval $(call add_share_file,share/microchip,techlibs/microchip/uSRAM_map.v))
$(eval $(call add_share_file,share/microchip,techlibs/microchip/uSRAM.txt))

OBJS += techlibs/microchip/microchip_dsp.o
GENFILES += techlibs/microchip/microchip_dsp_pm.h
GENFILES += techlibs/microchip/microchip_dsp_CREG_pm.h
GENFILES += techlibs/microchip/microchip_dsp_cascade_pm.h
techlibs/microchip/microchip_dsp.o: techlibs/microchip/microchip_dsp_pm.h techlibs/microchip/microchip_dsp_CREG_pm.h techlibs/microchip/microchip_dsp_cascade_pm.h
$(eval $(call add_extra_objs,techlibs/microchip/microchip_dsp_pm.h))
$(eval $(call add_extra_objs,techlibs/microchip/microchip_dsp_CREG_pm.h))
$(eval $(call add_extra_objs,techlibs/microchip/microchip_dsp_cascade_pm.h))
