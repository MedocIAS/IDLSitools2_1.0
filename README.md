![](http://github.com/SITools2/core-v2/raw/dev/workspace/client-public/res/images/logo_01_petiteTaille.png)
# IDLSitools2_1.0
## Description
IDLSitools2_1.0 is a generic IDL Sitools2V1.0 client

IDLSitools2 tool has been designed by MEDOC at IAS (Institut d'Astrophysique Spatiale) to perform all operations available within Sitools2 via IDL.

The IDLSitools2 routines allow you to interrogate Sitools2 server especially MEDIA & GAIA-DEM servers. 

## Building IDLSitools2_1.0

### Getting the sources

	$ git clone https://github.com/MedocIAS/IDLSitools2_1.0.git IDLSitools2_1.0
	
        The retrieved module structure is the following:
            LICENCE
            README.md
            -- clients
                -- MEDIA
                    README_MEDIA.txt
                    media_get.pro
		    media_get_selection.pro
	 	    media_search.pro
		    sdoaiadataset__define.pro
		    sdodata__define.pro
		    sdoiasdataset__define.pro
                -- GAIA-DEM
                    README_GAIA.txt
		    gaiadata__define.pro
		    gaiadataset__define.pro
		    gaia_get.pro
		    gaia_get_selection.pro
		    gaia_search.pro
            -- core
		dataset__define.pro
		field__define.pro
		project__define.pro
		query__define.pro
		sitools2Instance__define.pro
	    -- examples
                example_media.pro
                example_gaia.pro

## Installing the module
	- Download the last archive file using the buttons above.
	NB: Use the following command for a linux server :
     	$ git clone https://github.com/MedocIAS/IDLSitools2_1.0.git IDLSitools2_1.0  (git required)

	or 
        - Download the last archive file 
	Extract the content of IDLSitools2_1.0.tar.gz into your favourite directory ex : /usr/local/Sitools2Client

	-Add the install directory to your env var 'IDL_PATH'
	$ export IDL_PATH=$IDL_PATH:+/usr/local/Sitools2Client/

## Features

- Make a search providing a date range, if needed a wavelength and a cadence.
- Filter the results with specific keyword values (e.g. filter on quality, cdelt...)
- Download the results of your search.

## Examples of application

### MEDIA

This IDL module will allow you to :

    - Make a request using the media_search() function.

        $ sdo_list=media_search( DATES=LIST('2011-01-01T00:00','2011-01-01T00:05') , WAVES=LIST(304,193) , CADENCE='1 min',  NB_RES_MAX=10)


    - Simply download the result of your previous search() calling the media_get() function.
    
        $ media_execute=media_get(MEDIA_DATA_LIST=sdo_list)

    - Have additional metadata information about each previous answer using the metadata_search() method.

        $ for item in sdo_data_list:
            my_meta_search = item.metadata_search ( KEYWORDS=LIST('quality','cdelt1','cdelt2') )
            print my_meta_search

    - Filter on a specific keyword before download data using the get_file() method.
	
	$ FOREACH sdo_item, sdo_list DO BEGIN
		meta_data_search=sdo_item->metadata_search(KEYWORDS=LIST('quality','cdelt1','cdelt2'))
		PRINT, JSON_SERIALIZE(meta_data_search)
		file=obj_new()
		IF meta_data_search['quality'] EQ 0 THEN  file=sdo_item->get_file(TARGET_DIR='/tmp')
	  ENDFOREACH

  
### GAIA-DEM

This IDL module will allow you to :

    - Make a request using the gaia_search() function.

        $ gaia_list=gaia_search( DATES=LIST('2011-01-01T00:00','2011-01-01T23:05'),  NB_RES_MAX=10)

    - Simply download the result of your previous search() calling the gaia_get() function.

        $ gaia_execute=gaia_get( GAIA_LIST=gaia_list,TARGET_DIR='/tmp' )

    - Specify the TYPE you want to retrieve , it should be a list among : 'temp','em','width','chi2'

        $ gaia_collect_em_files=gaia_get (GAIA_LIST=gaia_list,TYPE=LIST("em","temp"), target_dir="/tmp" )

    - Download a tar ball file (slower):
	$ gaia_tar_collect=gaia_get (GAIA_LIST=gaia_list,DOWNLOAD_TYPE="tar", target_dir="/tmp" ,FILENAME="my_download_file.tar")

###Requirements

This IDL module requires IDL 8.2 or above.
