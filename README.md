# Using TransCAD 9.0 - Import GTFS to Link Layer Tool


## Updating the transit information in Routes


# Relevant Documentation: 

["TDM23 HLD Files and Folders"](https://docs.google.com/spreadsheets/d/1SzfMR93j-9eMHD-xKrijvFmkZMWkgXVLQpsHCowB2YI/edit?usp=sharing)

["Transit Service" (TDM19)](https://docs.google.com/spreadsheets/d/1MUH8CGTDwURq51fCLNuMZ5tpvD-mXjvvDxFbQvBxanU/edit?usp=sharing)

["TDM23 High Level Design"](https://docs.google.com/document/d/1m3TBGs-5KD0USOKogKt4PyXCyvK1oUo_piifL_f_ZRA/editlqBCXVBZltr8raD6OIoMrDIo-t0J8wG-A/edit#)


# Steps:

Download Recap GTFS (or Create)



* [https://mbta-massdot.opendata.arcgis.com/datasets/MassDOT::gtfs-recap-fall-2018/about](https://mbta-massdot.opendata.arcgis.com/datasets/MassDOT::gtfs-recap-fall-2018/about) 
* Creating a GTFS - [https://www.nationalrtap.org/Technology-Tools/GTFS-Builder](https://www.nationalrtap.org/Technology-Tools/GTFS-Builder) 

Clean GTFS



* Cleaning Script: 
    * [https://github.com/mmatkinson7/gtfs_transcad_prep/blob/main/itsleeds_cleangtfs.R](https://github.com/mmatkinson7/gtfs_transcad_prep/blob/main/itsleeds_cleangtfs.R)
        * Zip a folder of the outputs
* Use Validator: 
    * [https://github.com/MobilityData/gtfs-validator](https://github.com/MobilityData/gtfs-validator)

Consolidate GTFS



* Consolidation Script:
    * [https://github.com/mmatkinson7/gtfs_transcad_prep/blob/main/gtfs_consolidation_tod.ipynb](https://github.com/mmatkinson7/gtfs_transcad_prep/blob/main/gtfs_consolidation_tod.ipynb) 

Make Copy of Link Layer (TDM23 DBD)



* For example - make a copy of Links_Nodes.dbd from here: tdm23\inputs\networks

Open TransCAD 9.0



* Open Links_Nodes.dbd in TransCAD 9
1. Make Networks - 
    1. Select by Conditions
        1. Select only Links that are relevant to the mode you are trying to import from GTFS 
        2. You need a separate network for each of the transit modes.
        3. Look Up Table

<table>
  <tr>
   <td>
GTFS Mode
   </td>
   <td>Func_Class
   </td>
   <td>Mode
   </td>
  </tr>
  <tr>
   <td>0: Light Rail
   </td>
   <td>102
   </td>
   <td>4
   </td>
  </tr>
  <tr>
   <td>1: Heavy Rail
   </td>
   <td>102
   </td>
   <td>5
   </td>
  </tr>
  <tr>
   <td>2: Rail
   </td>
   <td>100
   </td>
   <td>6
   </td>
  </tr>
  <tr>
   <td>3: Bus
   </td>
   <td>&lt;> (100,101,102,90,99,190,20,21,30,40,41,42)
<p>
& FC_Summ &lt;> 9 
   </td>
   <td>1,2,3,8,9,10
   </td>
  </tr>
  <tr>
   <td>4: Ferry
   </td>
   <td>101
   </td>
   <td>7
   </td>
  </tr>
</table>




    2. Import GTFS to Link Layer
        4. Set Network for each route - file:///C:/Program%20Files/TransCAD%209.0/Help/TransCAD/Main/Using_GTFS_Data.htm 
            1. Basically just open the right network.
        5. Choose only 1 network per mode if can (I use same network for Light Rail as Subway)
        6. Select Create Schedules options and merge into one schedule.
        7. Result is one RTS file with all the GTFS routes, stops, and schedules imported.
    3. Check for accuracy - currently just a visual check of some routes. Since GTFS is in WGS-84, it should translate well onto the links. Especially given previous use of GTFS for Transit updates. We want to limit the amount of shape editing for consistency sake.


# Fixing GTFS-Network Conflation Issues


## Issues



1. GTFS shapes exist on roadways not represented by links in the model network
2. Physical Stops Layer created
3. Stops created that are not connected to links

    Potential Issues (Unconfirmed)

    * Multiple links are within conflation threshold for GTFS shapes and the wrong one is chosen 


## Tests



1. GTFS Shape Issue
    1. Select all lines in GTFS shapes not represented in model links - look at and decide whether they should be coded as links or if GTFS should be edited
        1. Compare with REMIX BNRD GTFS to determine if shapes should be coded as links 
    2. Select all lines in imported GTFS shapes (matched to links) not represented in GTFS shapes and look to see if (a) and © resolves these issues.
    3. When creating networks, remove the option to use centroid connectors for bus routes (FC_Summ &lt;> 9)
2. Physical Stops Layer
    4. Check if can not create in Import GTFS to Link Layer tool
    5. Check if can delete post Import
3. Unconnected Stops
    6. See if (1) resolves this issue


