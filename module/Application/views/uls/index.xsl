<?xml version="1.0" encoding="UTF-8"?>

<!--

 author: David Walker
 copyright: 2010 California State University
 version: $Id$
 package: pazpar2 
 link: http://xerxes.calstate.edu
 license: http://www.gnu.org/licenses/
 
 -->
 
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:php="http://php.net/xsl" exclude-result-prefixes="php">

<xsl:import href="../includes.xsl" />
<xsl:import href="../search/results.xsl" /> 
<xsl:import href="../pazpar2/includes.xsl" />
<xsl:import href="../pazpar2/eng.xsl" />

<xsl:output method="html" encoding="utf-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>

<xsl:template match="/*">
	<xsl:call-template name="surround" />
</xsl:template>

<xsl:template name="sidebar">
	<xsl:call-template name="account_sidebar" />
</xsl:template>

<!-- override ../includes to add own js -->
<xsl:template name="javascript_include"> 
    <xsl:call-template name="jslabels" /> 
    <script src="javascript/jquery/jquery-1.6.2.min.js" language="javascript" type="text/javascript"></script> 
</xsl:template>

<xsl:template name="main">
    <xsl:variable name="regions_num_columns">2</xsl:variable>

		<h1>Search25</h1>
	
    <form name="form1" method="get" action="{//request/controller}/startsession" class="metasearchForm"> 
        <input type="hidden" name="lang" value="{//request/lang}" /> 
        <input type="hidden" name="base" value="uls" /> 
        <input type="hidden" name="action" value="search" /> 
        <xsl:call-template name="searchbox" /> 
        <h2>Search the Union List of Serials</h2>
        <p>This search will find journals held within a subset of the
        M25 libraries.</p>
        <xsl:call-template name="loop_columns"/>
    </form>

</xsl:template>

<!-- overriddes search/results/searchbox, dropping the form element
     so we can wrap the target checkboxes in the same form -->
<xsl:template name="searchbox"> 
    <xsl:call-template name="searchbox_hidden_fields_local" /> 
    <xsl:if test="request/sort"> 
        <input type="hidden" name="sort" value="{request/sort}" /> 
    </xsl:if> 
    <xsl:choose> 
        <xsl:when test="$is_mobile = '1'"> 
            <xsl:call-template name="searchbox_mobile" /> 
        </xsl:when> 
        <xsl:otherwise> 
            <xsl:call-template name="searchbox_full" /> 
        </xsl:otherwise> 
    </xsl:choose> 
</xsl:template>

<xsl:template name="searchbox_hidden_fields_local">
    <xsl:call-template name="session-data"/>
    <xsl:for-each select="//target/pz2_key">
        <input type="hidden" name="target" value="{.}" />
    </xsl:for-each>
</xsl:template>

<!-- 
	TEMPLATE: LOOP_COLUMNS
	
	A recursively called looping template for dynamically determined number of columns.
	produces the following logic 
	
	for ($i = $initial-value; $i<=$maxount; ($i = $i + 1)) {
		// print column
	}
-->
<xsl:template name="loop_columns">
	<xsl:param name="num_columns">2</xsl:param>
	<xsl:param name="iteration_value">1</xsl:param>
	
	<xsl:variable name="total" select="count(//target)" />
	<xsl:variable name="numRows" select="ceiling($total div $num_columns)"/>
	<xsl:if test="$iteration_value &lt;= $num_columns">
		<div>
		<xsl:attribute name="class">
			<xsl:text>yui-u</xsl:text><xsl:if test="$iteration_value = 1"><xsl:text> first</xsl:text></xsl:if>
		</xsl:attribute>
			<ul>
			<xsl:for-each select="//target[@position &gt; ($numRows * ($iteration_value -1)) and 
				@position &lt;= ( $numRows * $iteration_value )]">
				
				<xsl:variable name="normalized" select="normalized" />
				<li><a href="{url}"><xsl:value-of select="name" /></a></li>
			</xsl:for-each>
			</ul>
		</div>
		
		<xsl:call-template name="loop_columns">
			<xsl:with-param name="num_columns" select="$num_columns"/>
			<xsl:with-param name="iteration_value"  select="$iteration_value+1"/>
		</xsl:call-template>
	
	</xsl:if>
	
</xsl:template>


</xsl:stylesheet>
