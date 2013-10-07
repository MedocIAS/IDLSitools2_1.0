
function sdodata::init,data
	compile_opt idl2

	self.url=''
	self.recnum=LONG(0)
	self.sunum=LONG(0)
	self.date_obs=''
	self.wave=UINT(0)
	self.ias_location=''
	self.exptime=FLOAT(0)
	self.t_rec_index=LONG(0)
	self->compute_attributes,data
	return,1
end

pro sdodata::compute_attributes,data
	compile_opt idl2
	self.url=data['get']
	self.recnum=data['recnum']
	self.sunum=data['sunum']
	self.date_obs=data['date__obs']
	self.wave=data['wavelnth']
	self.ias_location=data['ias_location']
	self.exptime=data['exptime']
	self.t_rec_index=data['t_rec_index']
end

function sdodata::get_attributes
	compile_opt idl2
	
	attributes={url : self.url,$
			recnum : self.recnum,$
			sunum :self.sunum,$
			date_obs :self.date_obs,$
			wave :self.wave,$
			ias_location :self.ias_location,$
			exptime :self.exptime,$
			t_rec_index: self.t_rec_index}
	
	return,attributes
end


function sdodata::get_url
	compile_opt idl2

	value=''
	if self.url ne '' then value=self.url
	return,value
end

function sdodata::get_sunum
	compile_opt idl2

	value=''
	if self.sunum ne '' then value=self.sunum
	return,value
end

function sdodata::get_ias_location
	compile_opt idl2

	value=''
	if self.ias_location ne '' then value=self.ias_location
	return,value
end

function sdodata::get_date_obs
	compile_opt idl2

	value=''
	if self.date_obs ne '' then value=self.date_obs
	return,value
end

function sdodata::get_wave
	compile_opt idl2

	value=''
	if self.wave ne '' then value=self.wave
	return,value
end

function sdodata::get_file, DECOMPRESS=decompress_value, FILENAME=filename_value, TARGET_DIR=target_dir_value, QUIET=quiet_value
	compile_opt idl2
	
	IF n_elements(decompress_value) EQ 0 THEN DECOMPRESS=0 ELSE DECOMPRESS=decompress_value
	IF n_elements(target_dir_value) EQ 0 THEN TARGET_DIR='./' ELSE TARGET_DIR=target_dir_value
	IF n_elements(filename_value) EQ 0 THEN FILENAME="aia.lev1."+STRCOMPRESS(self.wave, /REMOVE_ALL)+"A_"+self.date_obs+".image_lev1.fits" ELSE FILENAME=filename_value
	IF n_elements(quiet_value) EQ 0 THEN QUIET=0 ELSE QUIET=quiet_value
	IF n_elements(target_dir_value) NE 0 THEN BEGIN 
		IF STRMID(target_dir_value,1,1, /REVERSE_OFFSET) NE '/'  THEN FILENAME=TARGET_DIR+'/'+FILENAME ELSE FILENAME=TARGET_DIR+FILENAME
	ENDIF
	url=''
	IF NOT DECOMPRESS THEN url=(strsplit(self.url,"http://",/EXTRACT, /REGEX))[-1]+";compress=rice"
	oUrl_get=OBJ_NEW('IDLnetUrl')
	oUrl_get.SetProperty, url_scheme='http'
	oUrl_get.SetProperty, URL_HOST=url
	file=oUrl_get.Get(FILENAME=FILENAME)
	IF NOT QUIET THEN PRINT,"Downloading " +FILENAME+"..."
	OBJ_DESTROY, oUrl_get
	return , file
end 



function sdodata::metadata_search, KEYWORDS=keywords_list, RECNUM_LIST=recnum_list
	compile_opt idl2

	IF n_elements(keywords_list) EQ 0 THEN message," Error metadata_search(): keywords must be specified" ELSE KEYWORDS=keywords_list
	IF n_elements(recnum_list) EQ 0 THEN  RECNUM_LIST=LIST( STRCOMPRESS(self.recnum, /REMOVE_ALL) ) ELSE RECNUM_LIST=recnum_list
	
	ds_aia_lev1=obj_new('sdoaiadataset')
	;#Build Query
	fields_list=(ds_aia_lev1->get_attributes()).FIELDS_LIST
	param_query_aia=LIST(fields_list[0],RECNUM_LIST,'IN')
	Q_aia=obj_new('query',param_query_aia)
	O1_aia=LIST()
	FOREACH key, KEYWORDS DO BEGIN
		IF (ds_aia_lev1.fields_struct).HasKey(key) THEN O1_aia.Add,(ds_aia_lev1.fields_struct)[key] ELSE message,"Error metadata_search(): keyword does not exist" 
	ENDFOREACH

	S1_aia=LIST(LIST(fields_list[18],'ASC'));;sort by date_obs ascendant

	results=ds_aia_lev1->search(LIST(Q_aia),O1_aia,S1_aia)
	OBJ_DESTROY, ds_aia_lev1, Q_aia 
	IF n_elements(results) EQ 1 THEN return, results[0] ELSE return , results

end

pro sdodata__define
	compile_opt idl2

	void={sdodata,url : '',$
			recnum : LONG(0),$
			sunum : LONG(0),$
			date_obs : '',$
			wave : UINT(0) ,$
			ias_location : '',$
			exptime : FLOAT(0),$
			t_rec_index : LONG(0)}
 	return
end
