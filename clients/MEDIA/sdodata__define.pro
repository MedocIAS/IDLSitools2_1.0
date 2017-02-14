
function sdodata::init,data
	compile_opt idl2

	self.url=''
	self.recnum=LONG(0)
	self.sunum=LONG(0)
	self.date_obs=''
	self.series_name=''
	self.wave=UINT(0)
	self.ias_location=''
	self.exptime=FLOAT(0)
	self.t_rec_index=LONG(0)
	self.harpnum=LONG(0)
	self->compute_attributes,data
	return,1
end

pro sdodata::compute_attributes,data
	compile_opt idl2
	IF (data.keys()).WHERE('get') EQ !NULL THEN self.url=data['ias_path']  ELSE self.url=data['get']
;	PRINT, "self.url : ", self.url
	self.recnum=data['recnum']
;	PRINT, "self.recnum : ", self.recnum
	self.sunum=data['sunum']
;	PRINT, "self.sunum : ", self.sunum
	self.date_obs=data['date__obs']
;	PRINT, "self.date__obs : ", self.date_obs
	self.series_name=data['series_name']
;	PRINT, "self.series_name : ", self.series_name
	self.wave=data['wavelnth']
;	PRINT, "self.wavelnth : ", self.wave
	IF (data.keys()).WHERE('ias_location') EQ !NULL THEN self.ias_location='' ELSE self.ias_location=data['ias_location']
;	PRINT, "self.ias_location : ", self.ias_location
	IF (data.keys()).WHERE('exptime') EQ !NULL THEN self.exptime=0 ELSE self.exptime=data['exptime']
;	PRINT, "self.exptime : ", self.exptime
	self.t_rec_index=data['t_rec_index']
;	PRINT, "self.t_rec_index : ", self.t_rec_index
	IF (data.keys()).WHERE('harpnum') EQ !NULL THEN self.harpnum=0 ELSE self.harpnum=data['harpnum']
;	PRINT, "self.harpnum : ", self.harpnum
end

function sdodata::get_attributes
	compile_opt idl2
	
	IF STRMID(self.series_name,0,9) EQ 'hmi.sharp' THEN BEGIN 
		attributes={url : self.url,$
			recnum : self.recnum,$
			sunum :self.sunum,$
			date_obs :self.date_obs,$
			series_name : self.series_name,$
			wave :self.wave,$
			ias_location :self.ias_location,$
			exptime :self.exptime,$
			t_rec_index: self.t_rec_index,$
			harpnum:self.harpnum}
	ENDIF ELSE BEGIN
		attributes={url : self.url,$
			recnum : self.recnum,$
			sunum :self.sunum,$
			date_obs :self.date_obs,$
			series_name : self.series_name,$
			wave :self.wave,$
			ias_location :self.ias_location,$
			exptime :self.exptime,$
			t_rec_index: self.t_rec_index}
	ENDELSE

	return,attributes
end

function sdodata::get_url
	compile_opt idl2

	value=''
	if self.url ne '' then value=self.url
	return,value
end

function sdodata::get_recnum
	compile_opt idl2

	value=''
	if self.recnum ne '' then value=self.recnum
	return,value
end

function sdodata::get_sunum
	compile_opt idl2

	value=''
	if self.sunum ne '' then value=self.sunum
	return,value
end

function sdodata::get_date_obs
       compile_opt idl2

       value=''
       if self.date_obs ne '' then value=self.date_obs
       return,value
end

function sdodata::get_series_name
       compile_opt idl2

       value=''
       if self.series_name ne '' then value=self.series_name
       return,value
end

function sdodata::get_wave
	compile_opt idl2

	value=''
	if self.wave ne '' then value=self.wave
	return,value
end

function sdodata::get_ias_location
	compile_opt idl2

	value=''
	if self.ias_location ne '' then value=self.ias_location
	return,value
end

function sdodata::get_exptime
	compile_opt idl2

	value=''
	if self.exptime ne '' then value=self.exptime
	return,value
end

function sdodata::get_t_rec_index
	compile_opt idl2

	value=''
	if self.t_rec_index ne '' then value=self.t_rec_index
	return,value
end

function sdodata::get_harpnum
	compile_opt idl2

	value=''
	if self.harpnum ne '' then value=self.harpnum
	return,value
end


function sdodata::get_file, DECOMPRESS=decompress_value, FILENAME=filename_value, SEGMENT=segment_value, TARGET_DIR=target_dir_value, QUIET=quiet_value
	compile_opt idl2
	
	IF n_elements(decompress_value) EQ 0 THEN DECOMPRESS=0 ELSE DECOMPRESS=decompress_value
	IF n_elements(target_dir_value) EQ 0 THEN TARGET_DIR='./' ELSE TARGET_DIR=target_dir_value

	FILENAME_PRE=''
	LIST_FILES=LIST()
;	PRINT, "n elements 4 filename_value :", n_elements(filename_value)
;	PRINT, "series_name : ",self.series_name 

	;#Define prefix for output file 
	IF n_elements(filename_value) EQ 0 AND STRMID(self.series_name,0,9) EQ 'hmi.sharp' THEN BEGIN 
	;	PRINT ,"type series_name : ",TYPENAME(self.series_name)
	;	PRINT ,"type wave : ",TYPENAME(self.wave)
	;	PRINT ,"type date_obs : ",TYPENAME(self.date_obs)
	;	PRINT, "type harpnum : ", TYPENAME(self.harpnum)
		FILENAME_PRE=self.series_name+"_"+STRCOMPRESS(self.wave, /REMOVE_ALL)+"A_"+self.date_obs+"_"+STRCOMPRESS(self.harpnum, /REMOVE_ALL)+"."
	ENDIF ELSE IF n_elements(filename_value) EQ 0 AND STRMID(self.series_name,0,3) EQ 'hmi' THEN BEGIN 
		FILENAME_PRE=self.series_name+"_"+STRCOMPRESS(self.wave, /REMOVE_ALL)+"A_"+self.date_obs+"."
	ENDIF ELSE IF n_elements(filename_value) EQ 0 AND self.series_name EQ 'aia.lev1' THEN BEGIN
		FILENAME_PRE=self.series_name+"_"+STRCOMPRESS(self.wave, /REMOVE_ALL)+"A_"+self.date_obs+"." 
	ENDIF ELSE IF n_elements(filename_value) NE 0 THEN BEGIN
		FILENAME_PRE=filename_value
	ENDIF

	;#Define SEGMENT if that exists 
	IF n_elements(segment_value) EQ 0 AND STRMID(self.series_name,0,8) EQ 'aia.lev1' THEN BEGIN
		LIST_FILES=['image_lev1']
	ENDIF ELSE IF n_elements(segment_value) EQ 0 AND STRMID(self.series_name,0,9) EQ 'hmi.sharp' THEN BEGIN 
;;		PRINT , "url : ",self.url 
		url=(strsplit(self.url,"http://",/EXTRACT, /REGEX))[-1]
		url+='/?media=json'
;;		PRINT, "url json : ",url
		oUrl=OBJ_NEW('IDLnetUrl')
		oUrl.SetProperty, url_scheme='http'
		oUrl.SetProperty, URL_HOST=url

	  	json = oUrl.Get(/STRING_ARRAY)
		json_result=JSON_PARSE(STRJOIN(json))
		;;PRINT ,"json_result : ", JSON_SERIALIZE(json_result)
		
		IF (json_result.keys()).WHERE('items') NE !NULL THEN BEGIN 
			data_result=json_result['items']
			;;PRINT ,"data_result : ",JSON_SERIALIZE(data_result)
		ENDIF	

		FOREACH item , data_result DO BEGIN
			name=(strsplit(item['name'],".fits",/EXTRACT, /REGEX))[-1]
			LIST_FILES.Add, name
		ENDFOREACH
;;		PRINT , LIST_FILES
	ENDIF ELSE IF n_elements(segment_value) EQ 0 AND STRMID(self.series_name,0,6) EQ 'hmi.ic' THEN BEGIN 
		LIST_FILES=['continuum']
	ENDIF ELSE IF n_elements(segment_value) EQ 0 AND STRMID(self.series_name,0,5) EQ 'hmi.m' THEN BEGIN
		LIST_FILES=['magnetogram']
	ENDIF ELSE IF n_elements(segment_value) NE 0 THEN BEGIN
		LIST_FILES=segment_value
	ENDIF


	IF n_elements(quiet_value) EQ 0 THEN QUIET=0 ELSE QUIET=quiet_value

	;#Create directory if it does not exist yet
	IF n_elements(target_dir_value) NE 0 THEN BEGIN 
		result=FILE_TEST(target_dir_value,/DIRECTORY)
		IF result NE 1 THEN BEGIN
			 FILE_MKDIR, target_dir_value
		ENDIF
		IF STRMID(target_dir_value,1,1, /REVERSE_OFFSET) NE '/'  THEN FILENAME_PRE=TARGET_DIR+'/'+FILENAME_PRE ELSE FILENAME_PRE=TARGET_DIR+FILENAME_PRE
	ENDIF

	url=''
	self.url=(strsplit(self.url,"http://",/EXTRACT, /REGEX))[-1]
	IF NOT DECOMPRESS AND STRMID(self.series_name,0,8) EQ 'aia.lev1' THEN self.url+=";compress=rice"

	;#Define filename 
	FOREACH file_suff, LIST_FILES DO BEGIN 
		FILENAME=FILENAME_PRE+file_suff+".fits"
		IF STRMID(self.series_name,0,3) EQ 'hmi' THEN BEGIN
			url=self.url+"/"+file_suff+".fits"
		ENDIF ELSE IF self.series_name EQ "aia.lev1" THEN BEGIN 
			url=self.url
		ENDIF
;;		PRINT , FILENAME
;;		PRINT, url

		;#Retrieve data 	
		oUrl_get=OBJ_NEW('IDLnetUrl')
		oUrl_get.SetProperty, url_scheme='http'
		oUrl_get.SetProperty, URL_HOST=url
		file=oUrl_get.Get(FILENAME=FILENAME)
		IF NOT QUIET AND self.ias_location NE '' THEN BEGIN 
			PRINT,"Downloading " +FILENAME+"..." 
		ENDIF ELSE IF self.ias_location EQ '' THEN BEGIN 
			PRINT,"No data at IAS for recnum : "+ STRTRIM(self.recnum)
		ENDIF
		OBJ_DESTROY, oUrl_get 
;		OBJ_DESTROY, file
	ENDFOREACH
	return, 0
end 



function sdodata::metadata_search, KEYWORDS=keywords_list, RECNUM_LIST=recnum_list
	compile_opt idl2

	IF n_elements(keywords_list) EQ 0 THEN message," Error metadata_search(): keywords must be specified" ELSE KEYWORDS=keywords_list
	IF n_elements(recnum_list) EQ 0 THEN  RECNUM_LIST=LIST( STRCOMPRESS(self.recnum, /REMOVE_ALL) ) ELSE RECNUM_LIST=recnum_list
	
	server_adress='idoc-solar-portal-test.u-psud.fr'
	;server_adress='medoc-sdo.u-psud.fr'
	ds_sdo_dataset=obj_new('dataset', server_adress+'/webs_'+self.series_name+'_dataset')
;	ds_sdo_dataset=obj_new('sdoaiadataset')
	;#Build Query
	fields_list=(ds_sdo_dataset->get_attributes()).FIELDS_LIST
	param_query=LIST(fields_list[0],RECNUM_LIST,'IN')
	Q_aia=obj_new('query',param_query)
	O1_aia=LIST()
	FOREACH key, KEYWORDS DO BEGIN
		IF (ds_sdo_dataset.fields_struct).HasKey(key) THEN O1_aia.Add,(ds_sdo_dataset.fields_struct)[key] ELSE message,"Error metadata_search(): keyword does not exist" 
	ENDFOREACH

	S1_aia=LIST(LIST(fields_list[18],'ASC'));;sort by date_obs ascendant

	results=ds_sdo_dataset->search(LIST(Q_aia),O1_aia,S1_aia)
	OBJ_DESTROY, ds_sdo_dataset, Q_aia 
	IF n_elements(results) EQ 1 THEN return, results[0] ELSE return , results

end

pro sdodata__define
	compile_opt idl2

	void={sdodata,url : '',$
			recnum : LONG(0),$
			sunum : LONG(0),$
			date_obs : '',$
			series_name : '',$
			wave : UINT(0) ,$
			ias_location : '',$
			exptime : FLOAT(0),$
			t_rec_index : LONG(0),$
			harpnum :LONG(0)}
 	return
end
