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
    target_enabled          BOOLEAN DEFAULT 0,
	target_title_display	VARCHAR(100),
	target_title_short	    VARCHAR(50),
    target_pz2_key         VARCHAR(10),
    target_copac_key       CHAR(3),
    target_copac_prefix    CHAR(2),
    target_z3950_location  VARCHAR(100),
    target_catalogue_url   VARCHAR(255),
    target_has_opac_format BOOLEAN DEFAULT 0,
    target_record_linkback VARCHAR(255),
	target_description		MEDIUMTEXT,
	PRIMARY KEY (target_id)
);

INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_z3950_location) VALUES(1, 0, 'COPAC', 'COPAC', 'COPAC', 'z3950.copac.ac.uk:210/COPAC');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(2, 1, 'London School of Economics and Political Science', 'LSE', 'LSE', 'lse', '11', 'voyager-live.lse.ac.uk:7090/voyager','https://catalogue.lse.ac.uk', 1, '', 'Big library with massive atrium and funny stairs.');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(3, 1, 'University of Kent', 'Kent', 'KENT', '', '', 'nemesis.ukc.ac.uk:7090/voyager','https://catalogue.kent.ac.uk/', 1, '', 'Campus library.');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(4, 1, 'The Open University in London', 'OU', 'OU', '', '', 'bulbul.open.ac.uk:7090/voyager','http://bulbul.open.ac.uk/',1,'', 'The London library.');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(5, 0, 'University of the Arts, London', 'Arts', 'UOA','', '', 'llr-web1.arts.ac.uk:7090/voyager','','http://www.arts.ac.uk/library/librarycatalogue/',1,'Dunno where this is at all.');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(6, 1, 'University College, London', 'UCL', 'UCL', 'ucl', '10', 'wallace.lib.ucl.ac.uk:9993/UCL01','http://www.ucl.ac.uk/library/main.shtml',1,'','Big library with Egyptian museum attached');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(7, 1, 'Royal Holloway, University of London', 'Royal Holloway', 'RHUL','', '', 'library.rhul.ac.uk:9991/roy01','http://www.rhul.ac.uk/library',1,'','Stunning panelled library');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(8, 1, 'University of Westminster', 'Westminster', 'WMIN', '', '', 'aleph20-live.westminster.ac.uk:9991/WST01', '','http://2009.westminster.ac.uk/study/library-it-services/your-library',1,'Modern libraries');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(9, 1, 'Canterbury Christ Church University', 'Canterbury', 'CCHURCH','', '', 'libcat-nhr-01.canterbury.ac.uk:9993/CCC01','http://www.canterbury.ac.uk/library/',1,'','In Canterbury');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(10, 1, 'Goldsmiths, University of London', 'Goldsmiths', 'GOLD', '', '', 'libra.gold.ac.uk:9991/GOL01','http://www.gold.ac.uk/library/',1,'','Goldsmiths');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(11, 1, 'Kings College London', 'Kings', 'KCL','kcl', '12', 'library.kcl.ac.uk:9991/KCL01','http://library.kcl.ac.uk/',1,'','Kings library...');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(12, 1, 'Anglia Ruskin University', 'Anglia Ruskin', 'ANGLIA', '', '', 'oscar.lib.anglia.ac.uk:9992/APU01',1,'','http://libweb.anglia.ac.uk/','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(13, 1, 'Institute of Development Studies', 'IDS', 'IDS','', '', 'koha.ids.ac.uk:2100/biblios','http://www.ids.ac.uk/',0,'','Institute of Development Studies in Brighton');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(14, 1,'Birkbeck, University of London', 'Birkbeck', 'BIRKBECK','', '', 'mlib50.lib.bbk.ac.uk:210/HORIZON','http://www.bbk.ac.uk/lib/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(15, 0,'Victoria and Albert Museum (National Art Library)', 'V&amp;A', 'VANDA','vam', '75', 'has.nal.vam.ac.uk:210/HORIZON','http://www.vam.ac.uk/page/n/national-art-library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(16 , 1, 'University of Middlesex', 'Middlesex', 'MIDDX','', '', 'mdx-lib-dc1.mdx.ac.uk:210/HORIZON','http://unihub.mdx.ac.uk/study/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(17, 0, 'Royal College of Art', 'RCA', 'RCA','', '', 'dhcp-7-136.rca.ac.uk:210/xxdefault','http://www.rca.ac.uk/',0,'','');
# works but firewalled to laptop
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(18, 0, 'University of West London', 'West London', 'UWL','', '', 'tvutalis.tvu.ac.uk:2121/talislms','http://lrs.tvu.ac.uk/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(19, 0, 'University of East London', 'East London', 'UEL','', '', 'talis.uel.ac.uk:5210/ADOP','http://www.uel.ac.uk/lls/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(20, 1, 'University of Sussex', 'Sussex', 'SUSSEX','', '', 'ustie1.lib.susx.ac.uk:2121/prod_talis','http://www.sussex.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(21, 1, 'University of Brighton', 'Brighton', 'BRIGHTON','', '', 'prism.bton.ac.uk:2121/prod_talis','http://library.brighton.ac.uk/pages/index.php',0,'http://prism.talis.com/brighton-ac/items/____','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(22, 0,'Oxford Brookes University', 'Oxford Brookes', 'OXBROOKES','', '', 'wesleycat.brookes.ac.uk:2121/prod_talis','http://www.brookes.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(23, 0, 'University of Surrey', 'Surrey', 'SURREY', '', '', 'talis-prism.lib.surrey.ac.uk:2121/prod_talis','http://www.surrey.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(24, 1, 'University of Greenwich', 'Greenwich', 'GREENWICH','', '', 'reservedTalisExternal.gre.ac.uk:2121/prod_talis','http://www.gre.ac.uk/offices/ils/ls/services/lib',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(25, 1, 'Queen Mary, University of London', 'Queen Mary', 'QMUL','', '', 'flynn.library.qmul.ac.uk:2200/unicorn','http://www.library.qmul.ac.uk/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(26, 1, 'Imperial College', 'Imperial', 'IC','imp', '09', 'unicorn.lib.ic.ac.uk:2200/unicorn','http://www3.imperial.ac.uk/library',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(27, 1, 'London Business School', 'London Business School', 'LBS', '', '', 'webcat.london.edu:2200/unicorn','http://www.london.edu/theschool/ourfacilities/library.html',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(28, 1, 'London School of Hygiene and Tropical Medicine', 'LSHTM', 'LSHTM', '', '', 'unicorn.lshtm.ac.uk:2200/unicorn','http://www.lshtm.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(29, 1, 'Institute of Education', 'Institute of Education', 'IOE','ioe', '49', 'urd.sirsidynix.net.uk:7819/unicorn','http://www.ioe.ac.uk/services/4389.html',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(30, 0, 'St. George\'s, University of London', 'St. George\'s', 'SGUL','', '', 'unicorn.sghms.ac.uk:2200/unicorn','http://www.sgul.ac.uk/about-st-georges/services/library',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(31, 1, 'Buckinghamshire New University', 'Bucks New University', 'BUCKS','', '', 'unicorn2.bucks.ac.uk:2200/unicorn','https://bucks.ac.uk/en/student_experience/academic_services/library_/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(32, 1, 'Brunel University', 'Brunel', 'BRUNEL','', '', 'library.brunel.ac.uk:2200/unicorn','http://www.brunel.ac.uk/services/library',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(33, 1, 'University of Reading', 'Reading', 'READING', '', '', 'vlsirsi.rdg.ac.uk:2200/unicorn','http://www.reading.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(34, 1, 'Senate House', 'Senate House', 'SH','lon', '05', 'consull.ull.ac.uk:210/INNOPAC','http://www.ull.ac.uk/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(35, 1, 'London Metropolitan University', 'London Metropolitan', 'MET', '', '', 'emu.londonmet.ac.uk:210/INNOPAC','http://www.londonmet.ac.uk/services/sas/library-services/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(36, 1, 'School of African and Oriental Studies', 'SOAS', 'SOAS','soa', '23', 'lib2.soas.ac.uk:210/INNOPAC','http://www.soas.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(37, 1, 'The Wellcome Library', 'Wellcome Library', 'WELLCOME','wel', '22', 'libsys.wellcome.ac.uk:210/INNOPAC','http://library.wellcome.ac.uk/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(38, 1, 'South Bank University', 'South Bank', 'STHBANK', '', '', 'lispac.lsbu.ac.uk:210/INNOPAC','http://www.lsbu.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(39, 1, 'University of Bedfordshire', 'Bedfordshire', 'BEDS','', '', 'library.beds.ac.uk:210/INNOPAC','http://lrweb.beds.ac.uk/',1,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(40, 1, 'City University', 'City', 'CITY', '', '', '194.201.82.127:210/INNOPAC','http://www.city.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(41, 1, 'Royal Botanic Gardens, Kew', 'Kew Gardens', 'KEW','kew', '50', '193.128.243.23:2200/PUBNS','http://www.city.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(42, 0, 'School of Pharmacy', 'School of Pharmacy', 'PHARM','', '', '193.60.221.80:2200/unicorn','http://www.ucl.ac.uk/pharmacy',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(43, 0, 'University of Roehampton', 'Roehampton', 'ROEH','', '', '194.80.240.19:5210/ADOP','http://www.roehampton.ac.uk/library/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(44, 1, 'Kingston University', 'Kingston', 'KINGSTON','', '', '67.134.210.94:9991/PRIMO', 'http://www.kingston.ac.uk/informationservices/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(45, 0, 'St. Mary\'s University College, Twickenham', 'St Mary\'s Twickenham', 'TWICK','', '', '194.80.237.30:210/INNOPAC', 'http://www.smuc.ac.uk/student-life/is/index.htm',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(46, 0, 'Wiener Institute of Contemporary History', 'Wiener Library', 'ICH','', '', '87-224-95-244.spitfireuk.net:210', 'http://www.wienerlibrary.co.uk/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(47, 1, 'Lambeth Palace Library', 'Lambeth Palace', 'LAMBETH','lam', '', 'z3950.copac.ac.uk:210/LAM', 'http://www.lambethpalacelibrary.org/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(48, 1, 'British Museum Libraries', 'British Museum', 'BRM','brm', '', 'z3950.copac.ac.uk:210/BRM', 'http://www.britishmuseum.org/research/libraries_and_archives.aspx',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(49, 1, 'Imperial War Museum', 'Imperial War Museum', 'IWM','iwm', '', 'z3950.copac.ac.uk:210/IWM', 'http://www.iwm.org.uk/collections/search',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(50, 0, 'Aim25', 'Aim25', 'AIM25','', '', '128.86.236.71:2100/aim25', 'http://www.aim25.ac.uk',0,'','');

# ULS entries
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1000, 1, 'Birkbeck, University of London (ULS)', 'Birkbeck (ULS)', 'BIRKULS','', '', 'inform25.ac.uk:8000/BIRKBECK','http://www.bbk.ac.uk/lib/',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1001, 1, 'Goldsmith (ULS)', 'Goldsmith (ULS)', 'GOLDULS','', '', 'inform25.ac.uk:8000/GOLD','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1002, 1, 'Heythorp (ULS)', 'Heythorp (ULS)', 'HEYULS','', '', 'inform25.ac.uk:8000/HEY','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1003, 1, 'Royal Holloway (ULS)', 'Royal Holloway (ULS)', 'RHULULS','', '', 'inform25.ac.uk:8000/RHUL','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1004, 1, 'Institute of Cancer Research (ULS)', 'ICR (ULS)', 'ICRULS','', '', 'inform25.ac.uk:8000/ICR','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1005, 1, 'Imperial College (ULS)', 'Imperial (ULS)', 'ICULS','', '', 'inform25.ac.uk:8000/IC','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1006, 1, 'Institure of Education (ULS)', 'Institute of Education (ULS)', 'IOEULS','', '', 'inform25.ac.uk:8000/IOE','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1007, 1, 'Kings College (ULS)', 'KCL (ULS)', 'KCLULS','', '', 'inform25.ac.uk:8000/KCL','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1008, 1, 'London Business School (ULS)', 'LBS (ULS)', 'LBSULS','', '', 'inform25.ac.uk:8000/LBS','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1009, 1, 'London School of Economics (ULS)', 'LSE (ULS)', 'LSEULS','', '', 'inform25.ac.uk:8000/LSE','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1010, 1, 'London School of Health &amp; Tropical Medicine (ULS)', 'LSHTM (ULS)', 'LSHTMULS','', '', 'inform25.ac.uk:8000/LSHTM','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1011, 1, 'London School of Pharmacy (ULS)', 'Pharmacy (ULS)', 'PHARMULS','', '', 'inform25.ac.uk:8000/PHARM','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1012, 1, 'Queen Mary (ULS)', 'Queen Mary (ULS)', 'QMULS','', '', 'inform25.ac.uk:8000/QM','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1013, 1, 'Royal Veterinary College (ULS)', 'Royal Veterinary College (ULS)', 'VETULS','', '', 'inform25.ac.uk:8000/VET','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1014, 1, 'School of Advanced Studies (ULS)', 'SAS (ULS)', 'SASULS','', '', 'inform25.ac.uk:8000/SAS','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1015, 1, 'St George\'s Hospital (ULS)', 'St George (ULS)', 'STGULS','', '', 'inform25.ac.uk:8000/STG','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1016, 1, 'School of Oriental and African Studies (ULS)', 'SOAS (ULS)', 'SOASULS','', '', 'inform25.ac.uk:8000/SOAS','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1017, 1, 'University College London (ULS)', 'UCL (ULS)', 'UCLULS','', '', 'inform25.ac.uk:8000/UCL','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1018, 1, 'Senate House (ULS)', 'Senate House (ULS)', 'ULLULS','', '', 'inform25.ac.uk:8000/ULL','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1019, 1, 'University of Westminster (ULS)', 'Westminster (ULS)', 'WMINULS','', '', 'inform25.ac.uk:8000/WMIN','',0,'','');
INSERT INTO xerxes_pz2_targets (target_id, target_enabled, target_title_display, target_title_short, target_pz2_key, target_copac_key, target_copac_prefix, target_z3950_location, target_catalogue_url, target_has_opac_format, target_record_linkback, target_description) VALUES(1020, 1, 'Courtauld Institute (ULS)', 'Courtauld (ULS)', 'COUULS','', '', 'inform25.ac.uk:8000/COU','',0,'','');
# End of ULS entries

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
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (11,'Sussex', 'SUSSEX', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (12,'Oxfordshire', 'OXON', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (13,'Buckinghamshire', 'BUCKS', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (14,'Berkshire', 'BERKS', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (15,'Bedfordshire', 'BEDS', '1');  

INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (100,'General', 'GENERAL', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (150,'ULS_PARENT', 'ULS_PARENT', '1');  
INSERT INTO xerxes_pz2_regions (region_id, name, region_key, parent_id) VALUES (200,'ULS', 'ULS', '150');  

CREATE TABLE xerxes_pz2_regions_targets(
	target_id	    MEDIUMINT,
  	region_id       MEDIUMINT,
 	FOREIGN KEY (target_id) REFERENCES xerxes_pz2_targets(target_id) ON DELETE CASCADE,
	FOREIGN KEY (region_id) REFERENCES xerxes_pz2_regions(region_id) ON DELETE CASCADE
);
# Kent in Kent
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (3, 9);  
# Canterbury in Kent
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (9, 9);  
# OU in Camden
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (4, 5);  
# LSE in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (2, 3);  
# Arts in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (5, 3); 
# Wmin in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (8, 3); 
# Birkbeck in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (14, 3); 
# V and A in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (15, 3); 
# RCA in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (17, 3); 
# Imperial in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (26, 3); 
# LBS in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (27, 3); 
# LSHTM in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (28, 3); 
# IoE in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (29, 3); 
# Senate House in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (34, 3); 
# SOAS in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (36, 3); 
# Wellcome in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (37, 3); 
# Pharmacy in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (42, 3); 
# wiener in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (46, 3); 
# lambeth in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (47, 3); 
# Brirish Museum in CL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (48, 3); 
# UCL in Central London
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (6, 3);  
# Kings in Central London
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (11, 3);  
# Middx in WL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (16, 4); 
# TVU in WL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (18, 4); 
# Brunel in WL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (32, 4); 
# Kew in WL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (41, 4); 
# Kingston in WL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (44, 4); 
# Twickenham in WL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (45, 4); 
# East London in EL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (19, 6); 
# Greenwich in EL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (24, 6); 
# QMUL in EL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (25, 6); 
# Metropolitan in EL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (35, 6); 
# City in EL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (40, 6); 
# St Georges in SL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (30, 7);  
# Goldmsiths in SL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (10, 7);  
# South bank in SL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (38, 7);  
# Roehampton in SL
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (43, 7);  
# Imperial War Museum in SL (just)
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (49, 7);  
# RHUL in Surrey
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (7, 8);  
# Surrey in Surrey
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (23, 8);  
# Ruskin in East Anglia
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (12, 10);
# IDS in Brighton, Sussex
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (13, 11);  
# Sussex in Sussex
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (20, 11);  
# Brighton in Sussex
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (21, 11);  
# OxBrookes in Oxfordshire
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (22, 12);  
# Bucks in Bucks
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (31, 13);  
# Readng in Berks
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (33, 14);  
# Beds in Beds
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (39, 15);  

# JUST TESTING AIM25 - REMEMBER TO REMOVE
#INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (50, 100);  

# Testing ULS
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (200, 150);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1000, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1001, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1002, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1003, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1004, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1005, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1006, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1007, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1008, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1009, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1010, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1011, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1012, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1013, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1014, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1015, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1016, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1017, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1018, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1019, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1020, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1021, 200);  
INSERT INTO xerxes_pz2_regions_targets (target_id, region_id) VALUES (1022, 200);  
