#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 20 09:48:00 2022

Modified by JRBuzan 
"""
import datetime

print(datetime.datetime.now().time())

import xarray as xr
import os
import numpy as np
import matplotlib.pyplot as plt
import HumanIndexMod
from xarray import DataArray
import pandas as pd
import gc
def MyXarray(mydata,time,lat,lon):
    return xr.DataArray(mydata,dims=('time','lat','lon'),coords={'time':time,'lat':lat,'lon':lon}).chunk({'lat':40,'lon':40})


# Typical ERA5 type dataset
#longitude
#	float longitude(longitude) ;
#		longitude:_FillValue = NaNf ;

#latitude        
#    float latitude(latitude) ;
#		latitude:_FillValue = NaNf ;

#time        
#    int time(time) ;
#		time:units = "hours since 1900-01-01" ;
#		time:calendar = "gregorian" ;

#huss
#huss_1950.nc
#	float huss(time, latitude, longitude) ;
#		huss:_FillValue = NaNf ;
#		huss:content = "specific humidity" ;

#ps
#ps1950.nc
#	short sp(time, latitude, longitude) ;
#		sp:scale_factor = 0.902618778420796 ;
#		sp:add_offset = 76703.4100187358 ;
#		sp:_FillValue = -32767s ;
#		sp:missing_value = -32767s ;
#		sp:units = "Pa" ;
#		sp:long_name = "Surface pressure" ;
#		sp:standard_name = "surface_air_pressure" ;

#tas
#tas1950.nc
#	short t2m(time, expver, latitude, longitude) ;
#		t2m:scale_factor = 0.00203560693576197 ;
#		t2m:add_offset = 259.33617854663 ;
#		t2m:_FillValue = -32767s ;
#		t2m:missing_value = -32767s ;
#		t2m:units = "K" ;
#		t2m:long_name = "2 metre temperature" ;

#u10m
#u10m1950.nc
#	short u10(time, latitude, longitude) ;
#		u10:scale_factor = 0.00295156829569942 ;
#		u10:add_offset = -46.5164065092455 ;
#		u10:_FillValue = -32767s ;
#		u10:missing_value = -32767s ;
#		u10:units = "m s**-1" ;
#		u10:long_name = "10 metre U wind component" ;

#v10m
#v10m1950.nc
#	short v10(time, latitude, longitude) ;
#		v10:scale_factor = 0.00207194438223753 ;
#		v10:add_offset = -15.8451674419177 ;
#		v10:_FillValue = -32767s ;
#		v10:missing_value = -32767s ;
#		v10:units = "m s**-1" ;
#		v10:long_name = "10 metre V wind component" ;

#rsds_interp
#rsds_interp1950.nc
#	short ssrd(time, latitude, longitude) ;
#		ssrd:_FillValue = -32767s ;
#		ssrd:standard_name = "surface_downwelling_shortwave_flux_in_air" ;
#		ssrd:long_name = "Surface solar radiation downwards" ;
#		ssrd:units = "J m**-2" ;
#		ssrd:add_offset = 2389211.5412998 ;
#		ssrd:scale_factor = 72.9174003936948 ;
#		ssrd:missing_value = -32767s ;


# input files (environement calls)
# Surface Pressure file
presfile = os.environ['PRESSFILE']

# Specific Humidity file
moisfile = os.environ['MOISSFILE']

# 2 m temperature
tempfile = os.environ['TEMPSFILE']

# 10 m Zonal winds
uwinfile = os.environ['UWINSFILE']

# 10 m Meridional winds
vwinfile = os.environ['VWINSFILE']

# Downwelling Solar Radiation
rsdsfile = os.environ['RSDSSFILE']

#Outfile
# Call in environment variables.
himoutfile = os.environ['HIMHROUTPATHFILE']


#open files
pres_file =  xr.open_dataset(presfile, decode_times=False)
mois_file =  xr.open_dataset(moisfile, decode_times=False)
temp_file =  xr.open_dataset(tempfile, decode_times=False)
uwin_file =  xr.open_dataset(uwinfile, decode_times=False)
vwin_file =  xr.open_dataset(vwinfile, decode_times=False)
rsds_file =  xr.open_dataset(rsdsfile, decode_times=False)

#call in data
lat = pres_file['lat'].values
lon = pres_file['lon'].values
time = pres_file['time'].values

sp_values = pres_file['sp'].values
huss_values = mois_file['huss'].values
t2m_values = temp_file['t2m'].values
uwin_values = uwin_file['u10'].values
vwin_values = vwin_file['v10'].values
#rsds_values = rsds_file['ssrd'].values
rsds_values = rsds_file['FSDS'].values

#change variables to 1d
sp_values_1d = np.reshape(sp_values,sp_values.size)
#sp_values_1d
huss_values_1d = np.reshape(huss_values,huss_values.size)
#huss_values_1d
t2m_values_1d = np.reshape(t2m_values,t2m_values.size)
#t2m_values_1d
uwin_values_1d = np.reshape(uwin_values,uwin_values.size)
#uwin_values_1d
vwin_values_1d = np.reshape(vwin_values,vwin_values.size)
#vwin_values_1d
rsds_values_1d = np.reshape(rsds_values,rsds_values.size)
#rsds_values_1d

# Generate Wind Magnitude
#U10_1d = uwin_values_1d
U10_1d = np.sqrt((uwin_values_1d * uwin_values_1d) + (vwin_values_1d * vwin_values_1d))

# Celcius
t2mC_values_1d = t2m_values_1d - 273.15

#create dummy arrays for HIM output
# Qsat2
es_mb_1d=np.empty(sp_values_1d.size)
de_mbdT_1d=np.empty(sp_values_1d.size)
dlnes_mbdT_1d=np.empty(sp_values_1d.size)
rs_1d=np.empty(sp_values_1d.size)
rsdT_1d=np.empty(sp_values_1d.size)
foftk_1d=np.empty(sp_values_1d.size)
fdT_1d=np.empty(sp_values_1d.size)

# reltative humidity vapor pressure
RH2M_1d=np.empty(sp_values_1d.size)
VAPE_1d=np.empty(sp_values_1d.size)
QS2M_1d=np.empty(sp_values_1d.size)

# Wet Bulb Davies-Jones
TEQ_1d=np.empty(sp_values_1d.size)
EPT_1d=np.empty(sp_values_1d.size)
WBA_1d=np.empty(sp_values_1d.size)

# Temperature Humidity Index  (livestock heatstress)
THIC_1d=np.empty(sp_values_1d.size)
THIP_1d=np.empty(sp_values_1d.size)

#SWMP80 SWMP65 (Infrastructure heatstress)
SWMP80_1d=np.empty(sp_values_1d.size)
SWMP65_1d=np.empty(sp_values_1d.size)

#Heat Index (NWS uncorrected Heat Index)
HIA_1d=np.empty(sp_values_1d.size)

#Simplified WBGT 
sWBGT_1d=np.empty(sp_values_1d.size)

#HUMIDEX
HUMIDEX_1d=np.empty(sp_values_1d.size)

#Discomfort Index
DI_1d=np.empty(sp_values_1d.size)

# Apparent Temperature
AT_1d=np.empty(sp_values_1d.size)

# ESI Environmental Stress Index, a WBGT proxy with radiation included
ESI_1d=np.empty(sp_values_1d.size)

j = (huss_values_1d.size-1)

# Run the HumanIndexMod
for j in (range(huss_values_1d.size-1)):
    #QSat2
    es_mb_1d[j],de_mbdT_1d[j],dlnes_mbdT_1d[j],rs_1d[j],rsdT_1d[j],foftk_1d[j],fdT_1d[j]=HumanIndexMod.qsat_2(t2m_values_1d[j],sp_values_1d[j])
    #Calculate Saturate Specific Humidity from Saturate Mixing Ratio 
    QS2M_1d[j]=rs_1d[j]/(1. + rs_1d[j])
    #Calculate Relative Humidity from Specific Humidity (consistent with CLM)
    RH2M_1d[j]=huss_values_1d[j]/QS2M_1d[j] * 100.
    #Vapor Pressure
    VAPE_1d[j]=HumanIndexMod.vaporpres(RH2M_1d[j], es_mb_1d[j] * 100.)
    #Wet Bulb Temperature, equivalent temperature, and equivalent potential temperature
    TEQ_1d[j],EPT_1d[j],WBA_1d[j]=HumanIndexMod.wet_bulb(t2m_values_1d[j],VAPE_1d[j],sp_values_1d[j],RH2M_1d[j],huss_values_1d[j])
    #THIC THIP 
    THIC_1d[j],THIP_1d[j]=HumanIndexMod.thindex(t2mC_values_1d[j],WBA_1d[j])
    #SWMP80 SWMP65
    SWMP80_1d[j],SWMP65_1d[j]=HumanIndexMod.swampcooleff(t2mC_values_1d[j],WBA_1d[j])
    #Heat Index
    HIA_1d[j]=HumanIndexMod.heatindex(t2mC_values_1d[j],RH2M_1d[j])
    #Simplified WBGT
    sWBGT_1d[j]=HumanIndexMod.swbgt(t2mC_values_1d[j],VAPE_1d[j])
    #HUMIDEX
    HUMIDEX_1d[j]=HumanIndexMod.hmdex(t2mC_values_1d[j],VAPE_1d[j])
    #Discomfort Index
    DI_1d[j]=HumanIndexMod.dis_coi(t2mC_values_1d[j],WBA_1d[j])
    # Apparent Temperature
    AT_1d[j]=HumanIndexMod.apptemp(t2mC_values_1d[j],VAPE_1d[j],U10_1d[j])
    # Stull, available but not in use. Maybe be good for exact treatment between Davies Jones and Stull
    #TWSTULL_1d[j]=HumanIndexMod.wet_Bulbs(t2mC_values_1d[j],RH2M_1d[j])

#Constants used in the Environmental Stress Index    
consa=0.63
consb=0.03
consc=0.002
consd=0.0054
conse=0.073
consf=0.1
consg=3.5
consh=5.
consi=0.5

ESI_1d = consa * t2mC_values_1d - consb * RH2M_1d + consc * rsds_values_1d + consd * ( t2mC_values_1d * RH2M_1d ) - conse / ( consf + rsds_values_1d )


# Reshape to 3D
ATnp = np.reshape(AT_1d,(time.size,lat.size,lon.size))
DInp = np.reshape(DI_1d,(time.size,lat.size,lon.size))
HIAnp = np.reshape(HIA_1d,(time.size,lat.size,lon.size))
sWBGTnp = np.reshape(sWBGT_1d,(time.size,lat.size,lon.size))
HUMIDEXnp = np.reshape(HUMIDEX_1d,(time.size,lat.size,lon.size))
SWMP80np = np.reshape(SWMP80_1d,(time.size,lat.size,lon.size))
SWMP65np = np.reshape(SWMP65_1d,(time.size,lat.size,lon.size))
THICnp = np.reshape(THIC_1d,(time.size,lat.size,lon.size))
THIPnp = np.reshape(THIP_1d,(time.size,lat.size,lon.size))
EPTnp = np.reshape(EPT_1d,(time.size,lat.size,lon.size))
WBAnp = np.reshape(WBA_1d,(time.size,lat.size,lon.size))
RH2Mnp = np.reshape(RH2M_1d,(time.size,lat.size,lon.size))
Q2Mnp = np.reshape(huss_values_1d,(time.size,lat.size,lon.size))
TSAnp = np.reshape(t2m_values_1d,(time.size,lat.size,lon.size))
PSurfnp = np.reshape(sp_values_1d,(time.size,lat.size,lon.size))
U10np = np.reshape(U10_1d,(time.size,lat.size,lon.size))
FSDSnp = np.reshape(rsds_values_1d,(time.size,lat.size,lon.size))
ESInp = np.reshape(ESI_1d,(time.size,lat.size,lon.size))


# Convert into xarray
ATda=MyXarray(ATnp,time,lat,lon)
AT=xr.DataArray(data = ATda, coords=[time,ATda.lat,ATda.lon],dims=['time','lat','lon'])
AT.name = 'AT'

DIda=MyXarray(DInp,time,lat,lon)
DI=xr.DataArray(data = DIda, coords=[time,DIda.lat,DIda.lon],dims=['time','lat','lon'])
DI.name = 'DI'

HIAda=MyXarray(HIAnp,time,lat,lon)
HIA=xr.DataArray(data = HIAda, coords=[time,HIAda.lat,HIAda.lon],dims=['time','lat','lon'])
HIA.name = 'HIA'

sWBGTda=MyXarray(sWBGTnp,time,lat,lon)
sWBGT= xr.DataArray(data = sWBGTda, coords=[time,sWBGTda.lat,sWBGTda.lon],dims=['time','lat','lon'])
sWBGT.name = 'sWBGT'

HUMIDEXda=MyXarray(HUMIDEXnp,time,lat,lon)
HUMIDEX= xr.DataArray(data = HUMIDEXda, coords=[time,HUMIDEXda.lat,HUMIDEXda.lon],dims=['time','lat','lon'])
HUMIDEX.name = 'HUMIDEX'

SWMP80da=MyXarray(SWMP80np,time,lat,lon)
SWMP80= xr.DataArray(data = SWMP80da, coords=[time,SWMP80da.lat,SWMP80da.lon],dims=['time','lat','lon'])
SWMP80.name = 'SWMP80'

SWMP65da=MyXarray(SWMP65np,time,lat,lon)
SWMP65= xr.DataArray(data = SWMP65da, coords=[time,SWMP65da.lat,SWMP65da.lon],dims=['time','lat','lon'])
SWMP65.name = 'SWMP65'

THICda=MyXarray(THICnp,time,lat,lon)
THIC= xr.DataArray(data = THICda, coords=[time,THICda.lat,THICda.lon],dims=['time','lat','lon'])
THIC.name = 'THIC'

THIPda=MyXarray(THIPnp,time,lat,lon)
THIP= xr.DataArray(data = THIPda, coords=[time,THIPda.lat,THIPda.lon],dims=['time','lat','lon'])
THIP.name = 'THIP'

EPTda=MyXarray(EPTnp,time,lat,lon)
EPT= xr.DataArray(data = EPTda, coords=[time,EPTda.lat,EPTda.lon],dims=['time','lat','lon'])
EPT.name = 'EPT'

WBAda=MyXarray(WBAnp,time,lat,lon)
WBA= xr.DataArray(data = WBAda, coords=[time,WBAda.lat,WBAda.lon],dims=['time','lat','lon'])
WBA.name = 'WBA'

RH2Mda=MyXarray(RH2Mnp,time,lat,lon)
RH2M= xr.DataArray(data = RH2Mda, coords=[time,RH2Mda.lat,RH2Mda.lon],dims=['time','lat','lon'])
RH2M.name = 'RH2M'

Q2Mda=MyXarray(Q2Mnp,time,lat,lon)
Q2M= xr.DataArray(data = Q2Mda, coords=[time,Q2Mda.lat,Q2Mda.lon],dims=['time','lat','lon'])
Q2M.name = 'Q2M'

TSAda=MyXarray(TSAnp,time,lat,lon)
TSA= xr.DataArray(data = TSAda, coords=[time,TSAda.lat,TSAda.lon],dims=['time','lat','lon'])
TSA.name = 'TSA'

PSurfda=MyXarray(PSurfnp,time,lat,lon)
PSurf= xr.DataArray(data = PSurfda, coords=[time,PSurfda.lat,PSurfda.lon],dims=['time','lat','lon'])
PSurf.name = 'PSurf'

U10da=MyXarray(U10np,time,lat,lon)
U10= xr.DataArray(data = U10da, coords=[time,U10da.lat,U10da.lon],dims=['time','lat','lon'])
U10.name = 'U10'

FSDSda=MyXarray(FSDSnp,time,lat,lon)
FSDS= xr.DataArray(data = FSDSda, coords=[time,FSDSda.lat,FSDSda.lon],dims=['time','lat','lon'])
FSDS.name = 'FSDS'

ESIda=MyXarray(ESInp,time,lat,lon)
ESI= xr.DataArray(data = ESIda, coords=[time,ESIda.lat,ESIda.lon],dims=['time','lat','lon'])
ESI.name = 'ESI'



#Merge together all variables
ArraysTogether = xr.merge([AT,DI,HIA,sWBGT,HUMIDEX,SWMP80,SWMP65,THIC,THIP,EPT,WBA,RH2M,Q2M,TSA,PSurf,U10,FSDS,ESI])
# Write out to file
ArraysTogether.to_netcdf(himoutfile,engine='netcdf4')

print(datetime.datetime.now().time())

exit()
