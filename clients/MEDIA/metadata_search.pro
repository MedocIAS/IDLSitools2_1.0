
function  metadata_search, KEYWORDS=keywords_list, RECNUM_LIST=recnum_list
	compile_opt idl2
	
	IF n_elements(keywords_list) EQ 0 THEN message," Error metadata_search(): keywords must be specified" ELSE KEYWORDS=keywords_list
	IF n_elements(recnum_list) EQ 0 THEN  RECNUM_LIST=LIST( STRCOMPRESS(self.recnum, /REMOVE_ALL) ) ELSE RECNUM_LIST=recnum_list
	PRINT , N_ELEMENTS(RECNUM_LIST)

	ds_aia_lev1=obj_new('sdoaiadataset')
	;#Build Query
	fields_list=(ds_aia_lev1->get_attributes()).FIELDS_LIST
	param_query_aia=LIST(fields_list[0],RECNUM_LIST,'IN')
;;	PRINT , param_query_aia
	Q_aia=obj_new('query',param_query_aia)
	O1_aia=LIST()
	FOREACH key, KEYWORDS DO BEGIN
		IF (ds_aia_lev1->get_fields_struct()).HasKey(key) THEN O1_aia.Add,(ds_aia_lev1->get_fields_struct())[key] ELSE message,"Error metadata_search(): keyword does not exist" 
	ENDFOREACH

	S1_aia=LIST(LIST(fields_list[18],'ASC'));;sort by date_obs ascendant

	results=ds_aia_lev1->search(LIST(Q_aia),O1_aia,S1_aia)
	OBJ_DESTROY, ds_aia_lev1, Q_aia 
	IF n_elements(results) EQ 1 THEN return, results[0] ELSE return , results
end
