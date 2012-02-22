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
<xsl:import href="../search/record.xsl" />
<xsl:import href="../search/books.xsl" />

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
       TEMPLATE: OVERRIDE SEARCH/RECORD/RECORD AUTHORS TO ADD TITLE-RESPONSIBILITY
    -->

    <xsl:template name="record_authors">
        <xsl:choose>
            <xsl:when test="authors/author[@type = 'personal']"> 
                <div id="record-authors"> 
                    <dt><xsl:copy-of select="$text_results_author" />:</dt> 
                    <dd> 
                    <xsl:for-each select="authors/author[@type = 'personal']"> 
                        <xsl:value-of select="aufirst" /><xsl:text> </xsl:text> 
                        <xsl:value-of select="auinit" /><xsl:text> </xsl:text> 
                        <xsl:value-of select="aulast" /><xsl:text> </xsl:text> 
                        <xsl:if test="following-sibling::author[@type = 'personal']"> 
                            <xsl:text> ; </xsl:text> 
                        </xsl:if> 
                    </xsl:for-each> 
                    </dd> 
                    <xsl:if test="responsible">
                        <dt></dt>
                        <dd><xsl:value-of select="responsible"/></dd>
                    </xsl:if>
                </div>
            </xsl:when>
            <xsl:when test="responsible">
                <div id="record-authors"> 
                    <dt><xsl:copy-of select="$text_results_author" />:</dt> 
                    <dd><xsl:value-of select="responsible"/></dd>
                </div>
             </xsl:when>
             <xsl:otherwise />
          </xsl:choose>
    </xsl:template>

    <!--
       TEMPLATE: OVERRIDE SEARCH/RECORD/RECORD SERIES
    -->

    <xsl:template name="series"> 
        <xsl:if test="series_title"> 
            <div> 
                <dt>Series:</dt> 
                <dd> 
                <xsl:value-of select="series_title" /> 
                </dd> 
            </div> 
        </xsl:if> 
    </xsl:template>

    <!--
       TEMPLATE: OVERRIDE SEARCH/RECORD/RECORD record_details TO ADD PHYSICAL INFO
    -->

    <xsl:template name="record_details"> 
        <xsl:call-template name="record_abstract" /> 
        <xsl:call-template name="record_recommendations" /> 
        <xsl:call-template name="record_toc" /> 
        <xsl:call-template name="record_subjects" /> 
        <div id="record-additional-info"> 
            <h2>Additional details</h2> 
            <dl> 
                <xsl:call-template name="record_language" /> 
                <xsl:call-template name="physical" /> 
                <xsl:call-template name="record_standard_numbers" /> 
                <xsl:call-template name="record_notes" /> 
                <xsl:call-template name="description" /> 
                <xsl:call-template name="additional-title-info" /> 
            </dl> 
        </div> 
    </xsl:template>

    <xsl:template name="physical"> 
        <xsl:if test="physical"> 
            <div> 
                <dt>Format:</dt> 
                <dd> 
                <xsl:value-of select="physical" /> 
                </dd> 
            </div> 
        </xsl:if> 
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
