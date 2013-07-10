
function  gaia_get_selection, GAIA_LIST=gaia_list, TARGET_DIR=target_dir_value, DOWNLOAD_TYPE=downloadtype_value , QUIET=quiet_value, FILENAME=filename_value
	compile_opt idl2
	gaia_dataset=obj_new('gaiadataset')

	IF n_elements(gaia_list) EQ 0 THEN message, "Provide gaia list result of a gaia_search please" ELSE GAIA_LIST=gaia_list
	IF n_elements(target_dir_value) NE 0 THEN TARGET_DIR=target_dir_value
	IF n_elements(quiet_value) EQ 0 THEN QUIET=0 ELSE QUIET=quiet_value	
	IF n_elements(filename_value) NE 0 THEN FILENAME=filename_value	
	file=obj_new()
	IF n_elements(downloadtype_value) NE 0 THEN BEGIN 
		DOWNLOAD_TYPE=downloadtype_value
		gaia_data_sunum_list=LIST()
		FOREACH gaia_item, GAIA_LIST DO BEGIN
			gaia_data_sunum_list.Add, gaia_item->get_sunum_193()
		ENDFOREACH
		file=gaia_dataset->getSelection(SUNUM_LIST=gaia_data_sunum_list,  FILENAME=FILENAME, TARGET_DIR=TARGET_DIR, DOWNLOAD_TYPE=DOWNLOAD_TYPE, QUIET=QUIET )
	ENDIF

	return, file
end
