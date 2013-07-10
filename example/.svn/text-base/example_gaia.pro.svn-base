pro example_gaia
	compile_opt idl2

	gaia_list=gaia_search( DATES=LIST('2011-01-01T00:00','2011-01-01T23:05'),  NB_RES_MAX=10)
;; Print attributes	
	FOREACH gaia_data_item, gaia_list DO PRINT, gaia_data_item->get_attributes()

;; The fastest way to retrieve data
	get_execute=gaia_get(GAIA_LIST=gaia_list, TARGET_DIR="/tmp")

;;Need only 'em' and 'temp' files :
;;	tar_get_execute=gaia_get (GAIA_LIST=gaia_list,TYPE=LIST("em","temp"), target_dir="/tmp" )

;;Need to get a tar ball file :
;;PS: slower than the previous one
;;	tar_get_execute=gaia_get (GAIA_LIST=gaia_list,DOWNLOAD_TYPE="tar", target_dir="/tmp" ,FILENAME="my_download_file.tar")


end
