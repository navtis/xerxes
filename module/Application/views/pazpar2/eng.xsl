<?xml version="1.0" encoding="utf-8"?>

<!--

 author: David Walker
 copyright: 2009 California State University
 version: $Id: eng.xsl 1898 2011-04-15 11:26:15Z helix84@centrum.sk $
 package: Xerxes
 link: http://xerxes.calstate.edu
 license: http://www.gnu.org/licenses/
 
 -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:php="http://php.net/xsl" exclude-result-prefixes="php">

<!-- 
	TEXT LABELS 
	These are global variables that provide the text for the system.
	
	Variable names should follow the pattern of: text_{location}_{unique-name}
	Keep them in alphabetical order!!
-->
	
	<xsl:variable name="text_libraries_search">Search by library</xsl:variable>
	<xsl:variable name="text_region_libraries_desc">Select the regions or individual libraries you wish to search</xsl:variable>
    <xsl:variable name="text_results_edition">Edition</xsl:variable>

    <!-- override treatment of language in labels/eng.xsl for results page -->
    <xsl:template name="text_results_language">
        <xsl:if test="language and language != 'English'">
            <span class="results-language"> (<xsl:value-of select="language" />)</span>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
