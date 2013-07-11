pro example_media
	compile_opt idl2

	sdo_list=media_search( DATES=LIST('2011-01-01T00:00','2011-01-01T00:05') , WAVES=LIST('304','193') , CADENCE=LIST('1 min'),  NB_RES_MAX=10)
;; Print attributes	
	FOREACH sdo_data_item, sdo_list DO PRINT, sdo_data_item->get_attributes()

;; The fastest way to retrieve data
	media_execute=media_get(MEDIA_DATA_LIST=sdo_list, TARGET_DIR="/tmp")

;;Need to get a tar ball or zip file :
;;A bit slower than the previous one
;;	tar_get_execute=media_get (MEDIA_DATA_LIST=sdo_list,DOWNLOAD_TYPE="tar", target_dir="/tmp" ,FILENAME="my_download_file.tar")

;;Search meta data info
;;	FOREACH sdo_item, sdo_list, iter DO BEGIN
;;		meta_data_search=sdo_item->metadata_search(KEYWORDS=LIST('quality','cdelt1','cdelt2'))
;;		PRINT, JSON_SERIALIZE(meta_data_search)
;;	ENDFOREACH

;;Filter on a specific keyword before download data using the get_file() method.
	
;;	FOREACH sdo_item, sdo_list DO BEGIN
;;		meta_data_search=sdo_item->metadata_search(KEYWORDS=LIST('quality','cdelt1','cdelt2'))
;;		PRINT, JSON_SERIALIZE(meta_data_search)
;;		file=obj_new()
;;		IF meta_data_search['quality'] EQ 0 THEN  file=sdo_item->get_file(TARGET_DIR='/tmp')
;;	ENDFOREACH



end
