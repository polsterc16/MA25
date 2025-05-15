set hdsFileList [list]
set ipFileList [list]
array set hdsFileDialectsArray [list]
lappend hdsFileList proj_master_2025_lib
lappend hdsFileList "$::env(HDS_PROJECT_DIR)/proj_master_2025_lib/hdl/p_002_generic_01_pkg.vhd"
set hdsFileDialectsArray("$::env(HDS_PROJECT_DIR)/proj_master_2025_lib/hdl/p_002_generic_01_pkg.vhd") "VHDL_2008"
lappend hdsFileList proj_master_2025_lib
lappend hdsFileList "$::env(HDS_PROJECT_DIR)/proj_master_2025_lib/hdl/c_004_layer_01_rtl.vhd"
set hdsFileDialectsArray("$::env(HDS_PROJECT_DIR)/proj_master_2025_lib/hdl/c_004_layer_01_rtl.vhd") "VHDL_2008"
lappend hdsFileList proj_master_2025_lib
lappend hdsFileList "$::env(HDS_PROJECT_DIR)/proj_master_2025_lib/hdl/c_x_ANN_01_struct.vhd"
set hdsFileDialectsArray("$::env(HDS_PROJECT_DIR)/proj_master_2025_lib/hdl/c_x_ANN_01_struct.vhd") "VHDL_2008"
lappend hdsFileList proj_master_2025_lib
lappend hdsFileList "$::env(HDS_PROJECT_DIR)/proj_master_2025_lib/hdl/tb_005_ann_01_struct.vhd"
set hdsFileDialectsArray("$::env(HDS_PROJECT_DIR)/proj_master_2025_lib/hdl/tb_005_ann_01_struct.vhd") "VHDL_2008"
set vlogGlobalFileList [list]

