# get_wpns


USE
I personally use the output of the script (a csv file) to update my own weapon spreadsheets that calculate dps and whatever else I want. I use the tab created from the csv to pull data such as rpm, mag size, etc without having to input it manually. I just run the script once or twice a season when new weapons are released and then import it, and I have all the new data in my sheets.


REQUIREMENTS

The script was run on Windows 10 using Powershell 5.1.


SETUP INSTRUCTIONS

1) get a bungie API key
2) in the start bar, type "rundll32.exe sysdm.cpl,EditEnvironmentVariables" and hit enter
3) add your API key to a new use variable BungieWpnScriptKey
4) run the script; you should now have a list of weapons that can be imported into other apps such as google sheets


RUN INSTRUCTIONS

1) Open a powershell terminal
2) navigate to the downloaded ps1 file
3) run "./get_wpns.ps1"

The script will pull the latest event and season conversion data from the DIM repo and weapon data from the Bungie API and put it into a CSV. The CSV can then be imported into a spreadsheet.

There is a adept switch for those who also want to pull adept weapons info; this may not be necessary in most cases since the stats are the same as the regular weapon. To do this run "./get_wpns.ps1 -adept"

There is a debug switch for those that want to modify the code and want to output some info to the command line. To do this run "./get_wpns.ps1 -debug". Note that this might not be too helpful unless you reduce the output to only one or a few weapons.


IMPORT INTO SPREADSHEET

The CSV can be imported into any spreadsheet. There is also a spreadsheet available that will tell you which weapons have been sunset. Run the script before following these instructions. Steps for importing the csv are below:

1) Copy the spreadsheet from https://docs.google.com/spreadsheets/d/11IfAqcUUBIPySpLDAnYRWGKEC2RTtZE7oQfGtOc39iI/edit?usp=drive_link to your own drive
2) Make sure you are on the script-import tab
3) Select File->Import on the menu
4) Select Upload, then drag or browse for 'd2wpns.csv'
5) MAKE SURE you set the Import Location to 'Replace current sheet', then import the data

NOTE: My shared google sheet currently contains info from weapons up to season 21, so to get the latest weapons you must run the script and import data for season 22 and later


SUPPORT

I do not plan to extend or support this script. Copy and use the source however you want. I only ask that you credit me for creating it. Or not, I won't check anyway.