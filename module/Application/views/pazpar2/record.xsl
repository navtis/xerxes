<?xml version="1.0" encoding="UTF-8"?>

<!--

 author: David Walker
 copyright: 2010 California State University
 version: $Id: worldcat_lookup.xsl 1460 2010-10-26 21:00:20Z dwalker@calstate.edu $
 package: Worldcat
 link: http://xerxes.calstate.edu
 license: http://www.gnu.org/licenses/
 
 -->
 
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:php="http://php.net/xsl" exclude-result-prefixes="php">

<xsl:import href="../includes.xsl" />
<!-- <xsl:import href="results.xsl" /> -->
<xsl:import href="../search/books.xsl" />
<xsl:import href="../search/record.xsl" />

<xsl:output method="html" />

<xsl:template match="/*">
    <xsl:call-template name="surround" />
</xsl:template>

<xsl:template name="main">
    <xsl:call-template name="record" />
</xsl:template>

<!-- override javascript-include from ../includes.xsl GS -->
<xsl:template name="javascript_include"> 
    <xsl:call-template name="jslabels" /> 
    <script src="javascript/jquery/jquery-1.6.2.min.js" language="javascript" type="text/javascript"></script> <script src="javascript/results.js" language="javascript" type="text/javascript"></script> <script src="javascript/pz2_ping.js" language="javascript" type="text/javascript"></script> 
</xsl:template> 

<!--
<xsl:template match="/*">

	<xsl:for-each select="//xerxes_record">

		<xsl:call-template name="availability">
			<xsl:with-param name="type" select="//config/lookup_display" />
		</xsl:call-template>
		
	</xsl:for-each>
</xsl:template>
-->		

</xsl:stylesheet>
