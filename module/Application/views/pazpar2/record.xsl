<?xml version="1.0" encoding="UTF-8"?>

<!--

 author: David Walker
 copyright: 2011 California State University
 version: $Id$
 package: Xerxes
 link: http://xerxes.calstate.edu
 license: http://www.gnu.org/licenses/
 
 -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:php="http://php.net/xsl" exclude-result-prefixes="php">
	
<xsl:import href="../includes.xsl" />
<xsl:import href="../search/record.xsl" />

<xsl:output method="html" encoding="utf-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>

<xsl:template match="/*">
	<xsl:call-template name="surround" />
</xsl:template>

<xsl:template name="main">
		
	<xsl:call-template name="record" />
	
</xsl:template>

<!-- override template from search/record.xsl -->

<!-- override javascript-include from ../includes.xsl GS -->
    <xsl:template name="javascript_include">
        <xsl:call-template name="jslabels" />
        <script src="javascript/jquery/jquery-1.6.2.min.js" language="javascript" type="text/javascript"></script>
        <script src="javascript/results.js" language="javascript" type="text/javascript"></script>
        <script src="javascript/pz2_ping.js" language="javascript" type="text/javascript"></script>
    </xsl:template>

</xsl:stylesheet>
