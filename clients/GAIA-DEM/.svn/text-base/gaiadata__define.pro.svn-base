
function gaiadata::init,data
	compile_opt idl2

	self.download=''
	self.sunum_193=LONG(0)
	self.date_obs=''
	self.filename=''
	self.temp_fits_rice_uri=''
	self.em_fits_rice_uri=''
	self.width_fits_rice_uri=''
	self.chi2_fits_rice_uri=''
	self->compute_attributes,data
	return,1
end

pro gaiadata::compute_attributes,data
	compile_opt idl2

	self.download=data['download']
	self.sunum_193=data['sunum_193']
	self.date_obs=data['date_obs']
	self.filename=data['filename']
	self.temp_fits_rice_uri=data['temp_fits_rice']
	self.em_fits_rice_uri=data['em_fits_rice']
	self.width_fits_rice_uri=data['width_fits_rice']
	self.chi2_fits_rice_uri=data['chi2_fits_rice']
end

function gaiadata::get_attributes
	compile_opt idl2
	
	attributes={download : self.download,$
			sunum_193 : self.sunum_193,$
			date_obs :self.date_obs,$
			filename :self.filename,$
			temp_fits_rice_uri :self.temp_fits_rice_uri,$
			em_fits_rice_uri :self.em_fits_rice_uri,$
			width_fits_rice_uri :self.width_fits_rice_uri,$
			chi2_fits_rice_uri: self.chi2_fits_rice_uri}
	
	return,attributes
end


function gaiadata::get_download
	compile_opt idl2

	value=''
	if self.url ne '' then value=self.download
	return,value
end

function gaiadata::get_sunum_193
	compile_opt idl2

	value=''
	if self.sunum_193 ne '' then value=self.sunum_193
	return,value
end


function gaiadata::get_file, FILENAME=filename_value, TARGET_DIR=target_dir_value, QUIET=quiet_value, TYPE=type_value
	compile_opt idl2
	
	sitools2_url="medoc-dem.ias.u-psud.fr"
	IF n_elements(target_dir_value) EQ 0 THEN TARGET_DIR='./' ELSE TARGET_DIR=target_dir_value
	
	IF n_elements(quiet_value) EQ 0 THEN QUIET=0 ELSE QUIET=quiet_value
	IF n_elements(type_value) EQ 0 THEN TYPE='' ELSE TYPE=type_value
	IF n_elements(target_dir_value) NE 0 THEN BEGIN 
		IF STRMID(target_dir_value,1,1, /REVERSE_OFFSET) NE '/'  THEN TARGET_DIR=TARGET_DIR+'/'
	ENDIF
	url_hash=HASH('temp' , self.temp_fits_rice_uri,$
			'em' , self.em_fits_rice_uri,$
			'width' , self.width_fits_rice_uri,$
			'chi2' , self.chi2_fits_rice_uri)
	filename_hash=HASH()
	IF (n_elements(filename_value) EQ 0) AND (n_elements(type_value) EQ 0) THEN BEGIN 
		FOREACH v,url_hash,k DO BEGIN
			key=(strsplit(v,"/",/EXTRACT))[-1]
;;			PRINT , key
			value=sitools2_url+v
;;			PRINT, value
			filename_hash+=HASH(key,value)
		ENDFOREACH
	ENDIF ELSE IF (n_elements(filename_value) EQ 0) AND (n_elements(type_value) NE 0) THEN BEGIN
		FOREACH type_spec,TYPE DO BEGIN
			IF  (url_hash.Keys()).WHERE(type_spec) EQ !NULL AND type_spec NE 'all' THEN BEGIN 
				message, "TYPE entry for the search function is not allowed"
				message,"it should be in list 'temp','em','width','chi2', 'all'"
			ENDIF ELSE IF type_spec EQ 'all' THEN BEGIN
				key=(strsplit(v,"/",/EXTRACT))[-1]
;;				PRINT , key
				value=sitools2_url+v
;;				PRINT, value
				filename_hash+=HASH(key,value)
			ENDIF ELSE BEGIN
				FOREACH type_spec,TYPE DO BEGIN
					key=(strsplit(url_hash[type_spec],"/",/EXTRACT))[-1]
;;					PRINT , key
					value=sitools2_url+url_hash[type_spec]
;;					PRINT, value
					filename_hash+=HASH(key,value)
				ENDFOREACH
			ENDELSE
		ENDFOREACH
	ENDIF ELSE IF (n_elements(filename_value) NE 0) AND (n_elements(type_value) NE 0) THEN BEGIN
		message, "FILENAME and TYPE are both specified at the same time"
		message,"Not allowed please remove one"
	ENDIF ELSE BEGIN 
		FOREACH file,FILENAME,typefile DO BEGIN
			IF  (url_hash.Keys()).WHERE(type) EQ !NULL THEN BEGIN 
				message, "TYPE entry for the search function is not allowed"
				message,"it should be in list 'temp','em','width','chi2', 'all'"
			ENDIF ELSE BEGIN
				key=FILENAME[typefile]
				PRINT , key
				value=sitools2_url+url_hash[typefile]
				PRINT, value
				filename_hash+=HASH(key,value)
			ENDELSE
		ENDFOREACH
	ENDELSE
;;	PRINT, filename_hash
	oUrl_get=OBJ_NEW('IDLnetUrl')
	oUrl_get.SetProperty, url_scheme='http'
	FOREACH value, filename_hash, key DO BEGIN 
		oUrl_get.SetProperty, URL_HOST=value
		file=oUrl_get.Get(FILENAME=TARGET_DIR+key)
		IF NOT QUIET THEN PRINT,"Download file " +TARGET_DIR+key+" completed"
	ENDFOREACH
	OBJ_DESTROY, oUrl_get
	return , 1
end 




pro gaiadata__define
	compile_opt idl2

	void={gaiadata,download : '',$
			sunum_193 : LONG(0),$
			date_obs : '',$
			filename : '',$
			temp_fits_rice_uri : '',$
			em_fits_rice_uri : '',$
			width_fits_rice_uri : '',$ 
			chi2_fits_rice_uri : ''}
 	return
end
