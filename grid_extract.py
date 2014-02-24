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

# add indicator for water or land
import fiona
from shapely.geometry import MultiPolygon, Polygon, Point
from pyproj import transform, Proj
from numpy import array, vstack, tile, nan

# nybb.shp comes from nybb_13a.zip at
# http://www.nyc.gov/html/dcp/html/bytes/dwndistricts.shtml
with fiona.open('nybb_13a/nybb.shp','r') as source:
    # project into lat-lon
    p1 = Proj(source.crs, preserve_units=True)
    p2 = Proj({'proj': 'longlat', 'datum': 'WGS84'})

    nyc = MultiPolygon()
    for borough in source:
        for shape in borough['geometry']['coordinates']:
            p1_points = array(shape[0])

            p2_points = transform(p1, p2, p1_points[:,0], p1_points[:,1])
            p2_points = vstack([p2_points[0], p2_points[1]]).T

            new = Polygon(p2_points)
            nyc = nyc.union(new)

xyz['water'] = tile(nan, len(xyz))

print 'starting to loop'
for i in range(len(xyz)):
    if i % 1000 == 0:
        print i
    p = xyz.iloc[i][['x', 'y']]
    p = Point(p[0], p[1])
    xyz['water'].iloc[i] = nyc.contains(p)

water_grid = xyz['water'].values.reshape(len(xy['y'].unique()), len(xy['x'].unique()))
water_grid = DataFrame(water_grid)

water_grid.to_csv('water_grid.csv',index=False)
