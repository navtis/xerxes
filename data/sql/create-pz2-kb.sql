# author: David Walker
# author: Graham Seaman
# copyright: 2009 California State University
# version: $Id: create-kb.sql 1612 2011-01-11 17:22:13Z dwalker@calstate.edu $
# package: Xerxes
# link: http://xerxes.calstate.edu
# license: http://www.gnu.org/licenses/

CREATE DATABASE IF NOT EXISTS xerxes DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE xerxes;

SET storage_engine = INNODB;
set foreign_key_checks = 0 ; 
DROP TABLE IF EXISTS xerxes_pz2_targets;
DROP TABLE IF EXISTS xerxes_pz2_regions;
DROP TABLE IF EXISTS xerxes_pz2_regions_targets;


CREATE TABLE xerxes_pz2_targets(
	target_id       MEDIUMINT NOT NULL AUTO_INCREMENT,
	target_title_display	VARCHAR(100),
	target_title_short	    VARCHAR(50),
    target_pz2_key         VARCHAR(10),
    target_copac_key       VARCHAR(10),
    target_z3950_location  VARCHAR(100),
    target_catalogue_url   VARCHAR(255),
	target_description		MEDIUMTEXT,
	PRIMARY KEY (target_id)
);

INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_z3950_location) VALUES(1, 'COPAC', 'COPAC', 'COPAC', 'z3950.copac.ac.uk:210/COPAC');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(2, 'London School of Economics and Political Science', 'LSE', 'LSE', 'lse', 'voyager-live.lse.ac.uk:7090/voyager','https://catalogue.lse.ac.uk','Big library with massive atrium and funny stairs.');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(3, 'University of Kent', 'Kent', 'KENT', '', 'nemesis.ukc.ac.uk:7090/voyager','https://catalogue.kent.ac.uk/','Campus library.');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(4, 'The Open University in London', 'OU', 'OU', '', 'bulbul.open.ac.uk:7090/voyager','http://bulbul.open.ac.uk/','The London library.');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(5, 'University of the Arts, London', 'Arts', 'UOA','', 'llr-web1.arts.ac.uk:7090/voyager','http://www.arts.ac.uk/library/librarycatalogue/','Dunno where this is at all.');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(6, 'University College, London', 'UCL', 'UCL','ucl', 'wallace.lib.ucl.ac.uk:9993/UCL01','http://www.ucl.ac.uk/library/main.shtml','Big library with Egyptian museum attached');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(7, 'Royal Holloway, University of London', 'Royal Holloway', 'RHUL','', 'library.rhul.ac.uk:9991/roy01','http://www.rhul.ac.uk/library','Stunning panelled library');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(8, 'University of Westminster', 'Westminster', 'WMIN','','aleph20-live.westminster.ac.uk:9991/WST01', 'http://2009.westminster.ac.uk/study/library-it-services/your-library','Modern libraries');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(9, 'Canterbury Christ Church University', 'Canterbury', 'CCHURCH','', 'libcat-nhr-01.canterbury.ac.uk:9993/CCC01','http://www.canterbury.ac.uk/library/','In Canterbury');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(10, 'Goldsmiths, University of London', 'Goldsmiths', 'GOLD','','libra.gold.ac.uk:9991/GOL01','http://www.gold.ac.uk/library/','Goldsmiths');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(11, 'Kings College London', 'Kings', 'KCL','kcl', 'library.kcl.ac.uk:9991/KCL01','http://library.kcl.ac.uk/','Kings library...');
INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(12, 'Anglia Ruskin University', 'Anglia Ruskin', 'ANGLIA', '','oscar.lib.anglia.ac.uk:9992/APU01','http://libweb.anglia.ac.uk/','');

#INSERT INTO xerxes_pz2_targets (target_id, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_z3950_location, target_catalogue_url, target_description) VALUES(, '', '', '','', '','','');

# A region may be a subset of another region
CREATE TABLE xerxes_pz2_regions(
	region_id 	MEDIUMINT NOT NULL AUTO_INCREMENT,
	name     	VARCHAR(255),
    region_key  VARCHAR(10),
	parent_id	VARCHAR(255),
	PRIMARY KEY (region_id),
 	FOREIGN KEY (parent_id) REFERENCES xerxes_regions(region_id)
);
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (1,'All regions', 'ALL', '');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (2,'London', 'LON', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (3,'Central London', 'CLON', '2');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (4,'West London', 'wLON', '2');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (5,'North London', 'NLON', '2');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (6,'East London', 'ELON', '2');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (7,'South London', 'SLON', '2');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (8,'Surrey', 'SURR', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (9,'Kent', 'KENT', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (10,'East Anglia', 'EANGLIA', '1');  

CREATE TABLE xerxes_pz2_regions_targets(
	target_id	    MEDIUMINT,
  	region_id       MEDIUMINT,
 	FOREIGN KEY (target_id) REFERENCES xerxes_pz2_targets(target_id) ON DELETE CASCADE,
	FOREIGN KEY (region_id) REFERENCES xerxes_pz2_regions(region_id) ON DELETE CASCADE
);
# LSE in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (2, 3);  
# Kent in Kent
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (3, 9);  
# OU in Camden
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (4, 5);  
# Arts in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (5, 3); 
# UCL in Central London
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (6, 3);  
# RHUL in Surrey
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (7, 8);  
# Canterbury in Kent
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (9, 9);  
# Goldmsiths in SL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (10, 7);  
# KCL in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (11, 3);  
# Ruskin in East Anglia
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (12, 10);  
