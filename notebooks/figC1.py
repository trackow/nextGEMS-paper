from netCDF4 import Dataset, num2date
import numpy as np
import sys
import pandas as pd
import datetime as dt
import calendar
import matplotlib as mplt
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pickle 

mplt.rc('xtick', labelsize=9)
mplt.rc('ytick', labelsize=9)
#data=[hz9o,hzfy,hr2n_nemo_deep,hqys,ref,y5len,y1len,label,ls,lw,std,ref_std,nyears]
#with open('fig5.pickle', "wb") as f:
#    pickle.dump(data, f)
with open('figC1.pickle', "rb") as f:
   hz9o,hzfy,hr2n_nemo_deep,hqys,ref,y5len,y2len,y1len,label,ls,lw,std,ref_std,nyears,cs=pickle.load(f)

# DIFFS#
fig2=plt.figure(figsize=(10,6))
axx2 = fig2.subplots(3,1,sharex=True)
    
for ir,creg in enumerate(['GLB']):
  for it,ct in enumerate(['A','L','S']):
    if hz9o is not None : axx2[it].plot(hz9o.index,hz9o.loc[:,ct+'_'+creg]-ref.loc[:,ct+'_'+creg][dt.datetime(2020,1,20):dt.datetime(2020,1,20)+dt.timedelta(y5len-1)],c=cs[1],label=label[1],ls=ls[1],lw=lw[1])
    if hzfy is not None : axx2[it].plot(hzfy.index,hzfy.loc[:,ct+'_'+creg]-ref.loc[:,ct+'_'+creg][dt.datetime(2020,1,20):dt.datetime(2020,1,20)+dt.timedelta(y5len-1)],c=cs[0],label=label[0],ls=ls[0],lw=lw[0])
    if hr2n_nemo_deep is not None : axx2[it].plot(hr2n_nemo_deep.index[:],hr2n_nemo_deep.loc[:,ct+'_'+creg][:]-ref.loc[:,ct+'_'+creg][dt.datetime(2020,1,20):dt.datetime(2020,1,20)+dt.timedelta(y2len-1)],c=cs[4],label=label[4],ls=ls[4],lw=lw[4])
    if hqys is not None : axx2[it].plot(hqys.index,hqys.loc[:,ct+'_'+creg]-ref.loc[:,ct+'_'+creg][dt.datetime(2020,1,20):dt.datetime(2020,1,20)+dt.timedelta(y1len-1)],c=cs[3],label=label[3],ls=ls[3],lw=lw[3])
    if (std):
        if ref is not None : axx2[it].fill_between(ref.index,-ref_std.loc[:,ct+'_'+creg],ref_std.loc[:,ct+'_'+creg],color='0.5',zorder=0,alpha=0.5)

    axx2[0].set_title('ALL',fontsize=9,loc='center',y=0.85)#,x=0.95)
    axx2[1].set_title('LAND',fontsize=9,loc='center',y=0.85)#,x=0.95)
    axx2[2].set_title('OCEAN',fontsize=9,loc='center',y=0.85)#,x=0.95)
    xlims=[dt.datetime(2020,1,1),dt.datetime(2020+nyears,1,1)] 
    axx2[it].set_xlim(xlims)
    axx2[it].xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m'))
    axx2[it].xaxis.set_minor_locator(mdates.MonthLocator(interval=1))

    [ax.set_ylabel(r'$\Delta$ T (K)') for ax in axx2.reshape(-1)]
letters='abcd'
[ax.annotate('('+letters[i]+')', xy=(0.01, 0.87), xycoords='axes fraction',fontsize=12, fontweight='bold', color='black') for i,ax in enumerate(axx2.reshape(-1))]

axx2[0].set_ylim([-1.01,2.51])
axx2[1].set_ylim([-1.01,2.51])
axx2[2].set_ylim([-1.01,2.51])
for ax in axx2.reshape(-1):
  ax.tick_params(axis='x', rotation=45)

[ax.axhline(y=0,ls='--',c='0.5')for ax in axx2.reshape(-1)]
handles, labels = axx2[0].get_legend_handles_labels()
leg = fig2.legend(handles, labels, ncol=4,loc='center left',bbox_to_anchor=(0.02, 1.02))
fig2.tight_layout()
plt.margins(0.0)
plt.savefig('FigC1.jpg',format='jpg', bbox_inches='tight')
plt.show()
