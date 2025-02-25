#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 20 16:40:14 2020

@author: jrcarley
Modified by JRBuzan 
"""
import numpy as np
import matplotlib.pyplot as plt
import HumanIndexMod
import HumanIndexModOld

#Coord system, x-axis is temp and y-axis is rh

p=100000. #Pa
temps=np.linspace(-50,70,num=121,endpoint=True)+273.15
relhumids=np.linspace(0,100,num=21,endpoint=True)

#wb_new=np.empty((temps.size,relhumids.size))
#wb_old=np.empty((temps.size,relhumids.size))
wb_new=np.empty((relhumids.size,temps.size))
wb_old=np.empty((relhumids.size,temps.size))

x=0

for t in temps:
    es_mb,de_mbdT,dlnes_mbdT,rs,rsdT,foftk,fdT=HumanIndexMod.qsat_2(t,p)
    y=0
    for rh in relhumids:
        vape=HumanIndexMod.vaporpres(rh, es_mb*100.)
        #calc spfh, start with mixing ratio
        w=0.622*vape/(p-vape)
        qin=w/(1.+w)
        teq_temporary_new,epott_new,wb_it_new=HumanIndexMod.wet_bulb(t,vape,p,rh,qin)
        teq_temporary_old,epott_old,wb_it_old=HumanIndexModOld.wet_bulb(t,vape,p,rh,qin)
        wb_new[y,x]=wb_it_new
        wb_old[y,x]=wb_it_old
#        wb_new[x,y]=wb_it_new
#        wb_old[x,y]=wb_it_old
#        print(x)
 #       print(y)
        #print(Teq,epott,wb_it)
        y=y+1
    x=x+1    

#exit()

temps = temps - 273.15
    
diff_wb = wb_new - wb_old

#plotting
origin = 'lower'
level=[-2.,-1.,-0.1,-0.01, -0.001, -0.0001, -0.00001, -0.000001,-0.0000001, 0., 0.0000001, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1., 2.]
fig1, ax2 = plt.subplots(constrained_layout=True)
#fig, ax = plt.subplots()
CS = ax2.contourf(temps,relhumids,diff_wb, 10, cmap=plt.cm.bone, origin=origin, levels=level)
ax2.clabel(CS, fmt='%2.1f', colors='k', fontsize=14)
#fig=plt.contourf(temps,relhumids,diff_wb,levels=[-2.,-1.,-0.1,-0.01, -0.001, -0.0001, -0.00001, -0.000001,-0.0000001, 0., 0.0000001, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1., 2.], colors=('k',))
#fig=plt.contourf(temps,relhumids,diff_wb, levels=[-2.,-1.,-0.1,-0.01, -0.001, -0.0001, -0.00001, -0.000001,-0.0000001, 0., 0.0000001, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1., 2.],cmap='PiYG')

#ax.clabel(fig, inline=True, fontsize=10)
#ax = fig.add_subplot(111)
#line_colors = ['black' for l in fig.levels]
#plt.clabel(fig,fmt='%d')
#cbar = plt.colorbar()
plt.title('TwNew - TwOld')
plt.xlabel('Temperature (C)')
plt.ylabel('RH (%)')
plt.savefig('./tw.png',bbox_inches="tight")
plt.close()
#from matplotlib import cm
#from colorspacious import cspace_converter
#from collections import OrderedDict

fig2=plt.contourf(temps,relhumids,wb_new, levels=[-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70],cmap='hot')
cbar = plt.colorbar()
ax2.clabel(fig2, fmt='%2.1f', colors='k', fontsize=14)
plt.title('TwNew')
plt.xlabel('Temperature (C)')
plt.ylabel('RH (%)')
plt.savefig('./twNew.png',bbox_inches="tight")
plt.close()

fig3=plt.contourf(temps,relhumids,wb_old, levels=[-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70],cmap='hot')
cbar = plt.colorbar()
ax2.clabel(fig3, fmt='%2.1f', colors='k', fontsize=14)
plt.title('TwOld')
plt.xlabel('Temperature (C)')
plt.ylabel('RH (%)')
plt.savefig('./twOld.png',bbox_inches="tight")
plt.close()




exit()
#####


import numpy as np
import xarray as xr
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from cartopy.mpl.gridliner import LongitudeFormatter, LatitudeFormatter
import matplotlib.pyplot as plt

import geocat.datafiles as gdf
from geocat.viz import cmaps as gvcmaps
from geocat.viz import util as gvutil
