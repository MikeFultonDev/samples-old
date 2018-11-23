# samples

This repository contains utilities to make it easy to work with MVS resources from the Unix System Services shell environment.

The common utilities are in the utils directory. These utilities require the MVSCommand programs, specifically:
 mvscmd, mvscmdauth, opercmd
 
Here is a short description of each utility, by category

# Dataset Utilities

**dls**: analagous to the ls command, dls lists non-VSAM datasets (e.g. partitioned datasets and sequential datasets)
**mls**: analagous to the ls command, mls lists partitioned dataset members
**vls**: analagous to the ls command, vls lists VSAM datasets

**drm**: analagous to the rm command, drm deletes one or more non-VSAM datasets
**dvi**: analagous to the vi command, dvi edits a partitioned dataset member or sequential dataset.
**dgrep**: analagous to the grep command, dgrep searches partitioned datasets and sequential datasets for a string.
**dzip**: analagous to the zip command, dzip creates a blob that can be transferred (via a binary protocol) to another z/OS system.
**dunzip**: analagous to the unzip command, dunzip unzips a blob previously created by dzip.
**dsed**: analagous to the sed command, dsed provides rudimentary support for basic search and replace of a string in a dataset.
**dtouch**: analagous to the touch command, dtouch provides a way to allocate a dataset.

**dlsraw**: provides a raw list of information about datasets. Used by higher-level utilities like dls.
**dlsall**: provides a raw list of all datasets on the system. Used by higher-level utilities like dls.
**pcatalog**: prints out the catalogs on the system, including the master catalog
**pvol**: print the volumes on the system


# Console Utilities

**pcon**: print the console log to stdout





