
function  gaiadataset::init
	compile_opt idl2
	self.sitools2_url="medoc-dem.ias.u-psud.fr"	
	self.gaia_dataset_uri="/ws_SDO_DEM"
	gaia_url=self.sitools2_url+self.gaia_dataset_uri
	gaia_dataset_code=self->dataset::init(gaia_url)
	
	return,gaia_dataset_code
end

function  gaiadataset::getSelection,SUNUM_LIST=sunum_list_value , FILENAME=filename_value, TARGET_DIR=target_dir_value, DOWNLOAD_TYPE=download_type_value ,QUIET=quiet_value
	compile_opt idl2
	
	IF n_elements(sunum_list_value) EQ 0 THEN message,"Provide sunum_list" ELSE SUNUM_LIST=sunum_list_value
	IF n_elements(target_dir_value) EQ 0 THEN TARGET_DIR='./' ELSE TARGET_DIR=target_dir_value
	IF n_elements(download_type_value) EQ 0 THEN DOWNLOAD_TYPE="TAR" ELSE DOWNLOAD_TYPE=download_type_value
	IF n_elements(filename_value) EQ 0 THEN FILENAME="IAS_GAIA_export_"+SYSTIME(/UTC)+"."+STRLOWCASE(DOWNLOAD_TYPE) ELSE FILENAME=filename_value
	IF n_elements(quiet_value) EQ 0 THEN QUIET=0 ELSE QUIET=quiet_value
	IF n_elements(target_dir_value) NE 0 THEN BEGIN 
		IF STRMID(target_dir_value,1,1, /REVERSE_OFFSET) NE '/'  THEN FILENAME=TARGET_DIR+'/'+FILENAME ELSE FILENAME=TARGET_DIR+FILENAME
	ENDIF
	plugin_id=''
	IF STRUPCASE(DOWNLOAD_TYPE) EQ "TAR" THEN plugin_id="download_tar_DEM" ELSE message, "Only TAR is allowed for parameter DOWNLOAD_TYPE"
	IF NOT QUIET THEN PRINT,"Downloading " +FILENAME+"..."
	file=self->dataset::execute_plugin(plugin_name=plugin_id, pkey_list=SUNUM_LIST, FILENAME=FILENAME)
	IF NOT QUIET THEN PRINT,"Download " +FILENAME+" completed"
	return, file
end 

function gaiadataset::get_sitools2_url
	compile_opt idl2
	
	value=''
	if self.sitools2_url ne '' then value=self.sitools2_url
	return,value
	
end

function gaiadataset::get_sdo_dataset_uri
	compile_opt idl2
	
	value=''
	if self.sitools2_url ne '' then value=self.sdo_dataset_uri
	return,value
	
end


pro gaiadataset__define
	compile_opt idl2

	void={gaiadataset, sitools2_url : '',gaia_dataset_uri :'', INHERITS dataset}
 	return
end
