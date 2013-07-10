
function  media_get_selection, MEDIA_DATA_LIST=media_list, TARGET_DIR=target_dir_value, DOWNLOAD_TYPE=downloadtype_value , QUIET=quiet_value, FILENAME=filename_value
	compile_opt idl2
	sdo_dataset=obj_new('sdoiasdataset')

	IF n_elements(media_list) EQ 0 THEN message, "Provide media list result of a search please" ELSE MEDIA_DATA_LIST=media_list
	IF n_elements(target_dir_value) NE 0 THEN TARGET_DIR=target_dir_value
	IF n_elements(quiet_value) EQ 0 THEN QUIET=0 ELSE QUIET=quiet_value
	IF n_elements(filename_value) NE 0 THEN FILENAME=filename_value	
	file=obj_new()
	IF n_elements(downloadtype_value) NE 0 THEN BEGIN 
		DOWNLOAD_TYPE=downloadtype_value
		media_data_sunum_list=LIST()
		FOREACH media_item, MEDIA_DATA_LIST DO BEGIN
			media_data_sunum_list.Add, media_item->get_sunum()
		ENDFOREACH
		file=sdo_dataset->getSelection(SUNUM_LIST=media_data_sunum_list,  FILENAME=FILENAME, TARGET_DIR=TARGET_DIR, DOWNLOAD_TYPE=DOWNLOAD_TYPE, QUIET=QUIET )
	ENDIF

	return, file
end
