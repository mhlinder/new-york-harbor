# format depths in geometric grid (location in array corresponds to
# geographic location)
from pandas import read_csv, DataFrame

# Two panels, containing NYC coast
# 20142302_2110_crm.xyz:
#   http://maps.ngdc.noaa.gov/viewers/wcs-client/
#   Coastal Relief Model
#   -74.300, 40.400, -73.600, 40.900
#   XYZ
# NOAA National Geophysical Data Center, U.S. Coastal Relief Model, retrieved
# February 18, 2014. http://www.ngdc.noaa.gov/mgg/coastal/crm.html
xyz = read_csv('20142302_2110_crm.xyz',
        sep=" ", header=None)
xyz.columns = ['x','y','z']
xy = xyz[['x','y']]

# xyz contains two side-by-side panels, each containing a point cloud; points
# are listed as
#   <lon> <lat> <depth>
# There are 841 columns, and 601 rows. Each row is enumerated left-to-right,
# top-to-bottom. 

# Reshape z-coordinates according to 
depth_grid = xyz['z'].values.reshape(len(xy['y'].unique()), len(xy['x'].unique()))
depth_grid = DataFrame(depth_grid)

depth_grid.to_csv('depth_grid.csv',index=False)
