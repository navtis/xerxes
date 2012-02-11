<?xml version="1.0" encoding="UTF-8"?>

<!--

 author: David Walker
 copyright: 2010 California State University
 version: $Id$
 package: Pazpar2
 link: http://xerxes.calstate.edu
 license: http://www.gnu.org/licenses/
 
 -->
 
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:php="http://php.net/xsl" exclude-result-prefixes="php">

	<xsl:import href="../includes.xsl" />
	<xsl:import href="../search/results.xsl" />

    <!-- override javascript-include from ../includes.xsl GS -->
    <xsl:template name="javascript_include"> 
        <xsl:call-template name="jslabels" /> 
            <script src="javascript/jquery/jquery-1.6.2.min.js" language="javascript" type="text/javascript"></script> 
            <script src="javascript/results.js" language="javascript" type="text/javascript"></script>
            <script src="javascript/pz2_status.js" language="javascript" type="text/javascript"></script>
            <script src="javascript/pz2_ping.js" language="javascript" type="text/javascript"></script>
    </xsl:template>

    <!--  hidden field setting called from ../includes.xsl GS -->
    <xsl:template name="searchbox_hidden_fields_local">
        <!-- this is used by javascript and not a real hidden field -->
        <span id="pz2session" data-value="{//request/session/pz2session}" data-completed="{//request/session/completed}" data-querystring="{//request/session/querystring}" />
    </xsl:template>

	<xsl:output method="html" encoding="utf-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>

    <!-- make this conditional to keep refreshing status until finished.
         Then need to switch to js for pings to keep alive GS -->
<!--    <xsl:variable name="text_extra_meta_tags">
        <meta http-equiv="refresh" content="6" /> 
    </xsl:variable>
-->
	<xsl:template match="/*">
		<xsl:call-template name="surround">
			<xsl:with-param name="surround_template">none</xsl:with-param>
			<xsl:with-param name="sidebar">none</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
    
    <!-- FIXME this isn't called yet GS -->

    <xsl:variable name="progress" select="results/progress" />
    <xsl:template name="progress-bar">
        <xsl:param name="progress" />
    <div id="progress"><img src="images/progress_small{$progress}.gif" alt="" /></div>	
    </xsl:template>

	<xsl:template name="breadcrumb">
		<!-- TODO: FIX THIS ?   <xsl:call-template name="breadcrumb_worldcat" /> -->
		<xsl:call-template name="page_name" />
	</xsl:template>
	
	<xsl:template name="page_name">
		Search Results
	</xsl:template>
	
	<xsl:template name="title">
		<xsl:value-of select="//request/query" />
	</xsl:template>
	
	<xsl:template name="main">
		<xsl:call-template name="search_page" />
	</xsl:template>

    <xsl:template name="additional_brief_record_data" >
        <xsl:variable name="text_results_location">Copies at</xsl:variable>
        <strong><xsl:copy-of select="$text_results_location" />: </strong>
        <span class="results-holdings">
        <ul>
        <xsl:for-each select="holdings/*">
            <li>
                <!-- <a href="{.}"><xsl:value-of select="name(.)"/></a> -->
                <xsl:value-of select="."/>
            </li>
        </xsl:for-each>
        </ul>
        </span>
    </xsl:template>

    <!-- overriding search_page from ../search/results.xsl to add right sidebar
         for status display. FIXME this is overkill just to do that GS -->
         
	<!--
		TEMPLATE: SEARCH PAGE
	-->

	<xsl:template name="search_page">

		<!-- search box area -->
		
		<div class="yui-ge">
			<div class="yui-u first">
				<h1><xsl:value-of select="$text_search_module" /></h1>
				<xsl:call-template name="searchbox" />
			</div>
			<div class="yui-u">
				<div class="sidebar">
					<xsl:call-template name="account_sidebar" />
				</div>
			</div>
		</div>
		
		<xsl:call-template name="tabs" />
		
		<xsl:variable name="sidebar">
			<xsl:choose>
				<xsl:when test="//config/search_sidebar = 'right'">
					<xsl:text>right</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>left</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- results area -->
		
		<div class="">
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$sidebar = 'right'">
						<xsl:text>yui-ge</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>yui-gf</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<!-- results -->
	
			<div>
				<xsl:attribute name="class">
					<xsl:text>yui-u</xsl:text>
					<xsl:if test="$sidebar = 'right'">
						<xsl:text> first</xsl:text>
					</xsl:if>
				</xsl:attribute>	
			
				<xsl:call-template name="facets_applied" />
		
				<div class="tabs">
					<xsl:call-template name="sort_bar" />
				</div>

		    <!-- insert status info in right column (see local.css) GS -->    
            <div class="sidebar status">
               <div class="box">
                   <xsl:call-template name="status_sidebar" />
               </div>
            </div>

				<xsl:call-template name="brief_results" />
        <!-- move nav to bottom of page GS -->
        <div style="clear: both" />
				<xsl:call-template name="paging_navigation" />
				
				<xsl:call-template name="hidden_tag_layers" />
	
			</div>
			
			<!-- facets, etc. -->
			
			<div>
				<xsl:attribute name="class">
					<xsl:text>yui-u</xsl:text>
					<xsl:if test="$sidebar = 'left'">
						<xsl:text> first</xsl:text>
					</xsl:if>
				</xsl:attribute>		
					
				<div id="search-sidebar" class="sidebar {$sidebar}">				
					<xsl:call-template name="search_sidebar" />
				</div>
			</div>
		</div>	
		
	</xsl:template>

    <!-- and the new template GS -->
    <xsl:template name="status_sidebar">
        <h2>Libraries Searched</h2>
        <xsl:for-each select="//bytarget/target">
        <h3><xsl:value-of select="./title_short" /></h3>
        <ul id="status-{./name}">
            <li>State: <span class="status-state"><xsl:value-of select="./state" /></span></li>
            <li>Hits: <span class="status-hits"><xsl:value-of select="./hits" /></span></li>
            <li>Records: <span class="status-records"><xsl:value-of select="./records" /></span></li>
            <li>Diagnostic: <span class="status-diagnostic"><xsl:value-of select="./diagnostic" /></span></li>
        </ul>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
