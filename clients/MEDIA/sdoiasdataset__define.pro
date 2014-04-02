
function  sdoiasdataset::init
	compile_opt idl2

	self.sitools2_url="medoc-sdo.ias.u-psud.fr"	
	self.sdo_dataset_uri="/webs_IAS_SDO_dataset"
	sdo_url=self.sitools2_url+self.sdo_dataset_uri
	sdo_dataset_code=self->dataset::init(sdo_url)
	
	return,sdo_dataset_code
end



function  sdoiasdataset::getSelection,SUNUM_LIST=sunum_list_value , FILENAME=filename_value, TARGET_DIR=target_dir_value, DOWNLOAD_TYPE=download_type_value ,QUIET=quiet_value
	compile_opt idl2
	IF n_elements(sunum_list_value) EQ 0 THEN message,"Provide sunum_list" ELSE SUNUM_LIST=sunum_list_value
	IF n_elements(target_dir_value) EQ 0 THEN TARGET_DIR='./' ELSE TARGET_DIR=target_dir_value
	IF n_elements(download_type_value) EQ 0 THEN DOWNLOAD_TYPE="TAR" ELSE DOWNLOAD_TYPE=download_type_value
	IF n_elements(filename_value) EQ 0 THEN FILENAME="IAS_SDO_export_"+SYSTIME(/UTC)+"."+STRLOWCASE(DOWNLOAD_TYPE) ELSE FILENAME=filename_value
	IF n_elements(quiet_value) EQ 0 THEN QUIET=0 ELSE QUIET=quiet_value
	IF n_elements(target_dir_value) NE 0 THEN BEGIN 
		IF STRMID(target_dir_value,1,1, /REVERSE_OFFSET) NE '/'  THEN FILENAME=TARGET_DIR+'/'+FILENAME ELSE FILENAME=TARGET_DIR+FILENAME
	ENDIF
	plugin_id=''
		
	IF STRUPCASE(DOWNLOAD_TYPE) EQ "TAR" THEN plugin_id="plugin02" ELSE plugin_id="plugin03"
	IF NOT QUIET THEN PRINT,"Downloading " +FILENAME+"..."
	file=self->dataset::execute_plugin(plugin_name=plugin_id, pkey_list=SUNUM_LIST, FILENAME=FILENAME)
	IF NOT QUIET THEN PRINT,"Download " +FILENAME+" completed"
	return, file
end 

function sdoiasdataset::get_sitools2_url
	compile_opt idl2
	
	value=''
	if self.sitools2_url ne '' then value=self.sitools2_url
	return,value
	
end

function sdoiasdataset::get_sdo_dataset_uri
	compile_opt idl2
	
	value=''
	if self.sitools2_url ne '' then value=self.sdo_dataset_uri
	return,value
	
end


pro sdoiasdataset__define
	compile_opt idl2

	void={sdoiasdataset, sitools2_url : '',sdo_dataset_uri :'',  INHERITS dataset}
 	return
end
